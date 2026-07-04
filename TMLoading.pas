unit TMLoading;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  JvExControls, JvAnimatedImage, JvGIFCtrl, JvGIF, Vcl.VirtualImage,
  Vcl.BaseImageCollection, Vcl.ImageCollection;

type
  TLoadingForm = class(TForm)
    lblLoading: TLabel;
    aniLoading: TJvGIFAnimator;
    Bevel1: TBevel;
    imgLogo: TVirtualImage;
    imcImageCollection: TImageCollection;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SetFormPosition;
  public
    { Public declarations }
  end;

var
  LoadingForm: TLoadingForm;

const
  LOGO_NAME = 'bearsampp32';
  LOGO_PATH = 'core\resources\homepage\img\bearsampp.bmp';

implementation

uses Winapi.MultiMon;

{$R *.dfm}

procedure TLoadingForm.FormCreate(Sender: TObject);
var
  LImagePath: string;
begin
  SetFormPosition;

  lblLoading.Top := (ClientHeight - lblLoading.Height) div 2;

  LImagePath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + LOGO_PATH;

  if FileExists(LImagePath) then
  begin
    try
      imcImageCollection.Images.Clear;
      imcImageCollection.Add(LOGO_NAME, LImagePath);
      imgLogo.ImageName := LOGO_NAME;
    except
      // Keep the DFM image
    end;
  end;

  aniLoading.Animate := True;
end;

procedure TLoadingForm.SetFormPosition;
const MARGINBOTTOM = 6;
var
  LMonitorInfo: TMonitorInfo;
  LWorkArea: TRect;
begin
  // Initialize MonitorInfo
  LMonitorInfo.cbSize := SizeOf(TMonitorInfo);
  // Get the monitor where the application is located
  if GetMonitorInfo(MonitorFromWindow(Application.Handle, MONITOR_DEFAULTTONEAREST), @LMonitorInfo) then
  begin
    LWorkArea := LMonitorInfo.rcWork;
    // Calculate the desired position
    Left := LWorkArea.Right - Width;
    Top := LWorkArea.Bottom - Height - MARGINBOTTOM;
  end
  else
  begin
    // Fallback: Use the primary screen's work area
    Left := Screen.WorkAreaRect.Right - Width;
    Top := Screen.WorkAreaRect.Bottom - Height;
  end;
  end;

end.
