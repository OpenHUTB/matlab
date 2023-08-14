classdef statorparam<int32
    enumeration
        LdLqL0(1)
        LsLmMs(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('LdLqL0')='physmod:ee:library:comments:enum:statorparam:map_SpecifyLdLqAndL0';
            map('LsLmMs')='physmod:ee:library:comments:enum:statorparam:map_SpecifyLsLmAndMs';
        end
    end
end
