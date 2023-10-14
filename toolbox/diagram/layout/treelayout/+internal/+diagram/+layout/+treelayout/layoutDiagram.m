function layoutDiagram( syntax, operations, diagram )

arguments
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


