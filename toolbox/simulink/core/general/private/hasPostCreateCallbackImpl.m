function b = hasPostCreateCallbackImpl( ~, id )











callbacks = get_param( 0, 'RootCallbacks' );
assert( isempty( callbacks ) || ( isstruct( callbacks ) && isscalar( callbacks ) ) );
b = isfield( callbacks, id );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjGKxsu.p.
% Please follow local copyright laws when handling this file.

