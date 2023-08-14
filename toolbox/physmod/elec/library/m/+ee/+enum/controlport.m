classdef controlport<int32



    enumeration
        ps(0)
        elec(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('ps')='physmod:ee:library:comments:enum:controlport:map_PS';
            map('elec')='physmod:ee:library:comments:enum:controlport:map_Electrical';
        end
    end
end