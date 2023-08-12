classdef ( Sealed )Defer < handle











properties ( SetAccess = immutable )
Task( 1, 1 )function_handle = @(  )[  ]
Args cell
Mode( 1, 1 )string{ mustBeMember( Mode, [ "throttle", "debounce", "timeout" ] ) } = "timeout"
Interval( 1, 1 )uint32 = 0.25
end 

properties ( Dependent, SetAccess = immutable )
HasPending( 1, 1 )logical
end 

properties ( GetAccess = private, SetAccess = immutable )
Invoker
end 

properties ( Access = private )
Timers timer
LastExecuted datetime
end 

methods ( Static )

function [ taskWrapper, cleanup ] = create( task, opts )
R36
task( 1, 1 )function_handle
opts.Mode( 1, 1 )string{ mustBeMember( opts.Mode, [ "throttle", "debounce", "timeout" ] ) }
opts.Interval( 1, 1 )uint32
opts.Args cell
end 

nargoutchk( 2, 2 );
args = namedargs2cell( opts );
deferred = coderapp.internal.util.Defer( task, args{ : } );
taskWrapper = defered.Invoker;
cleanup = onCleanup( @(  )deferred.delete(  ) );
end 
end 

methods 

function this = Defer( task, opts )
R36
task( 1, 1 )function_handle
opts.Mode( 1, 1 )string{ mustBeMember( opts.Mode, [ "throttle", "debounce", "timeout" ] ) }
opts.Interval( 1, 1 )uint32
opts.Args cell
end 

this.Task = task;
if isfield( opts, 'Mode' )
this.Mode = opts.Mode;
end 
if isfield( opts, 'Interval' )
this.Interval = opts.Interval;
end 
if isfield( opts, 'Args' )
assert( this.Mode == "timeout",  ...
'Only timeout supports partial acpplication with Args' );
this.Args = reshape( opts.Args, 1, [  ] );
end 

switch this.Mode
case 'throttle'
narginchk( 1, 1 );
this.Invoker = @this.doThrottle;
case 'debounce'
this.Invoker = @this.doDebounce;
case 'timeout'
this.Invoker = @this.doTimeout;
end 
end 


function invoker = get( this )
invoker = this.Invoker;
end 


function invoke( this, varargin )
switch this.Mode
case { 'throttle', 'debounce' }
narginchk( 1, 1 );
end 
this.Invoker( varargin{ : } );
end 


function cancel( this )
this.clearTimers(  );
end 


function varargout = subsref( this, subs )
if isscalar( subs ) && subs.type == "()"
this.invoke( subs.subs{ : } );
elseif nargout > 0
[ varargout{ 1:nargout } ] = builtin( 'subsref', this, subs );
else 
builtin( 'subsref', this, subs )
end 
end 


function delete( this )
this.clearTimers(  );
end 


function pending = get.HasPending( this )
pending = any( [ this.Timers.Running ] );
end 
end 

methods ( Access = private )

function doThrottle( this )
if ~isempty( this.Timers )
return 
end 

if isempty( this.LastExecuted )
startDelay = 0;
else 
startDelay = max( 0, this.Interval - ( seconds( datetime(  ) - this.LastExecuted ) ) );
end 
this.Timers = timer(  ...
'ObjectVisibility', 'off',  ...
'Period', double( this.Interval ),  ...
'StartDelay', double( startDelay ),  ...
'ExecutionMode', 'fixedSpacing',  ...
'TimerFcn', @( ~, ~ )this.runTaskWithCleanup(  ) );
this.Timers.start(  );
end 


function doDebounce( this )
if isempty( this.LastExecuted )
startDelay = double( this.Interval );
else 
startDelay = double( max( 0, this.Interval - ( seconds( datetime(  ) - this.LastExecuted ) ) ) );
end 
if isempty( this.Timers )
this.Timers = timer(  ...
'ObjectVisibility', 'off',  ...
'StartDelay', startDelay,  ...
'TimerFcn', @( ~, ~ )this.runTaskWithCleanup(  ) );
elseif this.Timers.Running == "on"
this.Timers.stop(  );
this.Timers.StartDelay = startDelay;
end 
this.Timers.start(  );
end 


function doTimeout( this, varargin )
instanceTimer = timer(  ...
'ObjectVisibility', 'off',  ...
'StartDelay', double( this.Interval ),  ...
'TimerFcn', @once );
this.Timers( end  + 1 ) = instanceTimer;
instanceTimer.start(  );

function once( ~, ~ )
this.Timers = setdiff( this.Timers, instanceTimer, 'stable' );
this.Task( this.Args{ : }, varargin{ : } );
end 
end 


function runTaskWithCleanup( this )
this.Task( this.Args{ : } );
this.LastExecuted = datetime(  );
this.clearTimers(  );
end 


function clearTimers( this )
if ~isempty( this.Timers )
this.Timers.stop(  );
this.Timers.delete(  );
this.Timers = timer.empty(  );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpUTJHk0.p.
% Please follow local copyright laws when handling this file.

