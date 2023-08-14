classdef Inf<Sldv.Validator.CheckValidator.NumericalErrors




    methods
        function obj=Inf(blockData)

            obj@Sldv.Validator.CheckValidator.NumericalErrors(blockData);
            obj.expectedDiagnostics=obj.populateExpectedDiagnostics();
        end
    end
    methods(Access='private')
        function expectedDiagnostics=populateExpectedDiagnostics(obj)%#ok<MANU> 


            expectedDiagnostics={'Simulink:Engine:BlockOutputInfNanDetectedError'};
        end
    end
end
