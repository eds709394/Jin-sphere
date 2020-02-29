program ball;

uses
  Windows, Messages;

const
  PI = 3.1415926;
  SX = 8;
  SY = 16;
  DX = PI / SX;
  DY = PI * 2 / SY;

type
  Vec = record
    x, y: Double;
  end;

procedure Calc(i, j, rot: Double; var v: Vec);
var
  x, y, z, s, c, c1, u, u2: Double;
begin
  x := sin(i) * cos(j);
  y := sin(i) * sin(j);
  z := cos(i);
  s := sin(rot);
  c := cos(rot);
  c1 := 1 - c;
  u := 1 / sqrt(3);
  u2 := u * u;
  v.x := x * (c + u2 * c1) + y * (u2 * c1 - u * s) + z * (u2 * c1 + u * s);
  v.y := x * (u2 * c1 + u * s) + y * (c + u2 * c1) + z * (u2 * c1 - u * s);
end;

procedure DrawBall(wnd: HWND); stdcall;
var
  dc, dc2: HDC;
  bmp: HBITMAP;
  rot: double;
  rt: TRect;
  w, h, cx, cy, r: Integer;
  i, j: Integer;
  v: array[0..SX, 0..SY] of Vec;
begin
  dc := GetDC(wnd);
  rot := 0;
  while True do
  begin
    GetClientRect(wnd, rt);
    w := rt.right;
    h := rt.bottom;
    cx := w div 2;
    cy := h div 2;
    r := Trunc(h * 0.375);
    dc2 := CreateCompatibleDC(dc);
    bmp := CreateCompatibleBitmap(dc, w, h);
    SelectObject(dc2, bmp);
    SelectObject(dc2, GetStockObject(WHITE_PEN));

    for i := 0 to SX do
      for j := 0 to SY do
        Calc(i * DX, j * DY, rot, V[i][j]);

    for i := 0 to SX - 1 do
      for j := 0 to SY - 1 do
      begin
        MoveToEx(dc2, Trunc(cx + v[i][j].x * r), Trunc(cy + v[i][j].y * r), nil);
        LineTo(dc2, Trunc(cx + v[i + 1][j].x * r), Trunc(cy + v[i + 1][j].y * r));
        MoveToEx(dc2, Trunc(cx + v[i][j].x * r), Trunc(cy + v[i][j].y * r), nil);
        LineTo(dc2, Trunc(cx + v[i][j + 1].x * r), Trunc(cy + v[i][j + 1].y * r));
      end;
    BitBlt(dc, 0, 0, w, h, dc2, 0, 0, SRCCOPY);
    DeleteObject(bmp);
    DeleteDC(dc2);
    rot := rot + 0.01;
    Sleep(5);
  end;
end;

const
  ClassName = '3D Ball';
var
  wc: TWndClass;
  msg: TMsg;
  wnd: HWND;
  tid: Cardinal;
begin
  FillChar(wc, SizeOf(wc), #0);
  wc.hbrBackground := COLOR_BACKGROUND + 1;
  wc.lpfnWndProc := @DefWindowProc;
  wc.lpszClassName := ClassName;
  wc.hCursor := LoadCursor(0, IDC_ARROW);
  RegisterClass(wc);
  wnd := CreateWindowEx(0, ClassName, nil, WS_MAXIMIZE or WS_POPUP or WS_VISIBLE,
    0, 0, 0, 0, 0, 0, HInstance, nil);
  CloseHandle(CreateThread(nil, 0, @DrawBall, Pointer(wnd), 0, tid));
  while True do
  begin
    if not GetMessage(msg, 0, 0, 0) then Break;
    if msg.message = WM_KEYDOWN then Break;
    DispatchMessage(msg);
  end;
  ExitCode := msg.wParam;
end.

