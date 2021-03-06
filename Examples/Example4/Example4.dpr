(************************************************************************)
(*                                                                      *)
(*                       OpenCL1.2 and Delphi                           *)
(*                                                                      *)
(*      project site    : http://code.google.com/p/delphi-opencl/       *)
(*                                                                      *)
(*      file name       : Example5.dpr                                  *)
(*      last modify     : 24.12.11                                      *)
(*      license         : BSD                                           *)
(*                                                                      *)
(*      created by      : Maksym Tymkovych (niello)                     *)
(*      Site            : www.niello.org.ua                             *)
(*      e-mail          : muxamed13@ukr.net                             *)
(*      ICQ             : 446-769-253                                   *)
(*                                                                      *)
(*      and             : Alexander Kiselev (Igroman)                   *)
(*      Site            : http://Igroman14.livejournal.com              *)
(*      e-mail          : Igroman14@yandex.ru                           *)
(*      ICQ             : 207-381-695                                   *)
(*                                                                      *)
(************************delphi-opencl2010-2011**************************)

program Example4;

{$APPTYPE CONSOLE}
{$INCLUDE ..\..\Source\OpenCL.inc}

uses
  CL_Platform in '..\..\Source\CL_Platform.pas',
  CL in '..\..\Source\CL.pas',
  CL_GL in '..\..\Source\CL_GL.pas',
  DelphiCL in '..\..\Source\DelphiCL.pas',
  SimpleImageLoader in '..\..\Source\SimpleImageLoader.pas',
  Graphics,
  SysUtils;

const
  InputFileName = 'Lena.bmp';
  OutputFileName = 'Example4.bmp';

var
  Platforms: TDCLPlatforms;
  CommandQueue: TDCLCommandQueue;
  MainProgram: TDCLProgram;
  Kernel : TDCLKernel;
  InputImage, OutputImage: TDCLImage2D;
  ImageLoader: TImageLoader;
  FileName: TFileName;
begin
  InitOpenCL;

  Platforms := TDCLPlatforms.Create;
  with Platforms.Platforms[0]^.DeviceWithMaxClockFrequency^ do
  try
    CommandQueue := CreateCommandQueue;
    try
      FileName := ExtractFilePath(ParamStr(0)) + '..\..\Resources\' + InputFileName;
      Assert(FileExists(FileName));
      ImageLoader := TImageLoader.Create(FileName);
      with ImageLoader do
        InputImage := CreateImage2D(Format, Width, Height, 0, ImageLoader.Pointer,
          [mfReadOnly, mfUseHostPtr]);
      with ImageLoader do
        OutputImage := CreateImage2D(Format, Width, Height, 0, nil,
          [mfReadWrite, mfAllocHostPtr]);

      FileName := ExtractFilePath(ParamStr(0)) + '..\..\Resources\Example4.cl';
      Assert(FileExists(FileName));
      MainProgram := CreateProgram(FileName);

      // create kernel and specify arguments
      Kernel := MainProgram.CreateKernel('main');
      Kernel.SetArg(0, InputImage);
      Kernel.SetArg(1, OutputImage);

      // execute kernel
      CommandQueue.Execute(Kernel, [OutputImage.Width, OutputImage.Height]);

      ImageLoader.Resize(OutputImage.Width, OutputImage.Height); // Dispose and Get Memory
      CommandQueue.ReadImage2D(OutputImage, ImageLoader.Pointer);
      ImageLoader.SaveToFile(ExtractFilePath(ParamStr(0)) + OutputFileName);

      FreeAndNil(ImageLoader);
      FreeAndNil(Kernel);
      FreeAndNil(MainProgram);
      FreeAndNil(InputImage);
      FreeAndNil(OutputImage);
    finally
      FreeAndNil(CommandQueue);
    end;
  finally
    FreeAndNil(Platforms);
  end;

  Writeln('press any key...');
  Readln;
end.
