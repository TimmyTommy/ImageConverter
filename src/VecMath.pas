unit VecMath;

interface

uses
   GdiPlus;

function RealMod(x, y : extended) : extended;
function VecLength(Vec : TGpPointF) : Double;
procedure NormalizeVec(var Vec : TGpPointF);
function VecDot(A, B : TGpPointF) :Double;
function VecCross(A, B : TGpPointF) : double;
function CalcAngleBisector(Vec1, Vec2 : TGpPointF) : TGpPointF; overload;
function CalcAngleBisector(P1, PM ,P2 : TGpPointF) : TGpPointF; overload;

implementation

uses
   Types, Math;


function RealMod(x, y : extended) : extended;
begin
   Result := x - (Trunc(x / y) * y);
end;

function VecLength(Vec : TGpPointF) : Double;
begin
   Result := Sqrt(Sqr(Vec.X) + Sqr(Vec.Y));
end;

procedure NormalizeVec(var Vec : TGpPointF);
begin
   Vec := Vec * (1/VecLength(Vec));
end;

function VecDot(A, B : TGpPointF) :Double;
begin
  Result := A.X*B.X+A.Y*B.Y;
end;

function VecCross(A, B : TGpPointF) : double;
begin
  Result := A.X*B.Y-A.Y*B.X;
end;

function CalcAngleBisector(Vec1, Vec2 : TGpPointF) : TGpPointF; overload;
var
   angle : double;
   Mat : IGPMatrix;
begin
   NormalizeVec(Vec1);
   NormalizeVec(Vec2);

   Result := Vec1 + Vec2;
   if VecLength(Result) < 1e-4 then begin
      Result := Vec1;
      Mat := TGPMatrix.Create;
      Mat.Rotate(90);
      Mat.TransformPoint(Result);
   end else begin
      NormalizeVec(Result);

      angle := ArcTan2(Vec1.Y, Vec1.X) - ArcTan2(Vec2.Y, Vec2.X);
      angle := angle * 360 / (2*pi);
      if (angle < 0) then begin
         angle := angle + 360;
      end;
      if Angle > 180 then begin
         Result := Result * -1;
      end;
   end;
end;

function CalcAngleBisector(P1, PM ,P2 : TGpPointF) : TGpPointF; overload;
begin
   Result := CalcAngleBisector(P1-PM, P2-PM);
end;

end.
