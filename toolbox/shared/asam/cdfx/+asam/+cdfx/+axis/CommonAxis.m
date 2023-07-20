classdef CommonAxis<asam.cdfx.axis.AxisContainer















    properties

InstanceReference
ReferenceSize
    end

    methods
        function obj=CommonAxis(axisCont)


            obj.Category="COM_AXIS";


            obj.AxisContElement=axisCont;



            obj.InstanceReference=string(obj.AxisContElement.SW_INSTANCE_REF.elementValue);


            obj.ReferenceSize=[];
            if~isempty(obj.AxisContElement.SW_ARRAYSIZE)
                obj.ReferenceSize=str2double(obj.AxisContElement.SW_ARRAYSIZE.V(1).elementValue);
            end




            obj.IsReferencedAxis=true;
        end

    end
end

