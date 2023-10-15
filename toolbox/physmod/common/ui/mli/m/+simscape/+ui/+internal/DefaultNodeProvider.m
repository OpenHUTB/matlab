classdef DefaultNodeProvider < simscape.ui.internal.NodeProvider
    methods
        function out = children( obj, nodePath )
            arguments
                obj( 1, 1 )%#ok<INUSA>
                nodePath( 1, : )cell %#ok<INUSA>
            end
            out = repmat( simscape.ui.internal.Node, 0, 1 );
        end
    end
end
