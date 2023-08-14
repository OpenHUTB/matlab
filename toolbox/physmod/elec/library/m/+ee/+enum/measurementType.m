classdef measurementType<int32



    enumeration
        instantaneous(1)
        average(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('instantaneous')='physmod:ee:library:comments:enum:measurementType:instantaneous';
            map('average')='physmod:ee:library:comments:enum:measurementType:average';
        end
    end
end
