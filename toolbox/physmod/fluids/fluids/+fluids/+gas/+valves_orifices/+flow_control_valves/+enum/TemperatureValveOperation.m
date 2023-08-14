classdef TemperatureValveOperation<int32





    enumeration
        Opens(1)
        Closes(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Opens')='Opens above activation temperature';
            map('Closes')='Closes above activation temperature';
        end
    end
end