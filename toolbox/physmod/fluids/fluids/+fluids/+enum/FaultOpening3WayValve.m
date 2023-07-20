classdef FaultOpening3WayValve<int32





    enumeration
        ReducingClosedReliefOpen(1)
        ReducingOpenReliefClosed(2)
        Last(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('ReducingClosedReliefOpen')='Reducing valve closed and relief valve open';
            map('ReducingOpenReliefClosed')='Reducing valve open and relief valve closed';
            map('Last')='Maintain last value';
        end
    end
end