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
     Amplitude  : Double;
     SmoothingMode : TGPSmoothingMode;
     LineCap : TGPLineCap;
     DashCap : TGPDashCap;
  end;

  TSpiralShapeMethod = procedure(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF);
  TDrawStyleMethod = procedure(const Img : IGPGraphics; const ImageData : TImageData; const Options : TSpiralOptions; var ShapePoints : TPointArrayF);

procedure DrawSpiral(Bitmap : TBitmap; const Options : TSpiralOptions;
   const ImageData : TImageData;
   SpiralShapeMethod : TSpiralShapeMethod;
   DrawStyleMethod : TDrawStyleMethod);
procedure DrawMonochrom(Bitmap : TBitmap; ImageData : TImageData);

procedure ShapeToZigZag(var Shape, ZigZagOut : TPointArrayF; const ImageData : TImageData; const Amplitude : Double);
procedure ShapesToZigZag(var Shapes : TPointArrayArrayF; const ImageData : TImageData; const Amplitude : Double);

procedure CalcRoundSpiralShape(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF); overload;
procedure CalcRoundSpiralShape(const Diameter : Double; const Center : TGPPointF;
   const Options : TSpiralOptions; var Spiral : TPointArrayF); overload;

procedure CalcSquareSpiralShape(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF); overload;
procedure CalcSquareSpiralShape(const Size : Double; const Center : TGPPointF;
   const Options : TSpiralOptions; var Spiral : TPointArrayF); overload;

procedure DrawWobble(const Img : IGPGraphics; const ImageData : TImageData; const Options : TSpiralOptions; var ShapePoints : TPointArrayF);
procedure DrawZigZag(const Img : IGPGraphics; const ImageData : TImageData; const Options : TSpiralOptions; var ShapePoints : TPointArrayF);

implementation

uses
   Types, Math, VecMath;

procedure InterpolateBetweenPoints(const P1, P2 : TGPPointF; const Spacing : double; var OutPoints : TPointArrayF);
var
   Distance : Double;
   Dir : TGPPointF;
   i : Integer;
   N : Integer;
begin
   Distance := VecLength(P2-P1);
   N := Trunc(Distance/Spacing);
   if (N > 0) and (Abs(RealMod(Distance, Spacing)) < 1e-6) then begin
      Dec(N);
   end;
   SetLength(OutPoints, N);
   Dir := P2-P1;
   NormalizeVec(Dir);
   if not (IsInfinite(Dir.X) or IsNan(Dir.Y)) then begin
      for i := 0 to N - 1 do begin
         OutPoints[i] := P1 + (Dir*(Spacing*i));
      end;
   end;
//   OutPoints[High(OutPoints)] := P2;
end;

procedure CalcSquareSpiralShape(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF); overload;
begin
   CalcSquareSpiralShape(
      Min(ImageData.Width, ImageData.Height),
      TGPPointF.Create(ImageData.Width/2, ImageData.Height/2),
      Options,
      Spiral
   );
end;

procedure CalcSquareSpiralShape(const Size : Double; const Center : TGPPointF;
   const Options : TSpiralOptions; var Spiral : TPointArrayF); overload;
var
   Step : Integer;
   Pnt, LastPnt : TGPPointF;
   Matrix : IGPMatrix;
   Index : Integer;
   Dir : TGPPointF;
   FlipFlop : Boolean;

   TmpPnts : TPointArrayF;
   i : Integer;
begin
   Index := 0;
   Step := 0;
   FlipFlop := True;

   Dir := TGPPointF.Create(1, 0);;
   Matrix := TGPMatrix.Create;
   Matrix.Rotate(-90);

   Pnt := TGPPointF.Create(0, 0);
   SetLength(Spiral, 5000);
   while Step*Options.SpacingStep < Size do begin

      LastPnt := Pnt;
      Pnt := LastPnt + (Dir * (Step*Options.SpacingStep));

      SetLength(TmpPnts, 500);
      InterpolateBetweenPoints(LastPnt, Pnt, Options.LineStep, TmpPnts);
      for i := Low(TmpPnts) to High(TmpPnts) do begin
         if Index >= Length(Spiral) then begin
            SetLength(Spiral, Length(Spiral)*2);
         end;
         Spiral[Index] := TmpPnts[i] + Center;
         Inc(Index);
      end;

      if FlipFlop then begin
         Inc(Step);
      end;

      Matrix.TransformPoint(Dir);
      FlipFlop := not FlipFlop;
   end;
   SetLength(Spiral, Index);
end;

procedure CalcRoundSpiralShape(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF);
begin
   CalcRoundSpiralShape(
      Min(ImageData.Width, ImageData.Height),
      TGPPointF.Create(ImageData.Width/2, ImageData.Height/2),
      Options,
      Spiral
   );
end;

procedure CalcRoundSpiralShape(const Diameter : Double; const Center : TGPPointF;
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

procedure ShapeToZigZag(var Shape, ZigZagOut : TPointArrayF; const ImageData : TImageData; const Amplitude : Double);
var
   i : Integer;
   FlipFlop : Integer;
   Normal : TGPPointF;
   R : TRect;
   Brightness : Double;
   Pnt : TPoint;
begin
   R := Rect(0, 0, ImageData.Width, ImageData.Height);
   FlipFlop := 1;

   SetLength(ZigZagOut, Length(Shape));
   ZigZagOut[0] := Shape[0];
   ZigZagOut[High(Shape)] := Shape[High(Shape)];
   for i := Low(Shape)+1 to High(Shape)-1 do begin
      Normal := CalcAngleBisector(Shape[i-1], Shape[i], Shape[i+1]);
      Pnt := Point(Round(Shape[i].X), Round(Shape[i].Y));
      if R.Contains(Pnt) then begin
         Brightness := (255 - ImageData.BrightnessGrid[Pnt.X, Pnt.Y])/255
      end else begin
         Brightness := 0;
      end;
      ZigZagOut[i] := Shape[i] + Normal * (Amplitude * Brightness * FlipFlop);
      FlipFlop := -FlipFlop;
   end;
end;

procedure ShapesToZigZag(var Shapes : TPointArrayArrayF; const ImageData : TImageData; const Amplitude : Double);
var
   i : Integer;
   ZigZagOut : TPointArrayF;
begin
   for i := Low(Shapes) to High(Shapes) do begin
      ShapeToZigZag(Shapes[i], ZigZagOut, ImageData, Amplitude);
      Shapes[i] := ZigZagOut;
   end;
end;

procedure DrawSpiral(Bitmap : TBitmap; const Options : TSpiralOptions;
   const ImageData : TImageData;
   SpiralShapeMethod : TSpiralShapeMethod;
   DrawStyleMethod : TDrawStyleMethod);
var
   Img : IGPGraphics;
   SpiralPoints : TPointArrayF;
begin
   if Assigned(Bitmap) and Assigned(ImageData) then begin
      SpiralShapeMethod(ImageData, Options, SpiralPoints);

      Bitmap.PixelFormat := pf32bit;
      Bitmap.SetSize(ImageData.Width, ImageData.Height);
      Img := TGPGraphics.Create(Bitmap.Canvas.Handle);
      Img.SmoothingMode := Options.SmoothingMode;

      DrawStyleMethod(Img, ImageData, Options, SpiralPoints);
   end;
end;

procedure DrawWobble(const Img : IGPGraphics; const ImageData : TImageData; const Options : TSpiralOptions; var ShapePoints : TPointArrayF);
var
   Pen : IGPPen;
   i : Integer;
   Brightness : Double;
   Pnt : TPoint;
   CenterPnt : TGPPointF;
   R : TRect;
begin
   Pen := TGPPen.Create(TGPColor.Create(0, 0, 0), 1);
   Pen.SetLineCap(Options.LineCap, Options.LineCap, Options.DashCap);
   R := Rect(0, 0, ImageData.Width, ImageData.Height);
   for i := Low(ShapePoints)+1 to High(ShapePoints) do begin
      CenterPnt := (ShapePoints[i] + ShapePoints[i-1]) * 0.5;
      Pnt := Point(Round(CenterPnt.X), Round(CenterPnt.Y));
      if R.Contains(Pnt) then begin
         Brightness := (255 - ImageData.BrightnessGrid[Pnt.X, Pnt.Y])/255
      end else begin
         Brightness := 0.001;
      end;
      Pen.Width := Brightness * Options.Amplitude * 2;
      Img.DrawLine(Pen, ShapePoints[i-1], ShapePoints[i]);
   end;
end;

procedure DrawZigZag(const Img : IGPGraphics; const ImageData : TImageData; const Options : TSpiralOptions; var ShapePoints : TPointArrayF);
var
   Pen : IGPPen;
   ShapeZigZag : TPointArrayF;
begin
   ShapeToZigZag(ShapePoints, ShapeZigZag, ImageData, Options.Amplitude);

   Pen := TGPPen.Create(TGPColor.Create(0, 0, 0), 1);
   Pen.SetLineCap(Options.LineCap, Options.LineCap, Options.DashCap);
   Img.DrawLines(Pen, ShapeZigZag);
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
