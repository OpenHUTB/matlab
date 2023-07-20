classdef FaultOpening<int32




    enumeration
        Closed(1)
        Open(2)
        Last(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Closed')='Closed';
            map('Open')='Open';
            map('Last')='Maintain last value';
        end
    end
end