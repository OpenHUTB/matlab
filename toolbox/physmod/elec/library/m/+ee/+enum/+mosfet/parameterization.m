classdef parameterization<int32



    enumeration
        datasheet(1)
        equation(2)
        lookuptable2D(3)
        lookuptable3D(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('datasheet')='physmod:ee:library:comments:enum:mosfet:parameterization:map_SpecifyFromADatasheet';
            map('equation')='physmod:ee:library:comments:enum:mosfet:parameterization:map_SpecifyUsingEquationParametersDirectly';
            map('lookuptable2D')='physmod:ee:library:comments:enum:mosfet:parameterization:map_LookupTable2DTemperatureIndependent';
            map('lookuptable3D')='physmod:ee:library:comments:enum:mosfet:parameterization:map_LookupTable3DTemperatureDependent';
        end
    end
end