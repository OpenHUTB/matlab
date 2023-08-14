classdef BankHeatCoeffSpec<int32





    enumeration
        Colburn(1)
        Martin(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Colburn')='Colburn equation';
            map('Martin')='Correlation for flow over tube bank';
        end
    end
end