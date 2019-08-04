unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, LCLType;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
var
  snakeX, snakeY: Array[1..1000] of Integer; // coodinates of each snake part
  level, points, lngth, X, Y, foodX, foodY, I: Integer;
  A: Integer=20; // size of grid / parts of snake
  P: Integer=0;
  direction: String; // direction of moving
  stdColor: TColor;  // playing area colour
  apple, bananas, cherry, grapes, orange,
  pear, pineapple, strawberry, watermelon: TBitmap; // food images
  EOG: Boolean;                                     // end of game

procedure Food; // food generator
var
  rand_fruit: Integer;

  // these two functions move randomly generated coords of the pixel to the left top corner of the square in grid
  function GenX: Integer;
  begin
    result := Random(Form1.Image2.Width);
    while result mod A <> 0 do Dec(result); // moving X coord to the left side of the square
  end;

  function GenY: Integer;
  begin
    result := Random(Form1.Image2.Height);   // moving Y coord to the right side of the square
    while result mod A <> 0 do Dec(result);
  end;

begin
  foodX := GenX;
  foodY := GenY;
  while Form1.Image2.Canvas.Pixels[foodX, foodY] <> stdColor do // in case food was generated on the snake's body
  begin
    foodX := GenX;
    foodY := GenY;
  end;
  rand_fruit := Random(9) + 1; // choose random type of food
  case rand_fruit of
  1: Form1.Image2.Canvas.Draw(foodX, foodY, apple);
  2: Form1.Image2.Canvas.Draw(foodX, foodY, bananas);
  3: Form1.Image2.Canvas.Draw(foodX, foodY, cherry);
  4: Form1.Image2.Canvas.Draw(foodX, foodY, grapes);
  5: Form1.Image2.Canvas.Draw(foodX, foodY, orange);
  6: Form1.Image2.Canvas.Draw(foodX, foodY, pear);
  7: Form1.Image2.Canvas.Draw(foodX, foodY, pineapple);
  8: Form1.Image2.Canvas.Draw(foodX, foodY, strawberry);
  9: Form1.Image2.Canvas.Draw(foodX, foodY, watermelon);
  end;
end;

procedure EatFood;
begin
  if lngth = 1 then   // add new part of snake
  case direction of
  'left': begin
            snakeX[2] := X + A;
            snakeY[2] := Y;
          end;
  'up': begin
          snakeX[2] := X;
          snakeY[2] := Y + A;
        end;
  'right': begin
             snakeX[2] := X - A;
             snakeY[2] := Y;
           end;
  'down': begin
            snakeX[2] := X;
            snakeY[2] := Y - A;
          end;
  end
  else
    begin
      if snakeX[lngth] > snakeX[lngth-1] then
      begin
        snakeX[lngth+1] := snakeX[lngth] + A;
        snakeY[lngth+1] := snakeY[lngth];
      end;
      if snakeX[lngth] < snakeX[lngth-1] then
      begin
        snakeX[lngth+1] := snakeX[lngth] - A;
        snakeY[lngth+1] := snakeY[lngth];
      end;

      if snakeY[lngth] > snakeY[lngth-1] then
      begin
        snakeY[lngth+1] := snakeY[lngth] + A;
        snakeX[lngth+1] := snakeX[lngth];
      end;
      if snakeY[lngth] < snakeY[lngth-1] then
      begin
        snakeY[lngth+1] := snakeY[lngth] - A;
        snakeX[lngth+1] := snakeX[lngth];
      end;
    end;
  Inc(P, points);
  Inc(lngth);
  Form1.Label1.Caption := 'Scores: ' + IntToStr(P);
  Form1.Label2.Caption := 'Length: ' + IntToStr(lngth);
end;

function WallImpact: Boolean;
begin
  if (snakeX[1] < 0) or (snakeX[1] + A > Form1.Image2.Width) or
     (snakeY[1] < 0) or (snakeY[1] + A > Form1.Image2.Height)
  then result := True
  else result := False;
end;

function SelfImpact: Boolean;
begin
  if lngth < 4 then result := False
  else
  case direction of
  'left': for I := 4 to lngth do
          if (snakeX[1] - A = snakeX[I]) and (snakeY[1] = snakeY[I])
          then result := True;
  'up': for I := 4 to lngth do
        if (snakeX[1] = snakeX[I]) and (snakeY[1] - A = snakeY[I])
        then result := True;
  'right': for I := 4 to lngth do
           if (snakeX[1] + A = snakeX[I]) and (snakeY[1] = snakeY[I])
           then result := True;
  'down': for I := 4 to lngth do
          if (snakeX[1] = snakeX[I]) and (snakeY[1] + A = snakeY[I])
          then result := True;
  end;
end;

procedure NewGame;
var
  D: Integer;
begin
  EOG := False;
  lngth := 1;
  P := 0;
  Form1.Image2.Canvas.Brush.Color := stdColor;
  Form1.Image2.Canvas.FillRect(Form1.Image2.ClientRect);

  // random coords of the head
  X := Random(Form1.Image2.Width);
  Y := Random(Form1.Image2.Height);
  while X mod A <> 0 do Dec(X);   // move coords to the top left corner of the square in grid
  while Y mod A <> 0 do Dec(Y);
  Form1.Image2.Canvas.Brush.Color := clBlack;
  Form1.Image2.Canvas.Rectangle(X, Y, X + A, Y + A);
  snakeX[1] := X;
  snakeY[1] := Y;

  // random direction
  D := Random(4) + 1;
  case D of
  1: direction := 'left';
  2: direction := 'up';
  3: direction := 'right';
  4: direction := 'down';
  end;

  // change direction if snake is too close to the wall so player has enough time to response
  if (direction = 'left') and (X - A * 5 < 0) then direction := 'right';
  if (direction = 'up') and (Y - A * 5 < 0) then direction := 'down';
  if (direction = 'right') and (X + A * 5 > Form1.Image2.Width)
            then direction := 'left';
  if (direction = 'down') and (Y + A * 5 > Form1.Image2.Height)
            then direction := 'up';
  Food;

  Form1.Label1.Caption := 'Scores: 0';
  Form1.Label2.Caption := 'Length: 1';
  case level of
  1: Form1.Label3.Caption := 'Level: Grass snake';
  2: Form1.Label3.Caption := 'Level: Cobra';
  3: Form1.Label3.Caption := 'Level: Python';
  end;
  Form1.Button1.Enabled := False;
  Form1.Button2.Enabled := False;
  Form1.Button3.Enabled := False;
  Form1.Button4.Enabled := True;
  Form1.KeyPreview := True;
  Form1.Timer1.Enabled := True;
end;

procedure EndGame;
begin
  Form1.Timer1.Enabled := False;
  Form1.Image2.Canvas.Brush.Color := stdColor;
  Form1.Image2.Canvas.FillRect(Form1.ClientRect);
  Form1.Image2.Canvas.Font.Size := 70;
  Form1.Image2.Canvas.Font.Name := 'algerian';
  Form1.Image2.Canvas.TextOut(100, 140, 'GAME OVER!');
  Form1.Button1.Enabled := True;
  Form1.Button2.Enabled := True;
  Form1.Button3.Enabled := True;
  Form1.Button4.Enabled := False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  stdColor := RGBToColor(206, 224, 166);
  Image2.Canvas.Brush.Color := stdColor;
  Image2.Canvas.FillRect(Image2.ClientRect);
  Image2.Canvas.Pen.Style := psClear;
  apple      := TBitmap.Create;
  bananas    := TBitmap.Create;
  cherry     := TBitmap.Create;
  grapes     := TBitmap.Create;
  orange     := TBitmap.Create;
  pear       := TBitmap.Create;
  pineapple  := TBitmap.Create;
  strawberry := TBitmap.Create;
  watermelon := TBitmap.Create;
  apple.LoadFromFile('images/apple.bmp');
  bananas.LoadFromFile('images/bananas.bmp');
  cherry.LoadFromFile('images/cherry.bmp');
  grapes.LoadFromFile('images/grapes.bmp');
  orange.LoadFromFile('images/orange.bmp');
  pear.LoadFromFile('images/pear.bmp');
  pineapple.LoadFromFile('images/pineapple.bmp');
  strawberry.LoadFromFile('images/strawberry.bmp');
  watermelon.LoadFromFile('images/watermelon.bmp');
  Button4.Enabled := False;
  Randomize;
  ShowMessage('The game is designed for single player. The aim of the game is to extend the body of the snake as much as possible by eating randomly generated food. The game ends if you crash into a wall or yourself.');
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin // LCLType
  case Key of
  VK_P:     Timer1.Enabled := not Timer1.Enabled;
  VK_LEFT:  if (direction = 'up') or (direction = 'down')
            then direction := 'left';
  VK_UP:    if (direction = 'left') or (direction = 'right')
            then direction := 'up';
  VK_RIGHT: if (direction = 'up') or (direction = 'down')
            then direction := 'right';
  VK_DOWN:  if (direction = 'left') or (direction = 'right')
            then direction := 'down';
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if not (WallImpact or SelfImpact or EOG) then
  begin
    if (snakeX[1] = foodX) and (snakeY[1] = foodY) then
    begin
      EatFood;
      Food;
    end;

    Image2.Canvas.Brush.Color := stdColor;
    Image2.Canvas.Rectangle(snakeX[lngth], snakeY[lngth],
                            snakeX[lngth] + A, snakeY[lngth] + A);

    for I := lngth downto 1 do
    if I <> 1 then
    begin
      snakeX[I] := snakeX[I-1];
      snakeY[I] := snakeY[I-1];
    end
    else
    begin
      case direction of
      'left': Dec(X, A);
      'up': Dec(Y, A);
      'right': Inc(X, A);
      'down': Inc(Y, A);
      end;
      snakeX[1] := X;
      snakeY[1] := Y;
    end;

    Image2.Canvas.Brush.Color := clBlack;
    Image2.Canvas.Rectangle(snakeX[1], snakeY[1],
                            snakeX[1] + A, snakeY[1] + A);
  end
  else EndGame;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  level := 1;
  points := 2;
  Timer1.Interval := 200;
  NewGame;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  level := 2;
  points := 5;
  Timer1.Interval := 130;
  NewGame;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  level := 3;
  points := 8;
  Timer1.Interval := 80;
  NewGame;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  EOG := True;
end;

end.

