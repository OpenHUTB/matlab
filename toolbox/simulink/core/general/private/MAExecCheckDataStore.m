function [ ResultDescription, ResultHandles ] = MAExecCheckDataStore( system )









ResultDescription = {  };
ResultHandles = {  };


model = bdroot( system );
encodedModelName = modeladvisorprivate( 'HTMLjsencode', get_param( model, 'Name' ), 'encode' );
encodedModelName = [ encodedModelName{ : } ];
hScope = get_param( system, 'Handle' );
hModel = get_param( model, 'Handle' );
cs = getActiveConfigSet( model );
mdladvObj = Simulink.ModelAdvisor.getModelAdvisor( system );
mdladvObj.setCheckResultStatus( true );
htmlResult = '';


if ~strcmp( get_param( cs, 'MultiTaskDSMMsg' ), 'error' )
msgToUser = DAStudio.message( 'Simulink:tools:MAMsgMultiTaskDataStore', encodedModelName );
htmlResult = [ htmlResult, msgToUser, '<p />' ];
mdladvObj.setCheckResultStatus( false );
end 


if ~strcmp( get_param( cs, 'UniqueDataStoreMsg' ), 'error' )
msgToUser = DAStudio.message( 'Simulink:tools:MAMsgDuplicateDataStore', encodedModelName );
htmlResult = [ htmlResult, msgToUser, '<p />' ];
mdladvObj.setCheckResultStatus( false );
end 




dsmBlocks = find_system( hScope,  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'Findall', 'on',  ...
'LookUnderMasks', 'on',  ...
'BlockType', 'DataStoreMemory' );

numDSMBlocks = length( dsmBlocks );
weaklyTypedBlocks = {  };

for idx = 1:numDSMBlocks
hBlock = dsmBlocks( idx );

if strcmp( get_param( hBlock, 'OutDataTypeStr' ), 'Inherit: auto' ) ||  ...
strcmp( get_param( hBlock, 'SignalType' ), 'auto' )
stronglyTyped = false;


if ( strcmp( get_param( hBlock, 'StateMustResolveToSignalObject' ), 'on' ) ||  ...
strncmp( get_param( cs, 'SignalResolutionControl' ), 'TryResolve', 10 ) )
dsmName = get_param( hBlock, 'DataStoreName' );
signalObjectExists = false;
modelWS = get_param( model, 'modelworkspace' );
if modelWS.hasVariable( dsmName )
signal = modelWS.getVariable( dsmName );
if isa( signal, 'Simulink.Signal' )
signalObjectExists = true;
if ~strcmp( signal.DataType, 'auto' ) &&  ...
~strcmp( signal.Complexity, 'auto' )
stronglyTyped = true;
end 
end 
end 



if ~signalObjectExists && existsInGlobalScope( model, dsmName )
signal = evalinGlobalScope( model, dsmName );
if isa( signal, 'Simulink.Signal' ) &&  ...
~strcmp( signal.DataType, 'auto' ) &&  ...
~strcmp( signal.Complexity, 'auto' )
stronglyTyped = true;
end 
end 
end 
if ~stronglyTyped
weaklyTypedBlocks = [ weaklyTypedBlocks;hBlock ];%#ok<AGROW>
end 
end 
end 

weaklyTypedBlocks = mdladvObj.filterResultWithExclusion( weaklyTypedBlocks );


if ~isempty( weaklyTypedBlocks )
htmlResult = [ htmlResult, '<p />', DAStudio.message( 'Simulink:tools:MAResultWeaklyTypedDataStores' ), '<p />' ];
mdladvObj.setCheckResultStatus( false );
end 

if isempty( htmlResult )
htmlResult = [ '<font color="#008000">', DAStudio.message( 'Simulink:tools:MAPassedMsg' ), '</font>' ];
end 

ResultDescription{ end  + 1 } = htmlResult;
ResultHandles{ end  + 1 } = weaklyTypedBlocks;




% Decoded using De-pcode utility v1.2 from file /tmp/tmpzLigm0.p.
% Please follow local copyright laws when handling this file.

