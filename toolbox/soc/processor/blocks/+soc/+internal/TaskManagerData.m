classdef TaskManagerData < handle




properties ( SetAccess = protected, GetAccess = protected )
EncodedData = '';









Version = '2.4';
end 

methods ( Static = true, Hidden )
function eventName = getDefaultEventName( taskName )
eventName = [ taskName, 'Event' ];
end 
end 

methods ( Access = 'private' )
function data = decodeData( ~, data )
data = jsondecode( data );
end 
function data = encodeData( ~, data )
data = jsonencode( data );
end 
function value = evalParam( ~, value, mdl )
value = soc.blocks.evaluateBlockParameter( value, mdl );
end 
function updateData( h, currentEncoddedData )
data = h.decodeData( currentEncoddedData );
if ~isempty( data )
curVersion = '1.0';
if isfield( data( 1 ), 'version' )
curVersion = data( 1 ).version;
end 
curVersionNum = str2double( curVersion );
if ( curVersionNum < 2.0 )
i_convertToTaskDurationData(  );
end 
if ( curVersionNum < 2.1 )
i_convertTaskEditDataToStr(  )
end 
if ( curVersionNum < 2.2 )
i_addEventSourceToTaskData(  );
end 
if ( curVersionNum < 2.3 )
i_addEventSourceAssignmentTypeToTaskData(  );
end 
if ( curVersionNum < 2.4 )
i_addEventSourceTypeToTaskData(  );
end 
end 
h.EncodedData = h.encodeData( data );
function i_convertToTaskDurationData


for i = 1:numel( data )
dur = data( i ).taskDuration;
dev = data( i ).taskDurationDeviation;
data( i ).version = h.Version;
data( i ).taskDurationData = h.getDefaultTaskDurationData;
data( i ).taskDurationData.mean = dur;
data( i ).taskDurationData.dev = dev;
data( i ).taskDurationData.min = dur - 3 * dev;
data( i ).taskDurationData.max = dur + 3 * dev;
end 
end 
function i_convertTaskEditDataToStr(  )

for ii = 1:numel( data )
data( ii ).version = h.Version;
data( ii ).taskPeriod = num2str( data( ii ).taskPeriod );
data( ii ).taskPriority = num2str( data( ii ).taskPriority );
data( ii ).coreNum = num2str( data( ii ).coreNum );
for jj = 1:numel( data( ii ).taskDurationData )
tdd = data( ii ).taskDurationData( jj );
fnames = fieldnames( tdd );
for kk = 1:numel( fnames )
data( ii ).taskDurationData( jj ).( fnames{ kk } ) =  ...
num2str( data( ii ).taskDurationData( jj ).( fnames{ kk } ) );
end 
end 
end 
end 
function i_addEventSourceToTaskData

for ii = 1:numel( data )
data( ii ).version = h.Version;
if isequal( data( ii ).taskType, 'Timer-driven' )
str = DAStudio.message( 'codertarget:utils:InternalEvent' );
else 
str = DAStudio.message( 'codertarget:utils:UnspecifiedEvent' );
end 
data( ii ).taskEventSource = str;
end 
end 
function i_addEventSourceAssignmentTypeToTaskData

for ii = 1:numel( data )
data( ii ).version = h.Version;
if isequal( data( ii ).taskType, 'Timer-driven' )
str = DAStudio.message( 'codertarget:utils:AutoAssigned' );
else 
str = DAStudio.message( 'codertarget:utils:Unassigned' );
end 
data( ii ).taskEventSourceAssignmentType = str;
end 
end 
function i_addEventSourceTypeToTaskData

for ii = 1:numel( data )
data( ii ).version = h.Version;
str = DAStudio.message( 'codertarget:utils:UnspecifiedEvent' );
data( ii ).taskEventSourceType = str;
end 
end 
end 
function evaluateData( h, mdl )
tD = h.decodeData( h.EncodedData );
for i = 1:numel( tD )
tD( i ).taskPeriod = h.evalParam( tD( i ).taskPeriod, mdl );
tD( i ).taskPriority = h.evalParam( tD( i ).taskPriority, mdl );
tD( i ).coreNum = h.evalParam( tD( i ).coreNum, mdl );
for j = 1:numel( tD( i ).taskDurationData )
durData = tD( i ).taskDurationData( j );
fNames = fieldnames( durData );
for k = 1:numel( fNames )
tD( i ).taskDurationData( j ).( fNames{ k } ) =  ...
h.evalParam( durData.( fNames{ k } ), mdl );
end 
end 
end 
h.EncodedData = h.encodeData( tD );
end 
function data = getDefaultTaskDurationData( ~ )

data( 1 ).percent = '100';
data( 1 ).mean = '1e-06';
data( 1 ).dev = '0';
data( 1 ).min = '1e-06';
data( 1 ).max = '1e-06';
end 
function newPri = getNextHigherPriority( h )
data = decodeAndGetData( h );
idx = arrayfun( @( x )( isequal( x.taskType, 'Event-driven' ) ), data );
if ~any( idx )
newPri = '50';
else 
eventdriven = data( idx );
strPri = arrayfun( @( x )( x.taskPriority ), eventdriven,  ...
'UniformOutput', false );
numPri = cellfun( @( x )iEval( x ), strPri );
maxPri = max( numPri );
newPri = num2str( maxPri + 1 );
end 
function p = iEval( p )
if isvarname( p )
p = 0;
elseif ~isnumeric( p )
p = eval( p );
end 
end 
end 
function task = getDefaultTask( h, name, supportsEventPorts )

task.taskName = name;
task.taskType = 'Event-driven';
if supportsEventPorts
task.taskEvent = [ name, 'Event' ];
else 
task.taskEvent = '<empty>';
end 
task.taskPeriod = '0.1';
task.taskPriority = h.getNextHigherPriority;
task.coreSelection = 'Specified core';
task.coreNum = '0';
task.dropOverranTasks = false;
task.playbackRecorded = false;




task.diagnosticsFile = '';
task.taskDurationSource = 'Dialog';
task.taskDuration = 0.000001;
task.taskDurationDeviation = 0.0;
task.logExecutionData = true;
task.logDroppedTasks = false;
task.version = h.Version;
task.taskDurationData = h.getDefaultTaskDurationData;
task.taskEventSource = DAStudio.message( 'codertarget:utils:UnspecifiedEvent' );
task.taskEventSourceAssignmentType = DAStudio.message( 'codertarget:utils:Unassigned' );
task.taskEventSourceType = DAStudio.message( 'codertarget:utils:UnspecifiedEvent' );








end 
function allValues = getFieldCellArr( ~, matArr, idxField )
if isempty( matArr )
allValues = {  };
else 
allFields = struct2cell( matArr );
allValues = squeeze( allFields( idxField, :, : ) );
end 
end 
end 

methods 
function h = TaskManagerData( encodedData, varargin )
if ~isempty( encodedData )
h.updateData( encodedData );
if isequal( nargin, 3 ) && isequal( varargin{ 1 }, 'evaluate' )
mdl = varargin{ 2 };
h.evaluateData( mdl );
end 
end 
end 
function data = getData( h )
data = h.EncodedData;
end 
function data = decodeAndGetData( h )
if isempty( h.EncodedData )
data = '';
else 
data = h.decodeData( h.EncodedData );
end 
end 
function encodeAndSetData( h, data )
if ~isempty( data )
h.EncodedData = h.encodeData( data );
else 
h.EncodedData = '';
end 
end 
function addNewTask( h, name, supportsEventPorts )
task = h.getDefaultTask( name, supportsEventPorts );
data = h.decodeAndGetData;
num = numel( data );
if isequal( num, 0 )
data = task;
else 
data( num + 1 ) = task;
end 
h.encodeAndSetData( data );
end 
function deleteTask( h, taskName )
data = h.decodeAndGetData;
allTaskNames = getTaskNames( h );
[ ~, taskIdx ] = ismember( taskName, allTaskNames );
assert( ~isequal( taskIdx, 0 ), 'Task name in deleteTask invalid.' );
if ( numel( allTaskNames ) > 1 )
data( taskIdx ) = [  ];
else 
data = '';
end 
h.encodeAndSetData( data );
end 
function task = updateTask( h, taskName, paramName, paramValue )
data = h.decodeAndGetData;
allTaskNames = getTaskNames( h );
[ ~, taskIdx ] = ismember( taskName, allTaskNames );
assert( ~isequal( taskIdx, 0 ), 'Task name in updateTask invalid.' );
data( taskIdx ).( paramName ) = paramValue;
h.encodeAndSetData( data );
task = data( taskIdx );
end 
function task = getTask( h, taskName )
data = h.decodeAndGetData;
allTaskNames = getTaskNames( h );
[ ~, taskIdx ] = ismember( taskName, allTaskNames );
assert( ~isequal( taskIdx, 0 ), 'Task name in getTask invalid.' );
if ( taskIdx > 0 )
task = data( taskIdx );
else 
task = [  ];
end 
end 
function allTaskNames = getTaskNames( h )
data = h.decodeAndGetData;
if isempty( data )
allTaskNames = {  };
else 
allTaskNames = { data( : ).taskName };
end 
end 
function eventName = setEventNameBasedOnTask( h, taskName )
eventName = soc.internal.TaskManagerData.getDefaultEventName( taskName );
assert( length( eventName ) <= 64, 'Task''s event name is longer than 64 characters' );
h.updateTask( taskName, 'taskEvent', eventName );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpj0Koz7.p.
% Please follow local copyright laws when handling this file.

