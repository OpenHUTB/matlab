function mustBeValidEventListenerCallback( callback, opts )





R36
callback function_handle
opts.numArgsIn uint8
end 
if ~isequal( nargin( callback ), opts.numArgsIn )
throwAsCaller( MException( message( "coderApp:services:callbackMustHaveSpecifiedNumberOfArguments",  ...
opts.numArgsIn ) ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpcEKVLF.p.
% Please follow local copyright laws when handling this file.

