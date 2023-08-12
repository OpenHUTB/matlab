function exception = toException( arg, opts )





R36
arg{ mustBeA( arg, { 'MException', 'message', 'cell', 'char', 'string' } ), mustBeNonempty( arg ) }
opts.Identifier( 1, : )char
opts.Text{ mustBeA( opts.Text, { 'char', 'string', 'message', 'cell' } ) }
opts.NoStack( 1, 1 )logical = false
opts.OmitFrames( 1, 1 )uint32 = 0
opts.Stack struct
opts.Causes( :, 1 )cell
opts.ClearCauseStacks( 1, 1 )logical = true
end 


stack = [  ];
causes = {  };
if iscell( arg )
text = message( arg{ : } ).getString(  );
identifier = arg{ 1 };
elseif isa( arg, 'MException' )
identifier = arg.identifier;
text = arg.message;
causes = arg.cause;
stack = arg.stack;
elseif isa( arg, 'message' )
identifier = arg.identifier;
text = arg.getString(  );
else 
identifier = arg;
text = '';
end 


if isfield( opts, 'Identifier' )
identifier = opts.Identifier;
end 
if isfield( opts, 'Text' )
text = opts.Text;
if isstring( text )
text = char( text );
elseif isa( text, 'message' )
text = text.getString(  );
elseif iscell( text )
text = message( text{ : } ).getString(  );
end 
end 
if isfield( opts, 'Causes' )
causes = opts.Causes;
end 


if ~opts.NoStack
if isfield( opts, 'Stack' ) && ~isempty( opts.Stack )
assert( all( isfield( opts.Stack ), { 'file', 'name', 'line' } ),  ...
'Stack must be a struct of the form returned by dbstack' )
stack = opts.Stack;
elseif ~isfield( opts, 'Stack' )
if ~isstruct( stack )

stack = dbstack( opts.OmitFrames + 1 );
else 
if opts.OmitFrames < numel( stack )
stack = stack( opts.OmitFrames + 1:end  );
else 
stack( 1:end  ) = [  ];
end 
end 
end 
end 


errStruct.identifier = identifier;
errStruct.message = text;
errStruct.stack = stack;
try 
error( errStruct );
catch basis
exception = basis;

for i = 1:numel( causes )
cause = causes{ i };
if opts.NoStack || opts.ClearCauseStacks
cause = MException( cause.identifier, cause.message );
end 
exception = exception.addCause( cause );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp_BaaHs.p.
% Please follow local copyright laws when handling this file.

