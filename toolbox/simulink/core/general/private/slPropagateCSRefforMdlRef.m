function slPropagateCSRefforMdlRef(  )



me = daexplr;
im = DAStudio.imExplorer( me );

node = im.getCurrentTreeNode;
if ~isa( node, 'Simulink.ConfigSetRef' )
node = im.getSelectedListNodes;
end 

assert( isa( node, 'Simulink.ConfigSetRef' ) );

parent = node.getParent;
assert( isa( parent, 'Simulink.BlockDiagram' ) );


Progressbar = DAStudio.WaitBar;
Progressbar.setWindowTitle( DAStudio.message( 'Simulink:tools:CSRefPropagationPBarTitle' ) );
Progressbar.setLabelText( DAStudio.message( 'Simulink:tools:CSRefPropagationPBarFindRMLabel' ) );
Progressbar.setCircularProgressBar( true );
Progressbar.show(  );

slPropagateCSRef( parent.Name, node.Name, Progressbar );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpcy5c0o.p.
% Please follow local copyright laws when handling this file.

