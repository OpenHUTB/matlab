




classdef EEdge<Simulink.Graph.Edge
    properties
        handle=0;
        edge_type=[];
    end
    methods
        function obj=EEdge(edge_type,handle,src,sink)
            obj=obj@Simulink.Graph.Edge(src,sink);
            obj.edge_type=edge_type;
            obj.handle=handle;
        end

        function yesno=equals(obj1,obj2)

            yesno=equals@Simulink.Graph.Edge(obj1,obj2);
        end
    end
end