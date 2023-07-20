classdef FlowArrangementTLMA<int32





    enumeration
        Parallel(1)
        Counter(2)
        Cross(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Parallel')='Parallel flow';
            map('Counter')='Counter flow';
            map('Cross')='Cross flow';
        end
    end
end