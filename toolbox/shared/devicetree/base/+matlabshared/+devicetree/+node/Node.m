classdef Node<matlabshared.devicetree.node.NonTerminalNode&matlabshared.devicetree.node.ParentableNode


    methods
        function obj=Node(varargin)
            obj=obj@matlabshared.devicetree.node.NonTerminalNode(varargin{:});
        end

        function hRefNode=getReferenceNode(obj)
            name=obj.getReferenceName;
            hRefNode=matlabshared.devicetree.node.ReferenceNode(name);
        end
    end

    methods(Access=protected)
        function hTargetNode=getOverlayTargetNode(obj)

            hTargetNode=obj.ParentNode;

            if isempty(hTargetNode)
                error(message('devicetree:base:OverlayParentNodeMissing',obj.Name));
            end
        end


        function labelPrefix=getSourceLabelPrefix(obj)

            if~isempty(obj.Label)
                labelPrefix=obj.Label+": ";
            else
                labelPrefix="";
            end
        end
    end
end