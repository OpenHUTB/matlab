classdef StringToCastInput<handle



    methods(Abstract)
        castInputValueString=getStringToCastInputValue(inputType,breakpointType,inputNumber);
    end
end

