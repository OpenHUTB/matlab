

classdef slmsgviewer < handle

properties ( Constant )
m_InfoSeverity = 1;
m_WarnSeverity = 2;
m_ErrorSeverity = 3;
m_HighPriorityWarning = 4;

m_DefaultMaxMsgTabs = 5;

m_PrefferedDialogSize = [ 700, 370 ];
m_MinimumDialogSize = [ 400, 220 ];

m_DefaultModelName = '_ALL_';
m_DefaultComponentId = '0';
end 

properties ( Hidden )
m_Cache;
m_StandAloneMsgViewerInstance;
m_SuppressionManager;
m_DockedObservers;
m_Events;
m_Notify;
end 

methods ( Access = 'public', Hidden = true )
function obj = slmsgviewer(  )
obj.m_Cache = Simulink.messageviewer.internal.MsgCache(  );
obj.m_DockedObservers = Simulink.messageviewer.internal.DockedObservers(  );
obj.m_StandAloneMsgViewerInstance = [  ];
obj.m_SuppressionManager = [  ];
obj.m_Events = Simulink.messageviewer.internal.MsgViewerEvents(  );
obj.m_Notify = false;
end 

function aSLMsgViewer = standAloneInstance( this, aAction )
switch ( aAction )
case 'GetOrCreate'
if isempty( this.m_StandAloneMsgViewerInstance ) ||  ...
~isvalid( this.m_StandAloneMsgViewerInstance ) ||  ...
~isValid( this.m_StandAloneMsgViewerInstance.m_Dialog )
this.m_StandAloneMsgViewerInstance = Simulink.messageviewer.internal.MsgViewer( slmsgviewer.m_DefaultModelName );
end 
case 'Delete'
if ~isempty( this.m_StandAloneMsgViewerInstance )
this.m_StandAloneMsgViewerInstance.delete(  );
end 
this.m_StandAloneMsgViewerInstance = [  ];
case 'Clear'
this.m_StandAloneMsgViewerInstance.reset(  );
this.m_StandAloneMsgViewerInstance = [  ];
end 

aSLMsgViewer = this.m_StandAloneMsgViewerInstance;
end 

function aSuppressionManager = suppressionManagerInstance( this )

if ~matlab.ui.internal.hasDisplay
aSuppressionManager = [  ];
return ;
end 

if isempty( this.m_SuppressionManager ) || ~isvalid( this.m_SuppressionManager )
this.m_SuppressionManager = Simulink.messageviewer.internal.BrowserDialogFactory.create( 'SUPPRESSION_MANAGER_CEF' );
end 
aSuppressionManager = this.m_SuppressionManager;
end 

end 

methods ( Static = true, Access = 'private' )

function aSLMsgViewer = MsgViewerInstance( aAction, aModelName )
if nargin == 1
aModelName = slmsgviewer.m_DefaultModelName;
end 

aControllerInstance = slmsgviewer.ControllerInstance( 'GetOrCreate' );

if ~slmsgviewer.IsDockable
aSLMsgViewer = aControllerInstance.standAloneInstance( aAction );
else 

aSLMsgViewer = aControllerInstance.m_DockedObservers.canProcess( aModelName );
if isempty( aSLMsgViewer )
aSLMsgViewer = slmsgviewer.StandAloneInstance( aAction );
end 
end 
end 
end 


methods ( Static = true, Hidden = true, Access = 'public' )

function debug_address = getDebugAddress(  )
debug_address = Simulink.messageviewer.internal.BrowserDialogFactory.getDebugAddress( 'CEF' );
end 

function aControllerInstance = ControllerInstance( aAction )
mlock;
persistent aControllerSingleton;

switch ( aAction )
case 'GetOrCreate'
if isempty( aControllerSingleton ) || ~isvalid( aControllerSingleton )
aControllerSingleton = slmsgviewer(  );
end 

case 'Delete'
if ~isempty( aControllerSingleton )
aControllerSingleton.delete(  );
end 
aControllerSingleton = [  ];
end 
aControllerInstance = aControllerSingleton;
end 

function bIsDockable = IsDockable(  )
bIsDockable = false;

if ~isSimulinkStarted
return ;
end 

if slf_feature( 'get', 'DockedDiagnosticViewer' ) &&  ...
strcmp( get_param( 0, 'DiagnosticViewerPreference' ), 'on' )
bIsDockable = true;
end 
end 

function [ aSLMsgViewer ] = getInstanceList( aModelName )
aKey = slmsgviewer.m_DefaultModelName;
if nargin > 0 && slmsgviewer.IsDockable
aKey = aModelName;
end 
aSLMsgViewer = slmsgviewer.MsgViewerInstance( 'GetOrCreate', aKey );
if isempty( aSLMsgViewer )
aSLMsgViewer = slmsgviewer.StandAloneInstance(  );
else 
aSLMsgViewer( end  + 1 ) = slmsgviewer.StandAloneInstance(  );
end 
end 

function processRecord( aRecord )
aControllerInstance = slmsgviewer.ControllerInstance( 'GetOrCreate' );




if ~isempty( aRecord.Causes )
aSuppressAction = slmsgviewer.getSuppressionFromCause( aRecord );
aRecord.Actions = [ aRecord.Actions, aSuppressAction ];
end 

if isempty( aRecord.ModelName )
aRecord.ModelName = bdroot;
end 


aRecord = slmsgviewer.ProcessHyperLink( aRecord, aRecord.Component, aRecord.Category, aRecord.Severity, aRecord.StageId );
aRecord = slmsgviewer.ProcessObjects( aRecord );

if ~slmsgviewer.IsStageRecord( aRecord )
slmsgviewer.notifyEvent( 'PushMsgEvent', aRecord );
end 


if slmsgviewer.isModelLoadStage( aRecord.StageId ) && ~slmsgviewer.isModelLoadEndStage( aRecord )
aControllerInstance.m_Cache.push( aRecord )
else 
aSLMsgViewer = slmsgviewer.MsgViewerInstance( 'GetOrCreate', aRecord.ModelName );
if ~isempty( aSLMsgViewer )
aControllerInstance.m_Cache.clear( aSLMsgViewer );
for viewerId = 1:length( aSLMsgViewer )
aSLMsgViewer( viewerId ).processRecordDV( aRecord );
end 
else 
aStandAloneInstance = slmsgviewer.StandAloneInstance(  );
aControllerInstance.m_Cache.clear( aStandAloneInstance );
aStandAloneInstance.processRecordDV( aRecord );
end 
end 
end 

function removeTab( aTabName )


aSLMsgViewerList = slmsgviewer.MsgViewerInstance( 'Get', aTabName );
for i = 1:length( aSLMsgViewerList )
if ( ~isempty( aSLMsgViewerList( i ) ) )
try 
aSLMsgViewerList( i ).remove( aTabName );
catch 
end 
end 
end 

aControllerInstance = slmsgviewer.ControllerInstance( 'GetOrCreate' );
if ~isempty( aControllerInstance.m_SuppressionManager )
Simulink.output.connectorPublish( '/suppressionmanager/removeTab', jsonencode( aTabName ) );
end 
end 

function renameTab( aOldTabName, aNewTabName )

aSLMsgViewer = slmsgviewer.Instance( aOldTabName );
for i = 1:length( aSLMsgViewer )
if ( ~isempty( aSLMsgViewer( i ) ) )
aSLMsgViewer( i ).rename( aOldTabName, aNewTabName );
end 
end 

aControllerInstance = slmsgviewer.ControllerInstance( 'GetOrCreate' );
if ~isempty( aControllerInstance.m_SuppressionManager )
aRenameStruct.aOldTabName = aOldTabName;
aRenameStruct.aNewTabName = aNewTabName;
Simulink.output.connectorPublish( '/suppressionmanager/renameTab', jsonencode( aRenameStruct ) );
end 
end 

function [ aEventListener ] = registerListener( aListenerFcn )
aEventListener = [  ];
aControllerInstance = slmsgviewer.ControllerInstance( 'GetOrCreate' );
if ~isempty( aControllerInstance )
aEventHandler = aControllerInstance.m_Events;
aControllerInstance.m_Notify = true;
aEventListener = event.listener( aEventHandler, 'PushMsgEvent', aListenerFcn );
end 
end 

function [ aEventListener ] = registerUIEventListener( aListenerFcn )



aEventListener = [  ];
aControllerInstance = slmsgviewer.ControllerInstance( 'GetOrCreate' );
if ~isempty( aControllerInstance )
aEventHandler = aControllerInstance.m_Events;
aControllerInstance.m_Notify = true;
aEventListener = event.listener( aEventHandler, 'PushUIEvent', aListenerFcn );
end 
end 

function [ bIsError ] = isErrorMessage( aMsgRecord )
if isfield( aMsgRecord, 'Severity' ) && isequal( aMsgRecord.Severity, slmsgviewer.m_ErrorSeverity )
bIsError = true;
else 
bIsError = false;
end 
end 

function [ bIsModelLoadStage ] = isModelLoadStage( aStageId )
bIsModelLoadStage = strcmp( aStageId, 'Simulink:SLMsgViewer:Model_Load_Stage_Name' );
end 

function [ bIsModelLoadStage ] = isModelLoadStartStage( aRecord )
bIsModelLoadStage = slmsgviewer.isModelLoadStage( aRecord.StageId ) && isequal( aRecord.StageState, 1 );
end 

function [ bIsModelLoadStage ] = isModelLoadEndStage( aRecord )
bIsModelLoadStage = slmsgviewer.isModelLoadStage( aRecord.StageId ) && isequal( aRecord.StageState, 0 );
end 

function [ bIsSuppressType ] = isSuppressType( aActionType )
bIsSuppressType = strcmp( aActionType, 'SUPPRESSION' );
end 


function [ aActiontoAppend ] = getSuppressionFromCause( aRecordParse )





aActiontoAppend = {  };
aNotMultipleLevel = 1;
aCauseEmpty = 0;
while ( ~aCauseEmpty )
if ( length( aRecordParse.Causes ) > 1 )
aNotMultipleLevel = 0;
end 
if ( ~isempty( aRecordParse.Actions ) )
aAction = aRecordParse.Actions;
for i = 1:length( aAction )
if ( strcmp( aAction( i ).Type, 'SUPPRESSION' ) )
aActiontoAppend{ end  + 1 } = aAction( i );%#ok<AGROW> %Suppress at middle level
end 
end 
end 
if ( isempty( aRecordParse.Causes ) )
aCauseEmpty = 1;
else 
aRecordParse = aRecordParse.Causes( 1 );
end 
end 
if ( ~isempty( aActiontoAppend ) )
aActiontoAppend = aActiontoAppend{ 1 };
assert( aNotMultipleLevel == 1, 'Suppression has tree hierarchy' );
assert( length( aActiontoAppend ) < 2, 'Multiple Suppression from one diagnostic' );
end 
end 

function selectTab( aTabName )
aSLMsgViewer = slmsgviewer.Instance( aTabName );
if ~isempty( aSLMsgViewer )
aSLMsgViewer.m_MessageService.publish( 'selectTab', aTabName );
end 
end 

function suppressInvoker( aCallback )
aCallback = slmsgviewer.pruneCbTypeIdentifier( aCallback );
aObject = eval( aCallback );
aObject.suppress(  );
end 

function restoreInvoker( aCallback )
aCallback = slmsgviewer.pruneCbTypeIdentifier( aCallback );
aObject = eval( aCallback );
aObject.restore(  );
end 

function notifySuppressComment( aComment, aCallback )
aCallback = slmsgviewer.pruneCbTypeIdentifier( aCallback );
aObject = eval( aCallback );
aObject.Comments = aComment;
end 


function publishSuppressedDiagnostics(  )

loadedModels = find_system( 'LoadFullyIfNeeded', 'off', 'BlockDiagramType', 'model' );
suppressionCount = 0;


for i = 1:length( loadedModels )
suppressions = Simulink.getSuppressedDiagnostics( loadedModels{ i } );
for j = 1:length( suppressions )
if strcmp( suppressions( j ).Mode, 'AUTHORED' )
continue ;
end 
obj.Event = 'Add';
obj.Message = MSLDiagnostic( message( suppressions( j ).Id ) ).message;
obj.Source = suppressions( j ).Source;
obj.Comment = suppressions( j ).Comments;
obj.MessageId = suppressions( j ).Id;
obj.LastModified = suppressions( j ).LastModified;

suppressionCount = suppressionCount + 1;
Simulink.output.connectorPublish( '/suppression', jsonencode( obj ) );
end 
end 
if isequal( suppressionCount, 0 )
obj.Event = 'Empty';
Simulink.output.connectorPublish( '/suppression', jsonencode( obj ) );
end 
end 

function result = applyIntArgVaues( aCallback, aIntArgValues )
result = aCallback;
for i = 1:length( aIntArgValues )
placeholder = [ '__ARG', num2str( i ), '__' ];
result = strrep( result, placeholder, aIntArgValues{ i } );
end 
end 

function result = suggestionInvoker( aCallback, varargin )
result = '';
aCallback = slmsgviewer.pruneCbTypeIdentifier( aCallback );
int_arg_values = [  ];
int_arg_names = [  ];
if ( ~isempty( varargin ) )
int_arg_values = varargin{ 1 };
int_arg_names = varargin{ 2 };
end 
aCallback = interactive_actions_helper.applyIntArgVaues( aCallback, int_arg_values, int_arg_names );
eval( aCallback );
end 

function result = fixItFcn( aCallback, aCallbackReturnsStatus, varargin )
int_arg_values = [  ];
int_arg_names = [  ];
if ( ~isempty( varargin ) )
int_arg_values = varargin{ 1 };
int_arg_names = varargin{ 2 };
end 
aCallback = slmsgviewer.pruneCbTypeIdentifier( aCallback );
aCallback = interactive_actions_helper.applyIntArgVaues( aCallback, int_arg_values, int_arg_names );
try 
if ( startsWith( aCallback, "set_param" ) || ~aCallbackReturnsStatus )
eval( aCallback );
result = '';
else 
result = eval( aCallback );
end 
catch err
rethrow( err );
end 
end 

function aPrunedCallback = pruneCbTypeIdentifier( aCallback )
aPrunedCallback = interactive_actions_helper.pruneCbTypeIdentifier( aCallback );
end 


function hyperlinkFcn( aCallback )
try 
aCallback = slmsgviewer.pruneCbTypeIdentifier( aCallback );
eval( aCallback );
slmsgviewer.notifyEvent( 'PushUIEvent', 'hyperlink' );
catch exp
disp( exp.message );
end 
end 

function help( ~ )
try 
helpview( [ docroot, '/mapfiles/simulink.map' ], 'diagnostic_viewer' );
catch exp
disp( exp.message );
end 
end 

function close( ~ )

aSLMsgViewer = slmsgviewer.StandAloneInstance(  );
if ( ~isempty( aSLMsgViewer ) )
aSLMsgViewer.hide(  );
end 
end 

function PatternsForBuildCompiler = getUserBuildPattern( aModelName )
PatternsForBuildCompiler.WarningPattern = '';
PatternsForBuildCompiler.ErrorPattern = '';
PatternsForBuildCompiler.FileNamePattern = '';
PatternsForBuildCompiler.LineNumberPattern = '';
lToolchainInfo = coder.make.internal.getToolchainInfoFromName ...
( get_param( aModelName, 'Toolchain' ) );
isCPP = strcmp( get_param( aModelName, 'TargetLang' ), 'C++' );
if ( isCPP )
aCDirectives = lToolchainInfo.getBuildTool( 'C++ Compiler' );
else 
aCDirectives = lToolchainInfo.getBuildTool( 'C Compiler' );
end 
if aCDirectives.Directives.isKey( 'WarningPattern' )
PatternsForBuildCompiler.WarningPattern = aCDirectives.getDirective( 'WarningPattern' );
end 
if aCDirectives.Directives.isKey( 'ErrorPattern' )
PatternsForBuildCompiler.ErrorPattern = aCDirectives.getDirective( 'ErrorPattern' );
end 
if aCDirectives.Directives.isKey( 'FileNamePattern' )
PatternsForBuildCompiler.FileNamePattern = aCDirectives.getDirective( 'FileNamePattern' );
end 
if aCDirectives.Directives.isKey( 'LineNumberPattern' )
PatternsForBuildCompiler.LineNumberPattern = aCDirectives.getDirective( 'LineNumberPattern' );
end 
end 

function writeToFile( aFileSaveInfo )
if isempty( aFileSaveInfo )
return ;
end 

aFileHdl = fopen( aFileSaveInfo.aFullFileName, 'w+' );

if ( aFileSaveInfo.aStyle == 2 )
for i = 1:length( aFileSaveInfo.aFileContent )
fwrite( aFileHdl, unicode2native( aFileSaveInfo.aFileContent{ i }, 'UTF-8' ), 'uint8' );
end 
else 
for i = 1:length( aFileSaveInfo.aFileContent )
fwrite( aFileHdl, aFileSaveInfo.aFileContent{ i }, 'char' );
end 
end 

fclose( aFileHdl );
end 

function copyToClipboard( aContentsToCopy )
clipboard( 'copy', strjoin( aContentsToCopy, '' ) );
end 

function [ bRepositioned ] = setPosition( aCenterXPos, aCenterYPos )
bRepositioned = false;


aSLMsgViewer = slmsgviewer.StandAloneInstance( 'Get' );
if ( ~isempty( aSLMsgViewer ) )

if aSLMsgViewer.isVisible(  )
return ;
end 

aSLMsgViewer.reposition( aCenterXPos, aCenterYPos );
bRepositioned = true;
end 
end 

function publish( channel, message, modelName )
model = '_ALL_';
if nargin > 2
model = modelName;
end 
aSLMsgViewer = slmsgviewer.MsgViewerInstance( 'Get', model );
if ~isempty( aSLMsgViewer )
aSLMsgViewer.m_MessageService.publish( channel, message );
end 
end 

function [ aMsgRecords ] = getRecords( aModelName )
aSLMsgviewer = slmsgviewer.Instance( aModelName );
aMsgRecords = aSLMsgviewer.getRecordsDV( aModelName );
end 

function settings( aSettingName, iSettingValue )
aSLMsgviewer = slmsgviewer.Instance(  );
aSLMsgviewer.settingsDV( aSettingName, iSettingValue );
end 

function [ bIsStageRecord ] = IsStageRecord( aRecord )
if isequal( aRecord.StageState, 0 ) || isequal( aRecord.StageState, 1 )
bIsStageRecord = true;
return ;
end 

bIsStageRecord = false;
end 

function [ aProcessedMsgRecord ] = ProcessObjects( aMsgRecord )
aMsgRecord.SID = [  ];
aMsgRecord.SourceName = [  ];


if ~isempty( aMsgRecord.Objects )
aFirstObj = aMsgRecord.Objects{ 1 };

if ( ischar( aFirstObj ) || isStringScalar( aFirstObj ) )
aMsgRecord.SourceName = aFirstObj;
elseif isnumeric( aFirstObj )
if ( ( aFirstObj == fix( aFirstObj ) && sf( 'ishandle', aFirstObj ) ) || ( ishandle( aFirstObj ) && Stateflow.SLUtils.isChildOfStateflowBlock( aFirstObj ) ) )
aMsgRecord.SID = aFirstObj;
end 
end 
end 

iNumCauses = length( aMsgRecord.Causes );
if ( iNumCauses > 0 )
aCauses = cell( iNumCauses, 1 );
for i = 1:iNumCauses
aCauses{ i } = slmsgviewer.ProcessObjects( aMsgRecord.Causes( i ) );
end 

aMsgRecord.Causes = [ aCauses{ 1:iNumCauses } ];
end 

aProcessedMsgRecord = aMsgRecord;
end 

function [ aProcessedMsgRecord ] = ProcessHyperLink( aMsgRecord, aComponent, aCategory, iSeverity, aStageId )
if ~isempty( aMsgRecord.Message )
aMsgRecord.Message = Simulink.messageviewer.internal.processhtmllinks( aMsgRecord.Message, aComponent, aCategory, iSeverity, aStageId );
end 

for i = 1:length( aMsgRecord.Causes )
aMsgRecord.Causes( i ) = slmsgviewer.ProcessHyperLink( aMsgRecord.Causes( i ), aComponent, aCategory, iSeverity, aStageId );
end 

aProcessedMsgRecord = aMsgRecord;
end 

function notifyEvent( aEvent, aData )
aControllerInstance = slmsgviewer.ControllerInstance( 'GetOrCreate' );
if aControllerInstance.m_Notify
aEventHandler = aControllerInstance.m_Events;
notify( aEventHandler, aEvent, Simulink.messageviewer.internal.PushMsgEventData( aData ) );
end 
end 

function openCallbackTracingReport( ~ )
Simulink.CallbackTracing.openReport(  );
end 

function displayPreferenceChangeDlg( cb )
dlg_pdr = DAStudio.DialogProvider;
dlg_pdr.questdlg( DAStudio.message( 'Simulink:SLMsgViewer:DockedDVPrefChangeDialog' ),  ...
DAStudio.message( 'Simulink:SLMsgViewer:DockedDVPrefChangeDialogTitle' ),  ...
{ DAStudio.message( 'Simulink:dialog:CSCYes' ),  ...
DAStudio.message( 'Simulink:dialog:CSCNo' ) },  ...
DAStudio.message( 'Simulink:dialog:CSCNo' ),  ...
cb );
end 

function handleToolstripPreferenceToggle(  )
slmsgviewer.displayPreferenceChangeDlg( @toolstripPrefChangeCb );


function toolstripPrefChangeCb( answer )
if strcmp( answer, DAStudio.message( 'Simulink:dialog:CSCYes' ) )
if strcmpi( get_param( 0, 'DiagnosticViewerPreference' ), 'off' )
set_param( 0, 'DiagnosticViewerPreference', 'on' );
else 
set_param( 0, 'DiagnosticViewerPreference', 'off' );
end 
Simulink.Preferences.getInstance(  ).Save(  );
end 
end 
end 

function onoff = handlePreferenceChange( aWidget )
widgetVal = aWidget.getWidgetValue( 'DiagnosticViewerPreference' );
prefVal = strcmp( get_param( 0, 'DiagnosticViewerPreference' ), 'on' );
onoff = isOnOff( widgetVal );
if prefVal ~= widgetVal
slmsgviewer.displayPreferenceChangeDlg( @prefChangeCb );
end 


function prefChangeCb( answer )
if strcmp( answer, DAStudio.message( 'Simulink:dialog:CSCYes' ) )
onoff = isOnOff( widgetVal );
set_param( 0, 'DiagnosticViewerPreference', onoff );
else 
aWidget.setWidgetValue( 'DiagnosticViewerPreference', ~widgetVal );
onoff = isOnOff( ~widgetVal );
set_param( 0, 'DiagnosticViewerPreference', onoff );
end 
end 


function onOff = isOnOff( bVal )
if bVal
onOff = 'on';
else 
onOff = 'off';
end 
end 

end 

function handleFeatureValueChange


if isSimulinkStarted

slmsgviewer.DeleteInstance(  );





toolstripConfig = dig.Configuration.get(  );
toolstripConfig.reload(  );
end 
end 


function openSuppressionManager( cbinfo )
aSuppressionManager = slmsgviewer.SuppressionManager(  );
if ~isempty( aSuppressionManager )
aSuppressionManager.show(  );
aSuppressionManager.selectTab( cbinfo.model.Name );
end 
end 
end 


methods ( Static = true, Access = 'public' )

function aSLMsgViewer = Instance( aModelName )
aKey = slmsgviewer.m_DefaultModelName;
if nargin > 0 && slmsgviewer.IsDockable
aKey = aModelName;
end 
aSLMsgViewer = slmsgviewer.MsgViewerInstance( 'GetOrCreate', aKey );
end 

function aSLMsgViewer = StandAloneInstance( aAction )
action = 'GetOrCreate';
if nargin > 0
action = aAction;
end 
aControllerInstance = slmsgviewer.ControllerInstance( 'GetOrCreate' );
aSLMsgViewer = aControllerInstance.standAloneInstance( action );
end 

function RegisterDockedObserver( aModelName, aComponentId )
aControllerInstance = slmsgviewer.ControllerInstance( 'GetOrCreate' );
aSLMsgViewer = Simulink.messageviewer.internal.MsgViewer( aModelName, aComponentId );
if ~isempty( aSLMsgViewer )
aControllerInstance.m_DockedObservers.register( aSLMsgViewer );
end 
end 

function DeregisterDockedObserver( aComponentId )
aControllerInstance = slmsgviewer.ControllerInstance( 'GetOrCreate' );
aControllerInstance.m_DockedObservers.deregister( aComponentId );
end 

function RegisterReferencedComponent( aModelName, aRefComponent, aCB )
aSLMsgViewer = slmsgviewer.MsgViewerInstance( 'Get', aModelName );
for i = 1:length( aSLMsgViewer )
aSLMsgViewer( i ).addToRefComponentList( aRefComponent );
aSLMsgViewer( i ).updateRefHyperlinkCB( aRefComponent, aCB );
end 
end 

function RegisterReferencedComponents( aModelName, aRefComponentList )
aSLMsgViewer = slmsgviewer.MsgViewerInstance( 'Get', aModelName );
aRefComponentList = [ aRefComponentList{ : } ];
for i = 1:length( aSLMsgViewer )
aSLMsgViewer( i ).addToRefComponentList( aRefComponentList );
end 
end 

function DeregisterReferencedComponents( aModelName, aRefComponentList )
aSLMsgViewer = slmsgviewer.MsgViewerInstance( 'Get', aModelName );
aRefComponentList = [ aRefComponentList{ : } ];
for i = 1:length( aSLMsgViewer )
aSLMsgViewer( i ).removeFromRefComponentList( aRefComponentList );
end 
end 


function DeleteInstance(  )
aControllerInstance = slmsgviewer.ControllerInstance( '' );
if ~isempty( aControllerInstance )
aControllerInstance.standAloneInstance( 'Delete' );
end 
end 

function show( aModelName )
aSLMsgViewer = slmsgviewer.Instance( aModelName );
for i = 1:length( aSLMsgViewer )
aSLMsgViewer( i ).show;
end 
end 

function [ aUrlList ] = GetUrl( aModelName )
aUrlList = string.empty;
if slfeature( 'DockedDiagnosticViewer' ) == 2
baseUrl = connector.getUrl( '/toolbox/simulink/simulink/dockeddiagnosticviewer/slmsgviewer.html' );
else 
baseUrl = connector.getUrl( '/toolbox/simulink/simulink/slmsgviewer/slmsgviewer.html' );
end 
aSLMsgViewer = slmsgviewer.Instance( aModelName );
for i = 1:length( aSLMsgViewer )
componentId = aSLMsgViewer( i ).m_ComponentId;
aUrlList( end  + 1 ) = [ baseUrl, '&componentId=', componentId ];%#ok<AGROW>
end 
end 

function [ aUrlList ] = GetDebugUrl( aModelName )
aUrlList = string.empty;
if slfeature( 'DockedDiagnosticViewer' ) == 2
baseUrl = connector.getUrl( '/toolbox/simulink/simulink/dockeddiagnosticviewer/slmsgviewer-debug.html' );
else 
baseUrl = connector.getUrl( '/toolbox/simulink/simulink/slmsgviewer/slmsgviewer-debug.html' );
end 
aSLMsgViewer = slmsgviewer.Instance( aModelName );
for i = 1:length( aSLMsgViewer )
componentId = aSLMsgViewer( i ).m_ComponentId;
aUrlList( end  + 1 ) = [ baseUrl, '&componentId=', componentId ];%#ok<AGROW>
end 
end 


function aDDGDialog = dialog(  )
aDDGDialog = [  ];
aControllerInstance = slmsgviewer.ControllerInstance( '' );
if ~isempty( aControllerInstance )
aSLMsgViewer = aControllerInstance.standAloneInstance( 'Get' );
if ~isempty( aSLMsgViewer ) && ~isempty( aSLMsgViewer.m_Dialog )
aDDGDialog = aSLMsgViewer.m_Dialog.m_Dialog;
end 
end 
end 


function aSuppressionManager = SuppressionManager(  )
aControllerInstance = slmsgviewer.ControllerInstance( 'GetOrCreate' );
aSuppressionManager = aControllerInstance.suppressionManagerInstance(  );
end 

function [ aFileBrowserOutputInfo ] = showFileChooser( aFileBrowserInput )
aFileBrowserInput.aSupportedSaveStyles = reshape( aFileBrowserInput.aSupportedSaveStyles, length( aFileBrowserInput.aSupportedSaveStyles ) / 2, 2 );
[ aFileName, aPathName, aStyle ] = uiputfile( aFileBrowserInput.aSupportedSaveStyles, aFileBrowserInput.aDefaultTitle, aFileBrowserInput.aDefaultFileName );

if ~( ischar( aFileName ) || isStringScalar( aFileName ) )
aFileBrowserOutputInfo = [  ];
return ;
end 

aFileBrowserOutputInfo.aFullFileName = fullfile( aPathName, aFileName );
aFileBrowserOutputInfo.aStyle = aStyle;
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpGbr2aq.p.
% Please follow local copyright laws when handling this file.

