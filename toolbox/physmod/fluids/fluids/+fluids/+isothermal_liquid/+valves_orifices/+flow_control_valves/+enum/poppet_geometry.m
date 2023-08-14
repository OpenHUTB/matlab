classdef poppet_geometry<int32




    enumeration
        cylindrical_stem(1)
        round_ball(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('cylindrical_stem')='Cylindrical stem';
            map('round_ball')='Round ball';
        end
    end
end