classdef parameterization<int32



    enumeration
        equation(1)
        lookuptable2D(2)
        lookuptable3D(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('equation')='physmod:ee:library:comments:enum:igbt:parameterization:map_FundamentalNonlinearEquations';
            map('lookuptable2D')='physmod:ee:library:comments:enum:igbt:parameterization:map_LookupTable2DTemperatureIndependent';
            map('lookuptable3D')='physmod:ee:library:comments:enum:igbt:parameterization:map_LookupTable3DTemperatureDependent';
        end
    end
end