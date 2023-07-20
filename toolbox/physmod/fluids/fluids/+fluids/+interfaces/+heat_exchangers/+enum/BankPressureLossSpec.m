classdef BankPressureLossSpec<int32





    enumeration
        Euler(1)
        Martin(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Euler')='Euler number per tube row';
            map('Martin')='Correlation for flow over tube bank';
        end
    end
end