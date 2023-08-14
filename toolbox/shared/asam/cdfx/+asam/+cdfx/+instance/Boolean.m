classdef Boolean<asam.cdfx.instance.Instance




    methods
        function obj=Boolean(root,sys,inst)



            obj=obj@asam.cdfx.instance.Instance(root,sys,inst);


            obj.InstanceElement=obj.ParameterSet.SW_VALUE_CONT.SW_VALUES_PHYS.VT;


            obj.PhysicalValue=obj.getPhysicalValues();
            obj.Value=strcmpi(obj.PhysicalValue,'true');
        end

        function setValue(obj,value,~)







            if(isstring(value)||ischar(value))&&~any(strcmp(value,["true","false"]))||(~isstring(value)&&~isnumeric(value)&&~islogical(value)&&~ischar(value))
                error(message('asam_cdfx:CDFX:CategoryValueTypeMismatch',obj.Category));
            end


            if~isscalar(value)
                error(message('asam_cdfx:CDFX:CategoryValueSizeMismatch',obj.Category));
            end



            if isnumeric(value)
                if value~=0
                    finalValue="true";
                else
                    finalValue="false";
                end

            elseif islogical(value)
                if value
                    finalValue="true";
                else
                    finalValue="false";
                end

            else
                finalValue=value;
            end


            obj.Value=strcmp(finalValue,"true");
            obj.PhysicalValue=value;


            obj.InstanceElement(1).elementValue=string(finalValue);

        end

        function physVals=getPhysicalValues(obj)



            physVals=string(obj.InstanceElement(1).elementValue);
        end

        function valType=getValueType(~,~)



            valType="VT";
        end

    end
end

