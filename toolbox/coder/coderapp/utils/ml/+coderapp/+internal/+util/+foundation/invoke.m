function varargout = invoke( aFunctionHandle, args )

arguments
    aFunctionHandle( 1, 1 )function_handle
end
arguments( Repeating )
args
end
[ varargout{ 1:nargout } ] = coderapp.internal.util.foundation.unchecked.invoke( aFunctionHandle, args{ : } );
end


