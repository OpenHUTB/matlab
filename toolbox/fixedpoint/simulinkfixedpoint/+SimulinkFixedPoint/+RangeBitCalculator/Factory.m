classdef Factory<handle





    methods(Static)
        function calculator=getCalculator(calculatorType)
            calculator=SimulinkFixedPoint.RangeBitCalculator.(char(calculatorType));
        end
    end
end


