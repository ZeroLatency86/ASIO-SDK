unit DDSPOscSaw;

interface

uses DAVDCommon, DAVDComplex, DDspBaseComponent, DDSPBaseOsc;

type
  TDspOscSaw = class(TDspBaseOsc)
  protected
    procedure FrequencyChanged; override; 
    procedure Process(var Data: Single; const channel: integer); override;
    procedure Process(var Data: Double; const channel: integer); override;
  end;

implementation


procedure TDspOscSaw.FrequencyChanged;
begin
  FAngle.Re:=FFrequency/FSampleRate
end;

procedure TDspOscSaw.Process(var Data: Single; const channel: integer);
begin
  fPosition[channel].Re := fPosition[channel].Re+FAngle.Re;
  if fPosition[channel].Re>1 then
    fPosition[channel].Re := f_Frac(fPosition[channel].Re);

  Data:=(1-fPosition[channel].Re*2) * fAmplitude + FDCOffset;
end;

procedure TDspOscSaw.Process(var Data: Double; const channel: integer);
begin
  fPosition[channel].Re := fPosition[channel].Re+FAngle.Re;
  if fPosition[channel].Re>1 then
    fPosition[channel].Re := f_Frac(fPosition[channel].Re);

  Data:=(1-fPosition[channel].Re*2) * fAmplitude + FDCOffset;
end;

end.
