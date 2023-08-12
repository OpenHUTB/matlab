function b = hasCallbackImpl( obj, type, id )













callbacks = get_param( obj.Handle, 'Callbacks' );
assert( isempty( callbacks ) || ( isstruct( callbacks ) && isscalar( callbacks ) ) );
if isfield( callbacks, type )
f = callbacks.( type );
b = isfield( f, id );
else 
b = false;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4qUrTD.p.
% Please follow local copyright laws when handling this file.

