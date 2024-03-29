unit DVSTModuleWithMidi;

interface

{$I ASIOVST.INC}

uses classes, DVSTCustomModule, DVSTEffect, DAVDCommon;

type
  TProcessMidiEvent = procedure(Sender: TObject; MidiEvent: TVstMidiEvent) of object;

  TVSTModuleWithMidi = class(TCustomVSTModule)
  protected
    FMidiEvent    : TVstEvents;
    fOnProcessMidi: TProcessMidiEvent;
    procedure ProcessMidiEvent(MidiEvent: TVstMidiEvent); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure HostCallProcess(const Inputs, Outputs: PPSingle; const SampleFrames: Integer); override;
    procedure HostCallProcessReplacing(const Inputs, Outputs: PPSingle; const SampleFrames: Integer); override;
    procedure HostCallProcessDoubleReplacing(const Inputs, Outputs: PPDouble; const SampleFrames: Integer); override;

    function HostCallProcessEvents(Index, Value: Integer; ptr: pointer; opt: Single): Integer; override;
    function HostCallGetCurrentMidiProgram     (Index, Value: Integer; ptr: pointer; opt: Single): Integer; override;



    procedure MIDI_Out(b1, b2, b3, b4: byte; offset: Integer = 0);
    procedure MIDI_SendSysEx(Data: array of byte; offset: Integer = 0);
    procedure MIDI_CC(ch, num, val: Integer; offset: Integer = 0);
    procedure MIDI_ChannelAftertouch(ch, val: Integer; offset: Integer = 0);
    procedure MIDI_NoteOff(ch, note, val: Integer; offset: Integer = 0);
    procedure MIDI_NoteOn(ch, note, val: Integer; offset: Integer = 0);
    procedure MIDI_PitchBend(ch, val: Integer; offset: Integer = 0);
    procedure MIDI_PitchBend2(ch, x1, x2: Integer; offset: Integer = 0);
    procedure MIDI_PolyAftertouch(ch, note, val: Integer; offset: Integer = 0);
    procedure MIDI_ProgramChange(ch, val: Integer; offset: Integer = 0);

    property OnProcessMidi: TProcessMidiEvent read fOnProcessMidi write fOnProcessMidi;
  end;
  
implementation

const maxMidiEvents = 256;

constructor TVSTModuleWithMidi.Create(AOwner: TComponent);
var i:integer;
begin
  inherited;
  FMidiEvent.numEvents := 0;

  for i := 0 to maxMidiEvents - 1 do
  begin
   GetMem(FMidiEvent.events[i], sizeof(TVstMidiEvent));
   FillChar(FMidiEvent.events[i]^, sizeof(TVstMidiEvent), 0);
   PVstMidiEvent(FMidiEvent.events[i])^.EventType := etMidi;
   PVstMidiEvent(FMidiEvent.events[i])^.ByteSize := 24;
  end;
end;

destructor TVSTModuleWithMidi.Destroy;
var i : Integer;
begin
  for i := 0 to maxMidiEvents - 1 do FreeMem(FMidiEvent.events[i]);

  inherited;
end;

procedure TVSTModuleWithMidi.ProcessMidiEvent(MidiEvent: TVstMidiEvent);
begin
  if Assigned(fOnProcessMidi) then fOnProcessMidi(Self, MidiEvent);
end;

function TVSTModuleWithMidi.HostCallProcessEvents(Index, Value: Integer; ptr: pointer; opt: Single): Integer;
var i: Integer;
begin
  Result:= inherited HostCallProcessEvents(Index, Value, ptr, opt);
  for i := 0 to PVstEvents(ptr)^.numEvents - 1 do
    if (PVstEvents(ptr)^.events[i]^.EventType = etMidi) then
      ProcessMidiEvent(PVstMidiEvent(PVstEvents(ptr)^.events[i])^);
end;

function TVSTModuleWithMidi.HostCallGetCurrentMidiProgram(Index, Value: Integer; ptr: pointer; opt: Single): Integer;
begin
  Result := -1;
end;


procedure TVSTModuleWithMidi.HostCallProcess(const Inputs, Outputs: PPSingle; const SampleFrames: Integer);
begin
  inherited;
  if FMidiEvent.numEvents > 0 then
  begin
    sendVstEventsToHost(@FMidiEvent);
    FMidiEvent.numEvents := 0;
  end;
end;

procedure TVSTModuleWithMidi.HostCallProcessReplacing(const Inputs, Outputs: PPSingle; const SampleFrames: Integer);
begin
  inherited;
  if FMidiEvent.numEvents > 0 then
  begin
    sendVstEventsToHost(@FMidiEvent);
    FMidiEvent.numEvents := 0;
  end;
end;

procedure TVSTModuleWithMidi.HostCallProcessDoubleReplacing(const Inputs, Outputs: PPDouble; const SampleFrames: Integer);
var Ins  : TAVDArrayOfDoubleDynArray absolute Inputs;
    Outs : TAVDArrayOfDoubleDynArray absolute Outputs;
begin
  inherited;
  if FMidiEvent.numEvents > 0 then
  begin
    sendVstEventsToHost(@FMidiEvent);
    FMidiEvent.numEvents := 0;
  end;
end;

procedure TVSTModuleWithMidi.MIDI_Out(b1, b2, b3, b4: byte; offset: Integer);
begin
 with PVstMidiEvent(FMidiEvent.events[FMidiEvent.numEvents])^ do
  begin
   EventType := etMidi;
   MidiData[0] := b1;
   MidiData[1] := b2;
   MidiData[2] := b3;
   MidiData[3] := b4;
   DeltaFrames := offset;
   if FMidiEvent.numEvents < maxMidiEvents - 1 then inc(FMidiEvent.numEvents);
  end;
end;

procedure TVSTModuleWithMidi.MIDI_CC(ch, num, val: Integer; offset: Integer = 0);
begin
 with PVstMidiEvent(FMidiEvent.events[FMidiEvent.numEvents])^ do
  begin
   EventType := etMidi;
   MidiData[0] := $B0 + ch;
   MidiData[1] := num;
   MidiData[2] := val;
   DeltaFrames := offset;
   if FMidiEvent.numEvents < maxMidiEvents - 1 then inc(FMidiEvent.numEvents);
  end;
end;

procedure TVSTModuleWithMidi.MIDI_ChannelAftertouch(ch, val: Integer; offset: Integer = 0);
begin
 with PVstMidiEvent(FMidiEvent.events[FMidiEvent.numEvents])^ do
  begin
   EventType := etMidi;
   MidiData[0] := $D0 + ch;
   MidiData[1] := val;
   MidiData[2] := 0;
   DeltaFrames := offset;
   if FMidiEvent.numEvents < maxMidiEvents - 1 then inc(FMidiEvent.numEvents);
  end;
end;

procedure TVSTModuleWithMidi.MIDI_NoteOff(ch, note, val: Integer; offset: Integer = 0);
begin
 with PVstMidiEvent(FMidiEvent.events[FMidiEvent.numEvents])^ do
  begin
   EventType := etMidi;
   MidiData[0] := $80 + ch;
   MidiData[1] := note;
   MidiData[2] := val;
   DeltaFrames := offset;
   if FMidiEvent.numEvents < maxMidiEvents - 1 then inc(FMidiEvent.numEvents);
  end;
end;

procedure TVSTModuleWithMidi.MIDI_NoteOn(ch, note, val: Integer; offset: Integer = 0);
begin
 with PVstMidiEvent(FMidiEvent.events[FMidiEvent.numEvents])^ do
  begin
   EventType := etMidi;
   MidiData[0] := $90 + ch;
   MidiData[1] := note;
   MidiData[2] := val;
   DeltaFrames := offset;
   if FMidiEvent.numEvents < maxMidiEvents - 1 then inc(FMidiEvent.numEvents);
  end;
end;

procedure TVSTModuleWithMidi.MIDI_PitchBend(ch, val: Integer; offset: Integer = 0);
var a, b: Integer;
begin
 with PVstMidiEvent(FMidiEvent.events[FMidiEvent.numEvents])^ do
  begin
   EventType := etMidi;
   a := (val div 128) + 64;
   b := (val div 128);
   b := val - b * 128;
   MidiData[0] := $E0 + ch;
   MidiData[1] := b;
   MidiData[2] := a;
   DeltaFrames := offset;
   if FMidiEvent.numEvents < maxMidiEvents - 1 then inc(FMidiEvent.numEvents);
  end;
end;

procedure TVSTModuleWithMidi.MIDI_PitchBend2(ch, x1, x2: Integer; offset: Integer = 0);
begin
 with PVstMidiEvent(FMidiEvent.events[FMidiEvent.numEvents])^ do
  begin
   EventType := etMidi;
   MidiData[0] := $E0 + ch;
   MidiData[1] := x1;
   MidiData[2] := x2;
   DeltaFrames := offset;
   if FMidiEvent.numEvents < maxMidiEvents - 1 then inc(FMidiEvent.numEvents);
  end;
end;

procedure TVSTModuleWithMidi.MIDI_PolyAftertouch(ch, note, val: Integer; offset: Integer = 0);
begin
 with PVstMidiEvent(FMidiEvent.events[FMidiEvent.numEvents])^ do
  begin
   EventType := etMidi;
   MidiData[0] := $A0 + ch;
   MidiData[1] := note;
   MidiData[2] := val;
   DeltaFrames := offset;
   if FMidiEvent.numEvents < maxMidiEvents - 1 then inc(FMidiEvent.numEvents);
  end;
end;

procedure TVSTModuleWithMidi.MIDI_ProgramChange(ch, val: Integer; offset: Integer = 0);
begin
 with PVstMidiEvent(FMidiEvent.events[FMidiEvent.numEvents])^ do
  begin
   EventType := etMidi;
   MidiData[0] := $D0 + ch;
   MidiData[1] := val;
   MidiData[2] := 0;
   DeltaFrames := offset;
   if FMidiEvent.numEvents < maxMidiEvents - 1 then inc(FMidiEvent.numEvents);
  end;
end;

procedure TVSTModuleWithMidi.MIDI_SendSysEx(Data: array of byte; offset: Integer);
begin
 with PVstMidiSysexEvent(FMidiEvent.events[FMidiEvent.numEvents])^ do
  begin
   EventType := etSysEx;
   DeltaFrames := offset;
   dumpBytes := Length(Data);
   GetMem(sysexDump, dumpBytes);
   Move(Data[0], sysexDump^, dumpBytes);
   if FMidiEvent.numEvents < maxMidiEvents - 1 then inc(FMidiEvent.numEvents);
  end;
end;


end.
