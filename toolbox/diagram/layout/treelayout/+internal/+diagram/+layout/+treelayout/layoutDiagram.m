function layoutDiagram( syntax, operations, diagram )

R36
syntax( 1, 1 );
operations = [  ];
diagram = [  ];
end 

if isempty( diagram )
diagram = syntax.root;
end 

if isempty( operations )
syntax.modify( @( ops )layoutDiagram_internal( ops ) );
else 
layoutDiagram_internal( operations )
end 


function layoutDiagram_internal( ops )


dm = syntax.model;
digramTree = internal.diagram.layout.treelayout.DiagramTree( diagram, dm );
layout = internal.diagram.layout.treelayout.TreeLayout( digramTree );
bounds = layout.getNodeBounds(  );
for i = ( 1:numel( diagram.entities ) )
e = diagram.entities( i );
ops.setPosition( e, bounds{ i }( 1 ), bounds{ i }( 2 ) );
ops.setSize( e, bounds{ i }( 3 ), bounds{ i }( 4 ) );
end 

end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp8nGmn6.p.
% Please follow local copyright laws when handling this file.

