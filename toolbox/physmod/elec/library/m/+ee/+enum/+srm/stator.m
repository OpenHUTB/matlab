classdef stator<int32



    enumeration
        fourphase(1)
        fivephase(2)
        sixphase(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('fourphase')='physmod:ee:library:comments:enum:srm:stator:map_Fourphase';
            map('fivephase')='physmod:ee:library:comments:enum:srm:stator:map_Fivephase';
            map('sixphase')='physmod:ee:library:comments:enum:srm:stator:map_Sixphase';
        end
    end
end

