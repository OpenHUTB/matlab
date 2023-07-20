classdef IncludeNode<matlabshared.devicetree.node.TerminalNode


    methods
        function obj=IncludeNode(name)





            if~endsWith(name,[".dts",".dtsi"])
                error(message('devicetree:base:InvalidIncludeFile'));
            end

            obj=obj@matlabshared.devicetree.node.TerminalNode(name);
        end
    end


    methods(Access=protected)
        function printBody(obj,hDTPrinter,isOverlay,~)
            if isOverlay


                error(message('devicetree:base:NoOverlayWithInclude'));
            end











            hDTPrinter.addLine("/include/ "+""""+obj.Name+"""");



        end
    end
end