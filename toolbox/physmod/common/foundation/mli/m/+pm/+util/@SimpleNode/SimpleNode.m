classdef SimpleNode<pm.util.Node

    methods
        function snode=SimpleNode(nodeID)

            snode.NodeID=nodeID;
        end
    end
    methods(Access=protected)
        function accept_implementation(thisNode,aVisitor)


            aVisitor.visit_simplenode(thisNode);
        end
    end
end