classdef DependentValue<asam.cdfx.instance.Instance




    methods
        function obj=DependentValue(root,sys,inst)



            obj=obj@asam.cdfx.instance.Instance(root,sys,inst);


            if obj.hasVariantProps()
                firstVariant=inst.SW_INSTANCE_PROPS_VARIANTS.SW_INSTANCE_PROPS_VARIANT(1);
                try
                    obj.InstanceElement=firstVariant.SW_VALUE_CONT.SW_VALUES_PHYS.V(1);


                catch e

                    obj.InstanceElement=firstVariant.SW_VALUE_CONT.SW_VALUES_PHYS.VT(1);
                    obj.PhysicalValue=string(obj.InstanceElement.elementValue);
                    obj.Value=obj.PhysicalValue;
                    return;
                end
            else
                try
                    obj.InstanceElement=inst.SW_VALUE_CONT.SW_VALUES_PHYS.V(1);


                catch e

                    obj.InstanceElement=inst.SW_VALUE_CONT.SW_VALUES_PHYS.VT(1);
                    obj.PhysicalValue=string(obj.InstanceElement.elementValue);
                    obj.Value=obj.PhysicalValue;
                    return;
                end
            end


            obj.PhysicalValue=str2double(obj.InstanceElement.elementValue);
            obj.Value=obj.PhysicalValue;
        end

        function setValue(obj,value,~)





            if~isequal(value,obj.Value)
                error(message('asam_cdfx:CDFX:InvalidDependentValueSet'));
            end
        end

        function valueType=getValueType(obj,valueContainer)

            valueType="";
        end
    end
end

