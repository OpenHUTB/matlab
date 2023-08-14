classdef capParam<int32





    enumeration
        fixed(1)
        cvcurve(2)
        params(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fixed')='physmod:ee:library:comments:enum:diode:capParam:map_FixedOrZeroJunctionCapacitance';
            map('cvcurve')='physmod:ee:library:comments:enum:diode:capParam:map_UseCVCurveDataPoints';
            map('params')='physmod:ee:library:comments:enum:diode:capParam:map_UseParametersCJ0VJMampFC';
        end
    end
end
