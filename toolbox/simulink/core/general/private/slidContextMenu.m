function slidContextMenu( menuOption )





me = daexplr;

selectedNode = me.getTreeSelection(  );
if ~isempty( selectedNode )
switch menuOption
case DAStudio.message( 'Simulink:Data:ContextRefresh' )
doRefresh( selectedNode );
case DAStudio.message( 'Simulink:Data:ContextProperties' )
doProperties( selectedNode );
case DAStudio.message( 'sl_data_adapter:messages:openMENode' )
doOpen( selectedNode );
otherwise 
return ;
end 
end 
end 

function doRefresh( node )
node.refresh(  );
end 

function doProperties( node )
slprivate( 'showDDG', node );
end 

function doOpen( node )
eval( [ 'edit ', node.getFileSpec ] );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3rx36l.p.
% Please follow local copyright laws when handling this file.

