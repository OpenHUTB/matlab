classdef inputType<int32



    enumeration
        instantaneous(1)
        singleFreqAC(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('instantaneous')='physmod:ee:library:comments:enum:inputType:instantaneous';
            map('singleFreqAC')='physmod:ee:library:comments:enum:inputType:singleFreqAC';
        end
    end
end

