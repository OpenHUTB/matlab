function replaceWithEmptySubsystem( obj, block, blockTypeStr, initFcnErrMsg )












R36
obj;
block;
blockTypeStr = '';
initFcnErrMsg = '';
end 

if iscell( block )
for i = 1:numel( block )
obj.replaceWithEmptySubsystem( block{ i }, blockTypeStr, initFcnErrMsg );
end 
return ;
elseif isnumeric( block )
for i = 1:numel( block )
obj.replaceWithEmptySubsystem( getfullname( block( i ) ), blockTypeStr, initFcnErrMsg );
end 
return ;
end 

if isempty( blockTypeStr )


blockTypeStr = obj.getBlockTypeForDisplay( block );
end 

ports = get_param( block, 'Ports' );




sys = obj.getTempMdl;
replacement = createEmptySubsystem( obj,  ...
sys,  ...
blockTypeStr,  ...
ports );

obj.replaceBlock( block, replacement );
delete_block( replacement );

if ~isempty( initFcnErrMsg )


set_param( block, 'InitFcn', sprintf( 'error(''%s'')', initFcnErrMsg ) );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpbd8aVl.p.
% Please follow local copyright laws when handling this file.

