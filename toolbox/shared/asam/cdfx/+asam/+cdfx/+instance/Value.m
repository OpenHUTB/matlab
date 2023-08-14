classdef Value<asam.cdfx.instance.Instance




    methods
        function obj=Value(root,sys,inst)



            obj=obj@asam.cdfx.instance.Instance(root,sys,inst);


            obj.PhysicalValueDims=asam.cdfx.mf0.getValueDimensions(obj.ValueContainerElement,1,obj.ValueType,obj.HasGroupedValues);



            if obj.ValueContainerElement.SW_VALUES_PHYS.(obj.ValueType).Size==0

                obj.PhysicalValue=NaN;


                dataModel=mf.zero.Model;
                obj.InstanceElement=cdfx.VType(dataModel);
            else

                obj.PhysicalValue=obj.getPhysicalValues();


                switch obj.ValueType
                case "V"
                    obj.InstanceElement=obj.ValueContainerElement.SW_VALUES_PHYS.V(1);
                case "VT"
                    obj.InstanceElement=obj.ValueContainerElement.SW_VALUES_PHYS.VT(1);
                end
            end


            obj.Value=obj.PhysicalValue;

        end

        function setValue(obj,value,~)




            value=convertCharsToStrings(value);


            if~isstring(value)&&~isnumeric(value)
                error(message('asam_cdfx:CDFX:CategoryValueTypeMismatch',obj.Category));
            end

            if strcmp(obj.ValueType,"V")&&~isnumeric(value)
                error(message('asam_cdfx:CDFX:NumericValueElementMismatch',obj.ShortName))
            end

            if strcmp(obj.ValueType,"VT")&&~isstring(value)
                error(message('asam_cdfx:CDFX:TextValueElementMismatch',obj.ShortName))
            end

            if~isscalar(value)
                error(message('asam_cdfx:CDFX:CategoryValueSizeMismatch',obj.Category));
            end


            obj.Value=value;
            obj.PhysicalValue=value;


            obj.InstanceElement.elementValue=string(value);
        end

        function physVal=getPhysicalValues(obj)


            switch obj.ValueType
            case "V"
                physVal=str2double(obj.ValueContainerElement.SW_VALUES_PHYS.V(1).elementValue);
            case "VT"
                physVal=string(obj.ValueContainerElement.SW_VALUES_PHYS.VT(1).elementValue);
            end
        end

        function valType=getValueType(~,valueContainer)




            if~isequal(valueContainer.SW_VALUES_PHYS.V.Size,0)
                valType="V";
            else
                if~isequal(valueContainer.SW_VALUES_PHYS.VT.Size,0)
                    valType="VT";
                else
                    valType="V";
                end
            end
        end

    end
end

