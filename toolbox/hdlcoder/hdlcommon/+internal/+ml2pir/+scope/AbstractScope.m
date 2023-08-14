classdef AbstractScope<handle




    methods(Access=public)
        function[node,nodeType]=getNode(this,name)
            [~,nodeInfo]=this.getNodeInfo(name);

            node=nodeInfo.node;

            if nargout>1
                nodeType=nodeInfo.type;
            end
        end

        function setNode(this,name,node,nodeType)
            nodeInfo=internal.ml2pir.scope.NodeInfo(node,nodeType);
            this.setNodeInfo(name,nodeInfo);
        end
    end

    methods(Abstract,Access=protected)
        [foundNode,nodeInfo]=getNodeInfo(this,name);
        setNodeInfo(this,name,nodeInfo);
    end
end
