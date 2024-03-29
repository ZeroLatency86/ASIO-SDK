unit DASIOConvert;

{$I ASIOVST.INC}
{$IFDEF DELPHI6_UP}
{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$ELSE}
{$DEFINE PUREPASCAL}
{$ENDIF}

interface

uses {$IFDEF FPC}LCLIntf{$ELSE}Windows{$ENDIF}, DAVDCommon;

const
  MaxShort  : Single = $7F;
  MinShort  : Single = 1/$7F;
  MaxSmall  : Single = $7FFF;
  MinSmall  : Single = 1/$7FFF;
  Max18     : Double = $1FFFF;
  Min18     : Double = 1/$1FFFF;
  Max20     : Double = $7FFFF;
  Min20     : Double = 1/$7FFFF;
  Max24     : Double = $7FFFFF;
  Min24     : Double = 1/$7FFFFF;
  MaxLong   : Double = $7FFFFFFF;
  MinLong   : Double = 1/$7FFFFFFF;
  mmMaxLong : array[0..3] of Single = ($7FFFFFFF, $7FFFFFFF, $7FFFFFFF, $7FFFFFFF);
  mmMinLong : array[0..3] of Single = (1/$7FFFFFFF, 1/$7FFFFFFF, 1/$7FFFFFFF, 1/$7FFFFFFF);

type
  TProcessorType = (ptFPU, ptSSE, pt3DNow);
  TInConvertor = record
                  ic32 : procedure(source: pointer; target: PSingle; frames: longint);
                  ic64 : procedure(source: pointer; target: PDouble; frames: longint);
                 end;
  TOutConvertor = record
                   oc32 : procedure(source: PSingle; target: pointer; frames: longint);
                   oc64 : procedure(source: PDouble; target: pointer; frames: longint);
                  end;
  TClipBuffer = record
                 cb32 : procedure(InBuffer:PSingle; Samples:integer);
                 cb64 : procedure(InBuffer:PDouble; Samples:integer);
                end;

  TClipCheckFunction = function (source: Pointer; frames: longint):Boolean;

{$IFNDEF FPU}
type
  TBtArray   = Array[0..0] of Byte;
  PBtArray   = ^TBtArray;
  TWrdArray  = Array[0..0] of SmallInt;
  PWrdArray  = ^TWrdArray;
  TDblArray  = Array[0..0] of Double;
  PDblArray  = ^TDblArray;
  TntgrArray = Array[0..0] of Integer;
  PntgrArray = ^TntgrArray;
  TSnglArray = Array[0..0] of Single;
  PSnglArray = ^TSnglArray;
{$ENDIF}

procedure Use_FPU;
procedure Use_SSE;
procedure Use_3DNow;
procedure Use_FPU_UDF;
procedure Use_FPU_TDF;

var
  ProcessorType       : TProcessorType;
  FromInt16MSB        : TInConvertor;
  FromInt24MSB        : TInConvertor;  // used for 20 bits as well
  FromInt32MSB        : TInConvertor;
  FromSingleMSB       : TInConvertor;  // IEEE 754 32 bit float
  FromDoubleMSB       : TInConvertor;  // IEEE 754 64 bit Double float
  FromInt32MSB16      : TInConvertor;  // 32 bit data with 16 bit alignment
  FromInt32MSB18      : TInConvertor;  // 32 bit data with 18 bit alignment
  FromInt32MSB20      : TInConvertor;  // 32 bit data with 20 bit alignment
  FromInt32MSB24      : TInConvertor;  // 32 bit data with 24 bit alignment
  FromInt16LSB        : TInConvertor;
  FromInt24LSB        : TInConvertor;
  FromInt32LSB        : TInConvertor;
  FromSingleLSB       : TInConvertor;  // IEEE 754 32 bit float
  FromDoubleLSB       : TInConvertor;  // IEEE 754 64 bit Double float
  FromInt32LSB16      : TInConvertor;  // 32 bit data with 16 bit alignment
  FromInt32LSB18      : TInConvertor;  // 32 bit data with 18 bit alignment
  FromInt32LSB20      : TInConvertor;  // 32 bit data with 20 bit alignment
  FromInt32LSB24      : TInConvertor;  // 32 bit data with 24 bit alignment
  ToInt16MSB          : TOutConvertor;
  ToInt24MSB          : TOutConvertor;  // used for 20 bits as well
  ToInt32MSB          : TOutConvertor;
  ToSingleMSB         : TOutConvertor;  // IEEE 754 32 bit float
  ToDoubleMSB         : TOutConvertor;  // IEEE 754 64 bit Double float
  ToInt32MSB16        : TOutConvertor;  // 32 bit data with 16 bit alignment
  ToInt32MSB18        : TOutConvertor;  // 32 bit data with 18 bit alignment
  ToInt32MSB20        : TOutConvertor;  // 32 bit data with 20 bit alignment
  ToInt32MSB24        : TOutConvertor;  // 32 bit data with 24 bit alignment
  ToInt16LSB          : TOutConvertor;
  ToInt24LSB          : TOutConvertor;
  ToInt32LSB          : TOutConvertor;
  ToSingleLSB         : TOutConvertor;  // IEEE 754 32 bit float
  ToDoubleLSB         : TOutConvertor;  // IEEE 754 64 bit Double float
  ToInt32LSB16        : TOutConvertor;  // 32 bit data with 16 bit alignment
  ToInt32LSB18        : TOutConvertor;  // 32 bit data with 18 bit alignment
  ToInt32LSB20        : TOutConvertor;  // 32 bit data with 20 bit alignment
  ToInt32LSB24        : TOutConvertor;  // 32 bit data with 24 bit alignment

  ClipCheckInt16MSB   : TClipCheckFunction;
  ClipCheckInt24MSB   : TClipCheckFunction;  // used for 20 bits as well
  ClipCheckInt32MSB   : TClipCheckFunction;
  ClipCheckSingleMSB  : TClipCheckFunction;  // IEEE 754 32 bit float
  ClipCheckDoubleMSB  : TClipCheckFunction;  // IEEE 754 64 bit Double float
  ClipCheckInt32MSB16 : TClipCheckFunction;  // 32 bit data with 16 bit alignment
  ClipCheckInt32MSB18 : TClipCheckFunction;  // 32 bit data with 18 bit alignment
  ClipCheckInt32MSB20 : TClipCheckFunction;  // 32 bit data with 20 bit alignment
  ClipCheckInt32MSB24 : TClipCheckFunction;  // 32 bit data with 24 bit alignment
  ClipCheckInt16LSB   : TClipCheckFunction;
  ClipCheckInt24LSB   : TClipCheckFunction;
  ClipCheckInt32LSB   : TClipCheckFunction;
  ClipCheckSingleLSB  : TClipCheckFunction;  // IEEE 754 32 bit float
  ClipCheckDoubleLSB  : TClipCheckFunction;  // IEEE 754 64 bit Double float
  ClipCheckInt32LSB16 : TClipCheckFunction;  // 32 bit data with 16 bit alignment
  ClipCheckInt32LSB18 : TClipCheckFunction;  // 32 bit data with 18 bit alignment
  ClipCheckInt32LSB20 : TClipCheckFunction;  // 32 bit data with 20 bit alignment
  ClipCheckInt32LSB24 : TClipCheckFunction;  // 32 bit data with 24 bit alignment


var
  MixBuffers : record
                mb32 : procedure(InBuffer:PSingle; MixBuffer:PSingle; Samples:integer);
                mb64 : procedure(InBuffer:PDouble; MixBuffer:PDouble; Samples:integer);
               end;
  Volume     : record
                v32 : procedure(InBuffer:PSingle; Volume:Single; Samples:integer);
                v64 : procedure(InBuffer:PDouble; Volume:Double; Samples:integer);
               end;
  FadeInLinear  : record
                   v32 : procedure(InBuffer:PSingle; Samples:integer);
                   v64 : procedure(InBuffer:PDouble; Samples:integer);
                  end;
  FadeOutLinear : record
                   v32 : procedure(InBuffer:PSingle; Samples:integer);
                   v64 : procedure(InBuffer:PDouble; Samples:integer);
                  end;
  FadeLinear    : record
                   v32 : procedure(InBuffer:PSingle; Samples:Integer; CurrentFak, FacInc : Double);
                   v64 : procedure(InBuffer:PDouble; Samples:Integer; CurrentFak, FacInc : Double);
                  end;
  FadeExponential : record
                     v32 : procedure(InBuffer:PSingle; Samples:Integer; CurrentFak, FacInc : Double);
                     v64 : procedure(InBuffer:PDouble; Samples:Integer; CurrentFak, FacInc : Double);
                    end;
  ClipDigital   : TClipBuffer;
  ClipAnalog    : TClipBuffer;
  Trigger       : record
                   v32 : function(InBuffer: PSingle; Samples: Integer; TriggerFaktor : Double): Integer;
                   v64 : function(InBuffer: PDouble; Samples: Integer; TriggerFaktor : Double): Integer;
                  end;
  EnableSSE     : Boolean;

implementation

uses Math;

var RandSeed : LongInt;
{$WARNINGS OFF}



procedure ClipDigital_x86(InBuffer: PSingle; BSize: Integer); overload;
const
  c1a : Single = 1;
asm
 mov ecx,edx
@Start:
 mov edx, [eax]
 and edx, $7FFFFFFF
 cmp edx, c1a
 jle @Weiter
 mov edx, [eax]
 and edx, $80000000
 add edx, c1a
 mov [eax], edx
@Weiter:
 add eax,4
 loop @Start
end;

procedure ClipDigital_x86(InBuffer: PDouble; BSize: Integer); overload;
{$IFDEF PUREPASCAL}
var
  i: Integer;
begin
 for I := 0 to BSize - 1 do
  begin
   InBuffer^ := 0.5 * (abs(InBuffer^ + 1) - abs(InBuffer^ - 1));
   Inc(InBuffer);
  end;
end;
{$ELSE}
const
  c05 : Double = 0.5;
asm
 mov ecx,edx
 fld1
 fld c05
@Start:
 fld [eax + 8 * ecx - 8].Double
 fadd st(0), st(2)
 fabs
 fld [eax + 8 * ecx - 8].Double
 fsub st(0), st(3)
 fabs
 fsubp
 fmul st(0),st(1)
 fstp [eax + 8 * ecx - 8].Double
 loop @Start
 fstp st(0)
 fstp st(0)
end;
{$ENDIF}

procedure ClipAnalog_FPU(InBuffer: PSingle; Samples: Integer); overload;
const
  c3: Single = 3;
  c6: Single = 6;
asm
 fld c3.Single                      // 3
 fld c6.Single                      // 6, 3
 fld1                               // 1, 6, 3
 fld1                               // 1, 1, 6, 3
 faddp                              // 2, 6, 3
@Start:
 dec edx
 mov ecx,[eax + 4 * edx].Integer
 and ecx, $7FFFFFFF
 mov [esp - 4],ecx
 fld [esp - 4].Single               // abs(input), 2, 6, 3
 fld st(3)                          // 3, abs(input), 2, 6, 3
 fadd st(0), st(1)                  // 3 + abs(input), abs(input), 2, 6, 3
 fld st(0)                          // 3 + abs(input), 3 + abs(input), abs(input), 2, 6, 3
 fmul [eax + 4 * edx].Single        // input*(3 + abs(input)), 3 + abs(input), abs(input), 2, 6, 3
 fxch st(2)                         // abs(input), 3 + abs(input), input*(3 + abs(input)), 2, 6, 3
 fmulp                              // abs(input)* (3 + abs(input)), input*(3 + abs(input)), 2, 6, 3
 fadd st(0), st(3)                  // 6 + abs(input)* (3 + abs(input)), input*(3 + abs(input)), 2, 6, 3
 fdiv                               // 6 + abs(input)* (3 + abs(input)) / input*(3 + abs(input)), 2, 6, 3
 fmul st(0), st(1)                  // 2 * (6 + abs(input)* (3 + abs(input)) / input*(3 + abs(input))), 2, 6, 3
 fstp [eax + 4 * edx].Single        // 2, 6, 3
 test edx,edx
 jg @Start
 fstp st(0)
 fstp st(0)
 fstp st(0)
end;

procedure ClipAnalog_FPU(InBuffer: PDouble; Samples: Integer); overload;
const
  c3: Single = 3;
  c6: Single = 6;
asm
 fld c3.Single                      // 3
 fld c6.Single                      // 6, 3
 fld1                               // 1, 6, 3
 fld1                               // 1, 1, 6, 3
 faddp                              // 2, 6, 3
@Start:
 dec edx
 mov ecx, [eax + 8 * edx].Integer
 and ecx, $7FFFFFFF
 mov [esp - 8],ecx
 mov ecx, [eax + 4 * edx + 4].Integer
 mov [esp - 4],ecx
 fld [esp - 8].Double               // abs(input), 2, 6, 3
 fld st(3)                          // 3, abs(input), 2, 6, 3
 fadd st(0), st(1)                  // 3 + abs(input), abs(input), 2, 6, 3
 fld st(0)                          // 3 + abs(input), 3 + abs(input), abs(input), 2, 6, 3
 fmul [eax + 8 * edx].Double        // input*(3 + abs(input)), 3 + abs(input), abs(input), 2, 6, 3
 fxch st(2)                         // abs(input), 3 + abs(input), input*(3 + abs(input)), 2, 6, 3
 fmulp                              // abs(input)* (3 + abs(input)), input*(3 + abs(input)), 2, 6, 3
 fadd st(0), st(3)                  // 6 + abs(input)* (3 + abs(input)), input*(3 + abs(input)), 2, 6, 3
 fdiv                               // 6 + abs(input)* (3 + abs(input)) / input*(3 + abs(input)), 2, 6, 3
 fmul st(0), st(1)                  // 2 * (6 + abs(input)* (3 + abs(input)) / input*(3 + abs(input))), 2, 6, 3
 fstp [eax + 8 * edx].Double        // 2, 6, 3
 test edx, edx
 jg @Start
 fstp st(0)
 fstp st(0)
 fstp st(0)
end;

procedure FadeInLinear_FPU(InBuffer: PSingle; Samples: Integer); overload;
{$IFDEF PUREPASCAL}
var
  i : Integer;
  d : Double;
begin
 d := 1 / (Samples - 1);
 for i := 0 to Samples - 1 do
  begin
   InBuffer^ := InBuffer^ * i * d;
   inc(InBuffer);
  end;
end;
{$ELSE}
asm
 mov [esp - 4], edx
 fild [esp - 4].Single           // Samples
 fld1                            // 1, Samples
 fdivrp                          // 1 / Samples

 @FadeLoop:
   mov [esp - 4], edx
   fild [esp - 4].Single         // i, 1 / Samples
   dec edx
   fmul st(0), st(1)             // i / Samples, 1 / Samples
   fmul [eax + 4 * edx].Single   // i * Value / Samples, 1 / Samples
   fstp [eax + 4 * edx].Single   // write back
 jnz @FadeLoop
 fstp st(0)                      // clear stack
end;
{$ENDIF}

procedure FadeInLinear_FPU(InBuffer: PDouble; Samples: Integer); overload;
{$IFDEF PUREPASCAL}
var
  i : Integer;
  d : Double;
begin
 d := 1 / (Samples - 1);
 for i := 0 to Samples - 1 do
  begin
   InBuffer^ := InBuffer^ * i * d;
   inc(InBuffer);
  end;
end;
{$ELSE}
asm
 mov [esp - 4],edx
 fild [esp - 4].Single             // Samples
 fld1                              // 1, Samples
 fdivrp                            // 1 / Samples

 @FadeLoop:
   mov [esp - 4],edx
   fild [esp - 4].Single           // i, 1 / Samples
   fmul st(0), st(1)               // i / Samples, 1 / Samples
   dec edx
   fmul [eax + 8 * edx].Double     // i * Value / Samples, 1 / Samples
   fstp [eax + 8 * edx].Double     // write back
 jnz @FadeLoop
 fstp st(0)                        // clear stack
end;
{$ENDIF}

procedure FadeOutLinear_FPU(InBuffer: PSingle; Samples: Integer); overload;
{$IFDEF PUREPASCAL}
var
  i : Integer;
  d : Double;
begin
 d := 1 / (Samples - 1);
 for i := Samples - 1 downto 0 do
  begin
   InBuffer^ := InBuffer^ * i * d;
   inc(InBuffer);
  end;
end;
{$ELSE}
asm
 mov [esp - 4],edx
 fild [esp - 4].Single               // Samples
 fld1                                // 1, Samples
 fdivrp                              // 1 / Samples

 @FadeLoop:
   mov [esp - 4],edx
   fild [esp - 4].Single             // i, 1 / Samples
   fmul st(0), st(1)                 // i / Samples, 1 / Samples
   fld1                              // 1, i / Samples, 1 / Samples
   fsubp                             // 1 - i / Samples, 1 / Samples
   dec edx
   fmul [eax + 4 * edx - 4].Single   // Value * (1 - i / Samples), 1 / Samples
   fstp [eax + 4 * edx - 4].Single   // write back
 jnz @FadeLoop
 fstp st(0)                          // clear stack
end;
{$ENDIF}

procedure FadeOutLinear_FPU(InBuffer: PDouble; Samples: Integer); overload;
{$IFDEF PUREPASCAL}
var
  i : Integer;
  d : Double;
begin
 d := 1 / (Samples - 1);
 for i := Samples - 1 downto 0 do
  begin
   InBuffer^ := InBuffer^ * i * d;
   inc(InBuffer);
  end;
end;
{$ELSE}
asm
 mov [esp - 4],edx
 fild [esp - 4].Single              // Samples
 fld1                               // 1, Samples
 fdivrp                             // 1 / Samples

 @FadeLoop:
   mov [esp - 4],edx
   fild [esp - 4].Single            // i, 1 / Samples
   fmul st(0), st(1)                // i / Samples, 1 / Samples
   fld1                             // 1, i / Samples, 1 / Samples
   fsubp                            // 1 - i / Samples, 1 / Samples
   dec edx
   fmul [eax + 8 * edx - 8].Double  // Value * (1 - i / Samples), 1 / Samples
   fstp [eax + 8 * edx - 8].Double  // write back
 jnz @FadeLoop
 fstp st(0)                         // clear stack
end;
{$ENDIF}

procedure FadeExponential_FPU(InBuffer: PSingle; Samples: Integer; CurrentFadeFak, FadeMul : Double); overload;
{$IFDEF PUREPASCAL}
var
  i : Integer;
begin
 for i := 0 to Samples - 1 do
  begin
   InBuffer^ := InBuffer^ * CurrentFadeFak;
   CurrentFadeFak := CurrentFadeFak * FadeMul;
   if CurrentFadeFak > 1 then exit;
   inc(InBuffer);
  end;
{$ELSE}
asm
 fld1
 fld FadeMul.Double
 fld CurrentFadeFak.Double
 mov ecx,eax

 @FadeLoop:
   fld  [ecx + 4 * edx - 4].Single  // Value, CurrentFadeFak, FadeMul, 1
   fmul st(0), st(1)                // Value * CurrentFadeFak, CurrentFadeFak, FadeMul, 1
   fstp [ecx + 4 * edx - 4].Single  // CurrentFadeFak, FadeMul, 1
   fmul st(0), st(1)                // CurrentFadeFak * FadeMul = CurrentFadeFak, FadeMul, 1

   fcomi st(0), st(2)               // CurrentFadeFak <-> 1 ?
   fstsw ax                         // ax = FPU Status Word
   sahf                             // ax -> EFLAGS register
   jb @FadeLoopEnd                  // if CurrentFadeFak > 1 then exit!

   dec edx
 jnz @FadeLoop

 @FadeLoopEnd:
 fstp st(0)                    // clear stack
 fstp st(0)                    // clear stack
 fstp st(0)                    // clear stack
{$ENDIF}
end;

procedure FadeExponential_FPU(InBuffer: PDouble; Samples: Integer; CurrentFadeFak, FadeMul : Double); overload;
{$IFDEF PUREPASCAL}
var
  i : Integer;
begin
 for i := 0 to Samples - 1 do
  begin
   InBuffer^ := InBuffer^ * CurrentFadeFak;
   CurrentFadeFak := CurrentFadeFak * FadeMul;
   if CurrentFadeFak > 1 then exit;
   inc(InBuffer);
  end;
{$ELSE}
asm
 fld1                                // 1
 fld FadeMul.Double                  // FadeMul, 1
 fld CurrentFadeFak.Double           // CurrentFadeFak, FadeMul, 1
 mov ecx, eax                        // ecx = eax

 @FadeLoop:
   fld  [ecx + 8 * edx - 8].Double   // Value, CurrentFadeFak, FadeMul, 1
   fmul st(0), st(1)                 // Value * CurrentFadeFak, CurrentFadeFak, ...
   fstp [ecx + 8 * edx - 8].Double   // write back
   fmul st(0), st(1)                 // FadeMul * CurrentFadeFak, FadeMul, 1

   fcomi st(0), st(2)                // CurrentFadeFak <-> 1 ?
   fstsw ax                          // ax = FPU Status Word
   sahf                              // ax -> EFLAGS register
   jb @FadeLoopEnd                   // if CurrentFadeFak > 1 then exit!

   dec edx
 jnz @FadeLoop

 @FadeLoopEnd:
 fstp st(0)                          // clear stack
 fstp st(0)                          // clear stack
 fstp st(0)                          // clear stack
{$ENDIF}
end;

procedure FadeLinear_FPU(InBuffer: PSingle; Samples: Integer; CurrentFadeFak, FadeAddInc : Double); overload;
{$IFDEF PUREPASCAL}
var i : Integer;
begin
 for i := 0 to Samples-1 do
  begin
   InBuffer^ := InBuffer^*CurrentFadeFak;
   CurrentFadeFak := CurrentFadeFak+FadeAddInc;
   if CurrentFadeFak>1 then exit;
   inc(InBuffer);
  end;
{$ELSE}
asm
 fld1
 fld FadeAddInc.Double
 fld CurrentFadeFak.Double
 mov ecx, eax                        // ecx = eax

 @FadeLoop:
   fld  [ecx + 4 * edx - 4].Single   // Value, CurrentFadeFak
   fmul st(0), st(1)                 // Value * CurrentFadeFak, CurrentFadeFak
   fstp [ecx + 4 * edx - 4].Single   // write back
   fadd st(0), st(1)                 // CurrentFadeFak + FadeAddInc

   fcomi st(0), st(2)                // CurrentFadeFak <-> 1 ?
   fstsw ax                          // ax = FPU Status Word
   sahf                              // ax -> EFLAGS register
   jb @FadeLoopEnd                   // if CurrentFadeFak > 1 then exit!

   dec edx
 jnz @FadeLoop

 @FadeLoopEnd:
 fstp st(0)                          // clear stack
 fstp st(0)                          // clear stack
 fstp st(0)                          // clear stack
{$ENDIF}
end;

procedure FadeLinear_FPU(InBuffer: PDouble; Samples: Integer; CurrentFadeFak, FadeAddInc : Double); overload;
{$IFDEF PUREPASCAL}
var i : Integer;
begin
 for i := 0 to Samples - 1 do
  begin
   InBuffer^ := InBuffer^ * CurrentFadeFak;
   CurrentFadeFak := CurrentFadeFak + FadeAddInc;
   if CurrentFadeFak > 1 then exit;
   inc(InBuffer);
  end;
{$ELSE}
asm
 fld1
 fld FadeAddInc.Double
 fld CurrentFadeFak.Double
 mov ecx, eax                      // ecx = eax

 @FadeLoop:
   fld  [ecx + 8 * edx - 8].Double // Value, CurrentFadeFak
   fmul st(0),st(1)                // Value * CurrentFadeFak, CurrentFadeFak
   fstp [ecx + 8 * edx - 8].Double // write back
   fmul st(0),st(1)                // CurrentFadeFak + FadeAddInc

   fcomi st(0), st(2)              // CurrentFadeFak <-> 1 ?
   fstsw ax                        // ax = FPU Status Word
   sahf                            // ax -> EFLAGS register
   jb @FadeLoopEnd                 // if CurrentFadeFak > 1 then exit!

   dec edx
 jnz @FadeLoop

 @FadeLoopEnd:
 fstp st(0)                        // clear stack
 fstp st(0)                        // clear stack
 fstp st(0)                        // clear stack
{$ENDIF}
end;

function Trigger_FPU(InBuffer: PSingle; Samples: Integer; TriggerFaktor : Double): Integer; overload;
{$IFDEF PUREPASCAL}
var
  i : Integer;
begin
 result := 0;
 for i := 0 to Samples-1 do
  begin
   if abs(InBuffer^)>TriggerFaktor
    then exit
    else inc(result);
   inc(InBuffer);
  end;
 result := -1;
{$ELSE}
asm
 fld TriggerFaktor.Double
 mov ecx, eax                  // ecx = eax

 @FadeLoop:
   fld  [ecx+4*edx-4].Single   // Value, TriggerFaktor
   fabs                        // |Value|, TriggerFaktor

   fcomi st(0), st(1)          // CurrentFadeFak <-> 1 ?
   fstsw ax                    // ax = FPU Status Word
   sahf                        // ax -> EFLAGS register
   fstp st(0)                  // TriggerFaktor
   jb @TriggerFound            // if |Value| > TriggerFaktor then exit!

   dec edx
 jnz @FadeLoop

 mov result, -1                // not triggered
 jmp @FadeLoopEnd

 @TriggerFound:
 mov result, edx               // triggered at sample edx

 @FadeLoopEnd:
 fstp st(0)                    // clear stack
{$ENDIF}
end;

function Trigger_FPU(InBuffer: PDouble; Samples: Integer; TriggerFaktor : Double): Integer; overload;
{$IFDEF PUREPASCAL}
var i : Integer;
begin
 result := 0;
 for i := 0 to Samples-1 do
  begin
   if abs(InBuffer^)>TriggerFaktor
    then exit
    else inc(result);
   inc(InBuffer);
  end;
 result := -1;
{$ELSE}
asm
 fld TriggerFaktor.Double
 mov ecx, eax                  // ecx = eax

 @FadeLoop:
   fld  [ecx+8*edx-8].Double   // Value, TriggerFaktor
   fabs                        // |Value|, TriggerFaktor

   fcomi st(0), st(1)          // CurrentFadeFak <-> 1 ?
   fstsw ax                    // ax = FPU Status Word
   sahf                        // ax -> EFLAGS register
   fstp st(0)                  // TriggerFaktor
   jb @TriggerFound            // if |Value| > TriggerFaktor then exit!

   dec edx
 jnz @FadeLoop

 mov result, -1                // not triggered
 jmp @FadeLoopEnd

 @TriggerFound:
 mov result, edx               // triggered at sample edx

 @FadeLoopEnd:
 fstp st(0)                    // clear stack
{$ENDIF}
end;

// ReverseEndian3 : reverts 3-byte entities in place
procedure ReverseEndian3(buffer: pointer; frames: longint);
{$IFDEF PUREPASCAL}
type
  TByte3Array = Array [0..2] of Byte;
  PByte3Array = ^TByte3Array;
var
  BufArray : PByte3Array absolute buffer;
  BufByte  : PByte absolute buffer;
  i        : Integer;
  b        : Byte;
begin
 for i := 0 to frames - 1 do
  begin
   b := BufArray[0];
   BufArray[0] := BufArray[2];
   BufArray[2] := b;
   Inc(BufByte,3);
  end;
end;
{$ELSE}
asm
 mov ecx,edx
@Start:
 mov dh,[eax+2]
 mov dl,[eax  ]
 mov [eax+2],dl
 mov [eax  ],dh
 add  eax,3
 loop @Start
end;
{$ENDIF}

// ReverseEndian4 : reverts 4-byte entities in place
procedure ReverseEndian4(buffer: pointer; frames: longint);
{$IFDEF PUREPASCAL}
type
  TByte4Array = Array [0..3] of Byte;
  PByte4Array = ^TByte4Array;
var
  BufArray : PByte4Array absolute buffer;
  BufByte  : PByte absolute buffer;
  i        : Integer;
  b        : Byte;
begin
 for i := 0 to frames - 1 do
  begin
   b := BufArray[0]; BufArray[0] := BufArray[3]; BufArray[3] := b;
   b := BufArray[1]; BufArray[1] := BufArray[2]; BufArray[2] := b;
   Inc(BufByte, 4);
  end;
end;
{$ELSE}
asm
 mov ecx, frames
@Start:
 mov edx, [eax + 4 * ecx - 4]
 bswap edx
 mov [eax + 4 * ecx - 4], edx
 loop @Start
end;
{$ENDIF}

// ReverseEndian8 : reverts 8-byte entities in place
procedure ReverseEndian8(buffer: pointer; frames: longint);
{$IFDEF PUREPASCAL}
type
  TByte4Array = Array [0..7] of Byte;
  PByte4Array = ^TByte4Array;
var
  BufArray : PByte4Array absolute buffer;
  BufByte  : PByte absolute buffer;
  i        : Integer;
  b        : Byte;
begin
 for i := 0 to frames - 1 do
  begin
   b := BufArray[0]; BufArray[0] := BufArray[7]; BufArray[7] := b;
   b := BufArray[1]; BufArray[1] := BufArray[6]; BufArray[6] := b;
   b := BufArray[2]; BufArray[2] := BufArray[5]; BufArray[5] := b;
   b := BufArray[3]; BufArray[3] := BufArray[4]; BufArray[4] := b;
   Inc(BufByte, 8);
  end;
end;
{$ELSE}
asm
 push ebx
 mov  ecx, frames
@Start:
 mov edx,[eax]
 mov ebx,[eax+4]
 bswap edx
 bswap ebx
 mov [eax+4],edx
 mov [eax],ebx
 add  eax,8
 loop @Start
 pop ebx
end;
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// FPU ////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

procedure Int16LSBToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
var
  SourceArray : PWrdArray absolute source;
  TargetArray : PSnglArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i]*Minsmall;
end;
{$ELSE}
asm
  fld   Minsmall        //for speed
 @Start:
  fild  [eax+2*ecx-2].word
  fmul  st(0),st(1)
  fstp  [edx+4*ecx-4].single;
  loop @Start
  ffree st(0)
end;
{$ENDIF}

procedure Int16LSBToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
{$IFDEF PUREPASCAL}
var
  SourceArray : PWrdArray absolute source;
  TargetArray : PDblArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i]*Minsmall;
end;
{$ELSE}
asm
  fld   Minsmall        //for speed
 @Start:
  fild  [eax+2*ecx-2].Word
  fmul  st(0),st(1)
  fstp  [edx+8*ecx-8].Double;
  loop @Start
  ffree st(0)
end;
{$ENDIF}

procedure Int24LSBToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
var
  SourceInt   : PInteger absolute source;
  SourceByte  : PByte absolute source;
  TargetArray : PSnglArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1 do
  begin
   TargetArray[i] := (SourceInt^ shl 8) * MinLong;
   Inc(SourceByte, 3);
  end;
end;
{$ELSE}
asm
 fld MinLong
 push ebx
 mov  ecx, frames

@Start:
 mov ebx,[eax]
 shl ebx, 8
 mov [esp-4],ebx
 fild [esp-4].Single
 fmul  st(0),st(1)
 fstp [target].Single
 add  eax,3
 add  edx,4
 loop @Start
 pop ebx
 ffree st(0)
end;
{$ENDIF}

procedure Int24LSBToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
{$IFDEF PUREPASCAL}
var
  SourceInt   : PInteger absolute source;
  SourceByte  : PByte absolute source;
  TargetArray : PDblArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1 do
  begin
   TargetArray[i] := (SourceInt^ shl 8) * MinLong;
   Inc(SourceByte, 3);
  end;
end;
{$ELSE}
asm
 fld Min24
 push ebx
 mov  ecx, frames

@Start:
 mov ebx,[eax]
 and ebx, $FFFFFF
 mov [esp-4],ebx
 fild [esp-4].Single
 fmul  st(0),st(1)
 fstp [target].Double
 add  eax, 3
 add  edx, 8
 loop @Start
 pop ebx
 ffree st(0)
end;
{$ENDIF}

procedure Int32LSBToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
var
  SourceArray : PntgrArray absolute source;
  TargetArray : PSnglArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i]*minlong;
end;
{$ELSE}
asm
  fld   minlong         //for speed
 @Start:
  dec ecx
  fild  [eax+4*ecx].Dword
  fmul  st(0),st(1)
  fstp  [edx+4*ecx].Single
  jnz @Start
  ffree st(0)
end;
{$ENDIF}

procedure Int32LSBToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
{$IFDEF PUREPASCAL}
var
  SourceArray : PntgrArray absolute source;
  TargetArray : PDblArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i]*minlong;
end;
{$ELSE}
asm
  fld   minlong         //for speed
 @Start:
  dec ecx
  fild  [eax + 4 * ecx].DWord
  fmul  st(0), st(1)
  fstp  [edx + 8 * ecx].Double
  jnz @Start
  ffree st(0)
end;
{$ENDIF}

procedure SingleLSBToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
begin
 move(source^, target^, frames*SizeOf(Single));
end;

procedure SingleLSBToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
{$IFDEF PUREPASCAL}
var
  SourceArray : PSnglArray absolute source;
  TargetArray : PDblArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i];
end;
{$ELSE}
asm
 @Start:
  dec ecx
  fld   [eax+4*ecx].Single
  fstp  [edx+8*ecx].Double
  jnz @Start
end;
{$ENDIF}

procedure DoubleLSBToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
var
  SourceArray : PDblArray absolute source;
  TargetArray : PSnglArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i];
end;
{$ELSE}
asm
 @Start:
  dec ecx
  fld   [eax+8*ecx].Double
  fstp  [edx+4*ecx].Single
  jnz @Start
end;
{$ENDIF}

procedure DoubleLSBToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
begin
 move(source^, target^, frames*SizeOf(Double));
end;

procedure Int32LSB16ToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload; // 32 bit data with 16 bit alignment
{$IFDEF PUREPASCAL}
var
  SourceArray : PntgrArray absolute source;
  TargetArray : PSnglArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i]*MinSmall;
end;
{$ELSE}
asm
  fld      MinSmall
@Start:
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+4*ecx-4].Single
  loop @Start
  ffree    st(0)
end;
{$ENDIF}

procedure Int32LSB16ToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload; // 32 bit data with 16 bit alignment
{$IFDEF PUREPASCAL}
var
  SourceArray : PntgrArray absolute source;
  TargetArray : PDblArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i]*MinSmall;
end;
{$ELSE}
asm
  fld      MinSmall
@Start:
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+8*ecx-8].Double
  loop @Start
  ffree    st(0)
end;
{$ENDIF}

procedure Int32LSB18ToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload; // 32 bit data with 18 bit alignment
{$IFDEF PUREPASCAL}
var
  SourceArray : PntgrArray absolute source;
  TargetArray : PSnglArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i]*Min18;
end;
{$ELSE}
asm
  fld      Min18
@Start:
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+4*ecx-4].Single
  loop     @start
  ffree    st(0)
end;
{$ENDIF}

procedure Int32LSB18ToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload; // 32 bit data with 18 bit alignment
{$IFDEF PUREPASCAL}
var
  SourceArray : PntgrArray absolute source;
  TargetArray : PDblArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i]*Min18;
end;
{$ELSE}
asm
  fld      Min18
@Start:
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+8*ecx-8].Double
  loop     @start
  ffree    st(0)
end;
{$ENDIF}

procedure Int32LSB20ToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload; // 32 bit data with 20 bit alignment
{$IFDEF PUREPASCAL}
var
  SourceArray : PntgrArray absolute source;
  TargetArray : PSnglArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i]*Min20;
end;
{$ELSE}
asm
  fld      Min20
@Start:
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+4*ecx-4].Single
  loop     @start
  ffree    st(0)
end;
{$ENDIF}

procedure Int32LSB20ToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload; // 32 bit data with 20 bit alignment
{$IFDEF PUREPASCAL}
var
  SourceArray : PntgrArray absolute source;
  TargetArray : PDblArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i]*Min20;
end;
{$ELSE}
asm
  fld      Min20
@Start:
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+8*ecx-8].Double
  loop     @start
  ffree    st(0)
end;
{$ENDIF}

procedure Int32LSB24ToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload; // 32 bit data with 24 bit alignment
{$IFDEF PUREPASCAL}
var
  SourceArray : PntgrArray absolute source;
  TargetArray : PSnglArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i] * Min24;
end;
{$ELSE}
asm
  fld      Min24
@Start:
  fild     [eax + 4 * ecx - 4].DWord;
  fmul     st(0),st(1)
  fstp     [edx + 4 * ecx - 4].Single
  loop     @start
  ffree    st(0)
end;
{$ENDIF}

procedure Int32LSB24ToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload; // 32 bit data with 24 bit alignment
{$IFDEF PUREPASCAL}
var
  SourceArray : PntgrArray absolute source;
  TargetArray : PDblArray absolute target;
  i           : Integer;
begin
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i] * Min24;
end;
{$ELSE}
asm
  fld      Min24
@Start:
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+8*ecx-8].Double
  loop     @start
  ffree    st(0)
end;
{$ENDIF}

procedure Int16MSBToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
var
  SourceArray : PWrdArray absolute source;
  TargetArray : PSnglArray absolute target;
  i           : Integer;
begin
 ReverseEndian4(source, frames div 2);
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i] * MinSmall;
end;
{$ELSE}
asm
  push ebx
  fld   Minsmall
 @Start:
  mov bx,[eax + 2 * ecx - 2]
  rol bx, $8
  mov [eax + 2 * ecx - 2],bx
  fild  [eax + 2 * ecx - 2].Word
  fmul  st(0), st(1)
  fstp  [edx + 4 * ecx - 4].Single
  loop @start
  ffree st(0)
  pop ebx
end;
{$ENDIF}

procedure Int16MSBToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
{$IFDEF PUREPASCAL}
var
  SourceArray : PWrdArray absolute source;
  TargetArray : PDblArray absolute target;
  i           : Integer;
begin
 ReverseEndian4(source, frames div 2);
 for i := 0 to frames - 1
  do TargetArray[i] := SourceArray[i] * MinSmall;
end;
{$ELSE}
asm
  push ebx
  fld   Minsmall
 @Start:
  mov bx,[eax+2*ecx-2]
  rol bx,$8
  mov [eax+2*ecx-2],bx
  fild  [eax+2*ecx-2].Word
  fmul  st(0),st(1)
  fstp  [edx+8*ecx-8].Double
  loop @start
  ffree st(0)
  pop ebx
end;
{$ENDIF}

procedure Int24MSBToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian3(source, frames);
 Int24LSBToSingle_FPU(source, target, frames);
end;
{$ELSE}
asm
 fld Min24
 push ebx
@Start:
 xor ebx, ebx

 mov bl, [eax + 2]
 mov bh, [eax + 1]
 ror ebx, 8
 mov bh, [eax]
 rol ebx, 8

 mov [esp-4], ebx
 fild [esp-4].Single
 fmul  st(0), st(1)
 fstp [target].Single
 add  eax, 3
 add  target, 4
 loop @Start

 pop ebx
 ffree st(0)
end;
{$ENDIF}

procedure Int24MSBToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian3(source, frames);
 Int24LSBToDouble_FPU(source, target, frames);
end;
{$ELSE}
asm
 fld Min24
 push ebx
@Start:
 xor ebx, ebx

 mov bl, [eax + 2]
 mov bh, [eax + 1]
 ror ebx, 8
 mov bh, [eax]
 rol ebx, 8

 mov [esp-4], ebx
 fild [esp-4].Single
 fmul  st(0), st(1)
 fstp [target].Double
 add  eax, 3
 add  target, 8
 loop @Start

 pop ebx
 ffree st(0)
end;
{$ENDIF}

procedure Int32MSBToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian4(source, frames);
 Int32LSBToSingle_FPU(source, target, frames);
end;
{$ELSE}
asm
 push   ebx
 fld    minlong
@Start:
 mov    ebx,[eax+4*ecx-4]
 bswap  ebx
 mov    [eax+4*ecx-4],ebx
 fild   [eax+4*ecx-4].DWord
 fmul   st(0),st(1)
 fstp   [edx+4*ecx-4].Single
 loop   @start
 ffree  st(0)
 pop    ebx
end;
{$ENDIF}

procedure Int32MSBToDouble_FPU(source: pointer; target: PDouble; Frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian4(source, frames);
 Int32LSBToDouble_FPU(source, target, frames);
end;
{$ELSE}
asm
 push   ebx
 fld    minlong
@Start:
 mov    ebx,[eax+4*ecx-4]
 bswap  ebx
 mov    [eax+4*ecx-4],ebx
 fild   [eax+4*ecx-4].DWord
 fmul   st(0),st(1)
 fstp   [edx+8*ecx-8].Double
 loop   @start
 ffree  st(0)
 pop    ebx
end;
{$ENDIF}

procedure SingleMSBToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 move(source^, target^, frames*SizeOf(Single));
 ReverseEndian4(target, frames);
end;
{$ELSE}
asm
 push ebx
 mov ecx, frames
@Start:
 mov ebx,[eax+4*ecx-4]
 bswap ebx
 mov [edx+4*ecx-4],ebx
 loop @Start
 pop ebx
end;
{$ENDIF}

procedure SingleMSBToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian4(source, frames);
 SingleLSBToDouble_FPU(source, target, frames);
end;
{$ELSE}
asm
 push ebx
 @Start:
  mov ebx,[source+4*frames-4]
  bswap ebx
  mov [esp-4],ebx
  fld   [esp-4].Single
  fstp  [target+8*frames-8].Double
  loop @Start
 pop ebx
end;
{$ENDIF}

procedure DoubleMSBToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
begin
 ReverseEndian8(source, frames);
 DoubleLSBToSingle_FPU(source, target, frames);
end;

procedure DoubleMSBToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
begin
 move(source^, target^, frames*SizeOf(Double));
 ReverseEndian8(target, frames);
end;

procedure Int32MSB16ToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian4(source, frames);
 Int32LSB16ToSingle_FPU(source, target, frames);
end;
{$ELSE}
asm
  push     ebx
  fld      MinSmall
@Start:
  mov      ebx,[eax+4*ecx-4]
  bswap    ebx
  mov      [eax+4*ecx-4],ebx
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+4*ecx-4].Single
  loop     @start
  ffree    st(0)
  pop      ebx
end;
{$ENDIF}

procedure Int32MSB16ToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian4(source, frames);
 Int32LSB16ToDouble_FPU(source, target, frames);
end;
{$ELSE}
asm
  push     ebx
  fld      MinSmall
@Start:
  mov      ebx,[eax+4*ecx-4]
  bswap    ebx
  mov      [eax+4*ecx-4],ebx
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+8*ecx-8].Double
  loop     @start
  ffree    st(0)
  pop      ebx
end;
{$ENDIF}

procedure Int32MSB18ToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian4(source, frames);
 Int32LSB18ToSingle_FPU(source, target, frames);
end;
{$ELSE}
asm
  push     ebx
  fld      Min18
@Start:
  mov      ebx,[eax+4*ecx-4]
  bswap    ebx
  mov      [eax+4*ecx-4],ebx
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+4*ecx-4].Single
  loop     @start
  ffree    st(0)
  pop      ebx
end;
{$ENDIF}

procedure Int32MSB18ToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian4(source, frames);
 Int32LSB18ToDouble_FPU(source, target, frames);
end;
{$ELSE}
asm
  push     ebx
  fld      Min18
@Start:
  mov      ebx,[eax+4*ecx-4]
  bswap    ebx
  mov      [eax+4*ecx-4],ebx
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+8*ecx-8].Double
  loop     @start
  ffree    st(0)
  pop      ebx
end;
{$ENDIF}

procedure Int32MSB20ToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian4(source, frames);
 Int32LSB20ToSingle_FPU(source, target, frames);
end;
{$ELSE}
asm
  push     ebx
  fld      Min20
@Start:
  mov      ebx,[eax+4*ecx-4]
  bswap    ebx
  mov      [eax+4*ecx-4],ebx
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+4*ecx-4].Single
  loop     @start
  ffree    st(0)
  pop      ebx
end;
{$ENDIF}

procedure Int32MSB20ToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian4(source, frames);
 Int32LSB20ToDouble_FPU(source, target, frames);
end;
{$ELSE}
asm
  push     ebx
  fld      Min20
@Start:
  mov      ebx,[eax+4*ecx-4]
  bswap    ebx
  mov      [eax+4*ecx-4],ebx
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+8*ecx-8].Double
  loop     @start
  ffree    st(0)
  pop      ebx
end;
{$ENDIF}

procedure Int32MSB24ToSingle_FPU(source: pointer; target: PSingle; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian4(source, frames);
 Int32LSB24ToSingle_FPU(source, target, frames);
end;
{$ELSE}
asm
  push     ebx
  fld      Min24
@Start:
  mov      ebx,[eax+4*ecx-4]
  bswap    ebx
  mov      [eax+4*ecx-4],ebx
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+4*ecx-4].Single
  loop     @start
  ffree    st(0)
  pop      ebx
end;
{$ENDIF}

procedure Int32MSB24ToDouble_FPU(source: pointer; target: PDouble; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 ReverseEndian4(source, frames);
 Int32LSB24ToDouble_FPU(source, target, frames);
end;
{$ELSE}
asm
  push     ebx
  fld      Min24
@Start:
  mov      ebx,[eax+4*ecx-4]
  bswap    ebx
  mov      [eax+4*ecx-4],ebx
  fild     [eax+4*ecx-4].DWord
  fmul     st(0),st(1)
  fstp     [edx+8*ecx-8].Double
  loop     @start
  ffree    st(0)
  pop      ebx
end;
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////

procedure SingleToInt16LSB_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
  fld      MaxSmall    // move to register for speed
@Start:                // Samplecount already in ecx!
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)
  fistp    word ptr [edx+2*ecx-2]
  loop     @start
  ffree    st(0)       // free after loop has finished
end;

procedure SingleToInt16LSB_UDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((1.0/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    MaxSmall               // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul st(0),st(3)
  faddp

  fistp    word ptr [edx+2*ecx-2]
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure SingleToInt16LSB_TDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    MaxSmall               // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  faddp
  fmul st(0),st(3)
  faddp

  fistp    word ptr [edx+2*ecx-2]
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure DoubleToInt16LSB_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  fld      MaxSmall    // move to register for speed
@Start:                // Samplecount already in ecx!
  fld      [eax+8*ecx-8].Double
  fmul     st(0),st(1)
  fistp    word ptr [edx+2*ecx-2]
  loop     @start
  ffree    st(0)       // free after loop has finished
end;

procedure DoubleToInt16LSB_UDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((1.0/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    MaxSmall               // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+8*ecx-8].Double
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul st(0),st(3)
  faddp

  fistp    word ptr [edx+2*ecx-2]
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure DoubleToInt16LSB_TDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    MaxSmall               // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+8*ecx-8].Double
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  faddp
  fmul st(0),st(3)
  faddp

  fistp    word ptr [edx+2*ecx-2]
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;



procedure SingleToInt24LSB_FPU(source: PSingle; target: pointer; frames: longint); overload;
{$IFDEF PUREPASCAL}
var
  SourceArray : PSnglArray absolute source;
  TargetInt   : PByte absolute target;
  i           : Integer;
begin
 for i := 0 to Frames - 1 do
  begin
   PInteger(TargetInt)^ := round(SourceArray^[i] * Max24);
   Inc(TargetInt, 3);
  end;
end;
{$ELSE}
asm
  push ebx
  fld   Max24         //for speed
 @Start:
  fld   [eax].Single
  fmul  st(0),st(1)
  fistp [esp-4].DWord
  mov   ebx, [esp-4]
  mov   [edx], bx
  ror   ebx, 8
  mov   [edx+2], bh
  add   eax, 4
  add   edx, 3
  dec   ecx
  jnz   @Start
  ffree st(0)
  pop ebx
end;
{$ENDIF}

procedure SingleToInt24LSB_UDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((1/$10000) / $10000);  // 2^-32
asm
  push ebx
  fld   Scaler                 // move to register for speed
  fld   Max24                  //for speed
 @Start:
  fld   [eax].dword
  fmul  st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul Scaler.Double
  faddp

  fistp [esp-4].Single
  mov   ebx, [esp-4]
  mov   [edx], bx
  ror   ebx, 8
  mov   [edx+2], bh
  add   eax, 4
  add   edx, 3
  dec   ecx
  jnz   @Start
  ffree    st(0)               // free after loop has finished
  ffree    st(1)               // free after loop has finished
  pop ebx
end;

procedure SingleToInt24LSB_TDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
  push ebx
  fld   Scaler                 // move to register for speed
  fld   Max24                  //for speed
 @Start:
  fld   [eax].Single
  fmul  st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  faddp
  fmul st(0),st(3)
  faddp

  fistp [esp-4].dword;
  mov   ebx, [esp-4]
  mov   [edx], bx
  ror   ebx, 8
  mov   [edx+2], bh
  add   eax, 4
  add   edx, 3
  dec   ecx
  jnz   @Start
  ffree    st(0)               // free after loop has finished
  ffree    st(1)               // free after loop has finished
  pop ebx
end;

procedure DoubleToInt24LSB_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  push ebx
  fld   Max24         //for speed
 @Start:
  fld   [eax].Double
  fmul  st(0),st(1)
  fistp [esp-4].DWord
  mov   ebx, [esp-4]
  mov   [edx], bx
  ror   ebx, 8
  mov   [edx+2], bh
  add   eax, 8
  add   edx, 3
  dec   ecx
  jnz   @Start
  ffree st(0)
  pop ebx
end;

procedure DoubleToInt24LSB_UDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((1/$10000) / $10000);  // 2^-32
asm
  push ebx
  fld   Scaler                 // move to register for speed
  fld   Max24                  //for speed
 @Start:
  fld   [eax].Double
  fmul  st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul Scaler.Double
  faddp

  fistp [esp-4].dword;
  mov   ebx, [esp-4]
  mov   [edx], bx
  ror   ebx, 8
  mov   [edx+2], bh
  add   eax, 8
  add   edx, 3
  dec   ecx
  jnz   @Start
  ffree    st(0)               // free after loop has finished
  ffree    st(1)               // free after loop has finished
  pop ebx
end;

procedure DoubleToInt24LSB_TDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
  push ebx
  fld   Scaler                 // move to register for speed
  fld   Max24                  //for speed
 @Start:
  fld   [eax].Double
  fmul  st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  faddp
  fmul st(0),st(3)
  faddp

  fistp [esp-4].dword;
  mov   ebx, [esp-4]
  mov   [edx], bx
  ror   ebx, 8
  mov   [edx+2], bh
  add   eax, 8
  add   edx, 3
  dec   ecx
  jnz   @Start
  ffree    st(0)               // free after loop has finished
  ffree    st(1)               // free after loop has finished
  pop ebx
end;

procedure SingleToInt32LSB_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
  fld   MaxLong         //for speed
 @Start:
  fld   [eax + 4 * ecx - 4].single
  fmul  st(0),st(1)
  fistp [edx + 4 * ecx - 4].dword;
  loop @Start
  ffree st(0)
end;

procedure DoubleToInt32LSB_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  fld   MaxLong         //for speed
 @Start:
  fld   [eax + 8 * ecx - 8].Double
  fmul  st(0), st(1)
  fistp [edx + 4 * ecx - 4].DWord
  loop @Start
  ffree st(0)
end;

procedure SingleToSingleLSB_FPU(source: PSingle; target: pointer; frames: longint); overload;
begin
 move(source^, target^, frames*sizeOf(Single));
end;

procedure DoubleToSingleLSB_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
 @Start:
  fld   [source+8*ecx-8].Double
  fstp  [target+4*ecx-4].Single
  loop @Start
end;

procedure SingleToDoubleLSB_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
 @Start:
  fld   [eax+4*ecx-4].Single
  fstp  [edx+8*ecx-8].Double
  loop @Start
end;

procedure DoubleToDoubleLSB_FPU(source: PDouble; target: pointer; frames: longint); overload;
begin
 move(source^, target^, frames*sizeOf(Double));
end;

procedure SingleToInt32LSB16_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
  fld      MaxSmall
@Start:
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)
  fistp    [edx+4*ecx-4].DWord
  loop @Start
  ffree    st(0)
end;

procedure SingleToInt32LSB16_UDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((1.0/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    MaxSmall               // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure SingleToInt32LSB16_TDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    MaxSmall               // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  faddp
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure DoubleToInt32LSB16_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  fld      MaxSmall
@Start:
  fld      [eax+8*ecx-8].Double
  fmul     st(0),st(1)
  fistp    [edx+4*ecx-4].DWord
  loop @Start
  ffree    st(0)
end;

procedure DoubleToInt32LSB16_UDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((1.0/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    MaxSmall               // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+8*ecx-8].Double
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure DoubleToInt32LSB16_TDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    MaxSmall               // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+8*ecx-8].Double
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  faddp
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure SingleToInt32LSB18_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
  fld   Max18
 @Start:
  fld   [eax+4*ecx-4].Single
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].dword
  loop @Start
  ffree st(0)
end;

procedure SingleToInt32LSB18_UDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((1.0/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max18                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure SingleToInt32LSB18_TDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max18                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  faddp
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure DoubleToInt32LSB18_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  fld   Max18
 @Start:
  fld   [eax+8*ecx-8].Double
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  loop @Start
  ffree st(0)
end;

procedure DoubleToInt32LSB18_UDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((1.0/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max18                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+8*ecx-8].Double
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure DoubleToInt32LSB18_TDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max18                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+8*ecx-8].Double
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  faddp
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure SingleToInt32LSB20_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
  fld   Max20
 @Start:
  fld   [eax+4*ecx-4].Single
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  loop @Start
  ffree st(0)
end;

procedure SingleToInt32LSB20_UDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((1.0/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max20                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure SingleToInt32LSB20_TDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max20                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  faddp
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure DoubleToInt32LSB20_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  fld   Max20
 @Start:
  fld   [eax+8*ecx-8].Double
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  loop @Start
  ffree st(0)
end;

procedure DoubleToInt32LSB20_UDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((1.0/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max20                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+8*ecx-8].Double
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure DoubleToInt32LSB20_TDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max20                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+8*ecx-8].Double
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  faddp
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure SingleToInt32LSB24_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
  fld   Max24
 @Start:
  fld   [eax+4*ecx-4].Single
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  loop @Start
  ffree st(0)
end;

procedure SingleToInt32LSB24_UDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((1.0/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max24                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure SingleToInt32LSB24_TDF_FPU(source: PSingle; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max24                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+4*ecx-4].Single
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  faddp
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure DoubleToInt32LSB24_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  fld   Max24
 @Start:
  fld   [eax+8*ecx-8].Double
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  loop @Start
  ffree st(0)
end;

procedure DoubleToInt32LSB24_UDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((1.0/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max24                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld      [eax+8*ecx-8].Double
  fmul     st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov RandSeed,ebx
  fild  RandSeed
  fmul st(0),st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure DoubleToInt32LSB24_TDF_FPU(source: PDouble; target: pointer; frames: longint); overload;
const Scaler: Double = ((0.5/$10000) / $10000);  // 2^-32
asm
 push ebx
 fld    Scaler                 // move to register for speed
 fld    Max24                  // move to register for speed
 @Start:                       // Samplecount already in ecx!
  fld   [eax+8*ecx-8].Double
  fmul  st(0),st(1)

  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov   RandSeed,ebx
  fild  RandSeed
  imul  ebx,RandSeed,$08088405
  inc   ebx
  mov   RandSeed,ebx
  fild  RandSeed
  faddp
  fmul  st(0), st(3)
  faddp

  fistp   [edx+4*ecx-4].DWord
 loop     @start
 ffree    st(0)                // free after loop has finished
 ffree    st(1)                // free after loop has finished
 pop ebx
end;

procedure SingleToInt16MSB_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
   push ebx
   fld      MaxSmall
 @Start:
   fld      [eax+4*ecx-4].Single
   fmul     st(0),st(1)
   fistp    word ptr [edx+2*ecx-2]
   mov      bx,[edx+2*ecx-2]
   rol      bx,$8
   mov      [edx+2*ecx-2],bx
   loop @Start
   ffree    st(0)
   pop ebx
end;

procedure DoubleToInt16MSB_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
   push ebx
   fld      MaxSmall
 @Start:
   fld      [eax+8*ecx-8].Double
   fmul     st(0),st(1)
   fistp    word ptr [edx+2*ecx-2]
   mov      bx,[edx+2*ecx-2]
   rol      bx,$8
   mov      [edx+2*ecx-2],bx
   loop @Start
   ffree    st(0)
   pop ebx
end;

procedure SingleToInt24MSB_FPU(source: PSingle; target: pointer; frames: longint); overload;
begin
 SingleToInt24LSB_FPU(source, target, frames);
 ReverseEndian3(target, frames);
end;

procedure DoubleToInt24MSB_FPU(source: PDouble; target: pointer; frames: longint); overload;
begin
 DoubleToInt24LSB_FPU(source, target, frames);
 ReverseEndian3(target, frames);
end;

procedure SingleToInt32MSB_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
  push ebx
  fld   MaxLong         //for speed
 @Start:
  fld   [eax+4*ecx-4].single
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].dword;
  mov ebx,[edx+4*ecx-4]
  bswap ebx
  mov [edx+4*ecx-4],ebx
  loop @Start
  ffree st(0)
  pop ebx
end;

procedure DoubleToInt32MSB_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  push ebx
  fld   MaxLong         //for speed
 @Start:
  fld   [eax+8*ecx-8].Double
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  mov ebx,[edx+4*ecx-4]
  bswap ebx
  mov [edx+4*ecx-4],ebx
  loop @Start
  ffree st(0)
  pop ebx
end;

procedure SingleToSingleMSB_FPU(source: PSingle; target: pointer; frames: longint); overload;
begin
 move(source^, target^, frames * SizeOf(Single));
 ReverseEndian4(target, frames);
end;

procedure DoubleToSingleMSB_FPU(source: PDouble; target: pointer; frames: longint); overload;
{$IFDEF PUREPASCAL}
begin
 DoubleLSBToSingle_FPU(source, target, frames);
 ReverseEndian4(target, frames);
end;
{$ELSE}
asm
 push ebx
 @Start:
  fld   [source+8*frames-8].Double
  fstp  [target+4*frames-4].Single
  mov ebx,[target+4*frames-4]
  bswap ebx
  mov [target+4*frames-4],ebx
  loop @Start
 pop ebx
end;
{$ENDIF}

procedure SingleToDoubleMSB_FPU(source: PSingle; target: pointer; frames: longint); overload;
begin
 SingleToDoubleLSB_FPU(source, target, frames);
 ReverseEndian8(target, frames);
end;

procedure DoubleToDoubleMSB_FPU(source: PDouble; target: pointer; frames: longint); overload;
begin
 move(source^, target^, frames * SizeOf(Double));
 ReverseEndian8(target, frames);
end;

procedure SingleToInt32MSB16_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
  push ebx
  fld   MaxSmall
 @Start:
  fld   [eax+4*ecx-4].single
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  mov ebx,[edx+4*ecx-4]
  bswap ebx
  mov [edx+4*ecx-4],ebx
  loop @Start
  fstp st(0)
  pop ebx
end;

procedure DoubleToInt32MSB16_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  push ebx
  fld   MaxSmall
 @Start:
  fld   [eax+8*ecx-8].Double
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  mov ebx,[edx+4*ecx-4]
  bswap ebx
  mov [edx+4*ecx-4],ebx
  loop @Start
  fstp st(0)
  pop ebx
end;

procedure SingleToInt32MSB18_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
  push ebx
  fld   Max18
 @Start:
  fld   [eax+4*ecx-4].Single
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  mov ebx,[edx+4*ecx-4]
  bswap ebx
  mov [edx+4*ecx-4],ebx
  loop @Start
  ffree st(0)
  pop ebx
end;

procedure DoubleToInt32MSB18_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  push ebx
  fld   Max18
 @Start:
  fld   [eax+8*ecx-8].Double
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  mov ebx,[edx+4*ecx-4]
  bswap ebx
  mov [edx+4*ecx-4],ebx
  loop @Start
  ffree st(0)
  pop ebx
end;

procedure SingleToInt32MSB20_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
  push ebx
  fld   Max20
 @Start:
  fld   [eax+4*ecx-4].Single
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  mov ebx,[edx+4*ecx-4]
  bswap ebx
  mov [edx+4*ecx-4],ebx
  loop @Start
  ffree st(0)
  pop ebx
end;

procedure DoubleToInt32MSB20_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  push ebx
  fld   Max20
 @Start:
  fld   [eax+8*ecx-8].Double
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  mov ebx,[edx+4*ecx-4]
  bswap ebx
  mov [edx+4*ecx-4],ebx
  loop @Start
  ffree st(0)
  pop ebx
end;

procedure SingleToInt32MSB24_FPU(source: PSingle; target: pointer; frames: longint); overload;
asm
  push ebx
  fld   Max24
 @Start:
  fld   [eax+4*ecx-4].Single
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  mov ebx,[edx+4*ecx-4]
  bswap ebx
  mov [edx+4*ecx-4],ebx
  loop @Start
  ffree st(0)
  pop ebx
end;

procedure DoubleToInt32MSB24_FPU(source: PDouble; target: pointer; frames: longint); overload;
asm
  push ebx
  fld   Max24
 @Start:
  fld   [eax+8*ecx-8].Double
  fmul  st(0),st(1)
  fistp [edx+4*ecx-4].DWord
  mov ebx,[edx+4*ecx-4]
  bswap ebx
  mov [edx+4*ecx-4],ebx
  loop @Start
  ffree st(0)
  pop ebx
end;

function ClipCheckInt16LSB_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PSmallInt absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^ = $7FFF) or (v^ = $8000) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckInt24LSB_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
    b : PByte absolute source;
begin
 Result := false;
 for i := 0 to Frames - 1 do
  begin
   if (v^ = $7FFFFF) or (v^ = $800000) then
    begin
     Result := True;
     Exit;
    end;
   inc(b, 3);
  end;
end;

function ClipCheckInt32LSB_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^ = $7FFFFFF) or (v^ = $80000000) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckInt32LSB16_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^ = $7FFF) or (v^ = $8000) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckInt32LSB18_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^ = $1FFFF) or (v^ = $20000) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckInt32LSB20_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^ = $7FFFF) or (v^ = $80000) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckInt32LSB24_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^ = $7FFFFF) or (v^ = $800000) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckSingleLSB_FPU(source: Pointer; frames: longint):Boolean;
{$IFDEF PUREPASCAL}
var i : Integer;
    v : PSingle absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^>1) or (v^<1) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;
{$ELSE}
asm
 mov result, 1                 // Annahme, es klippt!
 mov ecx, eax                  // ecx = eax
 xor eax, eax
 fld1
 @FadeLoop:
   fld  [ecx+4*edx-4].Single   // Value, CurrentFadeFak
   fabs
   fcomi st(0), st(1)          // CurrentFadeFak <-> 1 ?
{
   fstsw ax                    // ax = FPU Status Word
   sahf                        // ax -> EFLAGS register
}
   fstp st(0)                  // clear stack
   ja @FadeLoopEnd             // if CurrentFadeFak > 1 then exit!

   dec edx
 jnz @FadeLoop
 mov result, 0                 // na gut, klippt doch nicht :-/

 @FadeLoopEnd:
 fstp st(0)                    // clear stack
end;
{$ENDIF}

function ClipCheckDoubleLSB_FPU(source: Pointer; frames: longint):Boolean;
{$IFDEF PUREPASCAL}
var i : Integer;
    v : PDouble absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^>1) or (v^<1) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;
{$ELSE}
asm
 mov result, 1                 // Annahme, es klippt!
 mov ecx, eax                  // ecx = eax
 xor eax, eax
 fld1
 @FadeLoop:
   fld  [ecx+8*edx-8].Double   // Value, CurrentFadeFak
   fabs
   fcomi st(0), st(1)          // CurrentFadeFak <-> 1 ?
{
   fstsw ax                    // ax = FPU Status Word
   sahf                        // ax -> EFLAGS register
}
   fstp st(0)                  // clear stack
   ja @FadeLoopEnd             // if CurrentFadeFak > 1 then exit!

   dec edx
 jnz @FadeLoop
 mov result, 0                 // na gut, klippt doch nicht :-/

 @FadeLoopEnd:
 fstp st(0)                    // clear stack
end;
{$ENDIF}

function ClipCheckInt16MSB_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PSmallInt absolute source;
begin
 Result := false;
 for i := 0 to Frames - 1 do
  begin
   if (v^ = $FF7F) or (v^ = $0080) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckInt24MSB_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
    b : PByte absolute source;
begin
 Result := false;
 for i := 0 to Frames - 1 do
  begin
   // ToDo BitReverse!!
   if (v^ = $7FFFFF) or (v^ = $800000) then
    begin
     Result := True;
     Exit;
    end;
   inc(b, 3);
  end;
end;

function ClipCheckInt32MSB_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^ = $FFFFF7F) or (v^ = $80) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckInt32MSB16_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^ = $7FFF) or (v^ = $8000) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckInt32MSB18_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^ = $1FFFF) or (v^ = $20000) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckInt32MSB20_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^ = $7FFFF) or (v^ = $80000) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckInt32MSB24_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PInteger absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   if (v^ = $7FFFFF) or (v^ = $800000) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckSingleMSB_FPU(source: Pointer; frames: longint):Boolean;
var i : Integer;
    v : PSingle absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   // ToDo ByteSwap here
   if (v^>1) or (v^<1) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

function ClipCheckDoubleMSB_FPU(source: Pointer; frames: longint):Boolean;
var i  : Integer;
    v : PDouble absolute source;
begin
 Result := false;
 for i := 0 to Frames-1 do
  begin
   // ToDo ByteSwap here
   if (v^>1) or (v^<1) then
    begin
     Result := True;
     Exit;
    end;
   inc(v);
  end;
end;

procedure MixBuffers_FPU(InBuffer:PSingle; MixBuffer:PSingle; samples:integer); overload;
asm
@Start:
  fld   [eax+4*ecx-4].Single
  fadd  [edx+4*ecx-4].Single
  fstp  [edx+4*ecx-4].Single
  loop @Start
end;

procedure MixBuffers_FPU(InBuffer:PDouble; MixBuffer:PDouble; samples:integer); overload;
asm
@Start:
  fld   [eax+8*ecx-8].Double
  fadd  [edx+8*ecx-8].Double
  fstp  [edx+8*ecx-8].Double
  loop @Start
end;

procedure Volume_FPU(InBuffer:PSingle; Volume:Single; samples:integer); overload;
asm
 mov ecx,samples
 fld Volume.Single
@Start:
 fld [eax+4*ecx-4].single
 fmul st(0),st(1)
 fstp [eax+4*ecx-4].single
 loop @Start
 fstp st(0)
end;

procedure Volume_FPU(InBuffer:PDouble; Volume:Double; samples:integer); overload;
asm
 mov ecx,samples
 fld Volume.Double
@Start:
 fld [eax+8*ecx-8].Double
 fmul st(0),st(1)
 fstp [eax+8*ecx-8].Double
 loop @Start
 fstp st(0)
end;

{$IFNDEF DELPHI5}

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// SSE ////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

procedure ClipDigital_SSE(InBuffer: PSingle; BSize: Integer);
const c1a : Single = 1;
      mm1pos : array[0..3] of Single = (1, 1, 1, 1);
      mm1neg : array[0..3] of Single = (-1, -1, -1, -1);
asm
 mov ecx,edx
 push ecx
 shr ecx,4  // number of large iterations = number of elements / 16
 jz @SkipLargeAddLoop
 movups xmm0,mm1pos
 movups xmm1,mm1neg
@LargeAddLoop:
 movups xmm2,[eax   ]
 movups xmm3,[eax+$10]
 movups xmm4,[eax+$20]
 movups xmm5,[eax+$30]
 minps xmm2,xmm0
 minps xmm3,xmm0
 minps xmm4,xmm0
 minps xmm5,xmm0
 maxps xmm2,xmm1
 maxps xmm3,xmm1
 maxps xmm4,xmm1
 maxps xmm5,xmm1
 movups [eax    ],xmm2
 movups [eax+$10],xmm3
 movups [eax+$20],xmm4
 movups [eax+$30],xmm5
 add eax,$40
 loop @LargeAddLoop

@SkipLargeAddLoop:
 pop ecx
 and ecx,$0000000F
 jz @EndAdd

@SmallAddLoop:
 mov edx, [eax]
 and edx, $7FFFFFFF
 cmp edx, c1a
 jle @Weiter
 mov edx, [eax]
 and edx, $80000000
 add edx, c1a
 mov [eax], edx
@Weiter:
 add eax,4
 loop @SmallAddLoop

@EndAdd:
end;

procedure ClipAnalog_SSE(InBuffer: PSingle; Samples: Integer);
const c3:Single = 3;
      c6:Single = 6;
      mm1sgn : array[0..3] of Integer = ($7FFFFFFF,$7FFFFFFF,$7FFFFFFF,$7FFFFFFF);
      mmc2   : array[0..3] of Single = (2,2,2,2);
      mmc3   : array[0..3] of Single = (3,3,3,3);
      mmc6   : array[0..3] of Single = (6,6,6,6);
// a := abs(x); b := 3+a; Result := (x*b)/(a*b+6);
asm
 mov ecx,edx
 push ecx
 shr ecx,2  // number of large iterations = number of elements / 16
 jz @SkipLargeAddLoop
 movups xmm0,mm1sgn
 movups xmm1,mmc3
 movups xmm2,mmc6
 movups xmm3,mmc2
@LargeAddLoop:
 movups xmm4,[eax]  // xmm3 = x
 movaps xmm5,xmm4   // xmm4 = x
 andps xmm5,xmm0    // xmm4 = |x|
 movaps xmm6,xmm5   // xmm5 = |x|
 addps xmm5,xmm1    // xmm4 = |x|+3
 mulps xmm4,xmm5    // xmm3 = x*(|x|+3)
 mulps xmm6,xmm5    // xmm5 = |x|*(|x|+3)
 addps xmm6,xmm2    // xmm5 = |x|*(|x|+3) + 6
 divps xmm4,xmm6    // xmm4 = x*(|x|+3)/(|x|*(|x|+3)+6)
 mulps xmm4,xmm3    // xmm4 = 2*(x*(|x|+3)/(|x|*(|x|+3)+6))
 movups [eax],xmm4

 add eax,$10
 loop @LargeAddLoop

@SkipLargeAddLoop:
 pop ecx
 and ecx,$00000003
 jz @EndAdd

 fld1
 fld1
 faddp

@SmallAddLoop:
 fld [eax].single
 fabs
 fld c3
 fadd st(0),st(1)
 fld st(0)
 fmul [eax].single
 fxch st(2)
 fmulp
 fadd c6.Single
 fdiv
 fmul st(0),st(1)
 fstp [eax].single
 add eax,4
 loop @SmallAddLoop
 ffree st(0)
@EndAdd:
end;

procedure SingleToSingle_SSE(source: PSingle; target: pointer; frames: longint);   // IEEE 754 32 bit float
asm
 push ecx
 shr ecx,5  // number of large iterations = number of elements / 16
 jz @SkipLargeAddLoop
@LargeAddLoop:
 prefetcht0 [eax+$80]
 movups xmm0,[eax    ]
 movups xmm1,[eax+$10]
 movups xmm2,[eax+$20]
 movups xmm3,[eax+$30]
 movups xmm4,[eax+$40]
 movups xmm5,[eax+$50]
 movups xmm6,[eax+$60]
 movups xmm7,[eax+$70]

 // TODO!!!

 movups [edx    ],xmm0
 movups [edx+$10],xmm1
 movups [edx+$20],xmm2
 movups [edx+$30],xmm3
 movups [edx+$40],xmm4
 movups [edx+$50],xmm5
 movups [edx+$60],xmm6
 movups [edx+$70],xmm7

 add eax,$80
 add edx,$80
 loop @LargeAddLoop

@SkipLargeAddLoop:
 pop ecx
 and ecx,$0000001F
 jz @EndAdd

 shr ecx,2 // number of small iterations = (number of elements modulo 16) / 4

@SmallAddLoop:
 movups xmm0,[eax]
 movups [edx],xmm0

 add eax,16
 add edx,16
 dec ecx
 jnz @SmallAddLoop

@EndAdd:
end;

procedure SingleToInt32LSB_SSE(source: PSingle; target: pointer; frames: longint);
asm
 movups xmm7,mmMaxLong

 push ecx
 shr ecx,4  // number of large iterations = number of elements / 16
 jz @SkipLargeAddLoop
@LargeAddLoop:
 movlps xmm0,[eax]
 prefetcht0 [eax+64]
 mulps xmm0,xmm7
 cvttps2pi mm0,xmm0
 movlps xmm1,[eax+8]
 mulps xmm1,xmm7
 cvttps2pi mm1,xmm1

 movlps xmm2,[eax+16]
 mulps xmm2,xmm7
 cvttps2pi mm2,xmm2
 movlps xmm3,[eax+24]
 mulps xmm3,xmm7
 cvttps2pi mm3,xmm3

 movlps xmm4,[eax+32]
 mulps xmm4,xmm7
 cvttps2pi mm4,xmm4
 movlps xmm5,[eax+40]
 mulps xmm5,xmm7
 cvttps2pi mm5,xmm5

 movlps xmm6,[eax+48]
 mulps xmm6,xmm7
 cvttps2pi mm6,xmm6
 movlps xmm6,[eax+56]
 mulps xmm6,xmm7
 cvttps2pi mm7,xmm6

 movntq [edx],mm0
 movntq [edx+8],mm1
 movntq [edx+16],mm2
 movntq [edx+24],mm3
 movntq [edx+32],mm4
 movntq [edx+40],mm5
 movntq [edx+48],mm6
 movntq [edx+56],mm7

 add eax,64
 add edx,64
 dec ecx
 jnz @LargeAddLoop

@SkipLargeAddLoop:
 pop ecx
 and ecx,$0000000F
 jz @EndAdd

 shr ecx,2 // number of small iterations = (number of elements modulo 16) / 4

@SmallAddLoop:
 movlps xmm0,[eax]
 mulps xmm0,xmm7
 cvttps2pi mm0,xmm0
 movlps xmm1,[eax+8]
 mulps xmm1,xmm7
 cvttps2pi mm1,xmm1

 add eax,16
 add edx,16
 dec ecx
 jnz @SmallAddLoop

@EndAdd:
 emms
end;

procedure MixBuffers_SSE(InBuffer:PSingle; MixBuffer:PSingle; samples:integer);
asm
 push ecx
 shr ecx,4  // number of large iterations = number of elements / 16
 jz @SkipLargeAddLoop
@LargeAddLoop:
  movups xmm0,[eax    ]
  movups xmm1,[eax+$10]
  movups xmm2,[eax+$20]
  movups xmm3,[eax+$30]
  movups xmm4,[edx    ]
  movups xmm5,[edx+$10]
  movups xmm6,[edx+$20]
  movups xmm7,[edx+$30]
  addps xmm0,xmm4
  addps xmm1,xmm5
  addps xmm2,xmm6
  addps xmm3,xmm7
  movups [edx    ],xmm0
  movups [edx+$10],xmm1
  movups [edx+$20],xmm2
  movups [edx+$30],xmm3
  add eax,64
  add edx,64
  dec ecx
  jnz @LargeAddLoop

@SkipLargeAddLoop:
  pop ecx
  and ecx,$0000000F
  jz @EndAdd

@AddLoop:
  fld   [eax+4*ecx-4].Single
  fadd  [edx+4*ecx-4].Single
  fstp  [edx+4*ecx-4].Single
  loop @AddLoop

@EndAdd:
end;

{$IFNDEF FPC}
procedure Volume_SSE(InBuffer:PSingle; Volume:Single; samples:integer);
asm
  mov   ecx,samples
  movss xmm4, Volume.Single
  shufps xmm4, xmm4, 0h

  push ecx
  shr ecx,4
  jz @SkipHugeLoop
@HugeLoop:
  movups  xmm0,[eax]
  mulps  xmm0,xmm4
  movups  xmm1,[eax+16]
  mulps  xmm1,xmm4
  movups  xmm2,[eax+32]
  mulps  xmm2,xmm4
  movups  xmm3,[eax+48]
  mulps  xmm3,xmm4

  movups  [eax],xmm0
  movups  [eax+16],xmm1
  movups  [eax+32],xmm2
  movups  [eax+48],xmm3
  add   eax, 64
  loop  @HugeLoop

@SkipHugeLoop:
  pop ecx
  and ecx,$0000000F
  jz @EndSmallLoop

  push ecx
  shr ecx,2
  jz @SkipLargeLoop
@LargeLoop:
  movups  xmm0,[eax]
  mulps  xmm0,xmm4
  movups  [eax],xmm0
  add   eax, 16
  loop  @LargeLoop

@SkipLargeLoop:
  pop ecx
  and ecx,$00000003
  jz @EndSmallLoop

  fld Volume.Single
@SmallLoop:
  fld [eax].single
  fmul st(0),st(1)
  fstp [eax].single
  add eax,4
  loop  @SmallLoop

@EndSmallLoop:
  ffree st(0)
end;
{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// 3DNow //////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

const mmInt      : array[0..1] of integer = ($30000000, $30000000);
      mmDivInt   : array[0..1] of integer = ($4F000000, $4F000000);
      mmInt16    : array[0..1] of Single  = (1/32767, 1/32767);
      mmDivInt16 : array[0..1] of Single  = (32767, 32767);
      mmInt18    : array[0..1] of Single  = (1/131071, 1/131071);
      mmDivInt18 : array[0..1] of Single  = (131071, 131071);
      mmInt20    : array[0..1] of Single  = (1/524287, 1/524287);
      mmDivInt20 : array[0..1] of Single  = (524287, 524287);
      mmInt24    : array[0..1] of Single  = (1/8388607, 1/8388607);
      mmDivInt24 : array[0..1] of Single  = (8388607, 8388607);
      mmSmall    : array[0..1] of integer = ($30000000, $30000000);
      mmDivSmall : array[0..1] of integer = ($4F000000, $4F000000);

procedure SingleToInt16LSB_3DNow(source: PSingle; target: pointer; frames: longint);
var temp64 : array[0..3] of Word;
asm
  femms                     // Fast MMX Enter/Leave
  shr       ecx, 3          // Unroll the loop by 8
  movq      mm4, mmDivSmall // use mm1 as 1/high(integer) divider
  prefetch [eax]            // Holds the total mmx0..7 line in cache
                            // until modified and written
  @Loop2:
  movq      mm0, [eax]      // Spl1 | Spl2
  movq      mm1, [eax + 8]  // Spl3 | Spl4
  movq      mm2, [eax +16]  // Spl5 | Spl7
  movq      mm3, [eax +24]  // Spl7 | Spl8
  pfmul     mm0, mm4        // Multiply by Low(Integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  pf2id     mm0, mm0        // convert to FP
  pf2id     mm1, mm1
  pf2id     mm2, mm2
  pf2id     mm3, mm3
  movq      [temp64], mm0
//  mov       [edx], temp64;
  movq      temp64, mm1
  movq      temp64, mm2
  movq      temp64, mm3
{
  movq      [edx]   , mm0   // Store Sample back to RAM
  movq      [edx+ 8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
}
  add       eax, 32
  add       edx, 32
  prefetch  [eax]           // Inform mmu about next Sample Position
  loop      @Loop2
  femms                     // Fast MMX Enter/Leave
end;

procedure SingleToInt32LSB_3DNow(source: PSingle; target: pointer; frames: longint);
asm
  femms                     // Fast MMX Enter/Leave
  shr       ecx, 3          // Unroll the loop by 8
  movq      mm4, mmDivInt   // use mm1 as 1/high(integer) divider
  prefetch [eax]            // Holds the total mmx0..7 line in cache
                            // until modified and written
  @Loop2:
  movq      mm0, [eax]      // Spl1 | Spl2
  movq      mm1, [eax + 8]  // Spl3 | Spl4
  movq      mm2, [eax +16]  // Spl5 | Spl7
  movq      mm3, [eax +24]  // Spl7 | Spl8
  pfmul     mm0, mm4        // Multiply by Low(Integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  pf2id     mm0, mm0        // convert to FP
  pf2id     mm1, mm1
  pf2id     mm2, mm2
  pf2id     mm3, mm3
  movq      [edx]   , mm0   // Store Sample back to RAM
  movq      [edx+ 8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
  add       eax, 32
  add       edx, 32
  prefetch  [eax]          // Inform mmu about next Sample Position
  loop      @Loop2
  femms                    // Fast MMX Enter/Leave
end;

procedure SingleToInt32LSB16_3DNow(source: PSingle; target: pointer; frames: longint);
asm
  femms                     // Fast MMX Enter/Leave
  shr       ecx, 3          // Unroll the loop by 8
  movq      mm4, mmDivInt16 // use mm1 as 1/high(integer) divider
  prefetch [eax]            // Holds the total mmx0..7 line in cache
                            // until modified and written
  @Loop2:
  movq      mm0, [eax]      // Spl1 | Spl2
  movq      mm1, [eax + 8]  // Spl3 | Spl4
  movq      mm2, [eax +16]  // Spl5 | Spl7
  movq      mm3, [eax +24]  // Spl7 | Spl8
  pfmul     mm0, mm4        // Multiply by Low(Integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  pf2id     mm0, mm0        // convert to FP
  pf2id     mm1, mm1
  pf2id     mm2, mm2
  pf2id     mm3, mm3
  movq      [edx]   , mm0   // Store Sample back to RAM
  movq      [edx+ 8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
  add       eax, 32
  add       edx, 32
  prefetch  [eax]          // Inform mmu about next Sample Position
  loop      @Loop2
  femms                    // Fast MMX Enter/Leave
end;

procedure SingleToInt32LSB18_3DNow(source: PSingle; target: pointer; frames: longint);
asm
  femms                     // Fast MMX Enter/Leave
  shr       ecx, 3          // Unroll the loop by 8
  movq      mm4, mmDivInt18 // use mm1 as 1/high(integer) divider
  prefetch [eax]            // Holds the total mmx0..7 line in cache
                            // until modified and written
  @Loop2:
  movq      mm0, [eax]      // Spl1 | Spl2
  movq      mm1, [eax + 8]  // Spl3 | Spl4
  movq      mm2, [eax +16]  // Spl5 | Spl7
  movq      mm3, [eax +24]  // Spl7 | Spl8
  pfmul     mm0, mm4        // Multiply by Low(Integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  pf2id     mm0, mm0        // convert to FP
  pf2id     mm1, mm1
  pf2id     mm2, mm2
  pf2id     mm3, mm3
  movq      [edx]   , mm0   // Store Sample back to RAM
  movq      [edx+ 8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
  add       eax, 32
  add       edx, 32
  prefetch  [eax]          // Inform mmu about next Sample Position
  loop      @Loop2
  femms                    // Fast MMX Enter/Leave
end;

procedure SingleToInt32LSB20_3DNow(source: PSingle; target: pointer; frames: longint);
asm
  femms                     // Fast MMX Enter/Leave
  shr       ecx, 3          // Unroll the loop by 8
  movq      mm4, mmDivInt20 // use mm1 as 1/high(integer) divider
  prefetch [eax]            // Holds the total mmx0..7 line in cache
                            // until modified and written
  @Loop2:
  movq      mm0, [eax]      // Spl1 | Spl2
  movq      mm1, [eax + 8]  // Spl3 | Spl4
  movq      mm2, [eax +16]  // Spl5 | Spl7
  movq      mm3, [eax +24]  // Spl7 | Spl8
  pfmul     mm0, mm4        // Multiply by Low(Integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  pf2id     mm0, mm0        // convert to FP
  pf2id     mm1, mm1
  pf2id     mm2, mm2
  pf2id     mm3, mm3
  movq      [edx]   , mm0   // Store Sample back to RAM
  movq      [edx+ 8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
  add       eax, 32
  add       edx, 32
  prefetch  [eax]          // Inform mmu about next Sample Position
  loop      @Loop2
  femms                    // Fast MMX Enter/Leave
end;

procedure SingleToInt32LSB24_3DNow(source: PSingle; target: pointer; frames: longint);
asm
  femms                     // Fast MMX Enter/Leave
  shr       ecx, 3          // Unroll the loop by 8
  movq      mm4, mmDivInt24 // use mm1 as 1/high(integer) divider
  prefetch [eax]            // Holds the total mmx0..7 line in cache
                            // until modified and written
  @Loop2:
  movq      mm0, [eax]      // Spl1 | Spl2
  movq      mm1, [eax + 8]  // Spl3 | Spl4
  movq      mm2, [eax +16]  // Spl5 | Spl7
  movq      mm3, [eax +24]  // Spl7 | Spl8
  pfmul     mm0, mm4        // Multiply by Low(Integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  pf2id     mm0, mm0        // convert to FP
  pf2id     mm1, mm1
  pf2id     mm2, mm2
  pf2id     mm3, mm3
  movq      [edx]   , mm0   // Store Sample back to RAM
  movq      [edx+ 8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
  add       eax, 32
  add       edx, 32
  prefetch  [eax]          // Inform mmu about next Sample Position
  loop      @Loop2
  femms                    // Fast MMX Enter/Leave
end;

procedure ToInt16LSB_3DNow(source: pointer; target: PSingle; frames: longint);
asm
  femms                    // Fast MMX Enter/Leave
  shr       ecx, 3         // unroll the loop by 8
  movq      mm4, mmSmall   // use mm4 as 1/high(integer) divider
  prefetchw [eax]          // give the mmu a heads-up,
                           // load the total line of mmx0..7 data in the cache
                           // and prepare for modification. (If I understand AMD correctly)
  @Loop2:
  movq      mm0, [eax]     // Spl1 | Spl2
  movq      mm1, [eax+8]   // Spl3 | Spl4
  movq      mm2, [eax+16]  // Spl5 | Spl7
  movq      mm3, [eax+24]  // Spl7 | Spl8
  pi2fd     mm0, mm0       // convert to FP
  pi2fd     mm1, mm1
  pi2fd     mm2, mm2
  pi2fd     mm3, mm3
  pfmul     mm0, mm4       // divide by high(integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  movq      [edx], mm0     // Store Sample back to RAM
  movq      [edx+8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
  add       eax, 32
  add       edx, 32
  prefetchw [eax]          // Inform mmu about next Sample Position
  loop      @Loop2
  femms                    // Fast MMX Enter/Leave
end;

procedure ToInt32LSB_3DNow(source: pointer; target: PSingle; frames: longint);
asm
  femms                    // Fast MMX Enter/Leave
  shr       ecx, 3         // unroll the loop by 8
  movq      mm4, mmInt     // use mm4 as 1/high(integer) divider
  prefetchw [eax]          // give the mmu a heads-up,
                           // load the total line of mmx0..7 data in the cache
                           // and prepare for modification. (If I understand AMD correctly)
  @Loop2:
  movq      mm0, [eax]     // Spl1 | Spl2
  movq      mm1, [eax+8]   // Spl3 | Spl4
  movq      mm2, [eax+16]  // Spl5 | Spl7
  movq      mm3, [eax+24]  // Spl7 | Spl8
  pi2fd     mm0, mm0       // convert to FP
  pi2fd     mm1, mm1
  pi2fd     mm2, mm2
  pi2fd     mm3, mm3
  pfmul     mm0, mm4       // divide by high(integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  movq      [edx], mm0     // Store Sample back to RAM
  movq      [edx+8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
  add       eax, 32
  add       edx, 32
  prefetchw [eax]          // Inform mmu about next Sample Position
  loop      @Loop2
  femms                    // Fast MMX Enter/Leave
end;

procedure ToInt32LSB16_3DNow(source: pointer; target: PSingle; frames: longint);
asm
  femms                    // Fast MMX Enter/Leave
  shr       ecx, 3         // unroll the loop by 8
  movq      mm4, mmInt16   // use mm4 as 1/high(integer) divider
  prefetchw [eax]          // give the mmu a heads-up,
                           // load the total line of mmx0..7 data in the cache
                           // and prepare for modification. (If I understand AMD correctly)
  @Loop2:
  movq      mm0, [eax]     // Spl1 | Spl2
  movq      mm1, [eax+8]   // Spl3 | Spl4
  movq      mm2, [eax+16]  // Spl5 | Spl7
  movq      mm3, [eax+24]  // Spl7 | Spl8
  pi2fd     mm0, mm0       // convert to FP
  pi2fd     mm1, mm1
  pi2fd     mm2, mm2
  pi2fd     mm3, mm3
  pfmul     mm0, mm4       // divide by high(integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  movq      [edx], mm0     // Store Sample back to RAM
  movq      [edx+8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
  add       eax, 32
  add       edx, 32
  prefetchw [eax]          // Inform mmu about next Sample Position
  loop      @Loop2
  femms                    // Fast MMX Enter/Leave
end;

procedure ToInt32LSB18_3DNow(source: pointer; target: PSingle; frames: longint);
asm
  femms                    // Fast MMX Enter/Leave
  shr       ecx, 3         // unroll the loop by 8
  movq      mm4, mmInt18   // use mm4 as 1/high(integer) divider
  prefetchw [eax]          // give the mmu a heads-up,
                           // load the total line of mmx0..7 data in the cache
                           // and prepare for modification. (If I understand AMD correctly)
  @Loop2:
  movq      mm0, [eax]     // Spl1 | Spl2
  movq      mm1, [eax+8]   // Spl3 | Spl4
  movq      mm2, [eax+16]  // Spl5 | Spl7
  movq      mm3, [eax+24]  // Spl7 | Spl8
  pi2fd     mm0, mm0       // convert to FP
  pi2fd     mm1, mm1
  pi2fd     mm2, mm2
  pi2fd     mm3, mm3
  pfmul     mm0, mm4       // divide by high(integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  movq      [edx], mm0     // Store Sample back to RAM
  movq      [edx+8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
  add       eax, 32
  add       edx, 32
  prefetchw [eax]          // Inform mmu about next Sample Position
  loop      @Loop2
  femms                    // Fast MMX Enter/Leave
end;

procedure ToInt32LSB20_3DNow(source: pointer; target: PSingle; frames: longint);
asm
  femms                    // Fast MMX Enter/Leave
  shr       ecx, 3         // unroll the loop by 8
  movq      mm4, mmInt20   // use mm4 as 1/high(integer) divider
  prefetchw [eax]          // give the mmu a heads-up,
                           // load the total line of mmx0..7 data in the cache
                           // and prepare for modification. (If I understand AMD correctly)
  @Loop2:
  movq      mm0, [eax]     // Spl1 | Spl2
  movq      mm1, [eax+8]   // Spl3 | Spl4
  movq      mm2, [eax+16]  // Spl5 | Spl7
  movq      mm3, [eax+24]  // Spl7 | Spl8
  pi2fd     mm0, mm0       // convert to FP
  pi2fd     mm1, mm1
  pi2fd     mm2, mm2
  pi2fd     mm3, mm3
  pfmul     mm0, mm4       // divide by high(integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  movq      [edx], mm0     // Store Sample back to RAM
  movq      [edx+8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
  add       eax, 32
  add       edx, 32
  prefetchw [eax]          // Inform mmu about next Sample Position
  loop      @Loop2
  femms                    // Fast MMX Enter/Leave
end;

procedure ToInt32LSB24_3DNow(source: pointer; target: PSingle; frames: longint);
asm
  femms                    // Fast MMX Enter/Leave
  shr       ecx, 3         // unroll the loop by 8
  movq      mm4, mmInt24   // use mm4 as 1/high(integer) divider
  prefetchw [eax]          // give the mmu a heads-up,
                           // load the total line of mmx0..7 data in the cache
                           // and prepare for modification. (If I understand AMD correctly)
  @Loop2:
  movq      mm0, [eax]     // Spl1 | Spl2
  movq      mm1, [eax+8]   // Spl3 | Spl4
  movq      mm2, [eax+16]  // Spl5 | Spl7
  movq      mm3, [eax+24]  // Spl7 | Spl8
  pi2fd     mm0, mm0       // convert to FP
  pi2fd     mm1, mm1
  pi2fd     mm2, mm2
  pi2fd     mm3, mm3
  pfmul     mm0, mm4       // divide by high(integer)
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  movq      [edx], mm0     // Store Sample back to RAM
  movq      [edx+8], mm1
  movq      [edx+16], mm2
  movq      [edx+24], mm3
  add       eax, 32
  add       edx, 32
  prefetchw [eax]          // Inform mmu about next Sample Position
  loop      @Loop2
  femms                    // Fast MMX Enter/Leave
end;

procedure MixBuffers_3DNow(InBuffer:PSingle; MixBuffer:PSingle; samples:integer);
asm
  femms
  shr       ecx, 3
  prefetchw [eax]
@Start:
  movq      mm0, [eax]
  movq      mm1, [eax+8]
  movq      mm2, [eax+16]
  movq      mm3, [eax+24]
  movq      mm4, [edx]
  movq      mm5, [edx+8]
  movq      mm6, [edx+16]
  movq      mm7, [edx+24]
  pfadd     mm4, mm0
  pfadd     mm5, mm1
  pfadd     mm6, mm2
  pfadd     mm7, mm3
  movq      [edx], mm4
  movq      [edx+8], mm5
  movq      [edx+16], mm6
  movq      [edx+24], mm7
  add       eax, 32
  add       edx, 32
  prefetchw [eax]          // Inform mmu about next Sample Position
  loop  @Start
  femms
end;

procedure Volume_3DNow(InBuffer:PSingle; Volume:Single; samples:integer);
var volArray : array[0..1] of Single;
asm
  fld       Volume.Single
  fst       [volArray].Single
  fst       [volArray+4].Single
  mov       ecx, samples
  shr       ecx, 3
  push      ecx
  jz        @SkipLargeLoop

  femms
  movq      mm4, volArray

  prefetchw [eax]
@LargeLoop:
  movq      mm0, [eax]
  movq      mm1, [eax+8]
  movq      mm2, [eax+16]
  movq      mm3, [eax+24]
  pfmul     mm0, mm4
  pfmul     mm1, mm4
  pfmul     mm2, mm4
  pfmul     mm3, mm4
  movq      [eax], mm0
  movq      [eax+8], mm1
  movq      [eax+16], mm2
  movq      [eax+24], mm3
  add       eax, 32
  add       edx, 32
  prefetchw [eax]
  loop      @LargeLoop
  femms
@SkipLargeLoop:
  pop ecx
  and ecx,$00000007
  jz @EndSmallLoop

  fld Volume.Single
@SmallLoop:
  fld [eax].single
  fmul st(0),st(1)
  fstp [eax].single
  add eax,4
  loop  @SmallLoop

@EndSmallLoop:
  ffree st(0)
end;

{$ENDIF}

////////////////////////////////////////////////////////////////////////////////
///////////////////////////////// Selection ////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

procedure Use_FPU;
begin
  FromInt16MSB.ic32    := Int16MSBToSingle_FPU;
  FromInt24MSB.ic32    := Int24MSBToSingle_FPU;
  FromInt32MSB.ic32    := Int32MSBToSingle_FPU;
  FromSingleMSB.ic32   := SingleMSBToSingle_FPU;
  FromDoubleMSB.ic32   := DoubleMSBToSingle_FPU;
  FromInt32MSB16.ic32  := Int32MSB16ToSingle_FPU;
  FromInt32MSB18.ic32  := Int32MSB18ToSingle_FPU;
  FromInt32MSB20.ic32  := Int32MSB20ToSingle_FPU;
  FromInt32MSB24.ic32  := Int32MSB24ToSingle_FPU;
  FromInt16LSB.ic32    := Int16LSBToSingle_FPU;
  FromInt24LSB.ic32    := Int24LSBToSingle_FPU;
  FromInt32LSB.ic32    := Int32LSBToSingle_FPU;
  FromSingleLSB.ic32   := SingleLSBToSingle_FPU;
  FromDoubleLSB.ic32   := DoubleLSBToSingle_FPU;
  FromInt32LSB16.ic32  := Int32LSB16ToSingle_FPU;
  FromInt32LSB18.ic32  := Int32LSB18ToSingle_FPU;
  FromInt32LSB20.ic32  := Int32LSB20ToSingle_FPU;
  FromInt32LSB24.ic32  := Int32LSB24ToSingle_FPU;
  /////////////////////////////////////////////
  FromInt16MSB.ic64    := Int16MSBToDouble_FPU;
  FromInt24MSB.ic64    := Int24MSBToDouble_FPU;
  FromInt32MSB.ic64    := Int32MSBToDouble_FPU;
  FromSingleMSB.ic64   := SingleMSBToDouble_FPU;
  FromDoubleMSB.ic64   := DoubleMSBToDouble_FPU;
  FromInt32MSB16.ic64  := Int32MSB16ToDouble_FPU;
  FromInt32MSB18.ic64  := Int32MSB18ToDouble_FPU;
  FromInt32MSB20.ic64  := Int32MSB20ToDouble_FPU;
  FromInt32MSB24.ic64  := Int32MSB24ToDouble_FPU;
  FromInt16LSB.ic64    := Int16LSBToDouble_FPU;
  FromInt24LSB.ic64    := Int24LSBToDouble_FPU;
  FromInt32LSB.ic64    := Int32LSBToDouble_FPU;
  FromSingleLSB.ic64   := SingleLSBToDouble_FPU;
  FromDoubleLSB.ic64   := DoubleLSBToDouble_FPU;
  FromInt32LSB16.ic64  := Int32LSB16ToDouble_FPU;
  FromInt32LSB18.ic64  := Int32LSB18ToDouble_FPU;
  FromInt32LSB20.ic64  := Int32LSB20ToDouble_FPU;
  FromInt32LSB24.ic64  := Int32LSB24ToDouble_FPU;
  ///////////////////////////////////////////////
  ToInt16MSB.oc32      := SingleToInt16MSB_FPU;
  ToInt24MSB.oc32      := SingleToInt24MSB_FPU;
  ToInt32MSB.oc32      := SingleToInt32MSB_FPU;
  ToSingleMSB.oc32     := SingleToSingleMSB_FPU;
  ToDoubleMSB.oc32     := SingleToDoubleMSB_FPU;
  ToInt32MSB16.oc32    := SingleToInt32MSB16_FPU;
  ToInt32MSB18.oc32    := SingleToInt32MSB18_FPU;
  ToInt32MSB20.oc32    := SingleToInt32MSB20_FPU;
  ToInt32MSB24.oc32    := SingleToInt32MSB24_FPU;
  ToInt16LSB.oc32      := SingleToInt16LSB_FPU;
  ToInt24LSB.oc32      := SingleToInt24LSB_FPU;
  ToInt32LSB.oc32      := SingleToInt32LSB_FPU;
  ToSingleLSB.oc32     := SingleToSingleLSB_FPU;
  ToDoubleLSB.oc32     := SingleToDoubleLSB_FPU;
  ToInt32LSB16.oc32    := SingleToInt32LSB16_FPU;
  ToInt32LSB18.oc32    := SingleToInt32LSB18_FPU;
  ToInt32LSB20.oc32    := SingleToInt32LSB20_FPU;
  ToInt32LSB24.oc32    := SingleToInt32LSB24_FPU;
  ///////////////////////////////////////////////
  ToInt16MSB.oc64      := DoubleToInt16MSB_FPU;
  ToInt24MSB.oc64      := DoubleToInt24MSB_FPU;
  ToInt32MSB.oc64      := DoubleToInt32MSB_FPU;
  ToSingleMSB.oc64     := DoubleToSingleMSB_FPU;
  ToDoubleMSB.oc64     := DoubleToDoubleMSB_FPU;
  ToInt32MSB16.oc64    := DoubleToInt32MSB16_FPU;
  ToInt32MSB18.oc64    := DoubleToInt32MSB18_FPU;
  ToInt32MSB20.oc64    := DoubleToInt32MSB20_FPU;
  ToInt32MSB24.oc64    := DoubleToInt32MSB24_FPU;
  ToInt16LSB.oc64      := DoubleToInt16LSB_FPU;
  ToInt24LSB.oc64      := DoubleToInt24LSB_FPU;
  ToInt32LSB.oc64      := DoubleToInt32LSB_FPU;
  ToSingleLSB.oc64     := DoubleToSingleLSB_FPU;
  ToDoubleLSB.oc64     := DoubleToDoubleLSB_FPU;
  ToInt32LSB16.oc64    := DoubleToInt32LSB16_FPU;
  ToInt32LSB18.oc64    := DoubleToInt32LSB18_FPU;
  ToInt32LSB20.oc64    := DoubleToInt32LSB20_FPU;
  ToInt32LSB24.oc64    := DoubleToInt32LSB24_FPU;
  MixBuffers.mb32      := MixBuffers_FPU;
  MixBuffers.mb64      := MixBuffers_FPU;
  Volume.v32           := Volume_FPU;
  Volume.v64           := Volume_FPU;
  ClipDigital.cb32     := ClipDigital_x86;
  ClipDigital.cb64     := ClipDigital_x86;
  ClipAnalog.cb32      := ClipAnalog_FPU;
  ClipAnalog.cb64      := ClipAnalog_FPU;
  FadeInLinear.v32     := FadeInLinear_FPU;
  FadeInLinear.v64     := FadeInLinear_FPU;
  FadeOutLinear.v32    := FadeOutLinear_FPU;
  FadeOutLinear.v64    := FadeOutLinear_FPU;
  FadeLinear.v32       := FadeLinear_FPU;
  FadeLinear.v64       := FadeLinear_FPU;
  FadeExponential.v32  := FadeExponential_FPU;
  FadeExponential.v64  := FadeExponential_FPU;
  Trigger.v32          := Trigger_FPU;
  Trigger.v64          := Trigger_FPU;

  ClipCheckInt16MSB    := ClipCheckInt16MSB_FPU;
  ClipCheckInt24MSB    := ClipCheckInt24MSB_FPU;
  ClipCheckInt32MSB    := ClipCheckInt32MSB_FPU;
  ClipCheckSingleMSB   := ClipCheckSingleMSB_FPU;
  ClipCheckDoubleMSB   := ClipCheckDoubleMSB_FPU;
  ClipCheckInt32MSB16  := ClipCheckInt32MSB16_FPU;
  ClipCheckInt32MSB18  := ClipCheckInt32MSB18_FPU;
  ClipCheckInt32MSB20  := ClipCheckInt32MSB20_FPU;
  ClipCheckInt32MSB24  := ClipCheckInt32MSB24_FPU;
  ClipCheckInt16LSB    := ClipCheckInt16LSB_FPU;
  ClipCheckInt24LSB    := ClipCheckInt24LSB_FPU;
  ClipCheckInt32LSB    := ClipCheckInt32LSB_FPU;
  ClipCheckSingleLSB   := ClipCheckSingleLSB_FPU;
  ClipCheckDoubleLSB   := ClipCheckDoubleLSB_FPU;
  ClipCheckInt32LSB16  := ClipCheckInt32LSB16_FPU;
  ClipCheckInt32LSB18  := ClipCheckInt32LSB18_FPU;
  ClipCheckInt32LSB20  := ClipCheckInt32LSB20_FPU;
  ClipCheckInt32LSB24  := ClipCheckInt32LSB24_FPU;
end;

procedure Use_FPU_UDF;
begin
 Use_FPU;
 RandSeed := GetTickCount;
 ToInt16LSB.oc32      := SingleToInt16LSB_UDF_FPU;
 ToInt24LSB.oc32      := SingleToInt24LSB_UDF_FPU;
 ToInt32LSB16.oc32    := SingleToInt32LSB16_UDF_FPU;
 ToInt32LSB18.oc32    := SingleToInt32LSB18_UDF_FPU;
 ToInt32LSB20.oc32    := SingleToInt32LSB20_UDF_FPU;
 ToInt32LSB24.oc32    := SingleToInt32LSB24_UDF_FPU;
 ///////////////////////////////////////////////
 ToInt16LSB.oc64      := DoubleToInt16LSB_UDF_FPU;
 ToInt24LSB.oc64      := DoubleToInt24LSB_UDF_FPU;
 ToInt32LSB16.oc64    := DoubleToInt32LSB16_UDF_FPU;
 ToInt32LSB18.oc64    := DoubleToInt32LSB18_UDF_FPU;
 ToInt32LSB20.oc64    := DoubleToInt32LSB20_UDF_FPU;
 ToInt32LSB24.oc64    := DoubleToInt32LSB24_UDF_FPU;
end;

procedure Use_FPU_TDF;
begin
 Use_FPU;
 RandSeed := GetTickCount;
 ToInt16LSB.oc32      := SingleToInt16LSB_TDF_FPU;
 ToInt24LSB.oc32      := SingleToInt24LSB_TDF_FPU;
 ToInt32LSB16.oc32    := SingleToInt32LSB16_TDF_FPU;
 ToInt32LSB18.oc32    := SingleToInt32LSB18_TDF_FPU;
 ToInt32LSB20.oc32    := SingleToInt32LSB20_TDF_FPU;
 ToInt32LSB24.oc32    := SingleToInt32LSB24_TDF_FPU;
 ///////////////////////////////////////////////
 ToInt16LSB.oc64      := DoubleToInt16LSB_TDF_FPU;
 ToInt24LSB.oc64      := DoubleToInt24LSB_TDF_FPU;
 ToInt32LSB16.oc64    := DoubleToInt32LSB16_TDF_FPU;
 ToInt32LSB18.oc64    := DoubleToInt32LSB18_TDF_FPU;
 ToInt32LSB20.oc64    := DoubleToInt32LSB20_TDF_FPU;
 ToInt32LSB24.oc64    := DoubleToInt32LSB24_TDF_FPU;
end;

procedure Use_SSE;
begin
 {$IFNDEF DELPHI5}
// ToInt32LSB.oc32 := SingleToInt32LSB_SSE;
 MixBuffers.mb32   := MixBuffers_SSE;
 ClipDigital.cb32  := ClipDigital_SSE;
 ClipAnalog.cb32   := ClipAnalog_SSE;
 {$IFNDEF FPC}
 Volume.v32        := Volume_SSE;
 {$ENDIF}
 {$ENDIF}
end;

procedure Use_3DNow;
begin
 {$IFNDEF DELPHI5}
{
 ToInt16LSB := SingleToInt16LSB_3DNow;
 FromInt16LSB := ToInt16LSB_3DNow;
 ToInt24LSB := SingleToInt24LSB_3DNow;
 FromInt24LSB := ToInt24LSB_3DNow;
}
 ToInt32LSB.oc32     := SingleToInt32LSB_3DNow;
 FromInt32LSB.ic32   := ToInt32LSB_3DNow;
 ToInt32LSB16.oc32   := SingleToInt32LSB16_3DNow;
 FromInt32LSB16.ic32 := ToInt32LSB16_3DNow;
 ToInt32LSB18.oc32   := SingleToInt32LSB18_3DNow;
 FromInt32LSB18.ic32 := ToInt32LSB18_3DNow;
 ToInt32LSB20.oc32   := SingleToInt32LSB20_3DNow;
 FromInt32LSB20.ic32 := ToInt32LSB20_3DNow;
 ToInt32LSB24.oc32   := SingleToInt32LSB24_3DNow;
 FromInt32LSB24.ic32 := ToInt32LSB24_3DNow;
 MixBuffers.mb32     := MixBuffers_3DNow;
 Volume.v32          := Volume_3DNow;
 {$ENDIF}
end;

initialization
 Use_FPU;
 {$IFNDEF FPC}
 try
  ProcessorType := ptFPU;
  asm
   mov eax, 1
   db $0F,$A2
   test edx,2000000h
   jnz @SSEFound
   mov ProcessorType, 0
   jmp @END_SSE
  @SSEFound:
   mov ProcessorType, 1
  @END_SSE:
  end;
 except
  ProcessorType := ptFPU;
 end;

 if ProcessorType = ptSSE then Use_SSE;
 asm
  mov eax, 80000000h
  db $0F,$A2
  cmp eax, 80000000h
  jbe @NO_EXTENDED
  mov eax, 80000001h
  db $0F, $A2
  test edx, 80000000h
  jz @NO_3DNow
  mov ProcessorType, 2
  jmp @END_3DNow
 @NO_EXTENDED:
 @NO_3DNow:
  jmp @END_3DNow
 @END_3DNow:
 end;
 if ProcessorType = pt3DNow then Use_3DNow;
 {$ENDIF}
 
end.
