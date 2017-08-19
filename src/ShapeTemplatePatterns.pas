unit ShapeTemplatePatterns;

interface

uses
   Windows, Graphics, ImageData, GdiPlus;

procedure CalculateSpiral(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF);
procedure DrawSpiral(Bitmap : TBitmap; const Options : TSpiralOptions; const ImageData : TImageData);
procedure DrawMonochrom(Bitmap : TBitmap; ImageData : TImageData);

procedure CalcSpiralShape(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF); overload;
procedure CalcSpiralShape(const Width, Height : Integer; const Options : TSpiralOptions; var Spiral : TPointArrayF); overload;
function RealMod(x, y : extended) : extended;

implementation

uses
   Types, Math;


function RealMod(x, y : extended) : extended;
begin
   Result := x - (Trunc(x / y) * y);
end;

procedure CalcSpiralShape(const ImageData : TImageData; const Options : TSpiralOptions; var Spiral : TPointArrayF);
begin
   CalcSpiralShape(ImageData.Width, ImageData.Height, Options, Spiral);
end;

function CalcAngleBisector(const Vec1, Vec2 : TGpPointF) : TGpPointF;
var
   angle : double;
   a1, a2 : double;
begin
   a1 := ArcTan2(Vec1.Y, Vec1.X);
   a2 := ArcTan2(Vec2.Y, Vec2.X);
   angle := a1-a2;
   //angle := ArcTan2(Vec2.Y, Vec2.X)- ArcTan2(Vec1.Y, Vec1.X);
   SinCos(angle, Result.Y, Result.X);
end;

procedure CalcSpiralShape(const Width, Height : Integer; const Options : TSpiralOptions; var Spiral : TPointArrayF);
var
   Center : TGPPointF;
   Radius, MaxRadius : double;
   Angle : double;

   circum : double;
   stepAngle : double;
   stepRadius : double;

   Pnt : TGPPointF;
   Matrix : IGPMatrix;
   Index : Integer;
   Normal : TGPPointF;
   LastPnt : TGPPointF;
   LastLastPnt : TGPPointF;
begin
   Index := 0;
   SetLength(Spiral, Options.PointCount);

   Angle := 0;
   Radius := 1;
   MaxRadius := Min(Width, Height) / 2;
   Center := TGPPointF.Create(Width / 2, Height / 2);

   while (Radius < MaxRadius) and (Index < Options.PointCount) do begin
      LastLastPnt := LastPnt;
      LastPnt := Pnt;

      Matrix := TGPMatrix.Create;
      Matrix.Scale(Radius, Radius);
      Matrix.Rotate(Angle);
      Pnt := TGPPointF.Create(1, 0);
      Matrix.TransformPoint(Pnt);

      Pnt.X := Pnt.X + Center.X;
      Pnt.Y := Pnt.Y + Center.Y;

//      if index > 2 then begin
//
////         SinCos(Angle/180*Pi, Normal.Y, Normal.X);
////         Normal := CalcAngleBisector(Pnt-LastPnt, LastLastPnt-LastPnt);
//         Normal := CalcAngleBisector(Pnt-LastPnt, LastLastPnt-LastPnt);
//
//         Normal := Normal * Options.DeltaSize;
//
//         Spiral[Index] := LastPnt + Normal;
//         Inc(Index);
//
//         Spiral[Index] := LastPnt;
//         Inc(Index);
//      end;

      if index > 1 then begin
         Spiral[Index] := Pnt;
         Inc(Index);

         SinCos(Angle/180*Pi, Normal.Y, Normal.X);

         Normal := Normal * Options.DeltaSize;

         Spiral[Index] := Pnt + Normal;
         Inc(Index);
      end;

      Spiral[Index] := Pnt;
      Inc(Index);

      circum := 2*Pi*Radius;
      stepAngle := Realmod(360 * Options.CircleStep / circum, 360);
      stepRadius := Options.SpacingStep * stepAngle / 360;

      Angle := Angle + stepAngle;
      Radius := Radius + stepRadius;
   end;
   SetLength(Spiral, Index);
end;

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
   Radius := 1;
   MaxRadius := Min(ImageData.Width, ImageData.Height) / 2;

   Center := TGPPointF.Create(ImageData.Width / 2, ImageData.Height / 2);

   while (Radius < MaxRadius) and (Index < Options.PointCount) do begin
      MatrixTmp := TGPMatrix.Create;
      MatrixTmp.Scale(Radius, Radius);
      MatrixTmp.Rotate(Angle);
      Pnt := TGPPointF.Create(1, 0);
      MatrixTmp.TransformPoint(Pnt);
      Pnt.X := Pnt.X + Center.X;
      Pnt.Y := Pnt.Y + Center.Y;
      X := Round(Pnt.X);
      Y := Round(Pnt.Y);
      if PtInRect(Rect(0,0, Length(ImageData.BrightnessGrid[0]),Length(ImageData.BrightnessGrid)), Point(X, Y)) then begin
         Brightness := ImageData.BrightnessGrid[Y, X];
         DELTA_R := (255 - Brightness)/255 * Options.DeltaSize * Factor;
         Factor := -Factor;

         Matrix := TGPMatrix.Create;
         Matrix.Scale(Radius + DELTA_R, Radius + DELTA_R);
         Matrix.Rotate(Angle);

         Pnt := TGPPointF.Create(1, 0);
         Matrix.TransformPoint(Pnt);
         Pnt.X := Pnt.X + Center.X;
         Pnt.Y := Pnt.Y + Center.Y;
         Spiral[Index] := Pnt;
         Inc(Index);
      end;

      circum := 2*Pi*Radius;
      stepAngle := Realmod(360 * Options.CircleStep / circum, 360);
      stepRadius := Options.SpacingStep * stepAngle / 360;

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

      Img.SmoothingMode := Options.SmoothingMode;

      Pen := TGPPen.Create(TGPColor.Create(0, 0, 0), 20);
      Pen.SetLineCap(LineCapSquare, LineCapArrowAnchor, DashCapTriangle);
      Pen.LineJoin := LineJoinRound;

      CalculateSpiral(ImageData, Options, SpiralPoints);
//      CalcSpiralShape(ImageData, Options, SpiralPoints);

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
