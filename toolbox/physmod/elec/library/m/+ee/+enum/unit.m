classdef unit<int32



    enumeration
        pu(1)
        si(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('pu')='physmod:ee:library:comments:enum:unit:map_PerUnit';
            map('si')='physmod:ee:library:comments:enum:unit:map_SI';
        end
    end
end

