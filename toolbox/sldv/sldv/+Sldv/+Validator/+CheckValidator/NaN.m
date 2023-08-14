classdef NaN<Sldv.Validator.CheckValidator.NumericalErrors





    methods
        function obj=NaN(blockData)
            obj@Sldv.Validator.CheckValidator.NumericalErrors(blockData);
            obj.expectedDiagnostics=obj.populateExpectedDiagnostics();
        end

    end
    methods(Access='private')
        function expectedDiagnostics=populateExpectedDiagnostics(obj)%#ok<MANU> 


            expectedDiagnostics={'Simulink:blocks:DivideByZero',...
            'Simulink:Engine:BlockOutputInfNanDetectedError',...
            'SimulinkFixedPoint:util:Overflowoccurred',...
            'Simulink:DataType:WarningOverFlowDetected'};
        end
    end
end
