classdef ( Sealed )MatlabProfiler < matlab.internal.profiler.interface.AbstractProfiler








properties ( Constant )

DEFAULT_TIMER = matlab.internal.profiler.types.Timer.Performance
DEFAULT_HISTORY_TRACKING = matlab.internal.profiler.types.HistoryTracking.TimeStamp
DEFAULT_HISTORY_SIZE = 5000000
DEFAULT_LOG_LEVEL = matlab.internal.profiler.types.LogLevel.Mmex
DEFAULT_MEMORY_LOGGING = matlab.internal.profiler.types.MemoryLogging.Off
DEFAULT_REMOVE_OVERHEAD = matlab.internal.profiler.types.RemoveOverhead.Off
end 

methods 
function obj = MatlabProfiler(  )
obj@matlab.internal.profiler.interface.AbstractProfiler(  );
end 

function running = isRunning( ~ )
running = strcmp( callstats( 'status' ), 'on' );
end 
end 

methods 


function turnOn( obj )
if ~obj.isRunning(  )
callstats( 'reset' );
end 
callstats( 'resume' );
end 

function turnOff( ~ )
callstats( 'stop' );
end 

function resume( ~ )
callstats( 'resume' );
end 

function clear( ~ )
callstats( 'clear' );
end 

function reset( obj )
obj.turnOff(  );
obj.clear(  );
callstats( 'timer', obj.DEFAULT_TIMER.toNumericId );
callstats( 'history', obj.DEFAULT_HISTORY_TRACKING.toNumericId );
callstats( 'historysize', obj.DEFAULT_HISTORY_SIZE );
callstats( 'level', obj.DEFAULT_LOG_LEVEL.toNumericId );
callstats( 'memory', obj.DEFAULT_MEMORY_LOGGING.toNumericId );
callstats( 'remove_sample_overhead', obj.DEFAULT_REMOVE_OVERHEAD.toNumericId );
end 

function info = getInfo( ~ )
[ ft, fh, cp, name, cs, ~, overhead ] = callstats( 'stats' );
info.FunctionTable = ft;
info.FunctionHistory = fh;
info.ClockPrecision = cp;
info.ClockSpeed = cs;
info.Name = name;
info.Overhead = overhead;
end 

function status = getStatus( ~ )
import matlab.internal.profiler.types.*
import matlab.internal.profiler.getMessageString

status.ProfilerStatus = callstats( 'status' );
switch LogLevel.fromNumericId( callstats( 'level' ) )
case LogLevel.Mmex
status.DetailLevel = getMessageString( 'MATLAB:profile:MMex' );
case LogLevel.Builtin
status.DetailLevel = getMessageString( 'MATLAB:profile:BuiltIn' );
end 

switch Timer.fromNumericId( callstats( 'timer' ) )
case Timer.None
status.Timer = getMessageString( 'MATLAB:profile:None' );
case Timer.Cpu
status.Timer = getMessageString( 'MATLAB:profile:CPU' );
case Timer.Real
status.Timer = getMessageString( 'MATLAB:profile:Real' );
case Timer.Performance
status.Timer = getMessageString( 'MATLAB:profile:Performance' );
case Timer.Processor
status.Timer = getMessageString( 'MATLAB:profile:Processor' );
otherwise 
status.Timer = '';
end 

switch HistoryTracking.fromNumericId( callstats( 'history' ) )
case HistoryTracking.Off
status.HistoryTracking = getMessageString( 'MATLAB:profile:Off' );
case HistoryTracking.On
status.HistoryTracking = getMessageString( 'MATLAB:profile:On' );
case HistoryTracking.TimeStamp
status.HistoryTracking = getMessageString( 'MATLAB:profile:Timestamp' );
end 

status.HistorySize = callstats( 'historysize' );
end 

function configure( ~, config )
R36
~
config( 1, 1 )matlab.internal.profiler.Configuration;
end 

import matlab.internal.profiler.types.*
for option = config.getOptions(  )
if HistoryTracking.isTypeOf( option )
callstats( 'history', option.toNumericId );
elseif LogLevel.isTypeOf( option )
callstats( 'level', option.toNumericId );
elseif Timer.isTypeOf( option )
callstats( 'timer', option.toNumericId );
elseif HistorySize.isTypeOf( option )
callstats( 'historysize', option.SizeOfHistory );
elseif MemoryLogging.isTypeOf( option )
callstats( 'memory', option.toNumericId );
elseif RemoveOverhead.isTypeOf( option )
callstats( 'remove_sample_overhead', option.toNumericId );
end 
end 
end 

function config = getConfig( ~ )
import matlab.internal.profiler.types.*

config = matlab.internal.profiler.Configuration(  );
config.addOption( HistoryTracking.fromNumericId( callstats( 'history' ) ) )
config.addOption( LogLevel.fromNumericId( callstats( 'level' ) ) );
config.addOption( Timer.fromNumericId( callstats( 'timer' ) ) );
config.addOption( HistorySize( callstats( 'historySize' ) ) );
config.addOption( MemoryLogging.fromNumericId( callstats( 'memory' ) ) );
config.addOption( RemoveOverhead.fromNumericId( callstats( 'remove_sample_overhead' ) ) );
end 

function files = getFilesToFilter( ~ )
files = {  ...
'matlab.internal.profiler.types.HistorySize',  ...
'matlab.internal.profiler.types.HistoryTracking',  ...
'matlab.internal.profiler.types.LogLevel',  ...
'matlab.internal.profiler.types.MatlabConfigOption',  ...
'matlab.internal.profiler.types.MemoryLogging',  ...
'matlab.internal.profiler.types.RemoveOverhead',  ...
'matlab.internal.profiler.types.Timer',  ...
'matlab.internal.profiler.MatlabProfiler',  ...
 };
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmph7gvfv.p.
% Please follow local copyright laws when handling this file.

