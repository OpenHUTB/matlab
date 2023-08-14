classdef ScopeTail<internal.ml2pir.scope.AbstractScope






    methods(Access=protected)
        function[foundNode,nodeInfo]=getNodeInfo(~,~)
            foundNode=false;
            nodeInfo=internal.ml2pir.scope.NodeInfo.unknownInfo;
        end

        function setNodeInfo(~,~,~)
            error('Cannot set a node in a ScopeTail object');
        end
    end
end
