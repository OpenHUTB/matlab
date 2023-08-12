classdef ( Sealed )Hook < coderapp.internal.log.Loggable








properties ( SetAccess = private )
Name( 1, 1 )string = "<anonymous>"
end 

properties ( Dependent, SetAccess = immutable )
NumAttached( 1, 1 )uint32
end 

properties ( Access = private )
Listeners( 1, 1 )dictionary = dictionary( [  ], {  } )
IdCounter( 1, 1 )uint32
end 

methods ( Static )

function [ hook, dispatcher ] = create( opts )
R36
opts.Name( 1, 1 )string
opts.Logger coderapp.internal.log.Logger{ mustBeScalarOrEmpty }
end 

assert( nargout == 2, 'Must accept the hook trigger function handle' );
hook = coderapp.internal.util.Hook(  );
if isfield( opts, 'Name' )
hook.Name = opts.Name;
end 
if isfield( opts, 'Logger' )
hook.Logger = opts.Logger;
end 
dispatcher = @( varargin )hook.invoke( varargin{ : } );
end 
end 

methods ( Access = private )

function this = Hook(  )
end 
end 

methods 

function cleanup = attach( this, funcHandle )
this.IdCounter = this.IdCounter + 1;
listenerId = this.IdCounter;

this.Logger.trace( @(  )sprintf( 'Attaching new hook callback "%s" as %d', func2str( funcHandle ), listenerId ) );
assert( nargout ~= 0, 'Must accept the onCleanup heandle for the attached function' );

this.Listeners( listenerId ) = { funcHandle };
cleanup = onCleanup( @(  )this.detach( listenerId ) );
end 


function num = get.NumAttached( this )
num = this.Listeners.numEntries(  );
end 
end 

methods ( Access = private )

function varargout = invoke( this, varargin )
logCleanup = this.Logger.debug( 'Invoking hook "%s"', this.Name );%#ok<NASGU>
if this.NumAttached == 0
return 
end 

listeners = this.Listeners.values(  );

if nargout ~= 0
varargout{ 1 } = cell( 1, numel( listeners ) );
for i = 1:numel( listeners )
varargout{ 1 }{ i } = feval( listeners{ i }, varargin{ : } );
end 
else 
for i = 1:numel( listeners )
feval( listeners{ i }, varargin{ : } );
end 
end 
end 


function detach( this, listenerId )
if this.Listeners.isKey( listenerId )
this.Logger.trace( @(  )sprintf( 'Detaching hook callback %d', listenerId ) );
this.Listeners( listenerId ) = [  ];
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpb3wiSW.p.
% Please follow local copyright laws when handling this file.

