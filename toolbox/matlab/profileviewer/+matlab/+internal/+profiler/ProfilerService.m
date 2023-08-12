classdef ProfilerService < handle





















properties ( Access = private )

ProfilerImpls


LockMessage = ''


Running = false
end 

properties ( SetAccess = private )







Locked = false
end 

methods 
function obj = registerProfiler( obj, profilerType, instance )
R36
obj
profilerType( 1, 1 )matlab.internal.profiler.ProfilerType
instance( 1, 1 )matlab.internal.profiler.interface.AbstractProfiler
end 


if ~isempty( instance )
obj.ProfilerImpls( char( profilerType ) ) = instance;
end 
end 
end 

methods ( Access = private )
function obj = ProfilerService(  )
obj.ProfilerImpls = containers.Map;
end 

function errorIfLocked( obj )
if obj.Locked
error( obj.LockMessage );
end 
end 

function varargout = executeOnAll( obj, func, executionOrder )




R36
obj
func{ mustBeA( func, 'function_handle' ) }
executionOrder matlab.internal.profiler.ProfilerType =  ...
matlab.internal.profiler.ProfilerType.getDefaultExecutionOrder(  );
end 



nargoutchk( 0, 1 );
if nargout == 1
varargout{ 1 } = containers.Map;
end 

for implIdx = 1:numel( executionOrder )
profilerType = executionOrder( implIdx );
instance = obj.getProfilerImpl( profilerType );
if isempty( instance )
continue ;
end 

if nargout == 1
instanceOutput = func( profilerType, instance );
if ~isempty( instanceOutput )
varargout{ 1 }( char( profilerType ) ) = instanceOutput;
end 
else 
func( profilerType, instance );
end 
end 
end 

function addFileFilters( obj )
import matlab.internal.profiler.addFileFilters


interfaceFiles = {  ...
'matlab.internal.profiler.interface.AbstractProfiler',  ...
'matlab.internal.profiler.interface.ConfigOption',  ...
'matlab.internal.profiler.interface.ProfilerAction',  ...
'matlab.internal.profiler.interface.NumericEnum',  ...
 };

infrastructureFiles = {  ...
'matlab.internal.profiler.addFileFilters',  ...
'matlab.internal.profiler.types.NullOption',  ...
'matlab.internal.profiler.getMessageString',  ...
'matlab.internal.profiler.Configuration',  ...
'matlab.internal.profiler.ProfilerOutputBuilder',  ...
'matlab.internal.profiler.ProfilerService',  ...
'matlab.internal.profiler.ProfilerType',  ...
'private/registerProfilers',  ...
 };
addFileFilters( [ interfaceFiles, infrastructureFiles ] );


obj.executeOnAll( @( ~, instance )addFileFilters( instance.getFilesToFilter ) );
end 
end 

methods 
function running = isRunning( obj )
running = obj.Running;
end 

function profilerImpl = getProfilerImpl( obj, profilerType )
R36
obj
profilerType( 1, 1 )matlab.internal.profiler.ProfilerType
end 

profilerTypeStr = char( profilerType );
if obj.ProfilerImpls.isKey( profilerTypeStr )
profilerImpl = obj.ProfilerImpls( profilerTypeStr );
else 
profilerImpl = matlab.internal.profiler.ProfilerType.empty(  );
end 
end 

function turnOnProfiling( obj )
import matlab.internal.profiler.ProfilerType
import matlab.internal.profiler.interface.ProfilerAction

obj.errorIfLocked(  );
notifyUI( 'start' );
obj.addFileFilters(  );
executionOrder = ProfilerType.getExecutionOrderForAction( ProfilerAction.On );
obj.executeOnAll( @( ~, instance )instance.turnOn, executionOrder );
obj.Running = true;
end 

function turnOffProfiling( obj )
import matlab.internal.profiler.ProfilerType
import matlab.internal.profiler.interface.ProfilerAction

obj.errorIfLocked(  );
executionOrder = ProfilerType.getExecutionOrderForAction( ProfilerAction.Off );
obj.executeOnAll( @( ~, instance )instance.turnOff, executionOrder );
notifyUI( 'stop' );
obj.Running = false;
end 

function resumeProfiling( obj )
import matlab.internal.profiler.ProfilerType
import matlab.internal.profiler.interface.ProfilerAction

obj.errorIfLocked(  );
notifyUI( 'resume' );
obj.addFileFilters(  );
executionOrder = ProfilerType.getExecutionOrderForAction( ProfilerAction.Resume );
obj.executeOnAll( @( ~, instance )instance.resume, executionOrder );
obj.Running = true;
end 

function clearProfilingData( obj )
import matlab.internal.profiler.ProfilerType
import matlab.internal.profiler.interface.ProfilerAction

obj.errorIfLocked(  );
executionOrder = ProfilerType.getExecutionOrderForAction( ProfilerAction.Clear );
obj.executeOnAll( @( ~, instance )instance.clear, executionOrder );
notifyUI( 'clear' );
obj.Running = false;
end 

function resetProfiling( obj )
import matlab.internal.profiler.ProfilerType
import matlab.internal.profiler.interface.ProfilerAction

obj.errorIfLocked(  );
executionOrder = ProfilerType.getExecutionOrderForAction( ProfilerAction.Reset );
obj.executeOnAll( @( ~, instance )instance.reset, executionOrder );
notifyUI( 'clear' );
obj.Running = false;
end 

function data = getProfilingData( obj )
import matlab.internal.profiler.ProfilerOutputBuilder
import matlab.internal.profiler.ProfilerType
import matlab.internal.profiler.interface.ProfilerAction

obj.errorIfLocked(  );
obj.turnOffProfiling(  );
executionOrder = ProfilerType.getExecutionOrderForAction( ProfilerAction.Info );
infoData = obj.executeOnAll( @( ~, instance )instance.getInfo, executionOrder );
data = ProfilerOutputBuilder.buildInfoOutput( infoData );
end 

function status = getProfilingStatus( obj )
import matlab.internal.profiler.ProfilerOutputBuilder
import matlab.internal.profiler.ProfilerType
import matlab.internal.profiler.interface.ProfilerAction

executionOrder = ProfilerType.getExecutionOrderForAction( ProfilerAction.Status );
statusData = obj.executeOnAll( @( ~, instance )instance.getStatus, executionOrder );
status = ProfilerOutputBuilder.buildStatusOutput( statusData );
end 

function configureProfilers( obj, config )
R36
obj
config( 1, 1 )matlab.internal.profiler.Configuration
end 

obj.errorIfLocked(  );
obj.executeOnAll( @( profilerType, instance ) ...
instance.configure( config.filterByProfilerType( profilerType ) ) );
end 

function config = getProfilersConfig( obj )
profilersConfig = obj.executeOnAll( @( ~, instance )instance.getConfig );
config = joinProfilersConfig( profilersConfig );
end 
end 

methods ( Hidden )
function lock( obj, reason )
R36
obj
reason( 1, 1 ){ mustBeA( reason, 'message' ) }
end 

obj.Locked = true;
obj.LockMessage = reason;
end 

function unlock( obj )
obj.Locked = false;
obj.LockMessage = '';
end 
end 

methods ( Static )
function obj = getInstance( instanceIn )


import matlab.internal.profiler.ProfilerService;

mlock;
persistent instance;
if nargin == 0
if isempty( instance )
instance = matlab.internal.profiler.ProfilerService;
registerProfilers( instance );
end 
else 
instance = instanceIn;
end 

obj = instance;
end 

function clearInstance(  )


matlab.internal.profiler.ProfilerService.getInstance( [  ] );
end 
end 
end 



function joinedConfig = joinProfilersConfig( configs )
options = {  };
for k = keys( configs )
options = [ options, configs( k{ 1 } ).getOptions ];%#ok<AGROW>
end 
joinedConfig = matlab.internal.profiler.Configuration( options );
end 

function notifyUI( action )
matlab.internal.profileviewer.notifyUI( action, matlab.internal.profileviewer.ProfilerType.MATLAB );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSjTRUq.p.
% Please follow local copyright laws when handling this file.

