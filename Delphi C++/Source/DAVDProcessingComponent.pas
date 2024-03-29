unit DAVDProcessingComponent;

interface

uses Classes, DAVDCommon;

type
  TDspBaseProcessFuncS   = procedure(var Data: Single; const channel: integer) of object;
  TDspBaseProcessFuncD   = procedure(var Data: Double; const channel: integer) of object;
  TDspBaseProcessFuncSA  = procedure(var ProcessBuffer: TAVDSingleDynArray; const channel, SampleFrames: integer) of object;
  TDspBaseProcessFuncDA  = procedure(var ProcessBuffer: TAVDDoubleDynArray; const channel, SampleFrames: integer) of object;
  TDspBaseProcessFuncSAA = procedure(var ProcessBuffer: TAVDArrayOfSingleDynArray; const SampleFrames: integer) of object;
  TDspBaseProcessFuncDAA = procedure(var ProcessBuffer: TAVDArrayOfDoubleDynArray; const SampleFrames: integer) of object;

  TAVDProcessingComponent = class(TComponent)
  protected
    fBypass:     Boolean;
    fEnabled:    Boolean;
    fSampleRate: Single;
    fChannels:   Integer;

    fTrailingSamples: Integer;

    fProcessS:   TDspBaseProcessFuncS;
    fProcessD:   TDspBaseProcessFuncD;
    fProcessSA:  TDspBaseProcessFuncSA;
    fProcessDA:  TDspBaseProcessFuncDA;
    fProcessSAA: TDspBaseProcessFuncSAA;
    fProcessDAA: TDspBaseProcessFuncDAA;

    fProcessQueueS:   TDspBaseProcessFuncS;
    fProcessQueueD:   TDspBaseProcessFuncD;
    fProcessQueueSA:  TDspBaseProcessFuncSA;
    fProcessQueueDA:  TDspBaseProcessFuncDA;
    fProcessQueueSAA: TDspBaseProcessFuncSAA;
    fProcessQueueDAA: TDspBaseProcessFuncDAA;

    function GetTrailingSamplesQueue: integer; virtual; abstract;

    procedure SetBypass(const Value: Boolean); virtual; abstract;
    procedure SetEnabled(const Value: Boolean); virtual; abstract;
    procedure SetSampleRate(const Value: Single); virtual; abstract;
    procedure SetChannels(const Value: Integer); virtual; abstract;
    procedure SetTrailingSamples(const Value: Integer); virtual; abstract;
  public
    procedure Init; virtual; abstract;
    procedure Reset; virtual; abstract;
    procedure ResetQueue; virtual; abstract;

    procedure NoteOff; virtual; abstract;
    procedure NoteOffQueue; virtual; abstract;

    procedure ProcessMidiEvent(MidiEvent: TAVDMidiEvent; var FilterEvent: Boolean); virtual; abstract;
    procedure ProcessMidiEventQueue(MidiEvent: TAVDMidiEvent; var FilterEvent: Boolean); virtual; abstract;

    
    property Enabled: Boolean   read fEnabled    write SetEnabled    default true;
    property Bypass: Boolean    read fBypass     write SetBypass     default true;
    property Channels: Integer  read fChannels   write SetChannels   default 2;
    property SampleRate: Single read fSampleRate write SetSampleRate;    

    property TrailingSamples: Integer read fTrailingSamples write SetTrailingSamples default 0;
    property TrailingSamplesQueue: Integer read GetTrailingSamplesQueue;

    property ProcessS:   TDspBaseProcessFuncS   read fProcessS;
    property ProcessD:   TDspBaseProcessFuncD   read fProcessD;
    property ProcessSA:  TDspBaseProcessFuncSA  read fProcessSA;
    property ProcessDA:  TDspBaseProcessFuncDA  read fProcessDA;
    property ProcessSAA: TDspBaseProcessFuncSAA read fProcessSAA;
    property ProcessDAA: TDspBaseProcessFuncDAA read fProcessDAA;

    property ProcessQueueS:   TDspBaseProcessFuncS   read fProcessQueueS;
    property ProcessQueueD:   TDspBaseProcessFuncD   read fProcessQueueD;
    property ProcessQueueSA:  TDspBaseProcessFuncSA  read fProcessQueueSA;
    property ProcessQueueDA:  TDspBaseProcessFuncDA  read fProcessQueueDA;
    property ProcessQueueSAA: TDspBaseProcessFuncSAA read fProcessQueueSAA;
    property ProcessQueueDAA: TDspBaseProcessFuncDAA read fProcessQueueDAA;
  end;

  TAVDProcessingComponentList = class(TList)
  protected
    function Get(Index: Integer): TAVDProcessingComponent;
    procedure Put(Index: Integer; Item: TAVDProcessingComponent);

    function GetTrailingSamplesQueue: integer;
  public
    function Add(Item: TAVDProcessingComponent): Integer;
    function Extract(Item: TAVDProcessingComponent): TAVDProcessingComponent;
    function First: TAVDProcessingComponent;
    function IndexOf(Item: TAVDProcessingComponent): Integer;
    function Last: TAVDProcessingComponent;
    function Remove(Item: TAVDProcessingComponent): Integer;
    procedure Insert(Index: Integer; Item: TAVDProcessingComponent);

    procedure SetSampleRate(Value: Single);
    procedure SetChannels(Value: Integer);
    procedure SetEnabled(Value: Boolean);
    procedure SetBypass(Value: Boolean);

    procedure ProcessMidiEventQueue(MidiEvent: TAVDMidiEvent; var FilterEvent: Boolean);
    procedure NoteOffQueue;

    property TrailingSamplesQueue: integer read GetTrailingSamplesQueue;
    property Items[Index: Integer]: TAVDProcessingComponent read Get write Put;
  end;

implementation

uses Math;

{ TAVDProcessingComponentList }

procedure TAVDProcessingComponentList.Insert(Index: Integer; Item: TAVDProcessingComponent);
begin
  inherited Insert(Index, Item);
end;

procedure TAVDProcessingComponentList.Put(Index: Integer; Item: TAVDProcessingComponent);
begin
   inherited Put(Index, Item);
end;

function TAVDProcessingComponentList.Add(Item: TAVDProcessingComponent): Integer;
begin
  Result := inherited Add(Item);
end;

function TAVDProcessingComponentList.Extract(Item: TAVDProcessingComponent): TAVDProcessingComponent;
begin
  Result := TAVDProcessingComponent(inherited Extract(Item));
end;

function TAVDProcessingComponentList.First: TAVDProcessingComponent;
begin
  Result := TAVDProcessingComponent(inherited First);
end;

function TAVDProcessingComponentList.Get(Index: Integer): TAVDProcessingComponent;
begin
  Result := TAVDProcessingComponent(inherited Get(Index));
end;

function TAVDProcessingComponentList.IndexOf(Item: TAVDProcessingComponent): Integer;
begin
  Result := inherited IndexOf(Item);
end;

function TAVDProcessingComponentList.Last: TAVDProcessingComponent;
begin
  Result := TAVDProcessingComponent(inherited Last);
end;

function TAVDProcessingComponentList.Remove(Item: TAVDProcessingComponent): Integer;
begin
  Result := inherited Remove(Item);
end;

procedure TAVDProcessingComponentList.SetSampleRate(Value: Single);
var i: integer;
begin
  for i := Count - 1 downto 0 do
    Items[i].SampleRate := Value;
end;

procedure TAVDProcessingComponentList.SetChannels(Value: Integer);
var i: integer;
begin
  for i := Count - 1 downto 0 do
    Items[i].Channels := Value;
end;

procedure TAVDProcessingComponentList.SetEnabled(Value: Boolean);
var i: integer;
begin
  for i := Count - 1 downto 0 do
    Items[i].Enabled := Value;
end;

procedure TAVDProcessingComponentList.SetBypass(Value: Boolean);
var i: integer;
begin
  for i := Count-1 downto 0 do
    Items[i].Bypass := Value;
end;

procedure TAVDProcessingComponentList.ProcessMidiEventQueue(MidiEvent: TAVDMidiEvent; var FilterEvent: Boolean);
var i: integer; filter: boolean;
begin
  FilterEvent:=false;
  for i := Count-1 downto 0 do
  begin
    filter:=false;
    Items[i].ProcessMidiEventQueue(MidiEvent, filter);
    FilterEvent:=FilterEvent or filter;
  end;
end;

procedure TAVDProcessingComponentList.NoteOffQueue;
var i: integer;
begin
  for i := Count-1 downto 0 do
    Items[i].NoteOffQueue;
end;

function TAVDProcessingComponentList.GetTrailingSamplesQueue: integer;
var i: integer;
begin
  result:=0;
  for i := Count-1 downto 0 do
    result:=max(result, Items[i].TrailingSamplesQueue);
end;


end.
