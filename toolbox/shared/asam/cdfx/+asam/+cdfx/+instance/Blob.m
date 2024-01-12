classdef Blob<asam.cdfx.instance.Instance

    methods
        function obj=Blob(root,sys,inst)
            obj=obj@asam.cdfx.instance.Instance(root,sys,inst);


            obj.InstanceElement=obj.ParameterSet.SW_VALUE_CONT.SW_VALUES_CODED.VH;


            obj.PhysicalValue=obj.getPhysicalValues();
            obj.Value=obj.PhysicalValue;
        end


        function setValue(obj,value,~)
            if~isstring(value)&&~ischar(value)
                error(message('asam_cdfx:CDFX:CategoryValueTypeMismatch',obj.Category));
            end

            if~isscalar(value)
                error(message('asam_cdfx:CDFX:CategoryValueSizeMismatch',obj.Category));
            end


            obj.Value=value;
            obj.PhysicalValue=value;


            obj.InstanceElement(1).elementValue=string(value);
        end

        function physVals=getPhysicalValues(obj)



            physVals=strjoin(split(string(obj.InstanceElement(1).elementValue)));
        end

        function valType=getValueType(~,~)



            valType="VH";
        end
    end
end

