function fcn = removeCallbackImpl( obj, type, id )













callbacks = get_param( obj.Handle, 'Callbacks' );
assert( isempty( callbacks ) || isstruct( callbacks ) );
if isfield( callbacks, type )
f = callbacks.( type );
else 
f = struct;
end 
if ~isfield( f, id )
DAStudio.error( 'Simulink:utility:BlockDiagramCallbackNotPresent',  ...
type, id, obj.Name );
end 
fcn = f.( id );
f = rmfield( f, id );
callbacks.( type ) = f;
set_param( obj.Handle, 'Callbacks', callbacks );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmptj55Gn.p.
% Please follow local copyright laws when handling this file.

