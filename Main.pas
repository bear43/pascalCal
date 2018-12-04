program test;
uses NoiseFunc, BMP;
const
  SOURCE = 'example.bmp';
  
function LoadFile(Filename : String) : array of byte;
var
  F : File;
  Size : int64;
  Ret : array of byte;
begin
  if not FileExists(Filename) 
  then
  begin
    Result := nil;
    exit;
  end;
  WriteLn('Reading ', Filename, ' file...');
  Assign(F, Filename);
  Reset(F);
  Size := FileSize(F);
  WriteLn('Filesize: ' , Size, ' bytes');
  SetLength(Ret, Size);
  for i : integer := 0 to Size-1 do
    Read(F, Ret[i]);
  Close(F);
  WriteLn('File has been read');
  Result := Ret;
end;

procedure SaveToFile(Filename: String; bmp: array of byte);
var
  F: file;
begin
  Assign(F, Filename);
  Rewrite(F);
  for i: integer := 0 to Length(bmp) - 1 do
    Write(F, bmp[i]);
  Close(F);
  WriteLn('BMP saved to ', Filename);
end;

var
  RowData, originalRowData : array of byte; 
  pixelsRowArray : array of byte;
  pixelsArray : array[,] of byte;
  glassPixels, wavePixels, randomPixels, blurPixels : List<List<Pixel>>;
  orig, np, wave, ran, blur, all : List<List<Pixel>>;
begin
  RowData := LoadFile(SOURCE);
  SetLength(originalRowData, RowData.Length);
  System.Array.Copy(RowData, 0, originalRowData, 0, RowData.Length);
  if RowData = nil
  then begin
    WriteLn('File ' + SOURCE + ' does not exist');
    exit;
  end;
  WriteLn('Got row byte array');
  if (not BMP.CheckBMPType(RowData) = 19778) AND 
     (not BMP.CheckBMPType(RowData) = 16973) then
  begin
    WriteLn('This is not BMP file! Fail');
    exit();
  end
  else WriteLn('BMP file detected. Bits per pixel: ', BMP.GetBitcount(RowData), '. Pixel data size: ', BMP.GetSizeimage(RowData), '.');
  BMP.GetPictureData(RowData);
  WriteLn('Width = ', BMP.width, ' | Height = ', BMP.height);
  pixelsRowArray := BMP.GetPixelsByteArray(RowData);
  orig := BuildPixels(pixelsRowArray);
  glassPixels := BuildPixels(pixelsRowArray);
  wavePixels := BuildPixels(pixelsRowArray);
  randomPixels := BuildPixels(pixelsRowArray);
  blurPixels := BuildPixels(pixelsRowArray);
  var glassCoeff, waveCoeff, ranCoeff, blurCoeff : integer;
 Write('Enter glass coefficient: ');
  repeat
    try
      ReadLn(glassCoeff);
    except
      on Exception do
        WriteLn('This is an invalid value! Try again.');
    end;
  until glassCoeff <> 0;
  Write('Enter wave coefficient: ');
    repeat
    try
      ReadLn(waveCoeff);
    except
      on Exception do
        WriteLn('This is an invalid value! Try again.');
    end;
  until waveCoeff <> 0;
    Write('Enter randomWave coefficient: ');
    repeat
    try
      ReadLn(ranCoeff);
    except
      on Exception do
        WriteLn('This is an invalid value! Try again.');
    end;
  until ranCoeff <> 0;
      Write('Enter blur division: ');
    repeat
    try
      ReadLn(blurCoeff);
    except
      on Exception do
        WriteLn('This is an invalid value(default: 16)! Try again.');
    end;
  until blurCoeff <> 0;
  np := NoiseFunc.GetGlassNoise(glassPixels, glassCoeff);
  BMP.SavePixels(RowData, np);
  SaveToFile('newG.bmp', RowData);
  wave := NoiseFunc.GetWaveNoise(wavePixels, waveCoeff);
  BMP.SavePixels(RowData, wave);
  SaveToFile('newW.bmp', RowData);
  ran := NoiseFunc.GetRandomWave(randomPixels, ranCoeff);
  BMP.SavePixels(RowData, ran);
  SaveToFile('newC.bmp', RowData);
  blur := NoiseFunc.GetBlur(blurPixels, blurCoeff);
  BMP.SavePixels(RowData, blur);
  SaveToFile('newB.bmp', RowData);
  all := BMP.ConcatPixels(np, wave, blur, orig);
  BMP.width *= 2;
  BMP.height *= 2;
  BMP.additional := BMP.width mod 4;
  BMP.totalPixelsBytesCount := ((BMP.width*3)+additional)*BMP.height;
  BMP.SavePixels(RowData, all);
  SaveToFile('output.bmp', RowData);
end.