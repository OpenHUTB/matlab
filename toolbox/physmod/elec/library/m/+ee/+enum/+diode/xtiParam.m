classdef xtiParam<int32





    enumeration
        pn(1)
        schottky(2)
        custom(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('pn')='physmod:ee:library:comments:enum:diode:xtiParam:map_UseNominalValueForPnjunctionDiodeXTI3';
            map('schottky')='physmod:ee:library:comments:enum:diode:xtiParam:map_UseNominalValueForSchottkyBarrierDiodeXTI2';
            map('custom')='physmod:ee:library:comments:enum:diode:xtiParam:map_SpecifyACustomValue';
        end
    end
end
