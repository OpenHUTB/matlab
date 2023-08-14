classdef TemperatureValveSpec<int32




    enumeration
        Open(1)
        Close(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Open')='Opens above activation temperature';
            map('Close')='Closes above activation temperature';
        end
    end
end