classdef thermalLossOption<int32



    enumeration
        constantvalues(1)
        tabulated2d(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('constantvalues')='physmod:ee:library:comments:enum:converters:thermalLossOption:map_SpecifyConstantValues';
            map('tabulated2d')='physmod:ee:library:comments:enum:converters:thermalLossOption:map_TabulateWithTemperatureAndCurrent';
        end
    end
end