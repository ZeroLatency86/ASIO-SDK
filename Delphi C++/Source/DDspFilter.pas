unit DDspFilter;

interface

{$I ASIOVST.INC}

uses
  Classes, DDspBaseComponent, DAVDComplex, DAVDCommon;

type
  TPNType = array[0..1] of TComplexSingle;

  TFilter = class(TPersistent)
  private
  protected
    fGain        : Double;
    fGainSpeed   : Double;
    fFrequency   : Double;
    fSinW0, fW0  : Double;
    fSampleRate  : Double;
    fSRR         : Double; // reciprocal of fSampleRate
    procedure SetW0; virtual;
    procedure SetGain(const Value:Double); virtual;
    procedure SetFrequency(const Value:Double); virtual;
    procedure SetSampleRate(const Value: Double); virtual;
    procedure SetOrder(Value: Integer); virtual; abstract;
    function GetOrder: Integer; virtual; abstract;
    procedure CalculateCoefficients; virtual; abstract;
  public
    constructor Create; virtual;
    function ProcessSample(const Input:Double):Double; overload; virtual; abstract;
    function ProcessSample(const Input:Int64):Int64; overload; virtual; abstract;
    function ProcessSampleASM:Double; virtual;
    function MagnitudeSquared(Frequency:Double):Double; virtual; abstract;
    function MagnitudeLog10(Frequency:Double):Double; virtual; abstract;
    function Phase(Frequency:Double):Double; virtual; abstract;
    function Real(Frequency:Double):Double; virtual; abstract;
    function Imaginary(Frequency:Double):Double; virtual; abstract;
    procedure Complex(Frequency:Double; out Real, Imaginary : Double); overload; virtual; abstract;
    procedure Complex(Frequency:Double; out Real, Imaginary : Single); overload; virtual; abstract;
    procedure ResetStates; virtual; abstract;
    procedure ResetStatesInt64; virtual; abstract;
    procedure Reset; virtual; abstract;
    procedure GetIR(ImpulseResonse : TAVDSingleDynArray); overload; virtual; abstract;
    procedure GetIR(ImpulseResonse : TAVDDoubleDynArray); overload; virtual; abstract;
    procedure PushStates; virtual; abstract;
    procedure PopStates; virtual; abstract;

    property GainSpeed: Double read fGainSpeed;
    property SampleRateReciprocal : Double read fSRR;
    property SinW0: Double read fSinW0;
    property W0: Double read fW0;
  published
    property Gain: Double read fGain write SetGain;
    property Frequency: Double read fFrequency write SetFrequency;
    property SampleRate: Double read fSampleRate write SetSampleRate;
    property Order: Integer read GetOrder write SetOrder;
  end;

  TIIRFilter=class(TFilter)
  private
  protected
    fBandWidth   : Double;
    fAlpha       : Double;
    procedure SetW0; override;
    procedure SetBW(const value:Double); virtual;
    procedure SetAlpha; virtual;
  public
    constructor Create; override;
    procedure GetIR(ImpulseResonse : TAVDSingleDynArray); overload; override;
    procedure GetIR(ImpulseResonse : TAVDDoubleDynArray); overload; override;
  published
    property Bandwidth: Double read fBandWidth write SetBW;
  end;

  TBiquadIIRFilter=class(TIIRFilter)
  protected
    fDenominator  : array[1..2] of Double;
    fNominator    : array[0..2] of Double;
    fPoles        : TPNType;
    fZeros        : TPNType;
    fState        : array[0..1] of Double;
    fStateStack   : array of array[0..1] of Double;
    procedure CalcPolesZeros; virtual;
    function GetPoles:TPNType;
    function GetZeros:TPNType;
    function GetOrder: Integer; override;
    procedure SetOrder(Value: Integer); override;
  public
    constructor Create; override;
    procedure ResetStates; override;
    procedure ResetStatesInt64; override;
    function ProcessSample(const Input:Double):Double; override;
    function ProcessSample(const Input:Int64):Int64; override;
    function ProcessSampleASM:Double; override;
    function MagnitudeSquared(Frequency: Double):Double; override;
    function MagnitudeLog10(Frequency: Double):Double; override;
    function Phase(Frequency: Double):Double; override;
    function Real(Frequency: Double):Double; override;
    function Imaginary(Frequency: Double):Double; override;
    procedure Complex(Frequency: Double; out Real, Imaginary : Double); overload; override;
    procedure Complex(Frequency: Double; out Real, Imaginary : Single); overload; override;
    procedure Reset; override;
    procedure PushStates; override;
    procedure PopStates; override;
    property Poles: TPNType read fPoles; //GetPoles;
    property Zeros: TPNType read fZeros; //GetZeros;
  published
  end;

  TSimpleGainFilter=class(TBiquadIIRFilter)
  protected
    procedure CalculateCoefficients; override;
  public
    function ProcessSample(const Input: Double): Double; override;
    function ProcessSampleASM: Double; override;
  end;

  TSimplePeakFilter=class(TBiquadIIRFilter)
  protected
    procedure CalculateCoefficients; override;
  end;

  TSimpleLowShelfFilter=class(TBiquadIIRFilter)
  protected
    procedure CalculateCoefficients; override;
  end;

  TSimpleHighShelfFilter=class(TBiquadIIRFilter)
  protected
    procedure CalculateCoefficients; override;
  end;

  TSimpleHighcutFilter=class(TBiquadIIRFilter)
  protected
    procedure CalculateCoefficients; override;
  end;

  TSimpleLowcutFilter=class(TBiquadIIRFilter)
  protected
    procedure CalculateCoefficients; override;
  end;

  TSimpleLowpassFilter=class(TSimpleHighcutFilter);
  TSimpleHighpassFilter=class(TSimpleLowcutFilter);

  TSimpleBandpass=class(TBiquadIIRFilter)
  protected
    procedure CalculateCoefficients; override;
  end;

  TSimpleNotch=class(TBiquadIIRFilter)
  protected
    procedure CalculateCoefficients; override;
  end;

  TDspLowpassFilter = class(TDspBaseComponent)
  private
    fFrequency: Single;
    fFilter : Array of TSimpleLowpassFilter;
    procedure SetFrequency(const Value: Single);
  protected
    procedure SampleRateChanged; override;
    procedure ChannelsChanged; override;
  published
  public
    procedure Init; override;
    procedure Reset; override;
    procedure Process(var Data: Single; const channel: integer); overload;
    procedure Process(var Data: Double; const channel: integer); overload;
  published
    property Frequency: Single read fFrequency write SetFrequency;  // 20..20000
  end;

implementation

uses Math;

{ TFilter }

constructor TFilter.Create;
begin
 fGain := 0; fGainSpeed := 1;
 SampleRate := 44100;
 fFrequency := 1000;
 SetW0;
end;

function TFilter.ProcessSampleASM: Double;
{$IFDEF PUREPASCAL}
begin
end;
{$ELSE}
asm
 push eax
 push ecx
 push edx
 fstp [esp-4].Single
 push dword ptr [esp-4]
 mov edx,[eax]
 call dword ptr [edx+$24] // ProcessSample
 pop edx
 pop ecx
 pop eax
end;
{$ENDIF}

procedure TFilter.SetFrequency(const Value:Double);
begin
 if fFrequency <> Value then
  begin
   if Value>0
    then fFrequency := Value
    else fFrequency := 1;
  end;
 SetW0;
 CalculateCoefficients;
end;

procedure TFilter.SetGain(const Value:Double);
begin
 fGain := Value;
 fGainSpeed := dB_to_Amp(0.5 * fGain);
 CalculateCoefficients;
end;

procedure TFilter.SetSampleRate(const Value: Double);
begin
 fSampleRate := Value;
 fSRR :=  1 / fSampleRate;
end;

procedure TFilter.SetW0;
begin
 fW0 := 2*Pi*fFrequency*fSRR;
 fSinW0 := sin(fW0);
 if fW0>3.1
  then fW0 := 3.1;
end;

{ TIIRFilter }

constructor TIIRFilter.Create;
begin
 fBandWidth := 1;
 SetAlpha;
 inherited;
end;

procedure TIIRFilter.GetIR(ImpulseResonse: TAVDSingleDynArray);
var i : Integer;
begin
 if Length(ImpulseResonse)=0 then Exit;
 PushStates;
 ImpulseResonse[0] := ProcessSample(1.0);
 for i := 1 to Length(ImpulseResonse)-1
  do ImpulseResonse[i] := ProcessSample(0.0);
 PopStates;
end;

procedure TIIRFilter.GetIR(ImpulseResonse: TAVDDoubleDynArray);
var i : Integer;
begin
 if Length(ImpulseResonse)=0 then Exit;
 PushStates;
 ImpulseResonse[0] := ProcessSample(1.0);
 for i := 1 to Length(ImpulseResonse)-1
  do ImpulseResonse[i] := ProcessSample(0.0);
 PopStates;
end;

procedure TIIRFilter.SetAlpha;
begin
 if (fSinW0=0)
  then fAlpha := fSinW0 /( 2 * fBandWidth)
  else fAlpha := Sinh(ln22 * cos(fW0 * 0.5) * fBandWidth * (fW0 / fSinW0)) * fSinW0;
end;

procedure TIIRFilter.SetBW(const Value: Double);
begin
 if Value<=0
  then fBandWidth := 0.01
  else fBandWidth := Value;
 SetAlpha;
 CalculateCoefficients;
end;

procedure TIIRFilter.SetW0;
begin
 inherited;
 SetAlpha;
end;

{ TBiquadIIRFilter }

constructor TBiquadIIRFilter.create;
begin
 fGain := 0;
 fGainSpeed := 1;
 fFrequency := 1000;
 fBandWidth := 1;
 fSampleRate := 44100;
 fSRR := 1/44100;
 ResetStates;
end;

function TBiquadIIRFilter.MagnitudeSquared(Frequency:Double):Double;
var cw : Double;
begin
 cw := 2*cos(2 * Frequency*pi*fSRR);
 Result := sqrt((sqr(fNominator[0]-fNominator[2])+sqr(fNominator[1])+(fNominator[1]*(fNominator[0]+fNominator[2])+fNominator[0]*fNominator[2]*cw)*cw)
             /(sqr(1-fDenominator[2])+sqr(fDenominator[1])+(fDenominator[1]*(fDenominator[2]+1)+cw*fDenominator[2])*cw ));
end;

function TBiquadIIRFilter.MagnitudeLog10(Frequency: Double): Double;
var cw : Double;
begin
 cw := 2*cos(2 * Frequency*pi*fSRR);
 Result := 10*log10((sqr(fNominator[0]-fNominator[2])+sqr(fNominator[1])+(fNominator[1]*(fNominator[0]+fNominator[2])+fNominator[0]*fNominator[2]*cw)*cw)
                 /(sqr(1-fDenominator[2])+sqr(fDenominator[1])+(fDenominator[1]*(fDenominator[2]+1)+cw*fDenominator[2])*cw ));
end;

function TBiquadIIRFilter.Phase(Frequency:Double):Double;
var cw, sw : Double;
begin
 GetSinCos(2 * Frequency*pi*fSRR,sw,cw);
 Result := ArcTan2(-sw*(fNominator[0]*(2*cw*fDenominator[2]+fDenominator[1])+fNominator[1]*(fDenominator[2]-1)-fNominator[2]*(2*cw+fDenominator[1])),
                     (fNominator[0]*(fDenominator[2]*(2*sqr(cw)-1)+1+fDenominator[1]*cw)+fNominator[1]*(cw*fDenominator[2]+cw+fDenominator[1])+fNominator[2]*(2*sqr(cw)+fDenominator[1]*cw+fDenominator[2]-1)));
end;

function TBiquadIIRFilter.Real(Frequency: Double): Double;
var cw : Double;
begin
 cw := cos(2 * Frequency * pi * fSRR);
 Real      := (fNominator[0] + fNominator[1] * fDenominator[1] + fNominator[2] * fDenominator[2]
              +        cw     * (fNominator[1] * (1 + fDenominator[2]) + fDenominator[1] * (fNominator[2] + fNominator[0]))
              + (2*sqr(cw)-1) * (fNominator[0] * fDenominator[2] + fNominator[2]))
              / ( sqr(fDenominator[2]) - 2 * fDenominator[2] + sqr(fDenominator[1]) + 1
              + 2 * cw * (fDenominator[1] * (fDenominator[2] + 1) + 2 * cw * fDenominator[2]));
end;

function TBiquadIIRFilter.Imaginary(Frequency: Double): Double;
var cw : Double;
begin
 cw := cos(2 * Frequency * pi * fSRR);
 Imaginary := (fDenominator[1] * (fNominator[2] - fNominator[0]) + fNominator[1] * (1 - fDenominator[2])
              + 2 * cw * (fNominator[2] - fNominator[0] * fDenominator[2])) * sqrt(1 - sqr(cw))
              / ( sqr(fDenominator[2]) - 2 * fDenominator[2] + sqr(fDenominator[1]) + 1
              + 2 * cw * (fDenominator[1] * (fDenominator[2] + 1) + 2 * cw * fDenominator[2]))
end;

procedure TBiquadIIRFilter.Complex(Frequency: Double; out Real, Imaginary: Double);
var cw, Divider : Double;
begin
 cw := cos(2 * Frequency * pi * fSRR);
 Divider   := 1 / ( sqr(fDenominator[2]) - 2 * fDenominator[2] + sqr(fDenominator[1]) + 1
                    + 2 * cw * (fDenominator[1] * (fDenominator[2] + 1) + 2 * cw * fDenominator[2]));
 Real      := (fNominator[0] + fNominator[1] * fDenominator[1] + fNominator[2] * fDenominator[2]
              +        cw     * (fNominator[1] * (1 + fDenominator[2]) + fDenominator[1] * (fNominator[2] + fNominator[0]))
              + (2*sqr(cw)-1) * (fNominator[0] * fDenominator[2] + fNominator[2])) * Divider;
 Imaginary := (fDenominator[1] * (fNominator[2] - fNominator[0]) + fNominator[1] * (1 - fDenominator[2])
              + 2 * cw * (fNominator[2] - fNominator[0] * fDenominator[2])) * sqrt(1 - sqr(cw)) * Divider;
end;

procedure TBiquadIIRFilter.Complex(Frequency: Double; out Real, Imaginary: Single);
var cw, Divider : Double;
begin
 cw := cos(2 * Frequency * pi * fSRR);
 Divider   := 1 / ( sqr(fDenominator[2]) - 2 * fDenominator[2] + sqr(fDenominator[1]) + 1
                    + 2 * cw * (fDenominator[1] * (fDenominator[2] + 1) + 2 * cw * fDenominator[2]));
 Real      := (fNominator[0] + fNominator[1] * fDenominator[1] + fNominator[2] * fDenominator[2]
              +        cw     * (fNominator[1] * (1 + fDenominator[2]) + fDenominator[1] * (fNominator[2] + fNominator[0]))
              + (2*sqr(cw)-1) * (fNominator[0] * fDenominator[2] + fNominator[2])) * Divider;
 Imaginary := (fDenominator[1] * (fNominator[2] - fNominator[0]) + fNominator[1] * (1 - fDenominator[2])
              + 2 * cw * (fNominator[2] - fNominator[0] * fDenominator[2])) * sqrt(1 - sqr(cw)) * Divider;
end;

procedure TBiquadIIRFilter.Reset;
begin
 Gain := 0;
end;

procedure TBiquadIIRFilter.ResetStates;
begin
 fState[0] := 0;
 fState[1] := 0;
end;

procedure TBiquadIIRFilter.ResetStatesInt64;
begin
 PInt64(@fState[0])^ := 0;
 PInt64(@fState[1])^ := 0;
end;

procedure TBiquadIIRFilter.SetOrder(Value: Integer);
begin {Dummy Function} end;

function dB_to_Amp(g:single):single;
begin
 if (g>-90.0) then result := math.power(10,g*0.05)
 else result := 0;
end;

procedure TBiquadIIRFilter.CalcPolesZeros;
var p,q : Double;
    e   : Double;
begin
 p := -fNominator[1]/(2*fNominator[0]);
 q := (fNominator[2]/fNominator[0]);
 fZeros[0].Re := p;
 fZeros[1].Re := p;
 e := q-(p*p);
 if e>0
  then
   begin
    fZeros[0].Im := sqrt(e);
    fZeros[1].Im := -sqrt(e);
   end
  else
   begin
    fZeros[0].Re := fZeros[0].Re+sqrt(-e);
    fZeros[1].Re := fZeros[0].Re-sqrt(-e);
    fZeros[0].Im := 0;
    fZeros[1].Im := 0;
   end;

 p := -fDenominator[1]/2;
 q := fDenominator[2];
 fPoles[0].Re := p;
 fPoles[1].Re := p;
 e := q-(p*p);
 if e>0
  then
   begin
    fPoles[0].Im := sqrt(e);
    fPoles[1].Im := -sqrt(e);
   end
  else
   begin
    fPoles[0].Re := fPoles[0].Re+sqrt(-e);
    fPoles[1].Re := fPoles[0].Re-sqrt(-e);
    fPoles[0].Im := 0;
    fPoles[1].Im := 0;
   end;
end;

function TBiquadIIRFilter.ProcessSample(const Input:Double):Double;
{$IFDEF PUREPASCAL}
begin
 result    := fNominator[0] * Input + fState[0];
 fState[0] := fNominator[1] * Input - fDenominator[1] * result + fState[1];
 fState[1] := fNominator[2] * Input - fDenominator[2] * result;
end;
{$ELSE}
asm
 fld Input.Double                    // Input
 fmul [self.fNominator].Double       // a0 * Input
 fadd [self.fState].Double           // r = d0 + a0 * Input
 fld st(0)                           // r, r
 fld st(0)                           // r, r, r
 fmul [self.fDenominator].Double     // b0 * r, r, r
 fld Input.Double                    // Input, b0 * r, r, r
 fmul [self.fNominator + 8].Double   // a1 * Input, b0 * r, r, r
 fsubrp                              // a1 * Input + b0 * r, r, r
 fadd [self.fState+8].Double         // d1 + a1 * Input - b0 * r, r, r
 fstp [self.fState].Double           // d0 = a1 * Input + d1 + b1 * r, r, r
 fmul [self.fDenominator+8].Double   // b1*r, r
 fld Input.Double                    // Input, b1*r, r
 fmul [self.fNominator+16].Double    // a2*Input, b1*r, r
 fsubrp st(1), st(0)                 // b1*r + a2*Input, r !!!
 fstp [self.fState+8].Double         // d1 = b1*r + a2*Input, r !!!
end;
{$ENDIF}

function TBiquadIIRFilter.ProcessSample(const Input: Int64): Int64;
begin
 result              := Round(fNominator[0]*Input) + PInt64(@fState[0])^;
 PInt64(@fState[0])^ := Round(fNominator[1]*Input) - Round(fDenominator[1]*result) + PInt64(@fState[1])^;
 PInt64(@fState[1])^ := Round(fNominator[2]*Input) - Round(fDenominator[2]*result);
end;

function TBiquadIIRFilter.ProcessSampleASM:Double;
{$IFDEF PUREPASCAL}
begin
end;
{$ELSE}
asm
 fld st(0)                           // s, s
 fmul [self.fNominator].Double       // a0*s, s
 fadd [self.fState].Double           // r=d0+a0*s, s
 fld st(0)                           // r, r, s
 fld st(0)                           // r, r, r, s
 fmul [self.fDenominator].Double     // b0*r, r, r, s
 fld st(3)                           // s, b0*r, r, r, s
 fmul [self.fNominator+8].Double     // a1*s, b0*r, r, r, s
 fsubrp                              // a1*s + b0*r, r, r, s
 fadd [self.fState+8].Double         // d1+a1*s-b0*r, r, r, s

 fstp [self.fState].Double           // d0 = a1*s + d1+b1*r, r, r, s
 fmul [self.fDenominator+8].Double   // b1*r, r, s
 fxch st(2)                          // s, r, b1*r,
 fmul [self.fNominator+16].Double    // a2*s, r, b1*r,
 fsubrp st(2), st(0)                 // b1*r + a2*s, r, !!!
 fxch
 fstp [self.fState+8].Double         // d1 = b1*r + a2*s, r, !!!
end;
{$ENDIF}

procedure TBiquadIIRFilter.PushStates;
begin
 SetLength(fStateStack,Length(fStateStack)+1);
 if Length(fStateStack)>1
  then Move(fStateStack[0,0],fStateStack[1,0], (Length(fStateStack)-1)*Length(fStateStack[0])*SizeOf(Double));
 Move(fState[0],fStateStack[0,0],Length(fStateStack[0])*SizeOf(Double));
end;

procedure TBiquadIIRFilter.PopStates;
begin
 if Length(fStateStack)>0 then
  begin
   Move(fStateStack[0,0],fState[0], Length(fStateStack[0])*SizeOf(Double));
   if Length(fStateStack)>1
    then Move(fStateStack[1,0],fStateStack[0,0], (Length(fStateStack)-1)*Length(fStateStack[0])*SizeOf(Double));
   SetLength(fStateStack,Length(fStateStack)-1);
  end;
end;

function TBiquadIIRFilter.GetOrder: Integer;
begin Result := 2; end;

function TBiquadIIRFilter.GetPoles:TPNType;
var p, q : Double;
begin
 p := fDenominator[1]/(2*fDenominator[2]);
 q := (1/fDenominator[2]);
 Result[0].Re := p;
 Result[1].Re := p;
 Result[0].Im := sqrt(q-(p*p));
 Result[1].Im := -sqrt(q-(p*p));
end;

function TBiquadIIRFilter.GetZeros:TPNType;
var p, q : Double;
begin
 p := fNominator[1]/(2*fNominator[2]);
 q := (fNominator[0]/fNominator[2]);
 Result[0].Re := p;
 Result[1].Re := p;
 Result[0].Im := sqrt(q-(p*p));
 Result[1].Im := -sqrt(q-(p*p));
end;

{ TSimplePeakFilter }

procedure TSimplePeakFilter.CalculateCoefficients;
var t : Double;
begin
 t := fGainSpeed / (fGainSpeed + fAlpha);
 fDenominator[2] := (fGainSpeed - fAlpha) / (fGainSpeed + fAlpha);
 fDenominator[1] := -2 * cos(fW0)*t;
 fNominator[1] := fDenominator[1];
 fNominator[0] := (1 + fAlpha * fGainSpeed) * t;
 fNominator[2] := (1 - fAlpha * fGainSpeed) * t;
 CalcPolesZeros;
end;

{ TSimpleLowShelfFilter }

procedure TSimpleLowShelfFilter.CalculateCoefficients;
var t,A1,A2 : Double;
    cn,sA   : Double;
begin
 sA := 2 * sqrt(fGainSpeed) * fAlpha;
 cn := cos(fW0);
 A1 := fGainSpeed + 1;
 A2 := fGainSpeed - 1;
 t  := 1 / (A1 + A2 * cn + sA);
 fDenominator[1] := -2 * (A2 + A1 * cn) * t;
 fDenominator[2] := (A1 + A2 * cn - sA) * t;
 fNominator[0] := fGainSpeed * t * (A1 - A2 * cn + sA);
 fNominator[1] := fGainSpeed * t * (A2 - A1 * cn) * 2;
 fNominator[2] := fGainSpeed * t * (A1 - A2 * cn - sA);
 CalcPolesZeros;
end;

{ TSimpleHighShelfFilter }

procedure TSimpleHighShelfFilter.CalculateCoefficients;
var t,A1,A2 : Double;
    cn,sA   : Double;
begin
 cn := cos(fW0);
 sA := 2*sqrt(fGainSpeed)*fAlpha;
 A1 := fGainSpeed + 1;
 A2 := fGainSpeed - 1;
 t  := 1 / (A1 - (A2 * cn) + sA);
 fDenominator[1] := 2 * (A2 -A1 * cn) * t;
 fDenominator[2] := (A1 - A2 * cn - sA) * t;
 fNominator[0] := fGainSpeed * (A1 + A2 * cn + sA) * t;
 fNominator[1] := fGainSpeed * (A2 + A1 * cn) * -2 * t;
 fNominator[2] := fGainSpeed * (A1 + A2 * cn - sA) * t;
 CalcPolesZeros;
end;

{ TSimpleHighcut }

procedure TSimpleHighcutFilter.CalculateCoefficients;
var cn, t : Double;
begin
 t := 1/(1+fAlpha);
 cn := cos(fW0);
 fNominator[0]   := sqr(fGainSpeed) * (1 - cn) * 0.5 * t;
 fNominator[1]   := 2 * fNominator[0];
 fNominator[2]   := fNominator[0];
 fDenominator[1] := -2 * cn * t;
 fDenominator[2] := (1 - fAlpha) * t;
 CalcPolesZeros;
end;

{ TSimpleLowcutFilter }

procedure TSimpleLowcutFilter.CalculateCoefficients;
var cn, t : Double;
begin
 t := 1 / (1 + fAlpha);
 cn := cos(fW0);
 fNominator[0]   := sqr(fGainSpeed) * (1 + cn) * 0.5 * t;
 fNominator[1]   := -2 * fNominator[0];
 fNominator[2]   := fNominator[0];
 fDenominator[1] := -2 * cn * t;
 fDenominator[2] := (1 - fAlpha) * t;
 CalcPolesZeros;
end;

{ TSimpleBandpass }

procedure TSimpleBandpass.CalculateCoefficients;
var t : Double;
begin
 t := 1 / (1 + fAlpha);
 fNominator[0]   := fGainSpeed*fGainSpeed*fAlpha*t;
 fNominator[2]   := -fNominator[0];
 fDenominator[1] := -2*cos(fW0)*t;
 fDenominator[2] := (1-fAlpha)*t;
 fNominator[1]   := 0;
end;

{ TSimpleNotch }

procedure TSimpleNotch.CalculateCoefficients;
var t,a : Double;
begin
 try
  t := 1 / (1 + fAlpha);
  a := sqr(fGainSpeed);
  fDenominator[1] := 2 * cos(fW0)*t;
  fNominator[1]   := -fDenominator[1]*a;
  fDenominator[2] := (fAlpha-1)*t;

  fNominator[0] := a * t;
  fNominator[2] := fNominator[0];
 except
  fNominator[0] := 1; fNominator[1] := 0; fNominator[2] := 0; fDenominator[1] := 0; fDenominator[2] := 0;
 end;
end;

{ TSimpleGainFilter }

procedure TSimpleGainFilter.CalculateCoefficients;
begin
 fNominator[0] := sqr(fGainSpeed);
 fNominator[1] := 0;
 fNominator[2] := 0;
 fDenominator[1] := 0;
 fDenominator[2] := 0;
end;

function TSimpleGainFilter.ProcessSample(const Input: Double): Double;
begin
 result := Input * sqr(fGainSpeed);
end;

function TSimpleGainFilter.ProcessSampleASM: Double;
asm
 fmul [eax.fGainSpeed].Double
 fmul [eax.fGainSpeed].Double
end;

{ TDspLowpassFilter }

procedure TDspLowpassFilter.ChannelsChanged;
var i : Integer;
begin
 inherited;
 for i := fChannels to Length(fFilter) - 1
  do fFilter[i].Free;
 SetLength(fFilter, fChannels);
 for i := 0 to fChannels - 1
  do if not Assigned(fFilter[i])
   then fFilter[i] := TSimpleLowpassFilter.Create;
end;

procedure TDspLowpassFilter.Init;
begin
  fStdProcessS  := Process;
  fStdProcessD  := Process;
  Reset;
end;

procedure TDspLowpassFilter.Process(var Data: Double; const channel: integer);
begin
  Data := fFilter[channel].ProcessSample(Data);
end;

procedure TDspLowpassFilter.Process(var Data: Single; const channel: integer);
begin
  Data := fFilter[channel].ProcessSample(Data);
end;

procedure TDspLowpassFilter.Reset;
begin
  ChannelsChanged;
  SampleRateChanged;
end;

procedure TDspLowpassFilter.SampleRateChanged;
var i : Integer;
begin
 inherited;
 for i := 0 to Length(fFilter) - 1
  do fFilter[i].SampleRate := fSampleRate;
end;

procedure TDspLowpassFilter.SetFrequency(const Value: Single);
var i : Integer;
begin
 if fFrequency <> Value then
  begin
   fFrequency := Value;
   for i := 0 to Length(fFilter) - 1
    do fFilter[i].Frequency := fFrequency;
  end;
end;

end.
