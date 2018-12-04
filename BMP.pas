unit BMP;

uses Memory;

const
  TYPE_OFFSET = 0;
  SIZE_OFFSET = 2;
  PIXELS_OFFSET = 10;
  WIDTH_OFFSET = 18;
  HEIGHT_OFFSET = 22;
  BIT_COUNT_OFFSET = 28;
  SIZEIMAGE_OFFSET = 34;
  
type
Pixel = class
  public Red : byte;
  public Green : byte;
  public Blue : byte;
  constructor (r : byte; g : byte; b : byte);
  begin
    self.Red := r;
    self.Green := g;
    self.Blue := b;
  end;
  function getBytes : array of byte;
  begin
    Result := new byte[3];
    Result[0] := Blue;
    Result[1] := Green;
    Result[2] := Red;
  end;
  procedure SetRed(Red: byte);
  begin
    self.Red := Red;
  end;
  procedure SetGreen(Green: byte);
  begin
    self.Green := Green;
  end;
 procedure SetBlue(Blue: byte);
  begin
    self.Blue := Blue;
  end;
end;

var
  offsetToPixels: cardinal;
  totalPixelsBytesCount: cardinal;
  width: cardinal;
  height: cardinal;
  sizeimage: cardinal;
  additional : integer;

{type BMPHeader = packed record
  0bfType : WORD;//2
  2bfSize : cardinal;//4
  6bfReserved1 : WORD;//2
  8bfReserved2 : WORD;//2
  10bfOffBits : cardinal;//4
  14biSize : cardinal;//4 
  18biWidth : cardinal//4 
  22biHeight :  cardinal;//4 
  26biPlanes : WORD;//2
  28biBitCount : WORD;//2
end;
}

function BuildPixels(pixelsArray : array of byte) : List<List<Pixel>>;
var
  counter : integer;
  l : List<List<Pixel>>;
  lm : List<Pixel>;
  p : Pixel;
  portion : array of byte;
begin
  lm := new List<Pixel>();
  l := new List<List<Pixel>>();
  portion := new byte[(width*3)+additional];
  for i : integer := 1 to height do
  begin
    System.Array.Copy(pixelsArray, (i-1)*portion.Length, portion, 0, portion.Length); 
    counter := 0;
    lm := new List<Pixel>();
    while(counter < width*3) do
    begin
      p := new Pixel(portion[counter+2], portion[counter+1], portion[counter]);
      lm.Add(p);
      counter += 3;
    end;
    l.Add(lm);
  end;
  Result := l;
end;

procedure SetPixelsByteArray(var RowData: array of byte; PixelsArray: array of byte);
begin 
  if((RowData.Length-offsetToPixels) < PixelsArray.Length) then
    begin
      var newRowData : array of byte;
      newRowData := new byte[PixelsArray.Length+offsetToPixels];
      System.Array.Copy(RowData, 0, newRowData, 0, RowData.Length);
      RowData := newRowData;
      Memory.SetCardinalFromPointer(@RowData[WIDTH_OFFSET], width);
      Memory.SetCardinalFromPointer(@RowData[HEIGHT_OFFSET], height);
      Memory.SetWordFromPointer(@RowData[SIZEIMAGE_OFFSET], PixelsArray.Length);
    end;
  for i : cardinal := 0 to totalPixelsBytesCount-1 do
    RowData[offsetToPixels+i] := PixelsArray[i];
end;

procedure SavePixels(var RowData : array of byte; pixels : List<List<Pixel>>);
var
  res : array of byte;
  currentPixel : array of byte;
  counter : integer;
begin
  res := new byte[((width*3)+additional)*height];
  foreach ps : List<Pixel> in pixels do
  begin
    foreach p : Pixel in ps do
      begin
        currentPixel := p.getBytes();
        res[counter] := currentPixel[0];
        res[counter+1] := currentPixel[1];
        res[counter+2] := currentPixel[2];
        counter += 3;
      end;
      counter += additional;
  end;
  SetPixelsByteArray(RowData, res);
end;

function CheckBMPType(RowData: array of byte): WORD;
begin
  Result := GetWordFromPointer(@RowData[TYPE_OFFSET]);
end;

function GetBitcount(RowData : array of byte) : WORD;
begin
  Result := GetWordFromPointer(@RowData[BIT_COUNT_OFFSET]);
end;

function GetSizeimage(RowData : array of byte) : cardinal;
begin
  Result := GetWordFromPointer(@RowData[SIZEIMAGE_OFFSET]);
  sizeimage := Result;
end;

function GetPixelsByteArray(RowData: array of byte): array of byte;
var
  ret: array of byte;
begin
  offsetToPixels := GetCardinalFromPointer(@RowData[PIXELS_OFFSET]);
  totalPixelsBytesCount := Length(RowData) - offsetToPixels;
  SetLength(ret, totalPixelsBytesCount);
  for i: cardinal := offsetToPixels to Length(RowData) - 1 do
    ret[i - offsetToPixels] := RowData[i];
  Result := ret;
end;

procedure GetPictureData(RowData : array of byte);
begin
  width := GetCardinalFromPointer(@RowData[WIDTH_OFFSET]);
  height := GetCardinalFromPointer(@RowData[HEIGHT_OFFSET]);
  additional := width mod 4;
end;

function ConcatPixels(first : List<List<Pixel>>; second : List<List<Pixel>>; third : List<List<Pixel>>; orig : List<List<Pixel>>) : List<List<Pixel>>;
var
  newPixels : List<List<Pixel>>;
  tmpList : List<Pixel>;
begin
  newPixels := new List<List<Pixel>>;
  for i : integer := 0 to (height*2)-1 do
  begin
    tmpList := new List<Pixel>();
    newPixels.Add(tmpList);
    for j : integer := 0 to (width*2)-1 do
      tmpList.Add(new Pixel(0, 0, 0));
  end;
  for i : integer := 0 to height-1 do
    for j : integer := 0 to width-1 do
      newPixels[i][j] := first[i][j];
  for i : integer := 0 to height-1 do
    for j : integer := 0 to width-1 do
      newPixels[i][j+width] := second[i][j];
  for i : integer := 0 to height-1 do
    for j : integer := 0 to width-1 do
      newPixels[i+height][j] := third[i][j];
  for i : integer := 0 to height-1 do
    for j : integer := 0 to width-1 do
      newPixels[i+height][j+width] := orig[i][j];
  Result := newPixels;
end;

begin

end. 