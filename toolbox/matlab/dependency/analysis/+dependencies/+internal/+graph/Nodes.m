classdef ( Abstract )Nodes

    properties ( Constant )
        BaseWorkspaceNode = dependencies.internal.graph.Node( strings( 1, 0 ), "BaseWorkspace", true );
    end

    methods ( Static )

        function node = createProductNode( basecodes )



            arguments
                basecodes( 1, : )string{ mustBeNonempty };
            end

            node = dependencies.internal.graph.Node.createProductNode( basecodes );
        end

        function node = createToolboxNode( path, name, version )


            location = [ path, name + " " + version ];
            node = dependencies.internal.graph.Node( location, "Toolbox", true );
        end

        function node = createTestHarnessNode( path, hOwner, hName )
            node = dependencies.internal.graph.Node.createTestHarnessNode( path, hOwner, hName );
        end

        function node = createVariableNode( busElements )
            node = dependencies.internal.graph.Node( busElements, "Variable", true );
        end

    end

end

