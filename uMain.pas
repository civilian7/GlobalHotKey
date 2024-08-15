unit uMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,

  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,

  FBC.HotKey;

type
  TForm5 = class(TForm)
  private
    FHotKeys: TGlobalHotkey;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

{ TForm5 }

constructor TForm5.Create(AOwner: TComponent);
begin
  inherited;

  TGlobalHotKey.Instance.Add('핫키1', MOD_NONE, VK_F2,
    procedure
    begin
      ShowMessage('F2 눌림');
    end
  );

  TGlobalHotKey.Instance.Add('핫키2', MOD_ALT, VK_F2,
    procedure
    begin
      ShowMessage('Alt+F2 눌림');
    end
  );

  TGlobalHotKey.Instance.Add('핫키3', MOD_ALT OR MOD_CTRL, VK_F2,
    procedure
    begin
      ShowMessage('Alt+Ctrl+F2 눌림');
    end
  );
end;

destructor TForm5.Destroy;
begin
  inherited;
end;

end.
