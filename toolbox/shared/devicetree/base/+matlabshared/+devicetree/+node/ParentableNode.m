classdef(Abstract)ParentableNode<handle









    properties(SetAccess={?matlabshared.devicetree.node.NonTerminalNode,?matlabshared.devicetree.tree.DeviceTree})



        ParentNode matlabshared.devicetree.node.NodeBase
    end


    methods
        function obj=ParentableNode()

        end
    end


    methods
        function set.ParentNode(obj,hNode)







            obj.validateParentNode(hNode);
            obj.ParentNode=hNode;
        end
    end

    methods(Access=?matlabshared.devicetree.node.NonTerminalNode)
        function removeParentNode(obj)
            obj.ParentNode=matlabshared.devicetree.node.NodeBase.empty;
        end
    end


    methods(Hidden,Sealed)


        function isRoot=isRootNode(obj)



            isRoot=(obj.ParentNode==obj);
        end



        function isAllowed=allowsParentNode(~)
            isAllowed=true;
        end

        function nodePath=getNodePath(obj)

            nodeName=obj.Name;%#ok<MCNPN>

            if isempty(obj.ParentNode)
                error(message('devicetree:base:NoPathForNode',nodeName));
            end





            if obj.isRootNode

                nodePath=nodeName;
            elseif obj.ParentNode.isRootNode

                nodePath="/"+nodeName;
            else


                nodePath=obj.ParentNode.getNodePath+"/"+nodeName;
            end
        end
    end


    methods(Access=protected)

        function validateParentNode(obj,hNode)%#ok<INUSD>


        end
    end
end