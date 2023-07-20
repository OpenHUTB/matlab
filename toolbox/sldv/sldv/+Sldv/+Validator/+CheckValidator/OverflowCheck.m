classdef OverflowCheck<Sldv.Validator.CheckValidator.NumericalErrors





    methods
        function obj=OverflowCheck(blockData)

            obj@Sldv.Validator.CheckValidator.NumericalErrors(blockData);
            obj.expectedDiagnostics=obj.populateExpectedDiagnostics();
        end
    end
    methods(Access='private')
        function expectedDiagnosticsList=populateExpectedDiagnostics(obj)%#ok<MANU> 


            expectedDiagnosticsList={'SimulinkFixedPoint:util:Overflowoccurred',...
            'Simulink:DataType:WarningOverFlowDetected',...
            'Simulink:blocks:AssignmentInvInputElement',...
            'Simulink:blocks:CaseOverflowIntegerInput',...
            'Simulink:blocks:CordicAngleOutOfRange',...
            'Simulink:blocks:PreLookupOutofRangeInputWarn_Clip',...
            'SimulinkFixedPoint:util:fxpParameterOverflow',...
            'Simulink:blocks:SelIntegerOutOfBounds',...
            'Stateflow:Runtime:DataOverflowErrorMSLD'};

        end
    end
end

