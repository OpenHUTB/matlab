classdef Hisl_0028<Sldv.Validator.CheckValidator.HISLErrors




    methods
        function obj=Hisl_0028(blockData)

            obj@Sldv.Validator.CheckValidator.HISLErrors(blockData);
            obj.expectedDiagnostics=obj.populateExpectedDiagnostics();
        end
    end
    methods(Access='private')
        function expectedDiagnosticsList=populateExpectedDiagnostics(obj)%#ok<MANU> 


            expectedDiagnosticsList={'Simulink:blocks:BmathRcpSqrtOfNegativeNumber',...
            'SimulinkFixedPoint:util:fxpDivisionByZero',...
'Simulink:blocks:DivideByZero'
            };
        end
    end
end
