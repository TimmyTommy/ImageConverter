unit ImageData;

interface

uses
   Graphics;

type
  TRGBA = packed record
    B : Byte;
    G : Byte;
    R : Byte;
    A : Byte;
  end;

  TByteGrid = array of array of Byte;
  TColorGrid = array of array of TRGBA;
  PColorGrid = ^TColorGrid;

  TImageData = class
  private
     FHeight : Integer;
     FWidth : Integer;
     FColorGrid : TColorGrid;
     FBrightnessGrid : TByteGrid;
  private
     procedure LoadColorGrid(const Bitmap : TBitmap);
     procedure LoadBrightnessGrid;
  public
     procedure LoadFromBitmap(const Bitmap : TBitmap);
     property Height : Integer read FHeight write FHeight;
     property Width : Integer read FWidth write FWidth;
     property ColorGrid : TColorGrid read FColorGrid;
     property BrightnessGrid : TByteGrid read FBrightnessGrid;
  end;

implementation

function GetBrightness(const Color : TRGBA) : Byte;
begin
   with Color do begin
      Result := Round(0.2126*R + 0.7152*G + 0.0722*B);
   end;
end;

{ TImageData }

procedure TImageData.LoadBrightnessGrid;
var
   x, y : Integer;
begin
   SetLength(FBrightnessGrid, FHeight);
   for y := 0 to FHeight - 1 do begin
      SetLength(FBrightnessGrid[y], FWidth);
      for x := 0 to FWidth - 1 do begin
         FBrightnessGrid[y, x] := GetBrightness(FColorGrid[y, x]);
      end;
   end;
end;

procedure TImageData.LoadColorGrid(const Bitmap: TBitmap);
type
   TScanline = packed array[0..MaxInt div SizeOf(TRGBA)-1] of TRGBA;
   PScanline = ^TScanline;
var
   x, y : Integer;
   Line : PScanline;
begin
   try
      Bitmap.PixelFormat := pf32bit;

      SetLength(FColorGrid, FHeight);
      for y := 0 to FHeight - 1 do begin
         Line := Bitmap.ScanLine[y];
         SetLength(FColorGrid[y], FWidth);
         for x := 0 to FWidth - 1 do begin
            FColorGrid[y, x] := Line[x];
         end;
      end;
   finally

   end;
end;

procedure TImageData.LoadFromBitmap(const Bitmap: TBitmap);
begin
   if Assigned(Bitmap) then begin
      FHeight := Bitmap.Height;
      FWidth := Bitmap.Width;

      LoadColorGrid(Bitmap);
      LoadBrightnessGrid;
   end else begin
      FHeight := 0;
      FWidth := 0;
      SetLength(FColorGrid, FHeight);
   end;
end;

end.
