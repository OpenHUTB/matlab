classdef DeleteEdgeType<fxptopo.internal.transformation.FilterEdgeType




    methods
        function wrapper=transform(this,wrapper)
            g=wrapper.Graph;
            g=g.rmedge(find(g.Edges.Type==this.EdgeType));%#ok<FNDSB>
            wrapper.Graph=g;
        end
    end
end
