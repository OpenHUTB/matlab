classdef Hisl_0002<Sldv.Validator.CheckValidator.HISLErrors




    methods
        function obj=Hisl_0002(blockData)

            obj@Sldv.Validator.CheckValidator.HISLErrors(blockData);
            obj.expectedDiagnostics=obj.populateExpectedDiagnostics();
        end
    end
    methods(Access='private')
        function expectedDiagnosticsList=populateExpectedDiagnostics(obj)%#ok<MANU> 


            expectedDiagnosticsList={'SimulinkFixedPoint:util:fxpDivisionByZero',...
            'Simulink:blocks:DivideByZero',...
            'Simulink:Engine:BlockOutputInfNanDetectedError',...
            };
        end
    end
end
