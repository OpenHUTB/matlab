classdef ( Abstract )AbstractErrorHandler < coderapp.internal.util.HookedMixin





properties ( SetAccess = immutable )

OnFailure coderapp.internal.util.Hook
end 

properties ( SetAccess = private )

Cause MException{ mustBeScalarOrEmpty }

DebugInfo
end 

properties ( Access = protected )
IsTemporaryContext( 1, 1 )logical = true
end 

methods 

function this = AbstractErrorHandler(  )
this.OnFailure = this.createHook( 'OnFailure' );
end 
end 

methods ( Sealed )

function hardFail( this, delegateName, errArgs )


arguments
this( 1, 1 )
delegateName( 1, 1 )string
end 
arguments( Repeating )
errArgs
end 

this.doFail( delegateName, errArgs, "hard" );
end 


function me = softFail( this, delegateName, errArgs )


arguments
this( 1, 1 )
delegateName( 1, 1 )string
end 
arguments( Repeating )
errArgs
end 

me = this.doFail( delegateName, errArgs, "soft" );
end 


function me = maybeFail( this, delegateName, errArgs )


arguments
this( 1, 1 )
delegateName( 1, 1 )string
end 
arguments( Repeating )
errArgs
end 

me = this.doFail( delegateName, errArgs, "defer" );
end 


function this = withContext( this, context )


arguments
this( 1, 1 )
end 
arguments( Repeating )
context
end 

this.applyContext( context{ : } );
end 


function cleanup = useTemporaryContext( this, context )


arguments
this( 1, 1 )
end 
arguments( Repeating )
context
end 

nargoutchk( 1, 1 );
this.withContext( context{ : } );
cleanup = onCleanup( @(  )this.withoutContext(  ) );
end 


function this = withDebugInfo( this, debugInfo )

arguments
this( 1, 1 )
debugInfo
end 

this.DebugInfo = debugInfo;
end 


function this = withCause( this, cause, varargin )

arguments
this( 1, 1 )
cause{ mustBeA( cause, [ "char", "string", "MException" ] ) }
end 
arguments( Repeating )
varargin
end 

if ~isa( cause, 'MException' )
try 
error( cause, varargin{ : } );
catch cause
end 
else 
narginchk( 2, 2 );
end 
this.Cause = cause;
end 


function this = withoutContext( this )

arguments
this( 1, 1 )
end 

this.doCleanup( true );
end 


function assert( this, failureType, condition, varargin )



arguments
this( 1, 1 )
failureType( 1, 1 )string
condition( 1, 1 )logical
end 
arguments( Repeating )
varargin
end 

try 
assert( condition, varargin{ : } );
catch me
this.withCause( me ).hardFail( failureType );
end 
end 


function throwEnumeratedError( this, errorSymbol, varargin )
arguments
this( 1, 1 )
errorSymbol( 1, 1 )coderapp.internal.error.ErrorEnumerable
end 
arguments( Repeating )
varargin
end 

errorSymbol.decoratable( varargin{ : } ).withCause( this.Cause ).throw(  );
end 
end 

methods ( Abstract, Access = protected )

applyContext( this, varargin )



clearContext( this )

end 

methods ( Access = private )

function me = doFail( this, delegateName, delegateArgs, mode )
arguments
this( 1, 1 )
delegateName( 1, 1 )string
delegateArgs( 1, : )cell
mode( 1, 1 )string{ mustBeMember( mode, [ "soft", "hard", "defer" ] ) }
end 

this.assertValidDelegate( delegateName );

me = MException.empty(  );
try 
feval( delegateName, this, delegateArgs{ : } );
catch me
end 
try 
this.invokeHook( 'OnFailure', delegateName, delegateArgs{ : } );
catch me
end 

this.doCleanup( false );

switch mode
case "hard"
if isempty( me )
error( '%s/%s', class( this ), delegateName );
else 
me.rethrow(  );
end 
case "defer"
if ~isempty( me )
me.rethrow(  );
end 
end 
end 


function doCleanup( this, force )
this.DebugInfo = [  ];
this.Cause = MException.empty(  );

if force || this.IsTemporaryContext
this.clearContext(  );
end 
end 


function assertValidDelegate( this, delegateName )
assert( coderapp.internal.util.ismethod( this, delegateName, Access = mfilename( 'class' ) ),  ...
'No method "s" with access list of AbstractErrorHandler', delegateName );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpMf0q6U.p.
% Please follow local copyright laws when handling this file.

