unit DGuiRegister;

interface

procedure Register;

implementation

{$IFNDEF FPC}{$R DGUIRegister.res}{$ENDIF}

uses Classes, DGuiStaticWaveform, DGuiDynamicWaveform, DGuiDial, DGuiMidiKeys, DGuiADSRGraph, DGuiLevelMeter;

procedure Register;
begin
  RegisterComponents('ASIO/VST GUI', [TGuiDynamicWaveform,
                                      TGuiStaticWaveform,
                                      TGuiDial,
                                      TGuiMidiKeys,
                                      TGuiADSRGraph,
                                      TGuiLevelMeter]);
end;

end.
