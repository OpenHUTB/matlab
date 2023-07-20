classdef cgdLinearity<int32



    enumeration
        constant(1)
        nonlinear(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('constant')='physmod:ee:library:comments:enum:mosfet:cgdLinearity:map_GateDrainCapacitanceIsConstant';
            map('nonlinear')='physmod:ee:library:comments:enum:mosfet:cgdLinearity:map_GateDrainChargeFunctionIsNonlinear';
        end
    end
end