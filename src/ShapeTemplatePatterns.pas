unit ShapeTemplatePatterns;

interface

uses
   Windows, Graphics, ImageData, GdiPlus;

procedure CalculateSpiral(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF);
procedure DrawSpiral(Bitmap : TBitmap; const Options : TSpiralOptions; const ImageData : TImageData);
procedure DrawMonochrom(Bitmap : TBitmap; ImageData : TImageData);

implementation

uses
   Types, Math;

procedure CalculateSpiral(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF);
var
   DELTA_R : Double;
   Center : TGPPointF;
   Radius, MaxRadius : double;
   Angle : double;

   circum : double;

   stepAngle : double;
   stepRadius : double;

   Pnt : TGPPointF;
   X, Y : Integer;

   Matrix : IGPMatrix;
   MatrixTmp : IGPMatrix;
   Index : Integer;

   Brightness : Byte;
   Factor : Integer;

begin
   Factor := 1;
   Index := 0;
   SetLength(Spiral, Options.PointCount);

   Angle := 0;
   Radius := 2;
   MaxRadius := Min(ImageData.Width, ImageData.Height) / 2;

   Center := TGPPointF.Create(ImageData.Width / 2, ImageData.Height / 2);

   while (Radius < MaxRadius) and (Index < Options.PointCount) do begin
      circum := 2*Pi*Radius;
      stepAngle := 360 * Options.CircleStep / circum;
      stepRadius := Options.RadiusStep / radius;


      MatrixTmp := TGPMatrix.Create;
      MatrixTmp.Scale(Radius, Radius);
      MatrixTmp.Rotate(Angle);
      Pnt := TGPPointF.Create(0, 1);
      MatrixTmp.TransformPoint(Pnt);
      Pnt.X := Pnt.X + Center.X;
      Pnt.Y := Pnt.Y + Center.Y;
      X := Round(Pnt.X);
      Y := Round(Pnt.Y);
      if PtInRect(Rect(0,0, Length(ImageData.BrightnessGrid[0]),Length(ImageData.BrightnessGrid)), Point(X, Y)) then begin
         Brightness := ImageData.BrightnessGrid[Y, X];
         DELTA_R := (255 - Brightness)/255 * Options.DeltaSize * Factor;
         Factor := -Factor;

         //DELTA_R := Random(400) / 100;

         Matrix := TGPMatrix.Create;
         Matrix.Scale(Radius + DELTA_R, Radius + DELTA_R);
         Matrix.Rotate(Angle);

         Pnt := TGPPointF.Create(0, 1);
         Matrix.TransformPoint(Pnt);
         Pnt.X := Pnt.X + Center.X;
         Pnt.Y := Pnt.Y + Center.Y;
         Spiral[Index] := Pnt;
         Inc(Index);
      end;

      Angle := Angle + stepAngle;
      Radius := Radius + stepRadius;
   end;
   SetLength(Spiral, Index);
end;

procedure DrawSpiral(Bitmap : TBitmap; const Options : TSpiralOptions; const ImageData : TImageData);
var
   ColorGrid : TColorGrid;
   BrightnessGrid : TByteGrid;

   Img : IGPGraphics;
   Pen : IGPPen;
   SpiralPoints : TPointArrayF;
begin
   if Assigned(Bitmap) and Assigned(ImageData) then begin
      ColorGrid := ImageData.ColorGrid;
      BrightnessGrid := ImageData.BrightnessGrid;

      Bitmap.PixelFormat := pf32bit;
      Bitmap.SetSize(ImageData.Width, ImageData.Height);

      Img := TGPGraphics.Create(Bitmap.Canvas.Handle);
      Img.SmoothingMode := SmoothingModeAntiAlias8x8;

      Pen := TGPPen.Create(TGPColor.Create(0, 0, 0), 20);
      Pen.SetLineCap(LineCapSquare, LineCapArrowAnchor, DashCapTriangle);
      Pen.LineJoin := LineJoinRound;

      CalculateSpiral(ImageData, Options, SpiralPoints);

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
