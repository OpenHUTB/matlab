function mustBeValidEventListenerCallback( callback, opts )

arguments
    callback function_handle
    opts.numArgsIn uint8
end
if ~isequal( nargin( callback ), opts.numArgsIn )
    throwAsCaller( MException( message( "coderApp:services:callbackMustHaveSpecifiedNumberOfArguments",  ...
        opts.numArgsIn ) ) );
end
end


