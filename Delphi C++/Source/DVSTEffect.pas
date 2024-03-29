unit DVSTEffect;

interface

{$I ASIOVST.INC}

{$IFDEF FPC}uses LCLIntf;{$ELSE}uses Windows;{$ENDIF}

const kEffectMagic = 'VstP';

type
  PPSingle = ^PSingle;
  PPDouble = ^PDouble;
  PVSTEffect = ^TVSTEffect;

{$ALIGN ON}
  TDispatcherOpcode = (
    effOpen,                  //  0: initialise
    effClose,                 //  1: exit, release all memory and other resources!
    effSetProgram,            //  2: program no in <value>
    effGetProgram,            //  3: return current program no.
    effSetProgramName,        //  4: user changed program name (max 24 char + 0) to as passed in string
    effGetProgramName,        //  5: stuff program name (max 24 char + 0) into string
    effGetParamLabel,         //  6: stuff parameter <index> label (max 8 char + 0) into string
                              //     (examples: sec, dB, type)
    effGetParamDisplay,       //  7: stuff parameter <index> textual representation into string
                              //     (examples: 0.5, -3, PLATE)
    effGetParamName,          //  8: stuff parameter <index> label (max 8 char + 0) into string
                              //     (examples: Time, Gain, RoomType)
    effGetVu,                 //  9: NOT USED SINCE 2.4 - called if (flags & (effFlagsHasClip | effFlagsHasVu))

    // system
    effSetSampleRate,         // 10: in opt (float value in Hz; for example 44100.0Hz)
    effSetBlockSize,          // 11: in value (this is the maximun size of an audio block,
                              //     pls check sampleframes in process call)
    effMainsChanged,          // 12: the user has switched the 'power on' button to
                              //     value (0 off, else on). This only switches audio
                              //     processing; you should flush delay buffers etc.
    // editor
    effEditGetRect,           // 13: stuff rect (top, left, bottom, right) into ptr
    effEditOpen,              // 14: system dependant Window Pointer in ptr
    effEditClose,             // 15: no arguments
    effEditDraw,              // 16: NOT USED SINCE 2.4 - draw method, ptr points to rect  (MAC only)
    effEditMouse,             // 17: NOT USED SINCE 2.4 - index: x, value: y (MAC only)
    effEditKey,               // 18: NOT USED SINCE 2.4 - system keycode in value
    effEditIdle,              // 19: no arguments. Be gentle!
    effEditTop,               // 20: NOT USED SINCE 2.4 - window has topped, no arguments
    effEditSleep,             // 21: NOT USED SINCE 2.4 - window goes to background

    // new
    effIdentify,              // 22: NOT USED SINCE 2.4 - returns 'NvEf'
    effGetChunk,              // 23: host requests Pointer to chunk into (void**)ptr, ByteSize returned
    effSetChunk,              // 24: plug-in receives saved chunk, ByteSize passed

    // VstEvents
    effProcessEvents,         // 25: VstEvents* in <ptr>

    // parameters and programs
    effCanBeAutomated,          // 26: parameter index in <index>
    effString2Parameter,        // 27: parameter index in <index>, string in <ptr>
    effGetNumProgramCategories, // 28: NOT USED IN 2.4 - no arguments. this is for dividing programs into groups (like GM)
    effGetProgramNameIndexed,   // 29: get program name of category <value>, program <index> into <ptr>.
                                //     category (that is, <value>) may be -1, in which case program indices
                                //     are enumerated linearily (as usual); otherwise, each category starts
                                //     over with index 0.
    effCopyProgram,             // 30: NOT USED IN 2.4 - copy current program to destination <index>, note: implies setParameter
                                //     connections, configuration
    effConnectInput,            // 31: NOT USED IN 2.4 - input at <index> has been (dis-)connected; <value> == 0: disconnected, else connected
    effConnectOutput,           // 32: NOT USED IN 2.4 - same as input
    effGetInputProperties,      // 33: <index>, VstPinProperties* in ptr, return != 0 => true
    effGetOutputProperties,     // 34: dto
    effGetPlugCategory,         // 35: no parameter, return value is category

    // realtime
    effGetCurrentPosition,      // 36: NOT USED IN 2.4 - for external dsp, see flag bits below
    effGetDestinationBuffer,    // 37: NOT USED IN 2.4 - for external dsp, see flag bits below. returns float*

    // offline
    effOfflineNotify,           // 38: ptr = VstAudioFile array, value = count, index = start flag
    effOfflinePrepare,          // 39: ptr = VstOfflineTask array, value = count
    effOfflineRun,              // 40: dto

    // other
    effProcessVarIo,              // 41: VstVariableIo* in <ptr>
    effSetSpeakerArrangement,     // 42: VstSpeakerArrangement* pluginInput in <value>
                                  //     VstSpeakerArrangement* pluginOutput in <ptr>
    effSetBlockSizeAndSampleRate, // 43: NOT USED IN 2.4 - block size in <value>, sampleRate in <opt>
    effSetBypass,                 // 44: onOff in <value> (0 = off)
    effGetEffectName,             // 45: char* name (max 32 Bytes) in <ptr>
    effGetErrorText,              // 46: NOT USED IN 2.4 - char* text (max 256 Bytes) in <ptr>
    effGetVendorString,           // 47: fills <ptr> with a string identifying the vendor (max 64 char)
    effGetProductString,          // 48: fills <ptr> with a string with product name (max 64 char)
    effGetVendorVersion,          // 49: returns vendor-specific version
    effVendorSpecific,            // 50: no definition, vendor specific handling
    effCanDo,                     // 51: <ptr>
    effGetTailSize,               // 52: returns tail size; 0 is default (return 1 for 'no tail')
    effIdle,                      // 53: idle call in response to audioMasterneedIdle. must
                                  //     NOT USED IN 2.4 - return 1 to keep idle calls beeing issued
    // gui
    effGetIcon,                   // 54: NOT USED IN 2.4 - void* in <ptr>, not yet defined
    effSetViewPosition,           // 55: NOT USED IN 2.4 - set view position (in window) to x <index> y <value>

    // and...
    effGetParameterProperties,    // 56: of param <index>, VstParameterProperties* in <ptr>
    effKeysRequired,              // 57: NOT USED IN 2.4 - returns 0: needs keys (default for 1.0 plugs), 1: don't need
    effGetVstVersion,             // 58: returns 2; older versions return 0

    effEditKeyDown,               // 59: character in <index>, virtual in <value>, modifiers in <opt>  return -1 if not used, return 1 if used
    effEditKeyUp,                 // 60: character in <index>, virtual in <value>, modifiers in <opt>  return -1 if not used, return 1 if used
    effSetEditKnobMode,           // 61: mode in <value>: 0: circular, 1:circular relativ, 2:linear

    // midi plugins channeldependent programs
    effGetMidiProgramName,        // 62: passed <ptr> points to MidiProgramName struct.
                                  //     struct will be filled with information for 'thisProgramIndex'.
                                  //     returns number of used programIndexes.
                                  //     if 0 is returned, no MidiProgramNames supported.

    effGetCurrentMidiProgram,     // 63: returns the programIndex of the current program.
                                  //     passed <ptr> points to MidiProgramName struct.
                                  //     struct will be filled with information for the current program.

    effGetMidiProgramCategory,    // 64: passed <ptr> points to MidiProgramCategory struct.
                                  //     struct will be filled with information for 'thisCategoryIndex'.
                                  //     returns number of used categoryIndexes.
                                  //     if 0 is returned, no MidiProgramCategories supported.

    effHasMidiProgramsChanged,    // 65: returns 1 if the MidiProgramNames or MidiKeyNames
                                  //     had changed on this channel, 0 otherwise. <ptr> ignored.

    effGetMidiKeyName,            // 66: passed <ptr> points to MidiKeyName struct.
                                  //     struct will be filled with information for 'thisProgramIndex' and
                                  //     'thisKeyNumber'. If keyName is "" the standard name of the key
                                  //     will be displayed. If 0 is returned, no MidiKeyNames are defined for 'thisProgramIndex'.

    effBeginSetProgram,           // 67: called before a new program is loaded
    effEndSetProgram,             // 68: called when the program is loaded

    effGetSpeakerArrangement,     // 69: VstSpeakerArrangement** pluginInput in <value>
                                  //     VstSpeakerArrangement** pluginOutput in <ptr>
    effShellGetNextPlugin,        // 70: This opcode is only called, if plugin is of type kPlugCategShell.
                                  //     returns the next plugin's uniqueID.
                                  //     <ptr> points to a char buffer of size 64, which is to be filled
                                  //     with the name of the plugin including the terminating zero.
    effStartProcess,              // 71: Called before the start of process call
    effStopProcess,               // 72: Called after the stop of process call
    effSetTotalSampleToProcess,   // 73: Called in offline (non RealTime) Process before process is called, indicates how many sample will be processed
    effSetPanLaw,                 // 74: PanLaw : Type (Linear, Equal Power,.. see enum PanLaw Type) in <value>,
                                  //     Gain in <opt>: for Linear : [1.0 => 0dB PanLaw], [~0.58 => -4.5dB], [0.5 => -6.02dB]
    effBeginLoadBank,             // 75: Called before a Bank is loaded, <ptr> points to VstPatchChunkInfo structure
                                  //     return -1 if the Bank can not be loaded, return 1 if it can be loaded else 0 (for compatibility)
    effBeginLoadProgram,          // 76: Called before a Program is loaded, <ptr> points to VstPatchChunkInfo structure
                                  //     return -1 if the Program can not be loaded, return 1 if it can be loaded else 0 (for compatibility)
    effSetProcessPrecision,       // 77: see TProcessPrecision
    effGetNumMidiInputChannels,   // 78: return number of used MIDI input channels (1-15)  @see AudioEffectX::getNumMidiInputChannels
    effGetNumMidiOutputChannels   // 79: return number of used MIDI output channels (1-15)  @see AudioEffectX::getNumMidiOutputChannels
  );

  TProcessPrecision = (
    pp32, //< single precision float (32bits)
    pp64  //< double precision (64bits)
  );


  TAudioMasterOpcode = (
    audioMasterAutomate,      //  0: index, value, returns 0
    audioMasterVersion,       //  1: vst version, currently 2 (0 for older), 2400 for VST 2.4!
    audioMasterCurrentId,     //  2: returns the unique id of a plug that's currently loading
    audioMasterIdle,          //  3: call application idle routine (this will call effEditIdle for all open editors too)
    audioMasterPinConnected,  //  4: inquire if an input or output is beeing connected;
                              //     index enumerates input or output counting from zero,
                              //     value is 0 for input and != 0 otherwise. note: the
                              //     return value is 0 for <true> such that older versions
    audioMasterUnused,        //  5: placeholder

    // VstEvents + VstTimeInfo
    audioMasterWantMidi,      //  6: <value> is a filter which is currently ignored
    audioMasterGetTime,       //  7: returns const VstTimeInfo* (or 0 if not supported)
                              //     <value> should contain a mask indicating which fields are required
                              //     (see valid masks above), as some items may require extensive conversions
    audioMasterProcessEvents, //  8: VstEvents* in <ptr>
    audioMasterSetTime,       //  9: NOT USED IN 2.4 - VstTimenfo* in <ptr>, filter in <value>, not supported
    audioMasterTempoAt,       // 10: NOT USED IN 2.4 - returns tempo (in bpm * 10000) at sample frame location passed in <value>

    // parameters
    audioMasterGetNumAutomatableParameters, // 11: NOT USED IN 2.4
    audioMasterGetParameterQuantization,    // 12: NOT USED IN 2.4 - returns the integer value for +1.0 representation,
                                            //     or 1 if full Single float precision is maintained in automation. parameter index in <value> (-1: all, any) connections, configuration
    audioMasterIOChanged,                   // 13: numInputs and/or numOutputs has changed
    audioMasterNeedIdle,                    // 14: NOT USED IN 2.4 - plug needs idle calls (outside its editor window)
    audioMasterSizeWindow,                  // 15: index: width, value: height
    audioMasterGetSampleRate,
    audioMasterGetBlockSize,
    audioMasterGetInputLatency,
    audioMasterGetOutputLatency,
    audioMasterGetPreviousPlug,             // 20: NOT USED IN 2.4 - input pin in <value> (-1: first to come), returns cEffect*
    audioMasterGetNextPlug,                 // 21: NOT USED IN 2.4 - output pin in <value> (-1: first to come), returns cEffect*

    // realtime info
    audioMasterWillReplaceOrAccumulate,     // 22: NOT USED IN 2.4 - returns: 0: not supported, 1: replace, 2: accumulate
    audioMasterGetCurrentProcessLevel,      // 23: returns: 0: not supported,
                                            //         1: currently in user thread (gui)
                                            //         2: currently in audio thread (where process is called)
                                            //         3: currently in 'sequencer' thread (midi, timer etc)
                                            //         4: currently offline processing and thus in user thread
                                            //     other: not defined, but probably pre-empting user thread.
    audioMasterGetAutomationState,          // 24: returns 0: not supported, 1: off, 2:read, 3:write, 4:read/write

    // offline
    audioMasterOfflineStart,
    audioMasterOfflineRead,                 // 26: ptr points to offline structure, see below. return 0: error, 1 ok
    audioMasterOfflineWrite,                // 27: same as read
    audioMasterOfflineGetCurrentPass,
    audioMasterOfflineGetCurrentMetaPass,

    // other
    audioMasterSetOutputSampleRate,         // 30: NOT USED IN 2.4 - for variable i/o, sample rate in <opt>
    audioMasterGetOutputSpeakerArrangement, // 31: NOT USED IN 2.4 - result in ret
    audioMasterGetVendorString,             // 32: fills <ptr> with a string identifying the vendor (max 64 char)
    audioMasterGetProductString,            // 33: fills <ptr> with a string with product name (max 64 char)
    audioMasterGetVendorVersion,            // 34: returns vendor-specific version
    audioMasterVendorSpecific,              // 35: no definition, vendor specific handling
    audioMasterSetIcon,                     // 36: NOT USED IN 2.4 - void* in <ptr>, format not defined yet
    audioMasterCanDo,                       // 37: string in ptr, see below
    audioMasterGetLanguage,                 // 38: see enum
    audioMasterOpenWindow,                  // 39: NOT USED IN 2.4 - returns platform specific ptr
    audioMasterCloseWindow,                 // 40: NOT USED IN 2.4 - close window, platform specific handle in <ptr>
    audioMasterGetDirectory,                // 41: get plug directory, FSSpec on MAC, else char*
    audioMasterUpdateDisplay,               // 42: something has changed, update 'multi-fx' display

    //---from here VST 2.1 extension opcodes------------------------------------------------------
    audioMasterBeginEdit,                   // 43: begin of automation session (when mouse down), parameter index in <index>
    audioMasterEndEdit,                     // 44: end of automation session (when mouse up),     parameter index in <index>
    audioMasterOpenFileSelector,            // 45: open a fileselector window with VstFileSelect* in <ptr>

    //---from here VST 2.2 extension opcodes------------------------------------------------------
    audioMasterCloseFileSelector,           // 46: close a fileselector operation with VstFileSelect* in <ptr>: Must be always called after an open !
    audioMasterEditFile,                    // 47: NOT USED IN 2.4 - open an editor for audio (defined by XML text in ptr)
    audioMasterGetChunkFile,                // 48: NOT USED IN 2.4 - get the native path of currently loading bank or project
                                            //     (called from writeChunk) void* in <ptr> (char[2048], or sizeof(FSSpec))
    audioMasterGetInputSpeakerArrangement); // 49: NOT USED IN 2.4 - result a VstSpeakerArrangement in ret
                                            //     will always return true.

  TAudioMasterCallbackFunc = function(Effect: PVSTEffect; Opcode: TAudioMasterOpcode; Index, Value: Integer; Ptr: Pointer; Opt: Single): LongInt; cdecl;
  TDispatcherFunc = function(Effect: PVSTEffect; Opcode : TDispatcherOpcode; Index, Value: Integer; Ptr: Pointer; Opt: Single): LongInt; cdecl;
  TProcessProc = procedure(Effect: PVSTEffect; Inputs, Outputs: PPSingle; Sampleframes: Integer); cdecl;
  TProcessDoubleProc = procedure(Effect: PVSTEffect; Inputs, Outputs: PPDouble; Sampleframes: Integer); cdecl;
  TSetParameterProc = procedure(Effect: PVSTEffect; Index: Longint; Parameter: Single); cdecl;
  TGetParameterFunc = function(Effect: PVSTEffect; Index: LongInt): Single; cdecl;

  TMainProc = function(audioMaster: TAudioMasterCallbackFunc): PVSTEffect; cdecl;

  TEffFlag = (
    effFlagsHasEditor,           // if set, is expected to react to editor messages
    effFlagsHasClip,             // NOT USED SINCE 2.4 - return > 1. in getVu() if clipped
    effFlagsHasVu,               // NOT USED SINCE 2.4 - return vu value in getVu(); > 1. means clipped
    effFlagsCanMono,             // NOT USED SINCE 2.4 - if numInputs == 2, makes sense to be used for mono in
    effFlagsCanReplacing,        // MUST BE SET! supports in place output (processReplacing() exsists)
    effFlagsProgramChunks,       // program data are handled in formatless chunks
    effFlagsUnused1,             // Unused
    effFlagsUnused2,             // Unused
    effFlagsIsSynth,             // host may assign mixer channels for its outputs
    effFlagsNoSoundInStop,       // does not produce sound when input is all silence
    effFlagsExtIsAsync,          // NOT USED IN 2.4! - for external dsp; plug returns immedeately from process()
                                 // host polls plug position (current block) via effGetCurrentPosition
    effFlagsExtHasBuffer,        // NOT USED IN 2.4! - external dsp, may have their own output buffer (32 bit float)
                                 // host then requests this via effGetDestinationBuffer
    effFlagsCanDoubleReplacing); // plug-in supports double precision processing

  TEffFlags = set of TEffFlag;

  TVSTEffect = record
    Magic            : array [0..3] of char; // must be kEffectMagic ('VstP')
    Dispatcher       : TDispatcherFunc;
    Process          : TProcessProc;         // Not used since 2.4, use ProcessReplacing instead!
    SetParameter     : TSetParameterProc;
    GetParameter     : TGetParameterFunc;
    numPrograms      : LongInt;
    numParams        : LongInt;              // all programs are assumed to have numParams parameters
    numInputs        : LongInt;              //
    numOutputs       : LongInt;              //
    EffectFlags      : TEffFlags;            // see constants
    reservedForHost  : Pointer;              // reserved for Host, must be 0 (Dont use it)
    resvd2           : LongInt;              // reserved for Host, must be 0 (Dont use it)
    InitialDelay     : LongInt;              // for algorithms which need input in the first place
    RealQualities    : LongInt;              // number of realtime qualities (0: realtime)
    OffQualities     : LongInt;              // number of offline qualities (0: realtime only)
    IORatio          : LongInt;              // input samplerate to output samplerate ratio, not used yet
    vObject          : Pointer;              // for class access (see AudioEffect.hpp), MUST be 0 else!
    User             : Pointer;              // user access
    UniqueID         : LongInt;              // pls choose 4 character as unique as possible. This is used to identify an effect for save+load
    Version          : LongInt;              // (example 1100 for version 1.1.0.0)
    ProcessReplacing : TProcessProc;
    ProcessDoubleReplacing: TProcessDoubleProc;
    Future           : array[0..55] of Byte;            // pls zero
  end;

  TVSTEventType = ( etNone,
    etMidi,      // 1: midi event, can be cast as VstMidiEvent (see below)
    etAudio,     // 2: audio
    etVideo,     // 3: video
    etParameter, // 4: parameter
    etTrigger,   // 5: trigger
    etSysEx      // 6: midi system exclusive
  );

  PVstEvent = ^TVstEvent;
  TVstEvent = packed record      // a generic timestamped event
    EventType   : TVSTEventType; // see above
    ByteSize    : LongInt;       // of this event, excl. type and ByteSize
    DeltaFrames : LongInt;       // sample frames related to the current block start sample position
    Flags       : LongInt;       // generic flags, none defined yet (0)
    Data        : array[0..15] of Byte;  // size may vary but is usually 16
  end;

  PVstEvents = ^TVstEvents;
  TVstEvents = packed record  // a block of events for the current audio block
    numEvents : LongInt;
    Reserved  : LongInt;                   // zero
    Events    : array[0..2047] of PVstEvent;  // variable
  end;

  // VstMidiEventFlag //////////////////////////////////////////////////////////
  TVstMidiEventFlag = (kVstMidiEventIsRealtime);
  TVstMidiEventFlags = set of TVstMidiEventFlag;

  // defined events ////////////////////////////////////////////////////////////
  PVstMidiEvent = ^TVstMidiEvent;
  TVstMidiEvent = record                    // to be casted from a VstEvent
    EventType       : TVSTEventType;        // kVstMidiType
    ByteSize        : LongInt;              // 24
    DeltaFrames     : LongInt;              // sample frames related to the current block start sample position
    Flags           : TVstMidiEventFlags;   // see above
    NoteLength      : LongInt;              // (in sample frames) of entire note, if available, else 0
    NoteOffset      : LongInt;              // offset into note from note start if available, else 0
    MidiData        : array[0..3] of Byte;  // 1 thru 3 midi Bytes; midiData[3] is reserved (zero)
    Detune          : Byte;                 // -64 to +63 cents; for scales other than 'well-tempered' ('microtuning')
    NoteOffVelocity : Byte;
    Reserved1       : Byte;                 // zero
    Reserved2       : Byte;                 // zero
  end;

  PVstMidiSysexEvent = ^TVstMidiSysexEvent;
  TVstMidiSysexEvent = record               // to be casted from a VstEvent
    EventType       : TVSTEventType;        // kVstSysexType
    ByteSize        : LongInt;              // 24
    DeltaFrames     : LongInt;              // sample frames related to the current block start sample position
    Flags           : LongInt;              // not defined yet
    dumpBytes       : LongInt;          		// byte size of sysexDump
    resvd1          : Pointer;              // zero (Reserved for future use)
    sysexDump       : PChar;                // sysex dump
    resvd2          : Pointer;              //< zero (Reserved for future use)
  end;

// VstTimeInfo ///////////////////////////////////////////////////////////////
//
// VstTimeInfo as requested via audioMasterGetTime (getTimeInfo())
// refers to the current time slice. note the new slice is
// already started when processEvents() is called

  TVstTimeInfoFlag = (
    vtiTransportChanged, // Indicates that Playing, Cycle or Recording has changed
    vtiTransportPlaying,
    vtiTransportCycleActive,
    vtiTransportRecording,
    vtiTransportUnused1,
    vtiTransportUnused2,
    vtiAutomationWriting,
    vtiAutomationReading,

    // flags which indicate which of the fields in this VstTimeInfo
    //  are valid; samplePos and sampleRate are always valid
    vtiNanosValid,
    vtiPpqPosValid,
    vtiTempoValid,
    vtiBarsValid,
    vtiCyclePosValid,  // start and end
    vtiTimeSigValid,
    vtiSmpteValid,
    vtiClockValid
  );
  TVstTimeInfoFlags = set of TVstTimeInfoFlag;

  PVstTimeInfo = ^TVstTimeInfo;
  TVstTimeInfo = packed record
    SamplePos          : Double;            // current location
    SampleRate         : Double;
    NanoSeconds        : Double;            // system time
    ppqPos             : Double;            // 1 ppq
    Tempo              : Double;            // in bpm
    BarStartPos        : Double;            // last bar start, in 1 ppq
    CycleStartPos      : Double;            // 1 ppq
    CycleEndPos        : Double;            // 1 ppq
    TimeSigNumerator   : LongInt;           // time signature
    TimeSigDenominator : LongInt;
    SmpteOffset        : LongInt;
    SmpteFrameRate     : LongInt;           // 0:24, 1:25, 2:29.97, 3:30, 4:29.97 df, 5:30 df
    SamplesToNextClock : LongInt;           // midi clock resolution (24 ppq), can be negative
    Flags              : TVstTimeInfoFlags; // see above
  end;

  PVstVariableIo = ^TVstVariableIo;
  TVstVariableIo = packed record
    Inputs                    : PPSingle;
    Outputs                   : PPSingle;
    numSamplesInput           : LongInt;
    numSamplesOutput          : LongInt;
    numSamplesInputProcessed  : PLongInt;
    numSamplesOutputProcessed : PLongInt;
  end;

  TVstHostLanguage = (
    kVstLangUnknown,
    kVstLangEnglish,
    kVstLangGerman,
    kVstLangFrench,
    kVstLangItalian,
    kVstLangSpanish,
    kVstLangJapanese
  );

  TVstParameterPropertiesFlag = (
    kVstParameterIsSwitch,
    kVstParameterUsesIntegerMinMax,
    kVstParameterUsesFloatStep,
    kVstParameterUsesIntStep,
    kVstParameterSupportsDisplayIndex,
    kVstParameterSupportsDisplayCategory,
    kVstParameterCanRamp);
  TVstParameterPropertiesFlags = set of TVstParameterPropertiesFlag;

  PVstParameterProperties = ^TVstParameterProperties;
  TVstParameterProperties = packed record
    StepFloat        : Single;
    SmallStepFloat   : Single;
    LargeStepFloat   : Single;
    Caption          : array[0..63] of Char;
    Flags            : TVstParameterPropertiesFlags;
    MinInteger       : LongInt;
    MaxInteger       : LongInt;
    StepInteger      : LongInt;
    LargeStepInteger : LongInt;
    ShortLabel       : array[0..7] of Char;   // recommended: 6 + delimiter

    // the following are for remote controller display purposes.
    // note that the kVstParameterSupportsDisplayIndex flag must be set.
    // host can scan all parameters, and find out in what order
    // to display them:
    DisplayIndex     : SmallInt;  // for remote controllers, the index where this parameter
                                  // should be displayed (starting with 0)

    // host can also possibly display the parameter group (category), such as
    // ---------------------------
    // Osc 1
    // Wave  Detune  Octave  Mod
    // ---------------------------
    // if the plug supports it (flag kVstParameterSupportsDisplayCategory)
    Category         : SmallInt;     // 0: no category, else group index + 1
    numParametersInCategory : SmallInt;
    Reserved         : SmallInt;
    CategoryLabel    : array[0..23] of Char;    // for instance, "Osc 1"
    Future           : array[0..15] of Char;
  end;

  TVstPinPropertiesFlag = (vppIsActive, vppIsStereo, vppUseSpeaker);
  TVstPinPropertiesFlags = set of TVstPinPropertiesFlag;

  PVstPinProperties = ^TVstPinProperties;
  TVstPinProperties = packed record
    Caption         : array[0..63] of char;
    Flags           : TVstPinPropertiesFlags; // see pin properties flags
    ArrangementType : LongInt;
    ShortLabel      : array[0..7] of Char;    // recommended: 6 + delimiter
    Future          : array[0..47] of Byte;
  end;

  TVstPluginCategory = (
    vpcUnknown,
    vpcEffect,
    vpcSynth,
    vpcAnalysis,
    vpcMastering,
    vpcSpacializer,    // 'panners'
    vpcRoomFx,         // delays and reverbs
    vpcSurroundFx,     // dedicated surround processor
    vpcRestoration,
    vpcOfflineProcess,
    vpcShell,          // plugin which is only a container of plugins.
    vpcGenerator
  );

  TMidiProgramNameFlag = (mpnIsOmni); // default is multi. for omni mode, channel 0 is used for inquiries and program changes
  TMidiProgramNameFlags = set of TMidiProgramNameFlag;

  PMidiProgramName = ^TMidiProgramName;
  TMidiProgramName = packed record
    ThisProgramIndex      : LongInt;  // >= 0. fill struct for this program index.
    Name                  : array[0..63] of char;
    MidiProgram           : shortint;  // -1:off, 0-127
    MidiBankMsb           : shortint;  // -1:off, 0-127
    MidiBankLsb           : shortint;  // -1:off, 0-127
    Reserved              : Byte;     // zero
    ParentCategoryIndex   : LongInt;  // -1:no parent category
    Flags                 : TMidiProgramNameFlags;  // omni etc, see below
  end;

  PMidiProgramCategory = ^TMidiProgramCategory;
  TMidiProgramCategory = packed record
    ThisCategoryIndex   : LongInt;      // >= 0. fill struct for this category index.
    Name                : array[0..63] of Char;
    ParentCategoryIndex : LongInt;      // -1:no parent category
    Flags               : LongInt;      // reserved, none defined yet, zero.
  end;

  PMidiKeyName = ^TMidiKeyName;
  TMidiKeyName = packed record
    ThisProgramIndex : LongInt;    // >= 0. fill struct for this program index.
    ThisKeyNumber    : LongInt;    // 0 - 127. fill struct for this key number.
    KeyName          : array[0..63] of char;
    Reserved         : LongInt;    // zero
    Flags            : LongInt;    // reserved, none defined yet, zero.
  end;

// surround setup ////////////////////////////////////////////////////////////

//---Speaker Types---------------------------------
// user-defined speaker types (to be extended in the negative range)
// (will be handled as their corresponding speaker types with abs values:
// e.g abs(stU1) == stL, abs(stU2) == stR)

  TVstSpeakerType = (
    {$IFDEF DELPHI6_UP}
    stU32                          = -32,
    stU31                          = -31,
    stU30                          = -30,
    stU29                          = -29,
    stU28                          = -28,
    stU27                          = -27,
    stU26                          = -26,
    stU25                          = -25,
    stU24                          = -24,
    stU23                          = -23,
    stU22                          = -22,
    stU21                          = -21,
    stU20                          = -20,       // == stLfe2
    stU19                          = -19,       // == stTrr
    stU18                          = -18,       // == stTrc
    stU17                          = -17,       // == stTrl
    stU16                          = -16,       // == stTfr
    stU15                          = -15,       // == stTfc
    stU14                          = -14,       // == stTfl
    stU13                          = -13,       // == stTm
    stU12                          = -12,       // == stSr
    stU11                          = -11,       // == stSl
    stU10                          = -10,       // == stCs
    stU9                           = -9,        // == stS
    stU8                           = -8,        // == stRc
    stU7                           = -7,        // == stLc
    stU6                           = -6,        // == stRs
    stU5                           = -5,        // == stLs
    stU4                           = -4,        // == stLfe
    stU3                           = -3,        // == stCenter
    stU2                           = -2,        // == stRight
    stU1                           = -1,        // == stLeft
    stUndefined                    = $7FFFFFFF, // Undefined
    {$ENDIF}
    stMono     {$IFDEF DELPHI6_UP} = 0 {$ENDIF},   // Mono (M)
    stLeft     {$IFDEF DELPHI6_UP} = 1 {$ENDIF},   // Left (L)
    stRight    {$IFDEF DELPHI6_UP} = 2 {$ENDIF},   // Right (R)
    stCenter   {$IFDEF DELPHI6_UP} = 3 {$ENDIF},   // Center (C)
    stLfe      {$IFDEF DELPHI6_UP} = 4 {$ENDIF},   // Subbass (Lfe)
    stLs       {$IFDEF DELPHI6_UP} = 5 {$ENDIF},   // Left Surround (Ls)
    stRs       {$IFDEF DELPHI6_UP} = 6 {$ENDIF},   // Right Surround (Rs)
    stLc       {$IFDEF DELPHI6_UP} = 7 {$ENDIF},   // Left of Center (Lc)
    stRc       {$IFDEF DELPHI6_UP} = 8 {$ENDIF},   // Right of Center (Rc)
    stSurround {$IFDEF DELPHI6_UP} = 9 {$ENDIF},   // Surround (S)
    stSl       {$IFDEF DELPHI6_UP} = 10 {$ENDIF},  // Side Left (Sl)
    stSr       {$IFDEF DELPHI6_UP} = 11 {$ENDIF},  // Side Right (Sr)
    stTm       {$IFDEF DELPHI6_UP} = 12 {$ENDIF},  // Top Middle (Tm)
    stTfl      {$IFDEF DELPHI6_UP} = 13 {$ENDIF},  // Top Front Left (Tfl)
    stTfc      {$IFDEF DELPHI6_UP} = 14 {$ENDIF},  // Top Front Center (Tfc)
    stTfr      {$IFDEF DELPHI6_UP} = 15 {$ENDIF},  // Top Front Right (Tfr)
    stTrl      {$IFDEF DELPHI6_UP} = 16 {$ENDIF},  // Top Rear Left (Trl)
    stTrc      {$IFDEF DELPHI6_UP} = 17 {$ENDIF},  // Top Rear Center (Trc)
    stTrr      {$IFDEF DELPHI6_UP} = 18 {$ENDIF},  // Top Rear Right (Trr)
    stLfe2     {$IFDEF DELPHI6_UP} = 19 {$ENDIF}); // Subbass 2 (Lfe2)

  PVstSpeakerProperties = ^TVstSpeakerProperties;
  TVstSpeakerProperties = record      // units:      range:            except:
    Azimuth   : Single;               // rad         -PI...PI    10.f for LFE channel
    Elevation : Single;               // rad         -PI/2...PI/2  10.f for LFE channel
    Radius    : Single;               // meter                          0.f for LFE channel
    Reserved  : Single;               // 0.
    Name      : array[0..63] of char; // for new setups, new names should be given (L/R/C... won't do)
    vType     : TVstSpeakerType;      // speaker type
    Future    : array[0..27] of Byte;
  end;

// note: the origin for azimuth is right (as by math conventions dealing with radians);
// the elevation origin is also right, visualizing a rotation of a circle across the
// -pi/pi axis of the horizontal circle. thus, an elevation of -pi/2 corresponds
// to bottom, and a speaker standing on the left, and 'beaming' upwards would have
// an azimuth of -pi, and an elevation of pi/2.
// for user interface representation, grads are more likely to be used, and the
// origins will obviously 'shift' accordingly.

  PVstSpeakerArrangement = ^TVstSpeakerArrangement;
  TVstSpeakerArrangement = record
    vType       : LongInt;                               // (was float lfeGain) LFE channel gain is adjusted [dB] higher than other channels)
    numChannels : LongInt;                               // number of channels in this speaker arrangement
    Speakers    : array[0..7] of TVstSpeakerProperties;  // variable
  end;

  TVstSpeakerArrangementType = (
    {$IFDEF DELPHI6_UP}
    satUserDefined     = -2,
    satEmpty           = -1,
    {$ENDIF}
    satMono            {$IFDEF DELPHI6_UP} =  0 {$ENDIF},  // M
    satStereo          {$IFDEF DELPHI6_UP} =  1 {$ENDIF},  // L R
    satStereoSurround  {$IFDEF DELPHI6_UP} =  2 {$ENDIF},  // Ls Rs
    satStereoCenter    {$IFDEF DELPHI6_UP} =  3 {$ENDIF},  // Lc Rc
    satStereoSide      {$IFDEF DELPHI6_UP} =  4 {$ENDIF},  // Sl Sr
    satStereoCLfe      {$IFDEF DELPHI6_UP} =  5 {$ENDIF},  // C Lfe
    sat30Cine          {$IFDEF DELPHI6_UP} =  6 {$ENDIF},  // L R C
    sat30Music         {$IFDEF DELPHI6_UP} =  7 {$ENDIF},  // L R S
    sat31Cine          {$IFDEF DELPHI6_UP} =  8 {$ENDIF},  // L R C Lfe
    sat31Music         {$IFDEF DELPHI6_UP} =  9 {$ENDIF},  // L R Lfe S
    sat40Cine          {$IFDEF DELPHI6_UP} = 10 {$ENDIF},  // L R C   S (LCRS)
    sat40Music         {$IFDEF DELPHI6_UP} = 11 {$ENDIF},  // L R Ls  Rs (Quadro)
    sat41Cine          {$IFDEF DELPHI6_UP} = 12 {$ENDIF},  // L R C   Lfe S (LCRS+Lfe)
    sat41Music         {$IFDEF DELPHI6_UP} = 13 {$ENDIF},  // L R Lfe Ls Rs (Quadro+Lfe)
    sat50              {$IFDEF DELPHI6_UP} = 14 {$ENDIF},  // L R C Ls  Rs
    sat51              {$IFDEF DELPHI6_UP} = 15 {$ENDIF},  // L R C Lfe Ls Rs
    sat60Cine          {$IFDEF DELPHI6_UP} = 16 {$ENDIF},  // L R C   Ls  Rs Cs
    sat60Music         {$IFDEF DELPHI6_UP} = 17 {$ENDIF},  // L R Ls  Rs  Sl Sr
    sat61Cine          {$IFDEF DELPHI6_UP} = 18 {$ENDIF},  // L R C   Lfe Ls Rs Cs
    sat61Music         {$IFDEF DELPHI6_UP} = 19 {$ENDIF},  // L R Lfe Ls  Rs Sl Sr
    sat70Cine          {$IFDEF DELPHI6_UP} = 20 {$ENDIF},  // L R C Ls  Rs Lc Rc
    sat70Music         {$IFDEF DELPHI6_UP} = 21 {$ENDIF},  // L R C Ls  Rs Sl Sr
    sat71Cine          {$IFDEF DELPHI6_UP} = 22 {$ENDIF},  // L R C Lfe Ls Rs Lc Rc
    sat71Music         {$IFDEF DELPHI6_UP} = 23 {$ENDIF},  // L R C Lfe Ls Rs Sl Sr
    sat80Cine          {$IFDEF DELPHI6_UP} = 24 {$ENDIF},  // L R C Ls  Rs Lc Rc Cs
    sat80Music         {$IFDEF DELPHI6_UP} = 25 {$ENDIF},  // L R C Ls  Rs Cs Sl Sr
    sat81Cine          {$IFDEF DELPHI6_UP} = 26 {$ENDIF},  // L R C Lfe Ls Rs Lc Rc Cs
    sat81Music         {$IFDEF DELPHI6_UP} = 27 {$ENDIF},  // L R C Lfe Ls Rs Cs Sl Sr
    sat102             {$IFDEF DELPHI6_UP} = 28 {$ENDIF},  // L R C Lfe Ls Rs Tfl Tfc Tfr Trl Trr Lfe2
    satNumSpeakerArr   {$IFDEF DELPHI6_UP} = 29 {$ENDIF});

  TVstOfflineTaskFlag = (
    votUnvalidParameter,
    votNewFile,
    votUnused1,
    votUnused2,
    votUnused3,
    votUnused4,
    votUnused5,
    votUnused6,
    votUnused7,
    votUnused8,
    votPlugError,
    votInterleavedAudio,
    votTempOutputFile,
    votFloatOutputFile,
    votRandomWrite,
    votStretch,
    votNoThread
  );
  TVstOfflineTaskFlags = set of TVstOfflineTaskFlag;

  PVstOfflineTask = ^TVstOfflineTask;
  TVstOfflineTask = packed record
    processName: array[0..95] of char;  // set by plug

    // audio access
    ReadPosition: Double;               // set by plug/host
    WritePosition: Double;              // set by plug/host
    ReadCount: LongInt;                 // set by plug/host
    WriteCount: LongInt;                // set by plug
    SizeInputBuffer: LongInt;           // set by host
    SizeOutputBuffer: LongInt;          // set by host
    InputBuffer: Pointer;               // set by host
    OutputBuffer: Pointer;              // set by host
    PositionToProcessFrom: Double;      // set by host
    NumFramesToProcess: Double;         // set by host
    MaxFramesToWrite: Double;           // set by plug

    // other data access
    ExtraBuffer: Pointer;               // set by plug
    Value: LongInt;                     // set by host or plug
    Index: LongInt;                     // set by host or plug

    // file attributes
    NumFramesInSourceFile: Double;      // set by host
    SourceSampleRate: Double;           // set by host or plug
    DestinationSampleRate: Double;      // set by host or plug
    NumSourceChannels: LongInt;         // set by host or plug
    NumDestinationChannels: LongInt;    // set by host or plug
    SourceFormat: LongInt;              // set by host
    DestinationFormat: LongInt;         // set by plug
    OutputText: array[0..511] of char;  // set by plug or host

    // progress notification
    Progress: Double;                   // set by plug
    ProgressMode: LongInt;              // reserved for future
    ProgressText: array[0..99] of char; // set by plug

    Flags: TVstOfflineTaskFlags;        // set by host and plug; see TVstOfflineTaskFlags
    ReturnValue: LongInt;               // reserved for future
    HostOwned: Pointer;                 // set by host
    PlugOwned: Pointer;                 // set by plug

    Future: array[0..1023] of Byte;
  end;

  TVstOfflineOption = (
    vooAudio,      // reading/writing audio samples
    vooPeaks,      // reading graphic representation
    vooParameter,  // reading/writing parameters
    vooMarker,     // reading/writing marker
    vooCursor,     // reading/moving edit cursor
    vooSelection,  // reading/changing selection
    vooQueryFiles  // to request the host to call asynchronously offlineNotify
  );

  TVstAudioFileFlag = (
    // set by host (in call offlineNotify)
    vafReadOnly,
    vafNoRateConversion,
    vafNoChannelChange,
    vafUnused1,
    vafUnused2,
    vafUnused3,
    vafUnused4,
    vafUnused5,
    vafUnused6,
    vafUnused7,

    // Set by plug (in function offlineStart)
    vafCanProcessSelection,
    vafNoCrossfade,
    vafWantRead,
    vafWantWrite,
    vafWantWriteMarker,
    vafWantMoveCursor,
    vafWantSelect
  );
  TVstAudioFileFlags = set of TVstAudioFileFlag;

  PVstAudioFile = ^TVstAudioFile;
  TVstAudioFile = packed record
    Flags: TVstAudioFileFlags;     // see enum TVstAudioFileFlags
    HostOwned: Pointer;            // any data private to host
    PlugOwned: Pointer;            // any data private to plugin
    Name: array[0..99] of char;    // file title
    UniqueId: LongInt;             // uniquely identify a file during a session
    SampleRate: Double;            // file sample rate
    NumChannels: LongInt;          // number of channels (1 for mono, 2 for stereo...)
    NumFrames: Double;             // number of frames in the audio file
    Format: LongInt;               // reserved for future
    EditCursorPosition: Double;    // -1 if no such cursor
    SelectionStart: Double;        // frame index of first selected frame, or -1
    SelectionSize: Double;         // number of frames in selection, or 0
    SelectedChannelsMask: LongInt; // 1 bit per channel
    NumMarkers: LongInt;           // number of markers in the file
    TimeRulerUnit: LongInt;        // see doc for possible values
    TimeRulerOffset: Double;       // offset in time ruler (positive or negative)
    Tempo: Double;                 // as bpm
    TimeSigNumerator: LongInt;     // time signature numerator
    TimeSigDenominator: LongInt;   // time signature denominator
    TicksPerBlackNote: LongInt;    // resolution
    SmpteFrameRate: LongInt;       // smpte rate (set as in TVstTimeInfo)
    Future: array[0..63] of Byte;
  end;

  PVstAudioFileMarker = ^TVstAudioFileMarker;
  TVstAudioFileMarker = packed record
    Position: Double;
    Name: array[0..31] of char;
    vType: LongInt;
    ID: LongInt;
    Reserved: LongInt;
  end;

  PVstWindow = ^TVstWindow;
  TVstWindow = packed record
    Title: array[0..127] of char;    // title
    xPos: SmallInt;                  // position and size
    yPos: SmallInt;
    Width: SmallInt;
    Height: SmallInt;
    Style: LongInt;                  // 0: with title, 1: without title

    Parent: Pointer;                 // parent of this window
    userHandle: Pointer;             // reserved
    winHandle: Pointer;              // reserved

    Future: array[0..103] of Byte;
  end;

  PVstKeyCode = ^TVstKeyCode;
  TVstKeyCode = packed record
    Character : LongInt;
    Virt      : Byte;     // see enum TVstVirtualKey
    Modifier  : Byte;     // see enum TVstModifierKey
  end;

// Used by member virt of VstKeyCode /////////////////////////////////////////
  TVstVirtualKey = LongInt;

const
  VKEY_BACK         = 1;
  VKEY_TAB          = 2;
  VKEY_CLEAR        = 3;
  VKEY_RETURN       = 4;
  VKEY_PAUSE        = 5;
  VKEY_ESCAPE       = 6;
  VKEY_SPACE        = 7;
  VKEY_NEXT         = 8;
  VKEY_END          = 9;
  VKEY_HOME         = 10;

  VKEY_LEFT         = 11;
  VKEY_UP           = 12;
  VKEY_RIGHT        = 13;
  VKEY_DOWN         = 14;
  VKEY_PAGEUP       = 15;
  VKEY_PAGEDOWN     = 16;

  VKEY_SELECT       = 17;
  VKEY_PRINT        = 18;
  VKEY_ENTER        = 19;
  VKEY_SNAPSHOT     = 20;
  VKEY_INSERT       = 21;
  VKEY_DELETE       = 22;
  VKEY_HELP         = 23;
  VKEY_NUMPAD0      = 24;
  VKEY_NUMPAD1      = 25;
  VKEY_NUMPAD2      = 26;
  VKEY_NUMPAD3      = 27;
  VKEY_NUMPAD4      = 28;
  VKEY_NUMPAD5      = 29;
  VKEY_NUMPAD6      = 30;
  VKEY_NUMPAD7      = 31;
  VKEY_NUMPAD8      = 32;
  VKEY_NUMPAD9      = 33;
  VKEY_MULTIPLY     = 34;
  VKEY_ADD          = 35;
  VKEY_SEPARATOR    = 36;
  VKEY_SUBTRACT     = 37;
  VKEY_DECIMAL      = 38;
  VKEY_DIVIDE       = 39;
  VKEY_F1           = 40;
  VKEY_F2           = 41;
  VKEY_F3           = 42;
  VKEY_F4           = 43;
  VKEY_F5           = 44;
  VKEY_F6           = 45;
  VKEY_F7           = 46;
  VKEY_F8           = 47;
  VKEY_F9           = 48;
  VKEY_F10          = 49;
  VKEY_F11          = 50;
  VKEY_F12          = 51;
  VKEY_NUMLOCK      = 52;
  VKEY_SCROLL       = 53;

  VKEY_SHIFT        = 54;
  VKEY_CONTROL      = 55;
  VKEY_ALT          = 56;

  VKEY_EQUALS       = 57;


// Used by member modifier of VstKeyCode /////////////////////////////////////
type
  TVstModifierKeys = LongInt;

const
  MODIFIER_SHIFT = 1;
  MODIFIER_ALTERNATE = 2;
  MODIFIER_COMMAND = 4;
  MODIFIER_CONTROL = 8;

// Used by audioMasterOpenFileSelector ///////////////////////////////////////
type
  PVstFileType = ^TVstFileType;
  TVstFileType = packed record
    name      : array[0..127] of char;
    macType   : array[0..7] of char;
    dosType   : array[0..7] of char;
    unixType  : array[0..7] of char;
    mimeType1 : array[0..127] of char;
    mimeType2 : array[0..127] of char;
  end;

  TVstFileCommand = (
    kVstFileLoad,
    kVstFileSave,
    kVstMultipleFilesLoad ,
    kVstDirectorySelect
  );

  TVstFileTypeType = (kVstFileType);

  PVstFileSelect = ^TVstFileSelect;
  TVstFileSelect = packed record
    Command              : TVstFileCommand;  // see enum kVstFileLoad....
    vType                : TVstFileTypeType; // see enum kVstFileType...
    MacCreator           : LongInt;          // optional: 0 = no creator
    nbFileTypes          : LongInt;          // nb of fileTypes to used
    FileTypes            : PVstFileType;     // list of fileTypes
    Title                : array[0..1023] of char;  // text display in the file selector's title
    InitialPath          : PChar;   // initial path
    ReturnPath           : PChar;   // use with kVstFileLoad and kVstDirectorySelect
                                    // if null is passed, the host will allocated memory
                                    // the plugin should then called closeOpenFileSelector for freeing memory
    SizeReturnPath       : LongInt;
    ReturnMultiplePaths  : ^PChar;  // use with kVstMultipleFilesLoad
                                    // the host allocates this array. The plugin should then called closeOpenFileSelector for freeing memory
    nbReturnPath         : LongInt; // number of selected paths
    Reserved             : LongInt; // reserved for host application
    Future               : array[0..115] of Byte;   // future use
  end;

  PVstPatchChunkInfo = ^TVstPatchChunkInfo;
  TVstPatchChunkInfo = packed record
    version        : LongInt;               // Format Version (should be 1)
    pluginUniqueID : LongInt;               // UniqueID of the plugin
    pluginVersion  : LongInt;               // Plugin Version
    numElements    : LongInt;               // Number of Programs (Bank) or Parameters (Program)
    future         : array[0..47] of char;
  end;

  TVstPanLawType = (
    kLinearPanLaw,      // L = pan * M; R = (1 - pan) * M;
    kEqualPowerPanLaw); // L = pow (pan, 0.5) * M; R = pow ((1 - pan), 0.5) * M;

const
  cMagic           = 'CcnK';
  presetMagic      = 'FxCk';
  bankMagic        = 'FxBk';
  chunkPresetMagic = 'FPCh';
  chunkBankMagic   = 'FBCh';
  chunkGlobalMagic = 'FxCh'; // not used
  fMagic           = presetMagic;

type
  //--------------------------------------------------------------------
  // For Preset (Program) (.fxp) without chunk (magic = 'FxCk')
  //--------------------------------------------------------------------
  TFXPreset = packed record
    chunkMagic : LongInt;   // 'CcnK'
    ByteSize   : LongInt;   // of this chunk, excl. magic + ByteSize

    fxMagic    : LongInt;   // 'FxCk'
    version    : LongInt;
    fxID       : LongInt;   // fx unique id
    fxVersion  : LongInt;

    numParams  : LongInt;
    prgName    : array[0..27] of Char;
    params     : Pointer; //array[0..0] of Single;    // variable no. of parameters
  end;

  //--------------------------------------------------------------------
  // For Preset (Program) (.fxp) with chunk (magic = 'FPCh')
  //--------------------------------------------------------------------
  TFXChunkSet = packed record
    chunkMagic  : LongInt;                // 'CcnK'
    ByteSize    : LongInt;                // of this chunk, excl. magic + ByteSize

    fxMagic     : LongInt;                // 'FPCh'
    version     : LongInt;
    fxID        : LongInt;                // fx unique id
    fxVersion   : LongInt;

    numPrograms : LongInt;
    prgName     : array[0..27] of Char;

    chunkSize   : LongInt;
    chunk       : Pointer; //array[0..7] of char;    // variable
  end;

  //--------------------------------------------------------------------
  // For Bank (.fxb) without chunk (magic = 'FxBk')
  //--------------------------------------------------------------------
  TFXSet = packed record
    chunkMagic  : LongInt;                   // 'CcnK'
    ByteSize    : LongInt;                   // of this chunk, excl. magic + ByteSize

    fxMagic     : LongInt;                   // 'FxBk'
    version     : LongInt;
    fxID        : LongInt;                   // fx unique id
    fxVersion   : LongInt;

    numPrograms : LongInt;
    future      : array[0..127] of Byte;

    programs    : Pointer;//array[0..0] of fxPreset;  // variable no. of programs
  end;

  //--------------------------------------------------------------------
  // For Bank (.fxb) with chunk (magic = 'FBCh')
  //--------------------------------------------------------------------
  TFXChunkBank = packed record
    chunkMagic  : LongInt;                // 'CcnK'
    ByteSize    : LongInt;                // of this chunk, excl. magic + ByteSize

    fxMagic     : LongInt;                // 'FBCh'
    version     : LongInt;
    fxID        : LongInt;                // fx unique id
    fxVersion   : LongInt;

    numPrograms : LongInt;
    future      : array[0..127] of Byte;

    chunkSize   : LongInt;
    chunk       : Pointer; //array[0..7] of char;    // variable
  end;

  PPERect = ^PERect;
  PERect = ^ERect;
  ERect = record
    Top, Left,
    Bottom, Right : Smallint;
  end;

function FourCharToLong(C1, C2, C3, C4: Char): Longint;
function FMod(d1, d2: Double): Double;
function Rect(Left, Top, Right, Bottom : Smallint):ERect;

procedure dB2string(value: Single; text: PChar);
procedure dB2stringRound(value: Single; text: PChar);
procedure float2string(value: Single; text: PChar);
procedure long2string(value: Longint; text: PChar);
procedure float2stringAsLong(value: Single; text: PChar);
procedure Hz2string(samples, sampleRate: Single; text: PChar);
procedure ms2string(samples, sampleRate: Single; text: PChar);

function gapSmallValue(value, maxValue: Double): Double;
function invGapSmallValue(value, maxValue: Double): Double;

function Opcode2String(opcode: TDispatcherOpcode): string;
function KeyCodeToInteger(VKC:TVstKeyCode):Integer;

implementation

uses Math, SysUtils;

{ this function converts four char variables to one LongInt. }
function FourCharToLong(C1, C2, C3, C4: Char): Longint;
begin
  Result := Ord(C4)  + (Ord(C3) shl 8) + (Ord(C2) shl 16) + (Ord(C1) shl 24);
end;

function FMod(d1, d2: Double): Double;
var
   i: Integer;
begin
  try
    i := Trunc(d1 / d2);
  except
    on EInvalidOp do i := High(Longint);
  end;
  Result := d1 - (i * d2);
end;

procedure dB2string(value: Single; text: PChar);
begin
 if (value <= 0)
  then StrCopy(text, '   -oo  ')
  else float2string(20 * log10(value), text);
end;

procedure dB2stringRound(value: Single; text: PChar);
begin
 if (value <= 0)
  then StrCopy(text, '    -96 ')
  else long2string(Round(20 * log10(value)), text);
end;

procedure float2string(value: Single; text: PChar);
begin
 StrCopy(text, PChar(Format('%f', [value])));
end;

procedure long2string(value: Longint; text: PChar);
begin
  if (value >= 100000000) then
  begin
    StrCopy(text, ' Huge!  ');
    Exit;
  end;
  StrCopy(text, PChar(Format('%7d', [Value])));
end;

procedure float2stringAsLong(value: Single; text: PChar);
begin
 if (value >= 100000000) then
  begin
   StrCopy(text, ' Huge!  ');
   Exit;
  end;
 StrCopy(text, PChar(Format('%7.0f', [value])));
end;

procedure Hz2string(samples, sampleRate: Single; text: PChar);
begin
 if (samples = 0)
  then float2string(0, text)
  else float2string(sampleRate / samples, text);
end;

procedure ms2string(Samples, SampleRate: Single; Text: PChar);
begin
 float2string(samples * 1000 / sampleRate, text);
end;

function gapSmallValue(value, maxValue: double): double;
begin
 Result := Power(maxValue, value);
end;

function invGapSmallValue(value, maxValue: double): double;
var r: Double;
begin
 r := 0;
 if (value <> 0)
  then r := logN(maxValue, value);
 Result :=  r;
end;

function Rect(Left, Top, Right, Bottom : Smallint):ERect;
begin
 Result.Left:=Left;
 Result.Top:=Top;
 Result.Right:=Right;
 Result.Bottom:=Bottom;
end;

function opcode2String(Opcode: TDispatcherOpcode): string;
begin
 case Opcode of
  effOpen                           : Result := 'effOpen';
  effClose                          : Result := 'effClose';
  effSetProgram                     : Result := 'effSetProgram';
  effGetProgram                     : Result := 'effGetProgram';
  effSetProgramName                 : Result := 'effSetProgramName';
  effGetProgramName                 : Result := 'effGetProgramName';
  effGetParamLabel                  : Result := 'effGetParamLabel';
  effGetParamDisplay                : Result := 'effGetParamDisplay';
  effGetParamName                   : Result := 'effGetParamName';
  effGetVu                          : Result := 'effGetVu';
  effSetSampleRate                  : Result := 'effSetSampleRate';
  effSetBlockSize                   : Result := 'effSetBlockSize';
  effMainsChanged                   : Result := 'effMainsChanged';
  effEditGetRect                    : Result := 'effEditGetRect';
  effEditOpen                       : Result := 'effEditOpen';
  effEditClose                      : Result := 'effEditClose';
  effEditDraw                       : Result := 'effEditDraw';
  effEditMouse                      : Result := 'effEditMouse';
  effEditKey                        : Result := 'effEditKey';
  effEditIdle                       : Result := 'effEditIdle';
  effEditTop                        : Result := 'effEditTop';
  effEditSleep                      : Result := 'effEditSleep';
  effIdentify                       : Result := 'effIdentify';
  effGetChunk                       : Result := 'effGetChunk';
  effSetChunk                       : Result := 'effSetChunk';
  effProcessEvents                  : Result := 'effProcessEvents';
  effCanBeAutomated                 : Result := 'effCanBeAutomated';
  effString2Parameter               : Result := 'effString2Parameter';
  effGetNumProgramCategories        : Result := 'effGetNumProgramCategories';
  effGetProgramNameIndexed          : Result := 'effGetProgramNameIndexed';
  effCopyProgram                    : Result := 'effCopyProgram';
  effConnectInput                   : Result := 'effConnectInput';
  effConnectOutput                  : Result := 'effConnectOutput';
  effGetInputProperties             : Result := 'effGetInputProperties';
  effGetOutputProperties            : Result := 'effGetOutputProperties';
  effGetPlugCategory                : Result := 'effGetPlugCategory';
  effGetCurrentPosition             : Result := 'effGetCurrentPosition';
  effGetDestinationBuffer           : Result := 'effGetDestinationBuffer';
  effOfflineNotify                  : Result := 'effOfflineNotify';
  effOfflinePrepare                 : Result := 'effOfflinePrepare';
  effOfflineRun                     : Result := 'effOfflineRun';
  effProcessVarIo                   : Result := 'effProcessVarIo';
  effSetSpeakerArrangement          : Result := 'effSetSpeakerArrangement';
  effSetBlockSizeAndSampleRate      : Result := 'effSetBlockSizeAndSampleRate';
  effSetBypass                      : Result := 'effSetBypass';
  effGetEffectName                  : Result := 'effGetEffectName';
  effGetErrorText                   : Result := 'effGetErrorText';
  effGetVendorString                : Result := 'effGetVendorString';
  effGetProductString               : Result := 'effGetProductString';
  effGetVendorVersion               : Result := 'effGetVendorVersion';
  effVendorSpecific                 : Result := 'effVendorSpecific';
  effCanDo                          : Result := 'effCanDo';
  effGetTailSize                    : Result := 'effGetTailSize';
  effIdle                           : Result := 'effIdle';
  effGetIcon                        : Result := 'effGetIcon';
  effSetViewPosition                : Result := 'effSetViewPosition';
  effGetParameterProperties         : Result := 'effGetParameterProperties';
  effKeysRequired                   : Result := 'effKeysRequired';
  effGetVstVersion                  : Result := 'effGetVstVersion';
  effEditKeyDown                    : Result := 'effEditKeyDown';
  effEditKeyUp                      : Result := 'effEditKeyUp';
  effSetEditKnobMode                : Result := 'effSetEditKnobMode';
  effGetMidiProgramName             : Result := 'effGetMidiProgramName';
  effGetCurrentMidiProgram          : Result := 'effGetCurrentMidiProgram';
  effGetMidiProgramCategory         : Result := 'effGetMidiProgramCategory';
  effHasMidiProgramsChanged         : Result := 'effHasMidiProgramsChanged';
  effGetMidiKeyName                 : Result := 'effGetMidiKeyName';
  effBeginSetProgram                : Result := 'effBeginSetProgram';
  effEndSetProgram                  : Result := 'effEndSetProgram';
  effGetSpeakerArrangement          : Result := 'effGetSpeakerArrangement';
  effShellGetNextPlugin             : Result := 'effShellGetNextPlugin';
  effStartProcess                   : Result := 'effStartProcess';
  effStopProcess                    : Result := 'effStopProcess';
  effSetTotalSampleToProcess        : Result := 'effSetTotalSampleToProcess';
  effSetPanLaw                      : Result := 'effSetPanLaw';
  effBeginLoadBank                  : Result := 'effBeginLoadBank';
  effBeginLoadProgram               : Result := 'effBeginLoadProgram';
  effSetProcessPrecision            : Result := 'effSetProcessPrecision';
  effGetNumMidiInputChannels        : Result := 'effGetNumMidiInputChannels';
  effGetNumMidiOutputChannels       : Result := 'effGetNumMidiOutputChannels';
  else Result := 'unkown opcode: ' +IntToStr(Integer(Opcode));
 end;
end;

function KeyCodeToInteger(VKC:TVstKeyCode):Integer;
begin
 if (VKC.character=0) then
  begin
{$IFNDEF FPC}
   case VKC.virt of
    VKEY_BACK: Result := VK_BACK;
    VKEY_TAB: Result := VK_TAB;
    VKEY_CLEAR: Result := VK_CLEAR;
    VKEY_RETURN: Result := VK_RETURN;
    VKEY_PAUSE: Result := VK_PAUSE;
    VKEY_ESCAPE: Result := VK_ESCAPE;
    VKEY_SPACE: Result := VK_SPACE;
    VKEY_NEXT: Result := VK_NEXT;
    VKEY_END: Result := VK_END;
    VKEY_HOME: Result := VK_HOME;
    VKEY_LEFT: Result := VK_LEFT;
    VKEY_UP: Result := VK_UP;
    VKEY_RIGHT: Result := VK_RIGHT;
    VKEY_DOWN: Result := VK_DOWN;
    VKEY_PAGEUP: Result := VK_UP;
    VKEY_PAGEDOWN: Result := VK_DOWN;
    VKEY_SELECT: Result := VK_SELECT;
    VKEY_PRINT: Result := VK_PRINT;
    VKEY_ENTER: Result := VK_RETURN;
    VKEY_SNAPSHOT: Result := VK_SNAPSHOT;
    VKEY_INSERT: Result := VK_INSERT;
    VKEY_DELETE: Result := VK_DELETE;
    VKEY_HELP: Result := VK_HELP;
    VKEY_NUMPAD0: Result := 48; //VK_NUMPAD0;
    VKEY_NUMPAD1: Result := 49; //VK_NUMPAD1;
    VKEY_NUMPAD2: Result := 50; //VK_NUMPAD2;
    VKEY_NUMPAD3: Result := 51; //VK_NUMPAD3;
    VKEY_NUMPAD4: Result := 52; //VK_NUMPAD4;
    VKEY_NUMPAD5: Result := 53; //VK_NUMPAD5;
    VKEY_NUMPAD6: Result := 54; //VK_NUMPAD6;
    VKEY_NUMPAD7: Result := 55; //VK_NUMPAD7;
    VKEY_NUMPAD8: Result := 56; //VK_NUMPAD8;
    VKEY_NUMPAD9: Result := 57; //VK_NUMPAD9;
    VKEY_MULTIPLY: Result := VK_MULTIPLY;
    VKEY_ADD: Result := VK_ADD;
    VKEY_SEPARATOR: Result := VK_SEPARATOR;
    VKEY_SUBTRACT: Result := VK_SUBTRACT;
    VKEY_DECIMAL: Result := VK_DECIMAL;
    VKEY_DIVIDE: Result := VK_DIVIDE;
    VKEY_F1: Result := VK_F1;
    VKEY_F2: Result := VK_F2;
    VKEY_F3: Result := VK_F3;
    VKEY_F4: Result := VK_F4;
    VKEY_F5: Result := VK_F5;
    VKEY_F6: Result := VK_F6;
    VKEY_F7: Result := VK_F7;
    VKEY_F8: Result := VK_F8;
    VKEY_F9: Result := VK_F9;
    VKEY_F10: Result := VK_F10;
    VKEY_F11: Result := VK_F11;
    VKEY_F12: Result := VK_F12;
    VKEY_NUMLOCK: Result := VK_NUMLOCK;
    VKEY_SCROLL: Result := VK_SCROLL;
    VKEY_SHIFT: Result := VK_SHIFT;
    VKEY_CONTROL: Result := VK_CONTROL;
    VKEY_ALT: Result := VK_MENU;
    VKEY_EQUALS: Result := $5D;
    else Result := VKC.character;
   end;
{$ENDIF}
  end
 else
  begin
   Result := VKC.character;
   if ((VKC.modifier and MODIFIER_SHIFT)<>0)
    then Dec(Result,32);
  end;
end;

{$WARNINGS ON}

end.
