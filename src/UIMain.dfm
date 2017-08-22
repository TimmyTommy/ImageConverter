object MainForm: TMainForm
  Left = 411
  Top = 77
  Caption = 'Image Converter'
  ClientHeight = 810
  ClientWidth = 1313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseWheel = FormMouseWheel
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 742
    Width = 1313
    Height = 68
    Align = alBottom
    TabOrder = 0
    object LabelOut: TLabel
      Left = 90
      Top = 42
      Width = 43
      Height = 13
      Caption = 'LabelOut'
    end
    object LabelStepSpacing: TLabel
      Left = 312
      Top = 10
      Width = 59
      Height = 13
      Caption = 'Line Spacing'
    end
    object LabelLineStep: TLabel
      Left = 312
      Top = 39
      Width = 44
      Height = 13
      Caption = 'Line Step'
    end
    object LabelPointCount: TLabel
      Left = 617
      Top = 39
      Width = 52
      Height = 13
      Caption = 'Max Points'
    end
    object LabelDeltaSize: TLabel
      Left = 617
      Top = 10
      Width = 48
      Height = 13
      Caption = 'Max Delta'
    end
    object LabelSpacingStepDisplay: TLabel
      Left = 527
      Top = 10
      Width = 54
      Height = 13
      Caption = 'RadiusStep'
    end
    object LabelLineStepDisplay: TLabel
      Left = 527
      Top = 39
      Width = 41
      Height = 13
      Caption = 'LineStep'
    end
    object LabelDeltaSizeDisplay: TLabel
      Left = 840
      Top = 10
      Width = 44
      Height = 13
      Caption = 'DeltaSize'
    end
    object BtnLoadImg: TButton
      Left = 9
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Load Image'
      TabOrder = 0
      OnClick = BtnLoadImgClick
    end
    object ButtonGenerate: TButton
      Left = 90
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Generate'
      TabOrder = 1
      OnClick = ButtonGenerateClick
    end
    object TrackBarStepSpacing: TTrackBar
      Left = 375
      Top = 6
      Width = 150
      Height = 27
      Max = 20000
      Min = 1
      Position = 5000
      ShowSelRange = False
      TabOrder = 2
      TickStyle = tsNone
      OnChange = TrackBarChange
    end
    object TrackBarStepLine: TTrackBar
      Left = 375
      Top = 35
      Width = 150
      Height = 26
      Max = 500
      Position = 5
      ShowSelRange = False
      TabOrder = 3
      OnChange = TrackBarChange
    end
    object SpinEditPointCount: TSpinEdit
      Left = 688
      Top = 36
      Width = 89
      Height = 22
      Increment = 1000
      MaxValue = 5000000
      MinValue = 0
      TabOrder = 4
      Value = 300000
    end
    object TrackBarDeltaSize: TTrackBar
      Left = 688
      Top = 6
      Width = 150
      Height = 26
      Max = 200
      Position = 18
      ShowSelRange = False
      TabOrder = 5
      OnChange = TrackBarChange
    end
    object ButtonSaveImage: TButton
      Left = 9
      Top = 37
      Width = 75
      Height = 25
      Caption = 'Save Image'
      TabOrder = 6
      OnClick = ButtonSaveImageClick
    end
    object ComboBoxSmoothing: TComboBox
      Left = 783
      Top = 36
      Width = 162
      Height = 21
      Style = csDropDownList
      TabOrder = 7
      OnChange = ComboBoxSmoothingChange
    end
  end
  object TabControl: TTabControl
    Left = 0
    Top = 0
    Width = 1313
    Height = 742
    Align = alClient
    TabOrder = 1
    Tabs.Strings = (
      'Source')
    TabIndex = 0
    OnChange = TabControlChange
    OnMouseUp = TabControlMouseUp
    object ScrollBox: TScrollBox
      Left = 4
      Top = 24
      Width = 1305
      Height = 714
      Align = alClient
      BevelEdges = []
      BevelInner = bvNone
      BevelOuter = bvNone
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
      object Image: TImage
        Left = 3
        Top = 3
        Width = 414
        Height = 590
        AutoSize = True
        Center = True
        OnMouseDown = ImageMouseDown
        OnMouseMove = ImageMouseMove
        OnMouseUp = ImageMouseUp
      end
    end
  end
end
