classdef FaultExternalTrigger<int32




    enumeration
        Off(0)
        On(1)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Off')='Off';
            map('On')='Fault when T >= 0.5';
        end
    end
end