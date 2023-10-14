classdef TreePlotter < handle

    properties
        Graph
    end

    methods
        function obj = TreePlotter( treeId )
            arguments
                treeId( 1, : )char
            end

            obj.Graph = digraph;
            tree = evolutions.internal.getDataObject( treeId );
            populateGraph( obj, tree.RootEvolution );
        end

        function displayGraph( obj )
            plot( obj.Graph );
        end
    end

    methods ( Access = protected )
        function nodeOut = populateGraph( obj, node )
            if isempty( node )
                nodeOut = [  ];
                return ;
            end

            for idx = 1:numel( node.Children )
                child = node.Children( idx );
                nodeToAdd = populateGraph( obj, child );
                if ~isempty( nodeToAdd )
                    obj.Graph = obj.Graph.addedge( node.Id, nodeToAdd.Id );
                end
            end
            nodeOut = node;
            return ;
        end
    end
end


