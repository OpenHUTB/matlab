classdef cgcLinearity<int32



    enumeration
        constant(1)
        nonlinear(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('constant')='physmod:ee:library:comments:enum:igbt:cgcLinearity:map_GateCollectorCapacitanceIsConstant';
            map('nonlinear')='physmod:ee:library:comments:enum:igbt:cgcLinearity:map_GateCollectorChargeFunctionIsNonlinear';
        end
    end
end