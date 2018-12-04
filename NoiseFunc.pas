Unit NoiseFunc;

uses BMP;

function GetPixelByMask(mask : array[,] of byte; pixels : array[,] of Pixel; divisionNumber : integer) : Pixel;
var
  r, g, b : integer;
begin
  //WriteLn('SOURCE = ', pixels[1,1].Red, ' | ', pixels[1,1].Green, ' | ', pixels[1,1].Blue);
  for i : integer := 0 to 2 do
    for j : integer := 0 to 2 do
      begin
        r += mask[i,j] * Pixels[i, j].Red;
        g += mask[i,j] * Pixels[i, j].Green;
        b += mask[i,j] * Pixels[i, j].Blue;
      end;
  r := r div divisionNumber;
  g := g div divisionNumber;
  b := b div divisionNumber;
  Result := new Pixel((byte)(r),(byte)(g),(byte)(b));
  //WriteLn('DST = ', Result.Red, ' | ', Result.Green, ' | ', Result.Blue);
  //Result := new Pixel((COLOR AND $FF0000) shr 16, (COLOR AND $FF00) shr 8, (COLOR AND $FF));
end;

function GetBlur(pixels : List<List<Pixel>>; blurCoeff : integer) : List<List<Pixel>>;
var
  mask : array[,] of byte;
  currentArrangment : array[,] of Pixel;
  newPixels : List<List<Pixel>>;
  oldPixel : List<Pixel>;
begin
  mask := new byte[3, 3];
  currentArrangment := new Pixel[3, 3];
  newPixels := new List<List<Pixel>>();
  foreach ps : List<Pixel> in Pixels do
  begin
    oldPixel := new List<Pixel>();
    foreach p : Pixel in ps do
      oldPixel.Add(new Pixel(0, 0, 0));
    newPixels.Add(oldPixel);
  end;
  for i : integer := 0 to 2 do
    for j : integer := 0 to 2 do
      mask[i, j] := 1;//Identity matrix
  mask[1,1] := 4;
  mask[0,1] := 2;
  mask[1,0] := 2;
  mask[1,2] := 2;
  mask[2,1] := 2;
  for i : cardinal := 0 to BMP.height-1 do
    for j : cardinal := 0 to BMP.width-1 do
      begin
        if (i-1 >= 0) AND (j-1 >= 0) then
          currentArrangment[0, 0] := Pixels[i-1][j-1]
        else
          currentArrangment[0, 0] := Pixels[i][j];
        if i-1 >= 0 then
          currentArrangment[0, 1] := Pixels[i-1][j]
        else
          currentArrangment[0, 1] := Pixels[i][j];
        if (i-1 >= 0) AND (j+1 >= 0) AND (i-1 < BMP.height) AND (j+1 < BMP.width) then
          currentArrangment[0, 2] := Pixels[i-1][j+1]
        else
          currentArrangment[0, 2] := Pixels[i][j];
        if j-1 >= 0 then
          currentArrangment[1, 0] := Pixels[i][j-1]
        else
          currentArrangment[1, 0] := Pixels[i][j];
        currentArrangment[1, 1] := Pixels[i][j];
        if (j+1 >= 0) AND (j+1 < BMP.width) then
          currentArrangment[1, 2] := Pixels[i][j+1]
        else
          currentArrangment[1, 2] := Pixels[i][j];
        if (i+1 >= 0) AND (j-1 >= 0) AND (i+1 < BMP.height) AND (j-1 < BMP.width) then
          currentArrangment[2, 0] := Pixels[i+1][j-1]
        else
          currentArrangment[2, 0] := Pixels[i][j];
        if (i+1 >= 0) AND (i+1 < BMP.height) then
          currentArrangment[2, 1] := Pixels[i+1][j]
        else
          currentArrangment[2, 1] := Pixels[i][j];
        if (i+1 >= 0) AND (j+1 >= 0) AND (i+1 < BMP.height) AND (j+1 < BMP.width) then
          currentArrangment[2, 2] := Pixels[i+1][j+1]
        else
          currentArrangment[2, 2] := Pixels[i][j];
        newPixels[i][j] := GetPixelByMask(mask, currentArrangment, blurCoeff);
      end;
   Result := newPixels;
end;

function GetRandomWave(pixels : List<List<Pixel>>; amplitude : integer) : List<List<Pixel>>;
var
  newI, newJ : cardinal;
  newPixels : List<List<Pixel>>;
begin
  randomize;
  newPixels := new List<List<Pixel>>(Pixels);
    for i : cardinal := 0 to BMP.height-1 do
      for j : cardinal := 0 to BMP.width-1 do
      begin
        newI := i + floor(amplitude*sin(Random(512)*2*PI*j/127));
        newJ := j;
        try
          newPixels[newI][newJ].Red := Pixels[i][j].Red;
          newPixels[newI][newJ].Green := Pixels[i][j].Green;
          newPixels[newI][newJ].Blue := Pixels[i][j].Blue;
        except
          on System.Exception do ;
        end;
      end;
   Result := newPixels;
end;


{
  x(k) = k + 20sin(2pi/128);
  y(l) = l;
}
function GetWaveNoise(pixels : List<List<Pixel>>; amplitude : integer) : List<List<Pixel>>;
var
  newI, newJ : cardinal;
  newPixels : List<List<Pixel>>;
  oldPixel : List<Pixel>;
begin
  newPixels := new List<List<Pixel>>();
  foreach ps : List<Pixel> in Pixels do
  begin
    oldPixel := new List<Pixel>();
    foreach p : Pixel in ps do
      oldPixel.Add(new Pixel(0, 0, 0));
    newPixels.Add(oldPixel);
  end;
    for i : cardinal := 0 to BMP.height-1 do
      for j : cardinal := 0 to BMP.width-1 do
      begin
        newI := i + floor(amplitude*sin(2*PI*j/30));
        newJ := j;
        try
          newPixels[newI][newJ].Red := Pixels[i][j].Red;
          newPixels[newI][newJ].Green := Pixels[i][j].Green;
          newPixels[newI][newJ].Blue := Pixels[i][j].Blue;
        except
          on System.Exception do ;
        end;
      end;
   Result := newPixels;
end;

{
 x(k) = k + (rand(1,1) - 0.5)*10 
 y(l) = l + (rand(1,1) - 0.5)*10
}
function GetGlassNoise(pixels : List<List<Pixel>>; GlassMultiplex : integer) : List<List<Pixel>>;
var
  newX, newY : cardinal;
  newPixels : List<List<Pixel>>;
  oldPixel : Pixel;
begin
  randomize();
  newPixels := new List<List<Pixel>>(pixels);
  for x : cardinal := 0 to BMP.height-1 do
    for y : cardinal := 0 to BMP.width-1 do
    begin
      newX := x + Random(1, 2)*GlassMultiplex;
      newY := y + Random(1, 2)*GlassMultiplex;
      try
        begin
          oldPixel := new Pixel(newPixels[x][y].Red, 
                                newPixels[x][y].Green, 
                                newPixels[x][y].Blue);
          newPixels[x][y].SetRed(newPixels[newX][newY].Red);
          newPixels[newX][newY].SetRed(oldPixel.Red);
          newPixels[x][y].SetGreen(newPixels[newX][newY].Green);
          newPixels[newX][newY].SetGreen(oldPixel.Green);
          newPixels[x][y].SetBlue(newPixels[newX][newY].Blue);
          newPixels[newX][newY].SetBlue(oldPixel.Blue);
        end;
      except
      on System.Exception do end;
    end;
  Result := newPixels;
end;

begin
end.