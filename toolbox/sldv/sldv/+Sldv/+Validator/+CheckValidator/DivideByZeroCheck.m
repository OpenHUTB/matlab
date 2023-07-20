classdef DivideByZeroCheck<Sldv.Validator.CheckValidator.NumericalErrors





    properties(Access='private')
        floatingPointIOBlocks={'Product','Math','Fcn','SampleTimeMath'};
    end

    methods
        function obj=DivideByZeroCheck(blockData)

            obj@Sldv.Validator.CheckValidator.NumericalErrors(blockData);
            obj.expectedDiagnostics=obj.populateExpectedDiagnostics();
        end
    end
    methods(Access='private')
        function expectedDiagnosticsList=populateExpectedDiagnostics(obj)%#ok<MANU> 


            expectedDiagnosticsList={'Simulink:blocks:DivideByZero',...
            'SimulinkFixedPoint:util:fxpDivisionByZero',...
            'Stateflow:Runtime:DataSaturateError',...
            'Coder:toolbox:idivide_divideByZero',...
            'Stateflow:Runtime:DataDivideByZero'};

        end
    end
end

