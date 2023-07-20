classdef poppet_valve_seat_spec<int32




    enumeration
        sharp(1)
        conical(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('sharp')='Sharp-edged';
            map('conical')='Conical';
        end
    end
end