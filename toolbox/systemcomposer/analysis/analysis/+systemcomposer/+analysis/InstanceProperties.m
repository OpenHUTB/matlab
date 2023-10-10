classdef(Hidden=true)InstanceProperties<systemcomposer.arch.Properties

    methods(Hidden)
        function value=getCustomPropertyValue(~,propObj)
            value=propObj.getAsMxArray;
        end

        function setCustomPropertyValue(~,propObj,value)
            propObj.setAsMxArray(value);
        end

    end
end
