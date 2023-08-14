classdef Hisl_0003<Sldv.Validator.CheckValidator.HISLErrors




    methods
        function obj=Hisl_0003(blockData)

            obj@Sldv.Validator.CheckValidator.HISLErrors(blockData);
            obj.expectedDiagnostics=obj.populateExpectedDiagnostics();
        end
    end
    methods(Access='private')
        function expectedDiagnosticsList=populateExpectedDiagnostics(obj)%#ok<MANU> 


            expectedDiagnosticsList={'Simulink:blocks:BmathSqrtOfNegativeNumber',...
'SimulinkFixedPoint:util:fxpSqrt_negativeinputnotsupported'
            };
        end
    end
end
