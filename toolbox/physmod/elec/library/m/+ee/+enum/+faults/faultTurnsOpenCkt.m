classdef faultTurnsOpenCkt<int32



    enumeration
        no(0)
        yes(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('no')='physmod:ee:library:comments:enum:faults:faultTurnsOpenCkt:map_no';
            map('yes')='physmod:ee:library:comments:enum:faults:faultTurnsOpenCkt:map_yes';
        end
    end
end
