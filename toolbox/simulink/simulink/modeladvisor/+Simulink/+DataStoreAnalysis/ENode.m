




classdef ENode<Simulink.Graph.Node

    properties
handle
node_type
node_name
node_id
        combine=[]
    end
    methods
        function obj=ENode(nodetype,nodename,nodeid,nodehandle)
            obj.handle=nodehandle;
            obj.node_type=nodetype;
            obj.node_name=nodename;
            obj.node_id=nodeid;
        end

        function yesno=equals(obj1,obj2)
            yesno=(obj1.handle==obj2.handle)&&...
            isequal(obj1.node_type,obj2.node_type)&&...
            isequal(obj1.node_name,obj2.node_name);

        end
    end

end