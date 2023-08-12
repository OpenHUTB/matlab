function locked = pmsl_isblocklocked( block )






blkId = pmsl_getdoublehandle( block );
block = get_param( block, 'Handle' );
locked = false;
root = bdroot( block );
locked = strcmp( get_param( root, 'BlockDiagramType' ), 'library' ) &&  ...
strcmp( get_param( root, 'Lock' ), 'on' );

block = get_param( get_param( block, 'Parent' ), 'Handle' );
while ~locked && block ~= root
locked = strcmp( pmsl_linkstatus( block ), 'resolved' );
block = get_param( get_param( block, 'Parent' ), 'Handle' );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpPuph4c.p.
% Please follow local copyright laws when handling this file.

