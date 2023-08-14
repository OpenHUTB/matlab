classdef ErrorCalculatorFactory<handle





    properties(SetAccess=private)
        AbsoluteErrorCalculator=fixed.internal.errorcalculator.AbsoluteErrorCalculator()
        RelativeErrorCalculator=fixed.internal.errorcalculator.RelativeErrorCalculator()
    end

    methods
        function calculator=getCalculatorForAbsoluteError(this)
            calculator=this.AbsoluteErrorCalculator;
        end

        function calculator=getCalculatorForRelativeError(this)
            calculator=this.RelativeErrorCalculator;
        end
    end
end
