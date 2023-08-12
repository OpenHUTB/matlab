classdef ( Abstract )ErrorEnumerable








properties ( Abstract, Constant )



Namespace( 1, 1 )string{ mustBeNonzeroLengthText }


IsInternal( 1, 1 )logical
end 

properties ( Dependent, SetAccess = immutable )

ErrorId( 1, 1 )string
end 

properties ( SetAccess = immutable )

MessageKey( 1, 1 )string
end 

methods 

function this = ErrorEnumerable( messageKey )
R36
messageKey( 1, 1 )string = ""
end 

assert( isenum( this ), 'ErrorEnumerable is intended to be a base class for enumerations' );
this.MessageKey = messageKey;
end 


function exception = create( this, varargin )

R36
this( 1, 1 )
end 
R36( Repeating )
varargin
end 

exception = MException( this.ErrorId, this.getMessageText( varargin{ : } ) );
end 


function exception = derive( this, toExceptionOpts )



R36
this( 1, 1 )
end 
R36( Repeating )
toExceptionOpts
end 

exception = coderapp.internal.error.toException( this.create(  ), toExceptionOpts{ : } );
end 


function exception = decoratable( this, varargin )


R36
this( 1, 1 )
end 
R36( Repeating )
varargin
end 

exception = coderapp.internal.error.DecoratedException( this, varargin{ : } );
end 


function createAndThrow( this, varargin )

R36
this( 1, 1 )
end 
R36( Repeating )
varargin
end 

this.create( varargin{ : } ).throw(  );
end 


function deriveAndThrow( this, toExceptionOpts )

R36
this( 1, 1 )
end 
R36( Repeating )
toExceptionOpts
end 

this.derive( toExceptionOpts{ : } ).throw(  );
end 


function error( this, varargin )

R36
this( 1, 1 )
end 
R36( Repeating )
varargin
end 

error( this.ErrorId, this.getMessageText( varargin{ : } ) );
end 


function assert( this, condition, varargin )

R36
this( 1, 1 )
condition( 1, 1 )logical
end 
R36( Repeating )
varargin
end 

assert( condition, this.ErrorId, this.getMessageText( varargin{ : } ) );
end 


function warning( this, varargin )

R36
this( 1, 1 )
end 
R36( Repeating )
varargin
end 


warnState = warning( 'QUERY', 'BACKTRACE' );
warnCleanup = onCleanup( @(  )warning( warnState ) );
warning( 'OFF', 'BACKTRACE' );

warning( this.ErrorId, this.getMessageText( varargin{ : } ) );
end 


function text = getMessageText( this, msgArgs )

R36
this( 1, 1 )
end 
R36( Repeating )
msgArgs
end 

if isscalar( msgArgs ) && isa( msgArgs{ 1 }, 'message' )

text = msgArgs{ 1 }.getString(  );
elseif strlength( this.MessageKey ) > 0
text = message( this.MessageKey, msgArgs{ : } ).getString(  );
else 

assert( this.IsInternal || ~coderapp.internal.util.isInstall(  ),  ...
'User-facing errors must have a message key in an install' );
text = this.createGenericMessage( msgArgs );
end 
end 


function yes = isInstance( obj, err )



R36
obj
err( 1, 1 ){ mustBeA( err, [ "MException", "struct" ] ) }
end 

assert( ~isstruct( err ) || all( isfield( err, { 'message', 'identifier', 'stack' } ) ),  ...
'Structs must be valid "error" structs' );
yes = strcmp( [ obj.ErrorId ], err.identifier );
end 


function errorId = get.ErrorId( this )
errorId = this.Namespace + ":" + string( this );
end 
end 

methods ( Access = private )

function text = createGenericMessage( this, args )
if isempty( args )
text = string( this );
return 
end 
argFmt = cell( size( args ) );
for i = 1:numel( args )
if isnumeric( args{ i } )
argFmt{ i } = '%g';
else 
argFmt{ i } = '%s';
end 
end 
text = sprintf( "%s: " + strjoin( argFmt, " " ), this, args{ : } );
end 
end 

methods ( Static, Access = protected )

function member = resolveFromErrorId( className, errorId )
R36
className( 1, 1 )string
errorId string
end 

members = enumeration( className );
member = members( ismember( [ members.ErrorId ], errorId ) );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpfY8KO2.p.
% Please follow local copyright laws when handling this file.

