classdef DeleteNodeType<fxptopo.internal.transformation.FilterNodeType




    methods
        function wrapper=transform(this,wrapper)
            g=wrapper.Graph;
            g=g.rmnode(find(strcmp(g.Nodes.Type,this.NodeType)));%#ok<FNDSB>
            wrapper.Graph=g;
        end
    end
end
