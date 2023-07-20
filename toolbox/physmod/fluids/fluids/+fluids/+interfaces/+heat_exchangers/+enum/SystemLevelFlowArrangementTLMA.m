classdef SystemLevelFlowArrangementTLMA<int32





    enumeration
        Parallel(1)
        Counter(2)
        Cross(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Parallel')='Parallel flow - Both fluids flow from A to B';
            map('Counter')='Counter flow - Thermal Liquid 1 flows from A to B, Moist Air 2 flows from B to A';
            map('Cross')='Cross flow - Both fluids flow from A to B';
        end
    end
end