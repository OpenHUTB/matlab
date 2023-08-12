function meRevertToSaved







try 
me = daexplr;
im = DAStudio.imExplorer( me );

ed = DAStudio.EventDispatcher;
broadcastEvent( ed, 'MESleepEvent' );
cleanupWake = onCleanup( @(  )broadcastEvent( ed, 'MEWakeEvent' ) );

node = me.getTreeSelection;
if isa( node, 'Simulink.BlockDiagram' )

mdl = node;
selectNode = @selectTreeViewNode;
else 

mdl = me.getListSelection;
selectNode = @selectListViewNode;
end 

name = mdl.Name;
file = mdl.FileName;
bdclose( mdl.Handle );
open( file );
mdlObj = get_param( name, 'Object' );
selectNode( im, mdlObj );
me.show;
catch ME
msgbox( ME.message, 'Error', 'error' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7z21N_.p.
% Please follow local copyright laws when handling this file.

