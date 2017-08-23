unit UIMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Generics.Collections,
  Types,
  GdiPlus,
  ImageData,
  ShapeTemplatePatterns,
  Jpeg,
  PngImage,
  GifImg,
  Vcl.ComCtrls,
  Vcl.Samples.Spin;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    BtnLoadImg: TButton;
    LabelOut: TLabel;
    ButtonGenRoundSpiral: TButton;
    TabControl: TTabControl;
    Image: TImage;
    ScrollBox: TScrollBox;
    TrackBarStepSpacing: TTrackBar;
    TrackBarStepLine: TTrackBar;
    LabelStepSpacing: TLabel;
    LabelLineStep: TLabel;
    TrackBarDeltaSize: TTrackBar;
    LabelDeltaSize: TLabel;
    ButtonSaveImage: TButton;
    LabelSpacingStepDisplay: TLabel;
    LabelLineStepDisplay: TLabel;
    LabelDeltaSizeDisplay: TLabel;
    ComboBoxSmoothing: TComboBox;
    ButtonGenSquareSpiral: TButton;
    procedure BtnLoadImgClick(Sender: TObject);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ButtonGenRoundSpiralClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabControlMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonSaveImageClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
    procedure ButtonGenSquareSpiralClick(Sender: TObject);
  private
    { Private declarations }
    FImageData : TImageData;
    FSourceGraphic : TBitmap;
    FGraphicList : TObjectList<TGraphic>;

    FStartMovePoint : TPoint;

    procedure RefreshImage;
    procedure RefreshValuesDisplay;
    procedure PopulateComboboxSmoothing;
    function GetSpiralOptions : TSpiralOptions;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
   Math;

procedure TMainForm.BtnLoadImgClick(Sender: TObject);
var
   OpenDialog : TOpenDialog;
   Graphic : TGraphic;
   Ext : String;
begin
   OpenDialog := TOpenDialog.Create(self);
   OpenDialog.Filter := 'Image files|*.jpg;*.jpeg;*.png;*.bmp';
   try
      if OpenDialog.Execute then begin
         Ext := LowerCase(ExtractFileExt(OpenDialog.FileName));
         if SameText('.jpeg', Ext) or SameText('.jpg', Ext)  then begin
            Graphic := TJPEGImage.Create;
         end
         else if SameText('.png', Ext) then begin
            Graphic := TPngImage.Create;
         end
         else if SameText('.gif', Ext) then begin
            Graphic := TGifImage.Create;
         end
         else begin
            Graphic := TBitmap.Create;
         end;

         Graphic.LoadFromFile(OpenDialog.FileName);
         FSourceGraphic.Assign(Graphic);
         Graphic.Free;
      end;
   finally
      OpenDialog.Free;
   end;
   TabControl.TabIndex := 0;
   RefreshImage;
   FImageData.LoadFromBitmap(FSourceGraphic);
end;

procedure TMainForm.ButtonSaveImageClick(Sender: TObject);
var
   SaveDialog : TSaveDialog;
   Graphic : TGraphic;
   Ext : String;
begin
   SaveDialog := TSaveDialog.Create(self);
   SaveDialog.Filter := 'PNG|*.png|JPEG|*.jpg|GIF|*.gif|BMP|*.bmp';
   SaveDialog.FilterIndex := 0;
   SaveDialog.DefaultExt := '*.png';
   SaveDialog.FileName := TabControl.Tabs[TabControl.TabIndex] + '_' + FormatDatetime('yyyy-mm-dd_hh-nn-ss', Now);
   try
      if SaveDialog.Execute then begin
         Ext := LowerCase(ExtractFileExt(SaveDialog.FileName));
         if SameText('.jpeg', Ext) or SameText('.jpg', Ext)  then begin
            Graphic := TJPEGImage.Create;
         end
         else if SameText('.png', Ext) then begin
            Graphic := TPngImage.Create;
         end
         else if SameText('.gif', Ext) then begin
            Graphic := TGifImage.Create;
         end
         else begin
            Graphic := TBitmap.Create;
         end;
         Graphic.Assign(FGraphicList[TabControl.TabIndex]);
         Graphic.SaveToFile(SaveDialog.FileName);
         Graphic.Free;
      end;
   finally
      SaveDialog.Free;
   end;
end;

procedure TMainForm.ButtonGenRoundSpiralClick(Sender: TObject);
var
   Bitmap : TBitmap;
   Time : TDateTime;
begin
   Time := Now;

   Bitmap := TBitmap.Create;
   try
      DrawRoundSpiral(Bitmap, GetSpiralOptions, FImageData);
      FGraphicList.Add(Bitmap);
      TabControl.TabIndex := TabControl.Tabs.Add('Dest');
      RefreshImage;
   finally

   end;

   Time := Now - Time;
   LabelOut.Caption := formatdatetime('ss.zzz', Time) + ' s';
end;

procedure TMainForm.ButtonGenSquareSpiralClick(Sender: TObject);
var
   Bitmap : TBitmap;
   Time : TDateTime;
begin
   Time := Now;

   Bitmap := TBitmap.Create;
   try
      DrawSquareSpiral(Bitmap, GetSpiralOptions, FImageData);
      FGraphicList.Add(Bitmap);
      TabControl.TabIndex := TabControl.Tabs.Add('Dest');
      RefreshImage;
   finally

   end;

   Time := Now - Time;
   LabelOut.Caption := formatdatetime('ss.zzz', Time) + ' s';
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
   FImageData := TImageData.Create;
   FSourceGraphic := TBitmap.Create;
   FGraphicList := TObjectList<TGraphic>.Create;
   FGraphicList.Add(FSourceGraphic);
   PopulateComboboxSmoothing;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
   FImageData.Free;
   FGraphicList.Free;
end;

procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  I: Integer;
begin
   Handled := PtInRect(TabControl.DisplayRect, TabControl.ScreenToClient(MousePos));
   if Handled then begin
      for I := 1 to Mouse.WheelScrollLines do begin
         if WheelDelta > 0 then begin
            ScrollBox.Perform(WM_VSCROLL,0,0);
         end else begin
            ScrollBox.Perform(WM_VSCROLL,1,0);
         end;
      end;
   end;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
   Img : IGPGraphics;
begin
   Img := TGPGraphics.Create(Image.Canvas.Handle);
   Img.Clear(TGPColor.White);
   FSourceGraphic.Assign(Image.Picture.Bitmap);
   FImageData.LoadFromBitmap(FSourceGraphic);
   RefreshValuesDisplay;
end;

function TMainForm.GetSpiralOptions: TSpiralOptions;
begin
   Result.LineStep := TrackBarStepLine.Position / 10 + 0.5;
   Result.SpacingStep := TrackBarStepSpacing.Position / 1000;
   Result.DeltaSize  := TrackBarDeltaSize.Position / 10;
   Result.SmoothingMode := TGPSmoothingMode(ComboBoxSmoothing.Items.Objects[ComboBoxSmoothing.ItemIndex]);
end;

procedure TMainForm.ImageMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if ssMiddle in Shift then begin
      FStartMovePoint := Point(X, Y);
      Image.Cursor := crSizeAll;
   end;
end;

procedure TMainForm.ImageMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
   DiffX : integer;
   DiffY : integer;
begin
   try
      LabelOut.Caption := ColorToString(TImage(Sender).Canvas.Pixels[X,Y]);

      if ssMiddle in Shift then begin
         DiffX := X - FStartMovePoint.X;
         DiffY := Y - FStartMovePoint.Y;
         FStartMovePoint := Point(X, Y);
         ScrollBox.HorzScrollBar.Position := ScrollBox.HorzScrollBar.Position - DiffX;
         ScrollBox.VertScrollBar.Position := ScrollBox.VertScrollBar.Position - DiffY;
      end
   finally

   end;
end;

procedure TMainForm.ImageMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   Image.Cursor := crDefault;
end;

procedure TMainForm.PopulateComboboxSmoothing;
begin
   ComboBoxSmoothing.Clear;
   ComboBoxSmoothing.AddItem('QualityModeDefault', TObject(QualityModeDefault));
   ComboBoxSmoothing.AddItem('QualityModeLow', TObject(QualityModeLow));
   ComboBoxSmoothing.AddItem('QualityModeHigh', TObject(QualityModeHigh));
   ComboBoxSmoothing.AddItem('SmoothingModeNone', TObject(SmoothingModeNone));
   ComboBoxSmoothing.AddItem('SmoothingModeAntiAlias', TObject(SmoothingModeAntiAlias));
   {$IF (GDIPVER >= $0110)}
   ComboBoxSmoothing.AddItem('SmoothingModeAntiAlias8x4', TObject(SmoothingModeAntiAlias8x4));
   ComboBoxSmoothing.AddItem('SmoothingModeAntiAlias8x8', TObject(SmoothingModeAntiAlias8x8));
   {$IFEND}
   ComboBoxSmoothing.ItemIndex := 4;
end;

procedure TMainForm.RefreshImage;
begin
   Image.Picture.Bitmap.Assign(FGraphicList[TabControl.TabIndex]);
   ScrollBox.HorzScrollBar.Range := Image.Width;
   ScrollBox.VertScrollBar.Range := Image.Height;
end;

procedure TMainForm.RefreshValuesDisplay;
var
   SpiralOptions : TSpiralOptions;
begin
   SpiralOptions := GetSpiralOptions;
   LabelSpacingStepDisplay.Caption := Format('%.3f', [SpiralOptions.SpacingStep]);
   LabelLineStepDisplay.Caption := Format('%.2f', [SpiralOptions.LineStep]);
   LabelDeltaSizeDisplay.Caption := Format('%.2f', [SpiralOptions.DeltaSize]);
end;

procedure TMainForm.TabControlChange(Sender: TObject);
begin
   RefreshImage;
end;

procedure TMainForm.TabControlMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   i : Integer;
begin
   if Button = mbMiddle then begin
      for I := 0 to TabControl.Tabs.Count - 1 do begin
         if PtInRect(TabControl.TabRect(i), Point(X,Y)) then begin
            if I <> 0 then begin
               if TabControl.TabIndex = i then begin
                  TabControl.TabIndex := i - 1;
               end;

               TabControl.Tabs.Delete(i);
               FGraphicList.Delete(i);
               RefreshImage;
            end else begin
               Close;
            end;
            Exit;
         end;
      end;
   end;
end;

procedure TMainForm.TrackBarChange(Sender: TObject);
begin
   RefreshValuesDisplay;
end;

end.
