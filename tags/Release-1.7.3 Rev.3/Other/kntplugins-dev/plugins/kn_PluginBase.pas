unit kn_PluginBase;

interface
uses Windows;

const
  // arbitrary, maximum length of text that KeyNote will
  // display in a dialog box. If plugin wants KeyNote
  // to show its output in a dialog box, output will be
  // truncated to this length
  _MAX_DLGBOX_MSG_LEN = 512;


type
  // These are used by the "KNTGetPluginFeatures" function to
  // inform KeyNote about the way the plugin works. They MUST be
  // be set properly, otherwise there will be a miscommunication
  // between KeyNote and the plugin.
  // The state of each flag (TRUE or FALSE) ir encoded in one bit
  // of the longint value that the KNTGetPluginFeatures function
  // returns. See source code for examples; basically, you use the
  // ordinal number of each of these flags as the number of the bit
  // to set or clear. Use the "gf_bits.pas" unit if you need bitwide
  // operation support.
  // SEE BELOW FOR EXPLANATION of the meaning each value.
  TPluginFeature = (
    plOK,
    plGetsData,
    plGetsRTF,
    plGetsSelection,
    plReturnsData,
    plReturnsRTF,
    plReturnsClipboard,
    plNeedsSelection,
    plWantsNewNote, // not implemented
    plWantsDlgBox,
    plWantsSavedFile, // not implemented
    plReloadFile, // not implemented
    plStaysResident
  );
  TPluginFeatures = set of TPluginFeature;

(*
EXPLANATION OF TPluginFeature ordinal type

plOK
  MUST be set; otherwise KeyNote will not run te plugin.
  Useful if the plugin wants to refuse to run.

plGetsData
  - If set, tells KeyNote that the plugin expects to receive data
  (text) from active note.
  - If not set, KeyNote will not pass any data whatsoever to the
  plugin.

plGetsRTF
  - If set, KeyNote will send RTF text to the plugin.
  - If not set, KeyNote will send plain text.

plGetsSelection
  - If set, KeyNote will send to the plugin only the text which is
  currently selected in the active note. If no text is selected
  in active note, KeyNote will run the plugin without passing any
  text to it, or will not run the plugin at all: see plNeedsSelection.
  NOTE: the state of "plGetsRTF" flag is respected; ie the selected
  text can be passed as RTF or plain text format.
  - If not set, KeyNote will pass to the plugin the complete text of
  active note (in RTF or plain text format)

plReturnsData
  - If set, KeyNote will know that the plugin will attempt to return
  text after it has been executed.
  - If not set, KeyNote will not expect the plugin to return any text.
  NOTE: this flag is ignored for resident plugins, which must use other
  techniques for passing text or other data back to KeyNote.

plReturnsRTF
  - If set, KeyNote will assume that the text returned by the plugin
  is in RTF format.
  - If not set, KeyNote will assume plain text format.
  NOTE: It's very important that this flag be set correctly!
  You will confuse KeyNote otherwise.

plReturnsClipboard
  - If set, it informs KeyNote that the plugin puts data in Clipboard
  when executed (rather than returning the data directly to KeyNote).
  KeyNote will offer the user a possibility of pasting the clipboard
  data into the active note (KeyNote can also be configured to paste
  such data automatically).
  NOTE: This gives you the ability to create plugins which output
  data other than text. For instance, if the plugin creates a bitmap,
  the bitmap could not be passed back to KeyNote via the standard
  techniques above. Instead, you could put the bitmap in Clipboard,
  and the user can paste it into a note.

plNeedsSelection
  - If set, and if plGetsSelection is also set, KeyNote will check
  if any text is selected in active note before running the plugin.
  If no text is selected, KeyNote will display an error message and
  refuse to execute the plugin.
  - If not set, KeyNote will just pass an empty string to the plugin
  if no text is selected.

plWantsNewNote, // not implemented
  - If set, KeyNote will place the text returned by the plugin
  in a new note. The new note (simple RTF, not a tree-type note)
  will be created automatically if the plugin returns any textual
  data.
  - If not set, the text returned by the plugin will be placed
  in active note.

plWantsDlgBox
  - If set, and if the plugin returns any text, KeyNote will display
  the returned text in a dialog box. The maximum length of the text
  that KeyNote will show in a dialog box is defined in the
  _MAX_DLGBOX_MSG_LEN constant, on top of this unit. The user will
  have an option of inserting the text into the active note.

plWantsSavedFile // not implemented
  - If set, KeyNote will save the currently open file before running
  the plugin. This is useful if the plugin will operate directly on
  the .KNT file.

plReloadFile // not implemented
  - If set, KeyNote will reload the current file after the plugin has
  been executed. This is useful if the plugin will operate directly on
  the .KNT file.

plStaysResident
  - If set, KeyNote will assume the plugin wants to go resident, and
  will NOT free the DLL after executing the plugin. (Note that the cleanup
  procedure will still be called.) KeyNote will ignore any flags related to
  the data returned by the plugin. Further, KeyNote will call an additional
  "KNTSetPluginID" procedure BEFORE calling the "KNTPluginExecute" procedure.
  The plugin must record the ID which KeyNote will pass to it, in order to
  identify itself to KeyNote when it shuts down. See "keyrepeat.dpr" and
  "scratchpad.dpr" for examples.

*)

const
  PluginFeatureNames : array[TPluginFeature] of string = (
  // these strings are used by the Plugins dialog box
  // in KeyNote, to notify user about the features of
  // each installed plugins. The plugins themselves do
  // not use these constants.
    'StatusOK',
    'Gets data',
    'Gets RTF',
    'Gets selection',
    'Returns data',
    'Returns RTF',
    'Returns clipboard',
    'Needs selection',
    'Wants new note',
    'Wants dialog box',
    'Wants saved file',
    'Reload file',
    'Stays resident'
  );


type
  // Exported procedure types.

  // They MUST correspond in name, spelling, argument list
  // and calling convention to the function declarations
  // in your plugin code.

  // NOTE ABOUT THE CALLING CONVETION:
  // All exported functions use the "stdcall" calling convention,
  // which MUST be explicitly specified, because it is not
  // the default. This allows KeyNote to use plugins
  // written in languages other than Delphi.

  KNTGetPluginNameProc = function( buf : pointer; size : longint ) : longint stdcall;
  KNTGetPluginVersionProc = function : longint stdcall;
  KNTGetPluginDescriptionProc = function( buf : pointer; size : longint ) : longint stdcall;

  KNTConfigurePluginProc = function ( OwnerHWND : HWND ) : longint; stdcall;
  KNTGetPluginFeaturesProc = function : longint; stdcall;
  KNTPluginExecuteProc = function(
    AppHandle : THandle;
    OwnerHWND : HWND;
    RichEditHWND : HWND;
    ActiveFileName : PChar;
    ActiveNoteName : PChar;
    InText : PChar;
    var OutText : pointer ) : longint; stdcall;
  KNTPluginCleanupProc = procedure; stdcall;

  // This one is for RESIDENT plugins only.
  // KeyNote calls this function to tell the plugin what its ID number is.
  // Plugin sends KeyNote a message with this ID number when it is about
  // to shut down. The ID enables KeyNote to identify the plugin and unload
  // the correct DLL. See "keyrepeat.dpr" and "scratchpad.dpr" for examples.
  // WARNING!! If your resident plugin does not notify KeyNote before it shuts
  // itself down, it will cause a resource leak (un-freed dll) and KeyNote
  // will not be able to run the plugin again. KeyNote will have to be restarted
  // before it can run the plugin egain.
  KNTSetPluginIDProc = procedure( ID : longint ); stdcall;

implementation

end.
