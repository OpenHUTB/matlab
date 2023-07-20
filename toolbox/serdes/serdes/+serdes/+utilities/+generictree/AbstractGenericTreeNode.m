classdef(Abstract)AbstractGenericTreeNode<handle















    properties(SetAccess=private)


NodeId
        Tree=[]
    end
    properties

NodeName




Locked


Sterile


        Visited=false;
    end
    methods
        function node=AbstractGenericTreeNode(NodeName)


            if(nargin<1)
                NodeName="";
            end
            node.NodeName=NodeName;
            node.NodeId=0;
            node.Locked=false;
            node.Sterile=false;
        end
        function set.NodeName(node,nodeName)
            nodeName=validName(node,nodeName);
            validateRename(node,nodeName);
            node.NodeName=nodeName;
        end
    end
    methods(Access=?serdes.utilities.generictree.AbstractGenericTree)
        function setNodeId(node,nodeId)






            node.NodeId=nodeId;
        end
        function setTree(node,tree)
            node.Tree=tree;
        end
        function resetNodeId(node)


            node.NodeId=serdes.utilities.generictree.AbstractGenericTree.ResetFlag;
        end
        function setRootId(node,tree)

            node.NodeId=tree.getRootNodeId();
        end
        function setToNodeId(node,otherNode)
            node.NodeId=otherNode.NodeId;
        end
    end
    methods(Abstract)
        copyNodeWithNewName(oldNode,newName)
    end
    methods(Access=private)
        function validateRename(node,newName)
            if~isempty(node.Tree)&&node.Tree.containsNode(node)&&~strcmpi(node.NodeName,newName)
                node.Tree.validateRename(node,newName)
            end
        end
    end
    methods(Access=protected)



        function vName=validName(~,pName)
            if isa(pName,'char')||isa(pName,'string')
                vName=pName;
            else
                vName=char.empty(1,0);
            end
        end
    end
end


