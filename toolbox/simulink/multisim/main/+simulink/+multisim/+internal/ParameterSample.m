classdef ParameterSample




    properties
        ParameterType simulink.multisim.mm.design.ParameterType
Value
    end

    methods
        function obj=ParameterSample(paramType,value)
            obj.ParameterType=paramType;
            obj.Value=value;
        end
    end
end