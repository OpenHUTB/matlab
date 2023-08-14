classdef DeleteNode<matlabshared.devicetree.node.TerminalNode&matlabshared.devicetree.node.ParentableNode


    methods
        function obj=DeleteNode(name)
            obj=obj@matlabshared.devicetree.node.TerminalNode(name);
        end
    end


    methods(Access=protected)
        function printBody(obj,hDTPrinter,isOverlay,~)



            if isOverlay


                error(message('devicetree:base:NoOverlayWithTopLevelDelete'));
            end


            hDTPrinter.addLine("/delete-node/ "+obj.Name+";");
        end
    end
end