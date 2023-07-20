classdef cartridge_valve_spec<int32




    enumeration
        conical(1)
        custom(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('conical')='Conical';
            map('custom')='Custom';
        end
    end
end