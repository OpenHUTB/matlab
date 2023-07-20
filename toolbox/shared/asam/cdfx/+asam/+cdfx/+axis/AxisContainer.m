classdef(Abstract)AxisContainer<matlab.mixin.Heterogeneous




    properties



        Category string

        Units string

ArrayDims



        IsReferencedAxis logical


PhysicalValue

AxisContElement
    end

    methods
        function isRefAxis=isReferencedAxis(obj)
            isRefAxis=obj.IsReferencedAxis;
        end
    end
end

