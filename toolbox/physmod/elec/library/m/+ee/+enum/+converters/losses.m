classdef losses<int32



    enumeration
        fixed(1)
        coefficients(2)
        profile(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fixed')='physmod:ee:library:comments:enum:converters:losses:map_FixedLosses';
            map('coefficients')='physmod:ee:library:comments:enum:converters:losses:map_LossesCoefficients';
            map('profile')='physmod:ee:library:comments:enum:converters:losses:map_LossesProfile';
        end
    end
end
