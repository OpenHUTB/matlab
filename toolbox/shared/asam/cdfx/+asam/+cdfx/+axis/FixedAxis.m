classdef FixedAxis<asam.cdfx.axis.AxisContainer















    methods
        function obj=FixedAxis(axisCont)


            obj.Category="FIX_AXIS";
            obj.IsReferencedAxis=false;

            obj.AxisContElement=axisCont;

            obj.Units=string(obj.AxisContElement.UNIT_DISPLAY_NAME.elementValue);

            obj.ArrayDims=zeros(1,ndims(obj.AxisContElement.SW_VALUES_PHYS.V.toArray));
            elementArray=obj.AxisContElement.SW_VALUES_PHYS.V.toArray;
            obj.ArrayDims(:)=size(elementArray);


            for idx=1:numel(elementArray)
                obj.PhysicalValue=[obj.PhysicalValue,str2double(elementArray(idx).elementValue)];
            end
        end

    end
end

