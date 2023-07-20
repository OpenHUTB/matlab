classdef Hisl_0004<Sldv.Validator.CheckValidator.HISLErrors




    methods
        function obj=Hisl_0004(blockData)

            obj@Sldv.Validator.CheckValidator.HISLErrors(blockData);
            obj.expectedDiagnostics=obj.populateExpectedDiagnostics();
        end
    end
    methods(Access='private')
        function expectedDiagnosticsList=populateExpectedDiagnostics(obj)%#ok<MANU> 


            expectedDiagnosticsList={'Simulink:blocks:BmathLogOfNegativeNumber',...
'Simulink:blocks:LogOfZero'
            };
        end
    end
end
