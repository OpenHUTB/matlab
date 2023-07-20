classdef DeleteProperty<matlabshared.devicetree.property.PropertyBase


    methods
        function obj=DeleteProperty(name)
            obj=obj@matlabshared.devicetree.property.PropertyBase(name);
        end
    end


    methods(Access=protected)
        function printBody(obj,hDTPrinter,~,~)


            hDTPrinter.addLine("/delete-property/ "+obj.Name+";");
        end
    end
end