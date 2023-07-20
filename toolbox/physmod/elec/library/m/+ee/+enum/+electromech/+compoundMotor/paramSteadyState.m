classdef paramSteadyState<int32
    enumeration
        equivCircuit(1)
        ratedStallNoload(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('equivCircuit')='physmod:ee:library:comments:enum:electromech:compoundMotor:paramSteadyState:map_EquivCircuit';
            map('ratedStallNoload')='physmod:ee:library:comments:enum:electromech:compoundMotor:paramSteadyState:map_RatedStallNoload';
        end
    end
end