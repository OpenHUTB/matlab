function fcn = removePostCreateCallbackImpl( ~, id )












callbacks = get_param( 0, 'RootCallbacks' );
assert( isempty( callbacks ) || isstruct( callbacks ) );
if ~isfield( callbacks, id )
DAStudio.error( 'Simulink:utility:RootCallbackNotPresent',  ...
'PostCreate', id );
end 
fcn = callbacks.( id );
callbacks = rmfield( callbacks, id );
set_param( 0, 'RootCallbacks', callbacks );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjKBSeW.p.
% Please follow local copyright laws when handling this file.

