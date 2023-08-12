classdef TimerEventSource < soc.internal.EventSource




properties ( SetAccess = private, GetAccess = private )
Data;
Period;
Counter;
MyTime;
NumOverunsOK;
end 
methods ( Access = private )
function loadMetaDataFromFile( h )
[ fid, msg ] = fopen( h.DiagnosticsFileName );
if isequal( fid,  - 1 )
error( message( 'soc:scheduler:DiagFileOpenFailed',  ...
h.DiagnosticsFileName, msg ) );
end 
fclose( fid );
metaData = importdata( h.DiagnosticsFileName );
idx = ismember( metaData.rowheaders, h.TaskName );
taskIdx = find( idx, 1 );
if isempty( taskIdx )
error( message( 'soc:scheduler:NoDataForTask',  ...
h.DiagnosticsFileName, h.TaskName ) );
end 
if isempty( metaData.rowheaders ) ||  ...
isempty( metaData.data )
error( message( 'soc:scheduler:NotMetaDataFormat',  ...
h.DiagnosticsFileName ) );
end 
h.Data.mean = metaData.data( taskIdx, 1 );
h.Data.dev = metaData.data( taskIdx, 2 );
end 

function event = handleOverrunsDropPolicy( h, event, curTime )
while ( event.Time < curTime ) && abs( event.Time - curTime ) > eps
if ( h.LogDroppedTasks )

h.getEventViewer.update( cast( 1, 'int32' ), int64( event.Time * 1e9 ) );
end 
event.Time = event.Time + h.Period;
end 
end 

function event = handleOverrunsCatchupPolicy( h, event, delta )
numExtraOverruns = floor( delta / h.Period ) + 1;
startTime = event.Time;
for i = 1:numExtraOverruns
if ( h.LogDroppedTasks )
val = startTime +  ...
( h.NumOverunsOK + i - 1 ) * h.Period;

h.getEventViewer.update( cast( 1, 'int32' ), int64( val * 1e9 ) );
end 
event.Time = event.Time + h.Period;
end 
end 
end 
methods ( Access = public )
function setPeriod( h, value )
h.Period = value;
end 

function value = getPeriod( h )
value = h.Period;
end 
end 
methods ( Access = public )
function h = TimerEventSource( eventID,  ...
durationFromDiag, diagFileName, taskPeriod, modelName,  ...
taskName, dropOverranTasks, logDroppedTasks, startTime )

h.EventID = eventID;
h.NumOverunsOK = 2;
h.ModelName = modelName;
h.TaskName = taskName;
h.DropOverranTasks = dropOverranTasks;
h.LogDroppedTasks = logDroppedTasks;
h.DurationFromDiagnostics = durationFromDiag;
h.DiagnosticsFileName = diagFileName;
h.StartTime = startTime;

h.Period = taskPeriod;
h.Counter = 0;
h.MyTime = h.StartTime;

if ( h.LogDroppedTasks )
postfix = DAStudio.message( 'soc:scheduler:LogDroppedPostfix' );
h.createTaskEventViewer( postfix );
end 

if h.DurationFromDiagnostics
h.loadMetaDataFromFile;
end 
end 

function setStartTime( h, value )
h.StartTime = value;
h.MyTime = h.StartTime;
end 

function event = getNextEvent( h, ~, curTime )
if h.DurationFromDiagnostics
event = getNextEventDurationFromDiagnostics( h, curTime, 1 );
else 
event = getNextEventDurationFromDialog( h, curTime, 1 );
end 
end 

function dropPastEvents( h, ~, curTime )
if h.DurationFromDiagnostics
getNextEventDurationFromDiagnostics( h, curTime, 0 );
else 
getNextEventDurationFromDialog( h, curTime, 0 );
end 
end 

function event = getNextEventDurationFromDialog( h, curTime, isGet )
event.ID = h.EventID;
event.Time = h.MyTime;
event.TaskDuration = 0.0;
event.IsDurationFromDiagnostics = false;
if h.DropOverranTasks
if ( event.Time < curTime )
event = h.handleOverrunsDropPolicy( event, curTime );
end 
else 
delta = curTime - ( event.Time + h.NumOverunsOK * h.Period );
if ( delta > 0 )
event = h.handleOverrunsCatchupPolicy( event, delta );
end 
end 
if isGet
h.MyTime = event.Time + h.Period;
else 
h.MyTime = event.Time;
end 
end 

function event = getNextEventDurationFromDiagnostics( h, curTime, isGet )
event.ID = h.EventID;
event.Time = h.MyTime;
event.TaskDuration = max( h.Data.mean + h.Data.dev * randn( 1, 1 ), 1e-6 );
event.IsDurationFromDiagnostics = true;
if h.DropOverranTasks
if ( event.Time < curTime )
event = h.handleOverrunsDropPolicy( event, curTime );
end 
else 
delta = curTime - ( event.Time + h.NumOverunsOK * h.Period );
if ( delta > 0 )
event = h.handleOverrunsCatchupPolicy( event, delta );
end 
end 
if isGet
h.MyTime = event.Time + h.Period;
else 
h.MyTime = event.Time;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpi5f0Zs.p.
% Please follow local copyright laws when handling this file.

