unit TMLoading;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  JvExControls, JvAnimatedImage, JvGIFCtrl, JvGIF;

type
  TLoadingForm = class(TForm)
    imgLogo: TImage;
    lblLoading: TLabel;
    aniLoading: TJvGIFAnimator;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SetFormPosition;
  public
    { Public declarations }
  end;

var
  LoadingForm: TLoadingForm;

implementation

uses Winapi.MultiMon;

{$R *.dfm}

procedure TLoadingForm.FormCreate(Sender: TObject);
begin
  SetFormPosition;
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
