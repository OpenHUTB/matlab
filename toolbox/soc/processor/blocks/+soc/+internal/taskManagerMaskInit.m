function taskManagerMaskInit( mgrBlk )




modelName = bdroot( mgrBlk );
mgrBlkParent = get_param( mgrBlk, 'Parent' );
if isequal( get_param( mgrBlkParent, 'Type' ), 'block' )
mgrBlkParentType = get_param( mgrBlkParent, 'BlockType' );

if isequal( mgrBlkParentType, 'SubSystem' ) &&  ...
~isequal( get_param( mgrBlkParent, 'IsSubsystemVirtual' ), 'on' )
error( message( 'soc:scheduler:TaskMgrMisplaced' ) );
end 
end 

simStatus = get_param( modelName, 'SimulationStatus' );
if ~ismember( simStatus, { 'stopped', 'initializing' } )


return ;
end 


ted = get_param( mgrBlk, 'TaskEditData' );
if ~isempty( ted ) && ~isequal( ted, '[]' ) && ~isequal( ted, '{}' )
decodedData = jsondecode( ted );
if isfield( decodedData, 'renamed' )
for i = 1:numel( decodedData.renamed )
task = decodedData.renamed( i );
appChangeTaskName( mgrBlk, task.oldName, task.newName );
end 
end 
decodedData = rmfield( decodedData, 'renamed' );

set_param( mgrBlk, 'TaskEditData', jsonencode( decodedData ) );
return 
end 

allTaskNames = hlpGetTaskNamesFromTaskManager( mgrBlk );
allTaskNamesFromBlocks = hlpGetTaskNamesFromBlocks( mgrBlk );


blksToAdd = setdiff( allTaskNames, allTaskNamesFromBlocks, 'stable' );


for idx = 1:numel( blksToAdd )
taskBlk = blksToAdd{ idx };
appAddTaskBlock( mgrBlk, taskBlk );
end 


blksToDel = setdiff( allTaskNamesFromBlocks, allTaskNames, 'stable' );
for idx = 1:numel( blksToDel )
taskName = blksToDel{ idx };
appDelTaskBlock( mgrBlk, taskName );
end 


appDelTaskEventPorts( mgrBlk );


allTaskData = get_param( mgrBlk, 'AllTaskData' );
dm = soc.internal.TaskManagerData( allTaskData );
for idx = 1:numel( allTaskNames )
taskName = allTaskNames{ idx };
taskData = dm.getTask( taskName );
streamToSDI = isequal( get_param( mgrBlk, 'StreamToSDI' ), 'on' );

taskData.logExecutionData = streamToSDI;
taskData.logDroppedTasks = streamToSDI;

appUpdateTaskBlock( mgrBlk, taskName, taskData );
appUpdateCoreTaskManager( mgrBlk, taskName, taskData );
end 
appScheduleEditorSettings( mgrBlk );
appSelectVariant( mgrBlk );
hCS = getActiveConfigSet( modelName );
if hCS.isValidParam( 'TaskManagerData' ) &&  ...
~isequal( get_param( modelName, 'TaskManagerData' ), allTaskData )
set_param( modelName, 'TaskManagerData', allTaskData );
end 
soc.internal.setBlockIcon( mgrBlk, 'socicons.TaskManager' );
end 


function appChangeTaskName( mgrBlk, oldName, newName )
allTaskData = get_param( mgrBlk, 'AllTaskData' );
dm = soc.internal.TaskManagerData( allTaskData );
if ~ismember( oldName, dm.getTaskNames ), return ;end 
task = dm.getTask( oldName );
mdlUpdateTaskManagerAfterTaskNameChange( mgrBlk, oldName, newName );
if hlpIsDurationFromInputPort( task )
mdlUpdateTaskBlockDurPortAfterTaskNameChange( mgrBlk, oldName, newName );
end 
if isequal( task.taskType, 'Event-driven' )
mdlUpdateCoreTaskManagerAfterTaskNameChange( mgrBlk, oldName, newName );
end 
mdlUpdateTaskBlockAfterTaskNameChange( mgrBlk, oldName, newName );
end 


function mdlUpdateTaskManagerAfterTaskNameChange( mgrBlk, oldName, newName )
taskBlocksSubs = hlpTaskBlocksSubsystem( mgrBlk );
fcnPortBlk = [ mgrBlk, '/', hlpGetFcnPortName( oldName ) ];
inpPortBlk = [ taskBlocksSubs, '/', oldName ];
set_param( fcnPortBlk, 'Name', newName );
set_param( inpPortBlk, 'Name', newName );
end 


function mdlUpdateTaskBlockAfterTaskNameChange( mgrBlk, oldName, newName )
subsName = hlpGetTaskSubsName( oldName );
portName = hlpGetFcnPortName( oldName );
tskBlkName = hlpGetTaskBlockName( oldName );
locChangeTaskBlkNameHSBONVariant(  );
locChangeFcnCallGenBlkNameHSBOFFVariant(  );

function locChangeTaskBlkNameHSBONVariant(  )
dest = hlpGetTaskBlocksHSBONVariant( mgrBlk );
thisSysBlks = get_param( dest, 'Blocks' );
portExists = any( strcmp( portName, thisSysBlks ) );
if portExists
set_param( [ dest, '/', portName ], 'Name', newName );
end 
set_param( [ dest, '/', subsName, '/TaskBlkPart/', tskBlkName ], 'Name', [ newName, 'Blk' ] );
set_param( [ dest, '/', subsName ], 'Name', [ newName, 'Subsystem' ] );
end 
function locChangeFcnCallGenBlkNameHSBOFFVariant(  )
dest = hlpGetTaskBlocksHSBOFFVariant( mgrBlk );
thisSysBlks = get_param( dest, 'Blocks' );
portExists = any( strcmp( portName, thisSysBlks ) );
if portExists
set_param( [ dest, '/', portName ], 'Name', newName );
end 
set_param( [ dest, '/', tskBlkName ], 'Name', [ newName, 'Blk' ] );
end 
end 
function mdlUpdateTaskBlockDurPortAfterTaskNameChange( mgrBlk, taskName, newName )
dest = hlpGetTaskBlocksHSBONVariant( mgrBlk );
curPortName = hlpGetDurPortName( taskName );
newPortName = [ newName, 'Dur' ];
allTaskSubs = hlpTaskBlocksSubsystem( mgrBlk );
subsName = hlpGetTaskSubsName( taskName );
set_param( [ mgrBlk, '/', curPortName ], 'Name', newPortName );
set_param( [ allTaskSubs, '/', curPortName ], 'Name', newPortName );
set_param( [ dest, '/', curPortName ], 'Name', newPortName );
set_param( [ dest, '/', subsName, '/', curPortName ], 'Name', newPortName );
end 
function mdlUpdateCoreTaskManagerAfterTaskNameChange( taskMgr, oldName, newName )
oldPort = [ oldName, 'Event' ];
newPort = [ newName, 'Event' ];
oldServ = [ oldName, 'EventServer' ];
newServ = [ newName, 'EventServer' ];
oldTerm = [ oldName, 'EventTerm' ];
newTerm = [ newName, 'EventTerm' ];
coreTaskMgr = [ taskMgr, '/', hlpGetCoreTaskManager ];

set_param( [ taskMgr, '/', oldPort ], 'Name', newPort );
set_param( [ coreTaskMgr, '/', oldPort ], 'Name', newPort );

varSys = [ coreTaskMgr, '/', hlpGetVariantSubsName ];
i_setNewName( [ varSys, '/HSBON' ], oldPort, newPort, 'Inport' );
i_setNewName( [ varSys, '/HSBON/Task Manager' ], oldPort, newPort, 'Inport' );
i_setNewName( [ varSys, '/HSBON/Task Manager/Task Manager' ], oldPort, newPort, 'Inport' );
i_setNewName( [ varSys, '/HSBON/Task Manager/Task Manager' ], oldServ, newServ, 'EntityServer' );
i_setNewName( [ varSys, '/HSBON/Task Manager/NOP' ], oldPort, newPort, 'Inport' );
i_setNewName( [ varSys, '/HSBON/Task Manager/NOP' ], oldTerm, newTerm, 'Terminator' );
eventName = soc.internal.TaskManagerData.getDefaultEventName( newName );
server = [ varSys, '/HSBON/Task Manager/Task Manager/', newServ ];
setServerEntryAction( server, eventName );
setServerServiceTime( server );

i_setNewName( [ varSys, '/HSBOFF' ], oldPort, newPort, 'Inport' );
i_setNewName( [ varSys, '/HSBOFF/Task Manager' ], oldPort, newPort, 'Inport' );
i_setNewName( [ varSys, '/HSBOFF/Task Manager/NOP' ], oldPort, newPort, 'Inport' );
i_setNewName( [ varSys, '/HSBOFF/Task Manager/NOP' ], oldTerm, newTerm, 'Terminator' );
i_setNewName( [ varSys, '/HSBOFF/Task Manager/Task Manager' ], oldPort, newPort, 'Inport' );
i_setNewName( [ varSys, '/HSBOFF/Task Manager/Task Manager' ], oldServ, newServ, 'EntityServer' );
i_setNewName( [ varSys, '/HSBOFF/Task Manager/Task Manager' ], oldTerm, newTerm, 'Terminator' );

function i_setNewName( sys, oldName, newName, type )
blks = find_system( sys, 'SearchDepth', 1, 'BlockType', type, 'Name', oldName );
if ~isempty( blks )
set_param( blks{ 1 }, 'Name', newName );
end 
end 
end 

function appSelectVariant( mgrBlk )
var1Blk = [ mgrBlk, '/Task Blocks/Variant Subsystem' ];
var2Blk = [ mgrBlk, '/Core Task Manager/Variant Subsystem' ];
if isequal( get_param( mgrBlk, 'EnableTaskSimulation' ), 'on' )
if ~isequal( get_param( var1Blk, 'LabelModeActiveChoice' ), 'hsbon' )
set_param( var1Blk, 'LabelModeActiveChoice', 'hsbon' );
end 
if ~isequal( get_param( var2Blk, 'LabelModeActiveChoice' ), 'hsbon' )
set_param( var2Blk, 'LabelModeActiveChoice', 'hsbon' );
end 
else 
if ~isequal( get_param( var1Blk, 'OverrideUsingVariant' ), 'hsboff' )
set_param( var1Blk, 'OverrideUsingVariant', 'hsboff' );
end 
if ~isequal( get_param( var2Blk, 'OverrideUsingVariant' ), 'hsboff' )
set_param( var2Blk, 'OverrideUsingVariant', 'hsboff' );
end 
end 
end 

function appScheduleEditorSettings( mgrBlk )
useScheduleEditor = isequal( get_param( mgrBlk, 'UseScheduleEditor' ), 'on' );
if useScheduleEditor
slfeature( 'ExplicitPartitionsSupportConcurrentTasking', 1 );
slfeature( 'AperiodicPartitionsWithoutTimedTask', 1 );
end 
fcnCallParts = locFindPartSubsystems( mgrBlk, 'FcnCallGenPart' );
taskBlkParts = locFindPartSubsystems( mgrBlk, 'TaskBlkPart' );
for i = 1:numel( fcnCallParts )
thisPart = fcnCallParts{ i };
if useScheduleEditor
tsk = locGetTaskName( thisPart );
st = get_param( [ thisPart, '/FcnCallGen' ], 'sample_time' );
locSetParamValue( thisPart, 'TreatAsAtomicUnit', 'on' );
locSetParamValue( thisPart, 'PartitionName', tsk );
locSetParamValue( thisPart, 'SystemSampleTime', st );
locSetParamValue( thisPart, 'ScheduleAs', 'Periodic partition' );
else 
locSetParamValue( thisPart, 'TreatAsAtomicUnit', 'off' );
locSetParamValue( thisPart, 'ScheduleAs', 'Sample time' );
locSetParamValue( thisPart, 'PartitionName', '' );
locSetParamValue( thisPart, 'SystemSampleTime', '-1' );
end 
end 
for i = 1:numel( taskBlkParts )
thisPart = taskBlkParts{ i };
tsk = locGetTaskName( thisPart );
blk = [ thisPart, '/', tsk, 'Blk' ];
isEventDriven = isequal( get_param( blk, 'TaskType' ), 'Event-driven' );

explPartEnableForSync = false;
if useScheduleEditor && isEventDriven && explPartEnableForSync
locSetParamValue( thisPart, 'TreatAsAtomicUnit', 'on' );
locSetParamValue( thisPart, 'PartitionName', tsk );
locSetParamValue( thisPart, 'SystemSampleTime', '-1' );
locSetParamValue( thisPart, 'ScheduleAs', 'Aperiodic partition' );
else 
locSetParamValue( thisPart, 'TreatAsAtomicUnit', 'off' );
locSetParamValue( thisPart, 'ScheduleAs', 'Sample time' );
locSetParamValue( thisPart, 'PartitionName', '' );
locSetParamValue( thisPart, 'SystemSampleTime', '-1' );
end 
end 
function blks = locFindPartSubsystems( mgrBlk, partName )


blks = find_system( mgrBlk, 'LookUnderMasks', 'all', 'FollowLinks', 'on',  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'Name', partName );
end 
function locSetParamValue( blk, param, value )
if ~isequal( get_param( blk, param ), value )
set_param( blk, param, value );
end 
end 
function tsk = locGetTaskName( thisPart )
pos = strfind( thisPart, '/' );
sys = thisPart( pos( end  - 1 ) + 1:pos( end  ) - 1 );
pos = strfind( sys, 'Subsystem' );
tsk = sys( 1:pos - 1 );
end 




























end 
function hTaskBlk = appAddTaskBlock( mgrBlk, taskName )
taskBlkName = hlpGetTaskBlockName( taskName );
hTaskBlk = [ hlpGetTaskSubs( mgrBlk, taskName ), '/TaskBlkPart/', taskBlkName ];
mdlAddTaskBlkHSBONVariant( mgrBlk, taskName );
mdlAddTaskBlkHSBOFFVariant( mgrBlk, taskName );
mdlAddTaskBlockFcnCallPort( mgrBlk, taskName );
set_param( hTaskBlk, 'taskName', taskName );
end 
function appDelTaskBlock( mgrBlk, taskName )
mdlDelTaskBlockDurPort( mgrBlk, taskName );
mdlDelTaskBlockFcnCallPort( mgrBlk, taskName );
mdlDelTaskBlock( mgrBlk, taskName );
end 
function appDelTaskEventPorts( mgrBlk )
toDel = hlpGetEventPortsToDel( mgrBlk );
if ~isempty( toDel )
coreTaskMgr = [ mgrBlk, '/', hlpGetCoreTaskManager ];
variant = [ coreTaskMgr, '/', hlpGetVariantSubsName ];
for idx = 1:numel( toDel )
event = soc.internal.TaskManagerData.getDefaultEventName( toDel{ idx } );
removePortFromCoreTaskManager( mgrBlk, event, coreTaskMgr, variant );
end 
end 
end 
function appUpdateTaskBlock( blk, taskName, task )
if hlpIsDurationFromInputPort( task )
mdlUpdateTaskBlockWithDurationPort( blk, taskName, task );
else 
mdlUpdateTaskBlockWithNoDurationPort( blk, taskName, task );
end 
end 

function name = hlpGetTaskBlockName( taskName )
name = [ taskName, 'Blk' ];
end 
function name = hlpGetFcnPortName( taskName )
name = [ taskName, '' ];
end 
function name = hlpGetDurPortName( taskName )
name = [ taskName, 'Dur' ];
end 
function subs = hlpGetTaskSubsName( taskName )
subs = [ taskName, 'Subsystem' ];
end 
function name = hlpGetVariantSubsName
name = 'Variant Subsystem';
end 
function name = hlpGetAllTasksSubsName
name = 'Task Blocks';
end 
function name = hlpGetCoreTaskManager
name = 'Core Task Manager';
end 
function name = hlpGetTaskManager
name = 'Task Manager';
end 
function name = hlpGetEntitySwitch
name = 'Switch';
end 
function name = hlpGetNop
name = 'NOP';
end 
function subs = hlpGetTaskSubs( mgrBlk, taskName )
subs = [ hlpGetTaskBlocksHSBONVariant( mgrBlk ), '/', hlpGetTaskSubsName( taskName ) ];
end 

function subs = hlpGetTaskBlocksHSBONVariant( mgrBlk )
subs = [ hlpGetTaskBlocksVariantSubsystem( mgrBlk ), '/HSBON' ];
end 

function subs = hlpGetTaskBlocksHSBOFFVariant( mgrBlk )
subs = [ hlpGetTaskBlocksVariantSubsystem( mgrBlk ), '/HSBOFF' ];
end 

function subs = hlpGetTaskBlocksVariantSubsystem( mgrBlk )
subs = [ hlpTaskBlocksSubsystem( mgrBlk ), '/', hlpGetVariantSubsName ];
end 

function subs = hlpTaskBlocksSubsystem( mgrBlk )
subs = [ mgrBlk, '/', hlpGetAllTasksSubsName ];
end 
function blkName = hlpGetSrcEventServer(  )
blkName = 'esblib_internal/EventServer';
end 
function blkName = hlpGetDstEventServer( eventName )
blkName = [ eventName, 'Server' ];
end 
function ret = hlpIsEventServer( blkName )
ret = endsWith( blkName, 'EventServer' );
end 
function val = hlpConvertValueToBlockDataType( inVal )
val = inVal;
if isnumeric( inVal )
val = num2str( inVal );
elseif islogical( inVal )
val = { 'off', 'on' };
val = val{ inVal + 1 };
end 
end 
function blks = hlpFindTaskBlocks( mgrBlk )
taskBlocksSubsystem = hlpGetTaskBlocksHSBONVariant( mgrBlk );


blks = find_system( taskBlocksSubsystem, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'MaskType', 'ESB Task' );
end 
function list = hlpGetTaskNamesFromTaskManager( blk )
allTaskData = get_param( blk, 'AllTaskData' );
dm = soc.internal.TaskManagerData( allTaskData );
list = dm.getTaskNames;
end 
function list = hlpGetTaskNamesFromBlocks( mgrBlk )
allTaskBlocks = hlpFindTaskBlocks( mgrBlk );
list = {  };
for idx = 1:numel( allTaskBlocks )
blkName = get_param( allTaskBlocks{ idx }, 'Name' );
indices = strfind( blkName, 'Blk' );
tskName = blkName( 1:indices( end  ) - 1 );
list{ end  + 1 } = tskName;%#ok<AGROW>
end 
end 
function name = hlpGetBlkName( hBlk )
name = get_param( hBlk, 'Name' );
end 
function name = hlpGetOutportBlkRootName( longBlkName )
indices = strfind( longBlkName, '/' );
name = longBlkName( indices( end  ) + 1:end  );
end 
function name = hlpGetEventNameFromPort( blk )
name = hlpGetBlkName( blk );
if endsWith( name, 'Event' )
name = name( 1:end  - length( 'Event' ) );
else 
name = '';
end 
end 
function namesToDel = hlpGetEventPortsToDel( blk )


namesToDel = [  ];
SupportEventPorts = get_param( blk, 'SupportEventPorts' );
if isequal( SupportEventPorts, 'on' )
allTaskData = get_param( blk, 'AllTaskData' );
dm = soc.internal.TaskManagerData( allTaskData );
list = dm.getTaskNames;
inportBlks = find_system( blk, 'LookUnderMasks', 'all',  ...
'FollowLinks', 'on', 'SearchDepth', 1, 'BlockType', 'Inport' );
h = @hlpGetEventNameFromPort;
allNames = cellfun( h, inportBlks, 'UniformOutput', false );
if isequal( allNames, { '' } ), allNames = {  };end 
for i = numel( allNames ): - 1:1
if isempty( allNames{ i } ), allNames( i ) = [  ];end 
end 
namesToDel = setdiff( allNames, list, 'stable' );
end 
end 
function idx = hlpFindOutportIdxForTask( searchIn, taskName )
outPortBlks = find_system( searchIn, 'LookUnderMasks', 'all',  ...
'FollowLinks', 'on', 'SearchDepth', 1, 'BlockType', 'Outport' );
h = @hlpGetOutportBlkRootName;
taskNames = cellfun( h, outPortBlks, 'UniformOutput', false );
[ ~, idx ] = ismember( taskName, taskNames );
end 
function idx = hlpFindInportIdxForName( searchIn, Name )
inportBlks = find_system( searchIn, 'LookUnderMasks', 'all',  ...
'FollowLinks', 'on', 'SearchDepth', 1, 'BlockType', 'Inport' );
h = @hlpGetBlkName;
allNames = cellfun( h, inportBlks, 'UniformOutput', false );
[ ~, idx ] = ismember( Name, allNames );
end 
function ret = hlpIsDurationFromInputPort( task )
ret = isequal( task.taskDurationSource, 'Input port' ) &&  ...
~task.playbackRecorded;
end 

function appCommonTaskBlockUpdate( mgrBlk, taskName, taskData )
taskBlkName = hlpGetTaskBlockName( taskName );
hTaskBlk = [ hlpGetTaskSubs( mgrBlk, taskName ), '/TaskBlkPart/', taskBlkName ];
oldTaskType = get_param( hTaskBlk, 'taskType' );
if ~isequal( taskData.taskType, oldTaskType )
locUpdateTaskSubsystem( mgrBlk, taskName, taskData, taskBlkName )
end 
locUpdateTaskBlockParameters( taskData, hTaskBlk );
if isequal( taskData.taskType, 'Timer-driven' )
locUpdateTimerDrivenTaskSampleTime( mgrBlk, taskName, taskData );
else 
hTaskBlk = [ hlpGetTaskBlocksHSBOFFVariant( mgrBlk ), '/', taskName ];
locUpdateTaskBlockParameters( taskData, hTaskBlk );
end 

function locUpdateTaskSubsystem( mgrBlk, taskName, taskData, tskBlkName )
i_HSBONVariant( mgrBlk, taskName, taskData, tskBlkName );
i_HandleHSBOFFVariant( mgrBlk, taskName, taskData, tskBlkName );

function i_HSBONVariant( mgrBlk, taskName, taskData, tskBlkName )
thisSys = hlpGetTaskBlocksHSBONVariant( mgrBlk );
taskSubsysName = hlpGetTaskSubsName( taskName );
taskSubs = [ thisSys, '/', taskSubsysName ];
if isequal( taskData.taskType, 'Timer-driven' )

delete_line( taskSubs, 'TaskBlkPart/1', 'Out1/1' );
delete_block( [ taskSubs, '/TaskBlkPart' ] );

mdlAddSyncPartForTask( taskSubs, tskBlkName );
else 

delete_line( taskSubs, 'Variant Source/1', 'Out1/1' );
delete_line( taskSubs, 'TaskBlkPart/1', 'Variant Source/1' );
delete_line( taskSubs, 'FcnCallGenPart/1', 'Variant Source/2' );
delete_block( [ taskSubs, '/Variant Source' ] );
delete_block( [ taskSubs, '/FcnCallGenPart' ] );
add_line( taskSubs, 'TaskBlkPart/1', 'Out1/1' );
end 
end 
function i_HandleHSBOFFVariant( mgrBlk, taskName, taskData, tskBlkName )
thisSys = hlpGetTaskBlocksHSBOFFVariant( mgrBlk );
delete_line( thisSys, [ tskBlkName, '/1' ], [ taskName, '/1' ] );
delete_block( [ thisSys, '/', tskBlkName ] );
if isequal( taskData.taskType, 'Timer-driven' )
blk = 'simulink/Ports & Subsystems/Function-Call Generator';
add_block( blk, [ thisSys, '/', tskBlkName ], 'sample_time', '-1' );
else 
blk = 'esblib_internal/Task';
add_block( blk, [ thisSys, '/', tskBlkName ],  ...
'taskType', 'Event-driven',  ...
'taskPriority', num2str( taskData.taskPriority ),  ...
'taskEvent', taskData.taskEvent );
end 
add_line( thisSys, [ tskBlkName, '/1' ], [ taskName, '/1' ] );
end 
end 
function locUpdateTaskBlockParameters( taskData, hTaskBlk )
params = fieldnames( taskData );
paramsToSkip = { 'coreSelection', 'taskDurationData', 'taskEventSource',  ...
'taskEventSourceAssignmentType', 'version' };
for iParam = 1:numel( params )
if ismember( params{ iParam }, paramsToSkip ), continue ;end 
outVal = hlpConvertValueToBlockDataType( taskData.( params{ iParam } ) );
try 
if ~isequal( get_param( hTaskBlk, params{ iParam } ), outVal )
set_param( hTaskBlk, params{ iParam }, outVal );
end 
catch ME %#ok<NASGU>




end 
end 
end 
function locUpdateTimerDrivenTaskSampleTime( mgrBlk, taskName, taskData )
blkName = hlpGetTaskBlockName( taskName );
blks{ 1 } = [ hlpGetTaskBlocksHSBONVariant( mgrBlk ), '/' ...
, hlpGetTaskSubsName( taskName ), '/FcnCallGenPart/', 'FcnCallGen' ];
blks{ end  + 1 } = [ hlpGetTaskBlocksHSBOFFVariant( mgrBlk ), '/', blkName ];
for i = 1:numel( blks )
blk = blks{ i };
if isequal( get_param( blk, 'MaskType' ), 'Function-Call Generator' )
set_param( blk, 'sample_time', num2str( taskData.taskPeriod ) );
end 
end 
end 
end 

function mdlAddSyncPartForTask( dest, tskBlkName )
locAddTaskBlkPart( dest, tskBlkName );
locAddFcnCallGenPart( dest );
locAddVariantSourceBlock( dest );
add_line( dest, 'TaskBlkPart/1', 'Variant Source/1' );
add_line( dest, 'FcnCallGenPart/1', 'Variant Source/2' );
add_line( dest, [ 'Variant Source', '/1' ], 'Out1/1' );
function locAddTaskBlkPart( dest, tskBlkName )
taskBlkPartSubsys = [ dest, '/TaskBlkPart' ];
mdlAddSubsystemWithOutportOnly( taskBlkPartSubsys );
add_block( 'esblib_internal/Task', [ taskBlkPartSubsys, '/', tskBlkName ],  ...
'taskType', 'Timer-driven' );
add_line( taskBlkPartSubsys, [ tskBlkName, '/1' ], 'Out1/1' );
end 
function locAddFcnCallGenPart( dest )
fcnCallGenPartSubsys = [ dest, '/FcnCallGenPart' ];
mdlAddSubsystemWithOutportOnly( fcnCallGenPartSubsys );
add_block( 'simulink/Ports & Subsystems/Function-Call Generator',  ...
[ fcnCallGenPartSubsys, '/', 'FcnCallGen' ], 'sample_time', '-1' );
add_line( fcnCallGenPartSubsys, 'FcnCallGen/1', 'Out1/1' );
end 
function locAddVariantSourceBlock( dest )
add_block( 'simulink/Signal Routing/Variant Source',  ...
[ dest, '/', 'Variant Source' ], 'OutputFunctionCall', 'on' );
set_param( [ dest, '/', 'Variant Source' ], 'VariantControlMode',  ...
'Sim codegen switching', 'VariantControls', { '(sim)';'(codegen)' } );

set_param( [ dest, '/', 'Variant Source' ], 'Tag', '_uses_sim_codegen_variant_' );
end 
end 
function mdlAddAsyncPartForTask( dest, tskBlkName )
taskBlkPartSubsys = [ dest, '/TaskBlkPart' ];
mdlAddSubsystemWithOutportOnly( taskBlkPartSubsys );
add_block( 'esblib_internal/Task', [ taskBlkPartSubsys, '/', tskBlkName ],  ...
'taskType', 'Event-driven' );
add_line( taskBlkPartSubsys, [ tskBlkName, '/1' ], 'Out1/1' );
add_line( dest, 'TaskBlkPart/1', 'Out1/1' );
end 
function mdlUpdateTaskBlockWithNoDurationPort( mgrBlk, taskName, taskData )
mdlDelTaskBlockDurPort( mgrBlk, taskName );
appCommonTaskBlockUpdate( mgrBlk, taskName, taskData );
end 
function mdlUpdateTaskBlockWithDurationPort( mgrBlk, taskName, taskData )
appCommonTaskBlockUpdate( mgrBlk, taskName, taskData );
portName = hlpGetDurPortName( taskName );


if isempty( find_system( hlpGetTaskSubs( mgrBlk, taskName ), 'FirstResultOnly', 'on', 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'Name', portName ) )
locAddDurPortTaskBlkPart(  );
locAddDurPortTaskSubs(  );
locAddDurPortHSBONVariant(  );
locAddDurPortVariantSubs(  );
locAddDurPortTaskBlockSubs(  );
locAddDurPortTaskManager(  );
end 

function locAddDurPortTaskBlkPart(  )
dest = [ hlpGetTaskSubs( mgrBlk, taskName ), '/TaskBlkPart' ];
tskBlkName = hlpGetTaskBlockName( taskName );
add_block( 'simulink/Sources/In1', [ dest, '/', portName ] );
add_line( dest, [ portName, '/1' ], [ tskBlkName, '/1' ] );
end 
function locAddDurPortTaskSubs(  )
dest = hlpGetTaskSubs( mgrBlk, taskName );
add_block( 'simulink/Sources/In1', [ dest, '/', portName ] );
add_line( dest, [ portName, '/1' ], 'TaskBlkPart/1' );
end 
function locAddDurPortHSBONVariant(  )
dest = hlpGetTaskBlocksHSBONVariant( mgrBlk );
tskSubsName = hlpGetTaskSubsName( taskName );
add_block( 'simulink/Sources/In1', [ dest, '/', portName ] );
add_line( dest, [ portName, '/1' ], [ tskSubsName, '/1' ] );
end 
function locAddDurPortVariantSubs(  )
dest = hlpGetTaskBlocksVariantSubsystem( mgrBlk );
add_block( 'simulink/Sources/In1', [ dest, '/', portName ] );

end 
function locAddDurPortTaskBlockSubs(  )
dest = hlpTaskBlocksSubsystem( mgrBlk );
add_block( 'simulink/Sources/In1', [ dest, '/', portName ] );
variantSubs = hlpGetTaskBlocksVariantSubsystem( mgrBlk );
idx = hlpFindInportIdxForName( variantSubs, portName );
idxStr = num2str( idx );
add_line( dest, [ portName, '/1' ], [ hlpGetVariantSubsName, '/', idxStr ] );
end 
function locAddDurPortTaskManager(  )
dest = mgrBlk;
add_block( 'simulink/Sources/In1', [ dest, '/', portName ] );
taskSubs = hlpTaskBlocksSubsystem( mgrBlk );
idx = hlpFindInportIdxForName( taskSubs, portName );
str = num2str( idx );
add_line( mgrBlk, [ portName, '/1' ], [ hlpGetAllTasksSubsName, '/', str ] );
end 
end 
function mdlAddTaskBlkHSBONVariant( mgrBlk, taskName )
dest = hlpGetTaskBlocksHSBONVariant( mgrBlk );
taskSubsysName = hlpGetTaskSubsName( taskName );
taskSubs = [ dest, '/', taskSubsysName ];
tskBlkName = hlpGetTaskBlockName( taskName );
fcnBlk = hlpGetFcnPortName( taskName );
add_block( 'simulink/Sinks/Out1', [ dest, '/', fcnBlk ] );
if locIsTimerDriven(  )
locAddSubsystemForSyncTask(  );
else 
locAddSubsystemForAsyncTask(  );
end 
add_line( dest, [ taskSubsysName, '/1' ], [ fcnBlk, '/1' ] );

function locAddSubsystemForSyncTask
mdlAddSubsystemWithOutportOnly( taskSubs );
mdlAddSyncPartForTask( taskSubs, tskBlkName );
set_param( [ taskSubs, '/FcnCallGenPart/', 'FcnCallGen' ], 'sample_time',  ...
locGetTaskPeriodStr(  ) );
end 
function locAddSubsystemForAsyncTask
mdlAddSubsystemWithOutportOnly( taskSubs );
mdlAddAsyncPartForTask( taskSubs, tskBlkName );
end 
function out = locIsTimerDriven
allTaskData = get_param( mgrBlk, 'AllTaskData' );
dm = soc.internal.TaskManagerData( allTaskData );
task = dm.getTask( taskName );
out = isequal( task.taskType, 'Timer-driven' );
end 
function out = locGetTaskPeriodStr
allTaskData = get_param( mgrBlk, 'AllTaskData' );
dm = soc.internal.TaskManagerData( allTaskData );
task = dm.getTask( taskName );
out = num2str( task.taskPeriod );
end 
end 
function mdlAddSubsystemWithOutportOnly( fullSubsName )
add_block( 'simulink/Ports & Subsystems/Subsystem', fullSubsName );
delete_line( fullSubsName, 'In1/1', 'Out1/1' );
delete_block( [ fullSubsName, '/In1' ] );
end 
function mdlAddTaskBlkHSBOFFVariant( mgrBlk, taskName )
tskBlkName = hlpGetTaskBlockName( taskName );
outBlkName = hlpGetFcnPortName( taskName );
thisSys = hlpGetTaskBlocksHSBOFFVariant( mgrBlk );
allTaskData = get_param( mgrBlk, 'AllTaskData' );
dm = soc.internal.TaskManagerData( allTaskData );
taskData = dm.getTask( taskName );
tskBlk = 'esblib_internal/Task';
outBlk = 'simulink/Sinks/Out1';
insertedTaskBlk = [ thisSys, '/', tskBlkName ];
if isequal( taskData.taskType, 'Event-driven' )
add_block( tskBlk, [ thisSys, '/', tskBlkName ], 'taskType', 'Event-driven' );
set_param( insertedTaskBlk, 'taskName', taskName );
set_param( insertedTaskBlk, 'taskEvent', taskData.taskEvent );
set_param( insertedTaskBlk, 'taskPriority', num2str( taskData.taskPriority ) );
else 
tskBlk = 'simulink/Ports & Subsystems/Function-Call Generator';
add_block( tskBlk, [ thisSys, '/', tskBlkName ], 'sample_time', taskData.taskPeriod );
end 
add_block( outBlk, [ thisSys, '/', outBlkName ] );
add_line( thisSys, [ tskBlkName, '/1' ], [ outBlkName, '/1' ] );
end 
function mdlAddTaskBlockFcnCallPort( mgrBlk, taskName )
fcnBlkName = hlpGetFcnPortName( taskName );
locAddFcnPortVariantSubs(  );
locAddFcnPortAllTaskBlocksSubs(  );
locAddFcnPortTaskManager(  );

function locAddFcnPortTaskManager(  )
dest = mgrBlk;
add_block( 'simulink/Sinks/Out1', [ dest, '/', fcnBlkName ] );
taskSubs = hlpTaskBlocksSubsystem( mgrBlk );
idx = hlpFindOutportIdxForTask( taskSubs, taskName );
idxStr = num2str( idx );
add_line( mgrBlk, [ hlpGetAllTasksSubsName, '/', idxStr ], [ fcnBlkName, '/1' ] );
end 
function locAddFcnPortAllTaskBlocksSubs(  )
dest = hlpTaskBlocksSubsystem( mgrBlk );
add_block( 'simulink/Sinks/Out1', [ dest, '/', fcnBlkName ] );
variantSubs = hlpGetTaskBlocksVariantSubsystem( mgrBlk );
idx = hlpFindOutportIdxForTask( variantSubs, taskName );
idxStr = num2str( idx );
add_line( dest, [ hlpGetVariantSubsName, '/', idxStr ], [ fcnBlkName, '/1' ] );
end 
function locAddFcnPortVariantSubs(  )
dest = hlpGetTaskBlocksVariantSubsystem( mgrBlk );
add_block( 'simulink/Sinks/Out1', [ dest, '/', fcnBlkName ], 'OutputFunctionCall', 'on' );

end 
end 
function mdlDelTaskBlockDurPort( mgrBlk, taskName )
portName = hlpGetDurPortName( taskName );
taskBlocksSubs = hlpGetTaskBlocksHSBONVariant( mgrBlk );
if ~isempty( find_system( taskBlocksSubs, 'Name', portName ) )
idx = hlpFindInportIdxForName( taskBlocksSubs, hlpGetDurPortName( taskName ) );
idxStr = num2str( idx );
locDelPortFromTaskManager(  );
locDelPortFromAllTaskSubs(  );
locDelPortFromVariantSubs(  );
locDelPortFromHSBONSubs(  );
locDelPortFromTaskSubs(  );
locDelPortFromTaskPart(  );
end 

function locDelPortFromTaskManager(  )
delete_line( mgrBlk, [ portName, '/1' ], [ hlpGetAllTasksSubsName, '/', idxStr ] );
delete_block( [ mgrBlk, '/', portName ] );
end 
function locDelPortFromAllTaskSubs(  )
from = hlpTaskBlocksSubsystem( mgrBlk );
delete_line( from, [ portName, '/1' ], [ hlpGetVariantSubsName, '/', idxStr ] );
delete_block( [ from, '/', portName ] );
end 
function locDelPortFromVariantSubs(  )
from = hlpGetTaskBlocksVariantSubsystem( mgrBlk );
delete_block( [ from, '/', portName ] );
end 
function locDelPortFromHSBONSubs(  )
from = hlpGetTaskBlocksHSBONVariant( mgrBlk );
delete_line( from, [ portName, '/1' ],  ...
[ hlpGetTaskSubsName( taskName ), '/1' ] );
delete_block( [ from, '/', portName ] );
end 
function locDelPortFromTaskSubs(  )
from = hlpGetTaskSubs( mgrBlk, taskName );
delete_line( from, [ portName, '/1' ], 'TaskBlkPart/1' );
delete_block( [ from, '/', portName ] );
end 
function locDelPortFromTaskPart(  )
from = [ hlpGetTaskSubs( mgrBlk, taskName ), '/TaskBlkPart' ];
tskBlkName = hlpGetTaskBlockName( taskName );
delete_line( from, [ portName, '/1' ], [ tskBlkName, '/1' ] );
delete_block( [ from, '/', portName ] );
end 
end 
function mdlDelTaskBlockFcnCallPort( mgrBlk, taskName )
fcnPortName = hlpGetFcnPortName( taskName );
locDelFcnPortTaskManager(  );
locDelFcnPortAllTaskBlocksSubs(  );
locDelFcnPortVariantSubs(  );

function locDelFcnPortTaskManager(  )
dest = mgrBlk;
taskSubs = hlpTaskBlocksSubsystem( mgrBlk );
idx = hlpFindOutportIdxForTask( taskSubs, taskName );
idxStr = num2str( idx );
delete_line( dest, [ hlpGetAllTasksSubsName, '/', idxStr ],  ...
[ fcnPortName, '/1' ] );
delete_block( [ dest, '/', fcnPortName ] );
end 
function locDelFcnPortAllTaskBlocksSubs(  )
dest = hlpTaskBlocksSubsystem( mgrBlk );
variantSubs = hlpGetTaskBlocksVariantSubsystem( mgrBlk );
idx = hlpFindOutportIdxForTask( variantSubs, taskName );
idxStr = num2str( idx );
delete_line( dest, [ hlpGetVariantSubsName, '/', idxStr ],  ...
[ fcnPortName, '/1' ] );
delete_block( [ dest, '/', fcnPortName ] );
end 
function locDelFcnPortVariantSubs(  )
dest = hlpGetTaskBlocksVariantSubsystem( mgrBlk );
delete_block( [ dest, '/', fcnPortName ] );
end 
end 
function mdlDelTaskBlock( mgrBlk, taskName )
taskSubsName = hlpGetTaskSubsName( taskName );
fcnPortName = hlpGetFcnPortName( taskName );
locDelTaskBlkHSBONVariant(  );
locDelFcnCallGenBlkHSBOFFVariant(  );

function locDelTaskBlkHSBONVariant(  )
dest = hlpGetTaskBlocksHSBONVariant( mgrBlk );
hTaskSubs = [ dest, '/', taskSubsName ];
delete_line( dest, [ taskSubsName, '/1' ], [ fcnPortName, '/1' ] );
delete_block( hTaskSubs );
delete_block( [ dest, '/', fcnPortName ] );
end 
function locDelFcnCallGenBlkHSBOFFVariant(  )
dest = hlpGetTaskBlocksHSBOFFVariant( mgrBlk );
tskBlockName = hlpGetTaskBlockName( taskName );
hTaskBlk = [ dest, '/', tskBlockName ];
delete_line( dest, [ tskBlockName, '/1' ], [ fcnPortName, '/1' ] );
delete_block( hTaskBlk );
delete_block( [ dest, '/', fcnPortName ] );
end 
end 
function appUpdateCoreTaskManager( mgrBlk, taskName, taskData )
isEventDriven = isequal( taskData.taskType, 'Event-driven' );
eventName = soc.internal.TaskManagerData.getDefaultEventName( taskName );
blks = get_param( mgrBlk, 'Blocks' );
portExist = any( strcmp( eventName, blks ) );
coreMgr = [ mgrBlk, '/', hlpGetCoreTaskManager ];
variant = [ coreMgr, '/', hlpGetVariantSubsName ];
if isEventDriven && ~portExist

priority = taskData.taskPriority;
addEventPortToCoreTaskManager( mgrBlk, eventName, priority, coreMgr, variant );
elseif ~isEventDriven && portExist

removePortFromCoreTaskManager( mgrBlk, eventName, coreMgr, variant );
end 
if isEventDriven
loc_updateServerEntryActionForHSBOFF( variant, eventName );
end 





function loc_updateServerEntryActionForHSBOFF( variant, event )
thisVar = [ variant, '/HSBOFF' ];
hsbSys = [ thisVar, '/Task Manager/Task Manager' ];
serv = [ hsbSys, '/', event, 'Server' ];
str = taskData.taskPriority;
actStr = [ 'soc_AsyncTaskHSBOff(uint32(', str, '))' ];
if ~isequal( get_param( serv, 'EntryAction' ), actStr )
set_param( serv, 'EntryAction', actStr );
end 
end 
end 
function addEventPortToCoreTaskManager( mgrBlk, eventName, priority, coreTaskManager, variant )
addEventPortToHSBOn( mgrBlk, eventName, coreTaskManager, variant );
addEventPortToHSBOff( mgrBlk, eventName, priority, coreTaskManager, variant );

variantBlks = get_param( variant, 'Blocks' );
portExists = any( strcmp( eventName, variantBlks ) );
if ~portExists
add_block( 'simulink/Sources/In1', [ variant, '/', eventName ] );
end 


coreTaskManagerBlks = get_param( coreTaskManager, 'Blocks' );
coreTaskManagerPortExists = any( strcmp( eventName, coreTaskManagerBlks ) );
if ~coreTaskManagerPortExists
add_block( 'simulink/Sources/In1', [ coreTaskManager, '/', eventName ] );
idx = hlpFindInportIdxForName( variant, eventName );
idxStr = num2str( idx );
add_line( coreTaskManager, [ eventName, '/1' ], [ hlpGetVariantSubsName, '/', idxStr ] );
end 

add_block( 'simulink/Sources/In1', [ mgrBlk, '/', eventName ] );
set_param( [ mgrBlk, '/', eventName ], 'OutDataTypeStr', 'Bus: rteEvent' );
idx = hlpFindInportIdxForName( coreTaskManager, eventName );
idxStr = num2str( idx );
add_line( mgrBlk, [ eventName, '/1' ], [ hlpGetCoreTaskManager, '/', idxStr ] );
end 
function addContentToCoreTaskManagerLayer3b( taskMgr, eventName )
thisSys = [ taskMgr, '/', hlpGetNop ];
containedBlks = get_param( thisSys, 'Blocks' );
thisEventPortExists = any( strcmp( eventName, containedBlks ) );
if ~thisEventPortExists
port = [ thisSys, '/', eventName ];
term = [ thisSys, '/', eventName, 'Term' ];
add_block( 'simulink/Sources/In1', port );
add_block( 'simulink/Sinks/Terminator', term );
add_line( thisSys, [ eventName, '/1' ], [ eventName, 'Term', '/1' ] );
end 
end 
function addContentToCoreTaskManagerLayer2( taskMgr, eventName )
taskManagerBlks = get_param( taskMgr, 'Blocks' );
topPortExists = any( strcmp( eventName, taskManagerBlks ) );
if ~topPortExists
add_block( 'simulink/Sources/In1', [ taskMgr, '/', eventName ] );
end 
end 
function addContentToCoreTaskManagerLayer1( taskMgr, thisSys, eventName )
hsbOnBlks = get_param( thisSys, 'Blocks' );
hsbOnPortExists = any( strcmp( eventName, hsbOnBlks ) );
if ~hsbOnPortExists
add_block( 'simulink/Sources/In1', [ thisSys, '/', eventName ] );
idx = hlpFindInportIdxForName( taskMgr, eventName );
idxStr = num2str( idx );
add_line( thisSys, [ eventName, '/1' ], [ hlpGetTaskManager, '/', idxStr ] );
end 
end 

function addContentToCoreTaskManagerLayer3aHSBON( taskMgr, eventName )
thisSys = [ taskMgr, '/', hlpGetTaskManager ];
thisSysBlks = get_param( thisSys, 'Blocks' );
serverExists = any( strcmp( hlpGetDstEventServer( eventName ), thisSysBlks ) );
if ~serverExists

entity = [ thisSys, '/', hlpGetEntitySwitch ];
curPort = str2double( get_param( entity, 'NumberInputPorts' ) );
newPort = num2str( curPort + 1 );
set_param( entity, 'NumberInputPorts', newPort );
port = [ thisSys, '/', eventName ];
server = [ thisSys, '/', hlpGetDstEventServer( eventName ) ];
add_block( hlpGetSrcEventServer, server );
add_block( 'simulink/Sources/In1', port );
add_line( thisSys, [ eventName, '/1' ],  ...
[ hlpGetDstEventServer( eventName ), '/1' ] );
add_line( thisSys, [ hlpGetDstEventServer( eventName ), '/1' ],  ...
[ hlpGetEntitySwitch, '/', newPort ] );
setServerEntryAction( server, eventName );
setServerServiceTime( server );
end 
end 

function addContentToCoreTaskManagerLayer3aHSBOFF( taskMgr, eventName, priority )
thisSys = [ taskMgr, '/', hlpGetTaskManager ];
thisSysBlks = get_param( thisSys, 'Blocks' );
eventPortExists = any( strcmp( eventName, thisSysBlks ) );
if ~eventPortExists
port = [ thisSys, '/', eventName ];
term = [ thisSys, '/', eventName, 'Term' ];
serv = [ thisSys, '/', eventName, 'Server' ];
add_block( 'simulink/Sources/In1', port );
add_block( 'esblib_internal/EventServer', serv );
add_block( 'simulink/Sinks/Terminator', term );
add_line( thisSys, [ eventName, '/1' ], [ eventName, 'Server', '/1' ] );
add_line( thisSys, [ eventName, 'Server', '/1' ], [ eventName, 'Term', '/1' ] );
str = mat2str( priority );
set_param( serv, 'EntryAction', [ 'soc_AsyncTaskHSBOff(uint32(', str, '))' ] );
dispatchExists = any( strcmp( 'Async Task Simplified Dispatch', thisSysBlks ) );
if ~dispatchExists
blk = [ thisSys, '/', 'Async Task Simplified Dispatch' ];
add_block( 'esblib_internal/Async Task Simplified Dispatch', blk );
end 
end 
end 


function addEventPortToHSBOn( ~, eventName, ~, variant )





















thisSys = [ variant, '/HSBON' ];
taskMgr = [ thisSys, '/', hlpGetTaskManager ];
addContentToCoreTaskManagerLayer3aHSBON( taskMgr, eventName );
addContentToCoreTaskManagerLayer3b( taskMgr, eventName );
addContentToCoreTaskManagerLayer2( taskMgr, eventName );
addContentToCoreTaskManagerLayer1( taskMgr, thisSys, eventName );
end 


function addEventPortToHSBOff( ~, eventName, priority, ~, variant )





















thisSys = [ variant, '/HSBOFF' ];
taskMgr = [ thisSys, '/', hlpGetTaskManager ];
addContentToCoreTaskManagerLayer3aHSBOFF( taskMgr, eventName, priority );
addContentToCoreTaskManagerLayer3b( taskMgr, eventName );
addContentToCoreTaskManagerLayer2( taskMgr, eventName );
addContentToCoreTaskManagerLayer1( taskMgr, thisSys, eventName );
end 
function removePortFromCoreTaskManager( mgrBlk, eventName, coreTaskMgr, variant )
idx = hlpFindInportIdxForName( coreTaskMgr, eventName );
str = num2str( idx );
delete_line( mgrBlk, [ eventName, '/1' ], [ hlpGetCoreTaskManager, '/', str ] );
delete_block( [ mgrBlk, '/', eventName ] );


coreTaskMgrBlks = get_param( coreTaskMgr, 'Blocks' );
coreTaskMgrPortExists = any( strcmp( eventName, coreTaskMgrBlks ) );
if coreTaskMgrPortExists
idx = hlpFindInportIdxForName( variant, eventName );
str = num2str( idx );
delete_line( coreTaskMgr, [ eventName, '/1' ], [ hlpGetVariantSubsName, '/', str ] );
delete_block( [ coreTaskMgr, '/', eventName ] );
end 


variantBlks = get_param( variant, 'Blocks' );
portExists = any( strcmp( eventName, variantBlks ) );
if portExists
delete_block( [ variant, '/', eventName ] );
end 
removePortFromHSBOn( mgrBlk, eventName, coreTaskMgr, variant );
removePortFromHSBOff( mgrBlk, eventName, coreTaskMgr, variant );
end 


function removePortFromHSBOn( ~, eventName, ~, variant )






















thisVar = [ variant, '/HSBON' ];
taskMgr = [ thisVar, '/', hlpGetTaskManager ];
locRemovePortFromLevel1( thisVar, taskMgr, eventName );
locRemovePortFromLevel2( taskMgr, eventName );
locRemovePortFromLevel3a( taskMgr, eventName );
locRemovePortFromLevel3b( taskMgr, eventName );

function locRemovePortFromLevel3a( taskMgr, event )
nop = [ taskMgr, '/', hlpGetNop ];
nopBlks = get_param( nop, 'Blocks' );
portExists = any( strcmp( event, nopBlks ) );
if portExists
port = [ nop, '/', event ];
term = [ nop, '/', event, 'Term' ];
delete_line( nop, [ event, '/1' ], [ event, 'Term', '/1' ] );
delete_block( port );
delete_block( term );
end 
end 
function locRemovePortFromLevel3b( taskMgr, event )
thisSys = [ taskMgr, '/', hlpGetTaskManager ];
thisSysBlks = get_param( thisSys, 'Blocks' );
serverExists = any( strcmp( hlpGetDstEventServer( event ), thisSysBlks ) );
if serverExists

entity = [ thisSys, '/', hlpGetEntitySwitch ];
curPort = str2double( get_param( entity, 'NumberInputPorts' ) );
newPort = num2str( curPort - 1 );
port = [ thisSys, '/', event ];
server = [ thisSys, '/', hlpGetDstEventServer( event ) ];
delete_line( thisSys, [ event, '/1' ],  ...
[ hlpGetDstEventServer( event ), '/1' ] );
delete_block( server );
delete_block( port );

set_param( entity, 'NumberInputPorts', newPort );

lines = find_system( thisSys, 'LookUnderMasks', 'all',  ...
'FindAll', 'on', 'SearchDepth', 1, 'Type', 'line' );

for i = 1:length( lines )
if ishandle( lines( i ) ) && ( get( lines( i ), 'DstPortHandle' ) < 0 ...
 || get( lines( i ), 'SrcPortHandle' ) < 0 )
delete_line( lines( i ) );
end 
end 

allBlocks = get_param( thisSys, 'Blocks' );
for i = 1:numel( allBlocks )
if hlpIsEventServer( allBlocks{ i } )
serverBlock = allBlocks{ i };
if ii_isServerDisconnected( thisSys, serverBlock )
pIdx = ii_getDisconnectedSwitchPortIdx( thisSys );
add_line( thisSys, [ serverBlock, '/1' ],  ...
[ hlpGetEntitySwitch, '/', num2str( pIdx ) ] );
end 
end 
end 
end 
function ret = ii_isServerDisconnected( thisSystem, serverBlock )
ret = false;
pc = get_param( [ thisSystem, '/', serverBlock ], 'PortConnectivity' );
for i1 = 1:numel( pc )
p = pc( i1 );
if ( isempty( p.SrcBlock ) && isempty( p.DstBlock ) )
ret = true;
return ;
end 
end 
end 
function pIdx = ii_getDisconnectedSwitchPortIdx( thisSystem )
blk = [ thisSystem, '/', 'Switch' ];
pc = get_param( blk, 'PortConnectivity' );
for i2 = 1:numel( pc )
p = pc( i2 );
if ( isempty( p.SrcBlock ) || isequal( p.SrcBlock,  - 1 ) ) &&  ...
( isempty( p.DstBlock ) || isequal( p.DstBlock,  - 1 ) )
pIdx = str2double( p.Type );
return ;
end 
end 
end 
end 
function locRemovePortFromLevel2( thisSys, event )
thisSysBlks = get_param( thisSys, 'Blocks' );
portExists = any( strcmp( event, thisSysBlks ) );
if portExists
delete_block( [ thisSys, '/', event ] );
end 
end 
function locRemovePortFromLevel1( thisSys, taskMgr, event )
thisSysBlks = get_param( thisSys, 'Blocks' );
portExists = any( strcmp( event, thisSysBlks ) );
if portExists
idx = hlpFindInportIdxForName( taskMgr, event );
str = num2str( idx );
delete_line( thisSys, [ event, '/1' ], [ hlpGetTaskManager, '/', str ] );
delete_block( [ thisSys, '/', event ] );
end 
end 
end 


function removePortFromHSBOff( ~, eventName, ~, variant )






















thisVar = [ variant, '/HSBOFF' ];
taskMgr = [ thisVar, '/', hlpGetTaskManager ];
locRemovePortFromLevel1( thisVar, taskMgr, eventName );
locRemovePortFromLevel2( taskMgr, eventName );
locRemovePortFromLevel3a( taskMgr, eventName );
locRemovePortFromLevel3b( taskMgr, eventName );

function locRemovePortFromLevel3a( taskMgr, event )
thisSys = [ taskMgr, '/', hlpGetTaskManager ];
thisSysBlks = get_param( thisSys, 'Blocks' );
portExists = any( strcmp( event, thisSysBlks ) );
if portExists
port = [ thisSys, '/', event ];
serv = [ thisSys, '/', event, 'Server' ];
term = [ thisSys, '/', event, 'Term' ];
delete_line( thisSys, [ event, '/1' ], [ event, 'Server', '/1' ] );
delete_line( thisSys, [ event, 'Server', '/1' ], [ event, 'Term', '/1' ] );
delete_block( port );
delete_block( serv );
delete_block( term );
if numel( thisSysBlks ) == 4
dispatch = [ thisSys, '/', 'Async Task Simplified Dispatch' ];
delete_block( dispatch );
end 
end 
end 
function locRemovePortFromLevel3b( taskMgr, event )
thisSys = [ taskMgr, '/NOP' ];
port = [ thisSys, '/', event ];
term = [ thisSys, '/', event, 'Term' ];
delete_line( thisSys, [ event, '/1' ], [ event, 'Term', '/1' ] );
delete_block( port );
delete_block( term );
end 
function locRemovePortFromLevel2( thisSys, event )
port = [ thisSys, '/', event ];
delete_block( port );
end 
function locRemovePortFromLevel1( thisSys, taskMgr, event )
thisSysBlks = get_param( thisSys, 'Blocks' );
portExists = any( strcmp( event, thisSysBlks ) );
if portExists
idx = hlpFindInportIdxForName( taskMgr, event );
str = num2str( idx );
delete_line( thisSys, [ event, '/1' ], [ hlpGetTaskManager, '/', str ] );
delete_block( [ thisSys, '/', event ] );
end 
end 
end 
function setServerEntryAction( server, eventName )
filler = 64 - length( eventName );
action = sprintf( 'entity.name = [uint16(''%s''),uint16(nan([1,%d]))]'';',  ...
eventName, filler );
set_param( server, 'EntryAction', action );
initFcn = sprintf( 'soc.internal.EventServerInitFcn(gcbh, ''%s'');\n',  ...
eventName );
set_param( server, 'InitFcn', initFcn );
end 
function setServerServiceTime( server )
set_param( server, 'ServiceTimeValue', 'mwTaskManagerKernelLatency' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpxLGPk7.p.
% Please follow local copyright laws when handling this file.

