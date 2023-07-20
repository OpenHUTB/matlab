classdef ReferencePropertyValue<handle

















    properties(SetAccess=protected)
        Name string
    end

    methods
        function obj=ReferencePropertyValue(name)
            matlabshared.devicetree.util.validateReferenceName(name);
            obj.Name=name;
        end
    end


    methods(Access=protected)
        function printBody(obj,hDTPrinter,~,~)
            hDTPrinter.addText(obj.Name);
        end
    end
end