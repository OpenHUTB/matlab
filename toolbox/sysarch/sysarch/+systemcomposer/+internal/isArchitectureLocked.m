function tf = isArchitectureLocked( hdlOrArch )



tf = false;
hdl = systemcomposer.internal.getHandle( hdlOrArch );

if ~ishandle( hdl )
error( 'The input must be a valid handle or architecture!' );
end 


if ( get_param( bdroot( hdl ), 'Lock' ) == "on" )
tf = true;
return ;
end 


if ( get_param( hdl, 'Type' ) == "block_diagram" )
tf = slInternal( 'isSRGraphLockedForEditing', hdl );

elseif systemcomposer.internal.isSubsystemReferenceComponent( hdl )
tf = slInternal( 'isSRGraphLockedForEditing', hdl ) ||  ...
~bdIsLoaded( get_param( hdl, 'ReferencedSubsystem' ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpcbAshD.p.
% Please follow local copyright laws when handling this file.

