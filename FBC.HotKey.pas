unit FBC.HotKey;

interface

{$REGION 'USES'}
uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Classes,
  System.Generics.Collections;
{$ENDREGION}

const
  MOD_NONE  = 0;
  MOD_ALT   = 1;
  MOD_CTRL  = 2;
  MOD_SHIFT = 4;
  MOD_WIN   = 8;

type
  TGlobalHotKey = class
  strict private
    type
      THotKeyInfo = class
      public
        Name: string;     // 핫키 이름
        ID: WORD;         // 아톰값
        Proc: TProc;      // 실행할 프로시져
      end;
    class var
      FInstance: TGlobalHotKey;

    class destructor Destroy;
  private
    FHandle: THandle;
    FHotKeys: TObjectDictionary<string, THotKeyInfo>;

    function  GetCount: Integer;
    class function GetInstance: TGlobalHotKey; static;
  protected
    procedure WndProc(var Msg: TMessage); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Add(const AName: string; const AModifier, AKey: UINT; AProc: TProc);
    procedure Clear;
    procedure Remove(const AName: string);

    property Count: Integer read GetCount;
    property Handle: THandle read FHandle;
    class property Instance: TGlobalHotKey read GetInstance;
  end;

implementation

{$REGION 'TGlobalHotKey'}

constructor TGlobalHotKey.Create;
begin
  FHandle := System.Classes.AllocateHWnd(WndProc);
  FHotKeys := TObjectDictionary<string, THotKeyInfo>.Create([doOwnsValues]);
end;

destructor TGlobalHotKey.Destroy;
begin
  Clear;

  FHotKeys.Free;
  System.Classes.DeallocateHWnd(FHandle);

  inherited;
end;

class destructor TGlobalHotKey.Destroy;
begin
  if Assigned(FInstance) then
    FInstance.Free;
end;

procedure TGlobalHotKey.Add(const AName: string; const AModifier, AKey: UINT; AProc: TProc);
begin
  var LInfo := THotkeyInfo.Create;

  LInfo.Name := LowerCase(AName);
  LInfo.ID := GlobalAddAtom(PChar(LInfo.Name));
  LInfo.Proc := AProc;

  //
  // 전역 핫키를 등록
  //
  if RegisterHotKey(Handle, LInfo.ID, AModifier, AKey) then
    FHotKeys.AddOrSetValue(LInfo.Name, LInfo)
  else
    LInfo.Free;
end;

procedure TGlobalHotKey.Clear;
begin
  //
  // 등록된 모든 핫키를 제거
  //
  for var LPair in FHotKeys.ToArray do
  begin
    UnregisterHotKey(Handle, LPair.Value.ID);
    GlobalDeleteAtom(LPair.Value.ID);
  end;
end;

function TGlobalHotKey.GetCount: Integer;
begin
  Result := FHotKeys.Count;
end;

class function TGlobalHotKey.GetInstance: TGlobalHotKey;
begin
  if not Assigned(FInstance) then
    FInstance := TGlobalHotKey.Create;

  Result := FInstance;
end;

procedure TGlobalHotKey.Remove(const AName: string);
begin
  var LInfo: THotkeyInfo;
  var LName := LowerCase(AName);

  if FHotKeys.TryGetValue(LName, LInfo) then
  begin
    UnregisterHotKey(Handle, LInfo.ID);
    GlobalDeleteAtom(LInfo.ID);

    FHotKeys.Remove(LName)
  end;
end;

procedure TGlobalHotKey.WndProc(var Msg: TMessage);
begin
  //
  // 메세지 처리
  //
  if Msg.Msg = WM_HOTKEY then
  begin
    for var LPair in FHotKeys.ToArray do
    begin
      if LPair.Value.ID = TWMHotKey(Msg).HotKey then
      begin
        LPair.Value.Proc();
        Break;
      end;
    end;
  end;

  Msg.Result := DefWindowProc(FHandle, Msg.Msg, Msg.WPARAM, Msg.LPARAM);
end;

{$ENDREGION}

end.
