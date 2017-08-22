unit ShapeTemplatePatterns;

interface

uses
   Windows, Graphics, ImageData, GdiPlus;

type
  TPointArrayF = array of TGPPointF;
  TPointArrayArrayF = array of TPointArrayF;

  TSpiralOptions = packed record
     LineStep : Double;
     SpacingStep : Double;
     DeltaSize  : Double;
     PointCount : Integer;
     SmoothingMode : TGPSmoothingMode;
  end;

procedure DrawSpiral(Bitmap : TBitmap; const Options : TSpiralOptions; const ImageData : TImageData);
procedure DrawMonochrom(Bitmap : TBitmap; ImageData : TImageData);


procedure ShapeToZigZag(var Shape : TPointArrayF; const ImageData : TImageData; const Delta : Double);
procedure ShapesToZigZag(var Shapes : TPointArrayArrayF; const ImageData : TImageData; const Delta : Double);
procedure CalcSpiralShape(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF); overload;
procedure CalcSpiralShape(const Diameter : Double; const Center : TGPPointF;
   const Options : TSpiralOptions; var Spiral : TPointArrayF); overload;

implementation

uses
   Types, Math, VecMath;

procedure CalcSpiralShape(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF);
begin
   CalcSpiralShape(
      Min(ImageData.Width, ImageData.Height),
      TGPPointF.Create(ImageData.Width/2, ImageData.Height/2),
      Options,
      Spiral
   );
end;

procedure CalcSpiralShape(const Diameter : Double; const Center : TGPPointF;
   const Options : TSpiralOptions; var Spiral : TPointArrayF);
var
   Radius, Angle : double;
   circum, stepAngle, stepRadius : double;

   Pnt : TGPPointF;
   Matrix : IGPMatrix;
   Index : Integer;
begin
   Index := 0;
   SetLength(Spiral, 5000);
   Angle := 0;
   Radius := 1;

   while Radius < Diameter / 2 do begin
      if Index >= Length(Spiral) then begin
         SetLength(Spiral, Length(Spiral)*2);
      end;

      Matrix := TGPMatrix.Create;
      Matrix.Scale(Radius, Radius);
      Matrix.Rotate(Angle);
      Pnt := TGPPointF.Create(1, 0);
      Matrix.TransformPoint(Pnt);

      Spiral[Index] := Pnt + Center;
      Inc(Index);

      circum := 2*Pi*Radius;
      stepAngle := Realmod(360 * Options.LineStep / circum, 360);
      stepRadius := Options.SpacingStep * stepAngle / 360;

      Angle := Angle + stepAngle;
      Radius := Radius + stepRadius;
   end;
   SetLength(Spiral, Index);
end;

procedure ShapeToZigZag(var Shape : TPointArrayF; const ImageData : TImageData; const Delta : Double);
var
   ZigZagOut : TPointArrayF;
   i : Integer;
   FlipFlop : Integer;
   Normal : TGPPointF;
   R : TRect;
   Brightness : Double;
   X, Y : Integer;
begin
   FlipFlop := 1;
   SetLength(ZigZagOut, Length(Shape));
   ZigZagOut[0] := Shape[0];
   ZigZagOut[High(Shape)] := Shape[High(Shape)];
   R := Rect(0, 0, Length(ImageData.BrightnessGrid[0]), Length(ImageData.BrightnessGrid));
   for i := Low(Shape)+1 to High(Shape)-1 do begin
      X := Round(Shape[i].X);
      Y := Round(Shape[i].Y);
      if R.Contains(Point(X, Y)) then begin
         Brightness := (255 - ImageData.BrightnessGrid[Y, X])/255;
      end else begin
         Brightness := 0;
      end;

      Normal := CalcAngleBisector(Shape[i-1], Shape[i], Shape[i+1]);
      Normal := Normal * (Delta * Brightness * FlipFlop);
      FlipFlop := -FlipFlop;
      ZigZagOut[i] := Shape[i] + Normal;
   end;
   Shape := ZigZagOut;
end;

procedure ShapesToZigZag(var Shapes : TPointArrayArrayF; const ImageData : TImageData; const Delta : Double);
var
   i : Integer;
begin
   for i := Low(Shapes) to High(Shapes) do begin
      ShapeToZigZag(Shapes[i], ImageData, Delta);
   end;
end;

procedure DrawSpiral(Bitmap : TBitmap; const Options : TSpiralOptions; const ImageData : TImageData);
var
   Img : IGPGraphics;
   Pen : IGPPen;
   SpiralPoints : TPointArrayF;
begin
   if Assigned(Bitmap) and Assigned(ImageData) then begin
      Bitmap.PixelFormat := pf32bit;
      Bitmap.SetSize(ImageData.Width, ImageData.Height);

      Img := TGPGraphics.Create(Bitmap.Canvas.Handle);
      Img.SmoothingMode := Options.SmoothingMode;

      CalcSpiralShape(ImageData, Options, SpiralPoints);
      ShapeToZigZag(SpiralPoints, ImageData, Options.DeltaSize);

      Pen := TGPPen.Create(TGPColor.Create(30, 30, 30), 1);
      Img.DrawLines(Pen, SpiralPoints);
   end;
end;

procedure DrawMonochrom(Bitmap : TBitmap; ImageData : TImageData);
var
//   ColorGrid : TColorGrid;
   BrightnessGrid : TByteGrid;
   x, y : Integer;
begin
   if Assigned(Bitmap) and Assigned(ImageData) then begin
//      ColorGrid := ImageData.ColorGrid;
      BrightnessGrid := ImageData.BrightnessGrid;

      Bitmap.PixelFormat := pf32bit;
      Bitmap.SetSize(ImageData.Width, ImageData.Height);

      for y := 0 to ImageData.Height - 1 do begin
         for x := 0 to ImageData.Width - 1 do begin
            //Bitmap.Canvas.Pixels[x, y] := RGB(ColorGrid[y, x].R, ColorGrid[y, x].G, ColorGrid[y, x].B);
            Bitmap.Canvas.Pixels[x, y] := RGB(BrightnessGrid[y, x], BrightnessGrid[y, x], BrightnessGrid[y, x]);
         end;
      end;
   end;
end;

end.
