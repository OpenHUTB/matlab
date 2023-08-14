classdef EmptyNode<matlabshared.devicetree.node.TerminalNode&matlabshared.devicetree.node.ParentableNode






    methods
        function obj=EmptyNode()
            obj=obj@matlabshared.devicetree.node.TerminalNode(string.empty);
        end
    end
end