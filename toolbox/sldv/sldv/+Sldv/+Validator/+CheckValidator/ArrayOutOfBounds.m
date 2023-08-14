classdef ArrayOutOfBounds<Sldv.Validator.CheckValidator.ModellingErrors




    methods
        function obj=ArrayOutOfBounds(blockData)

            obj@Sldv.Validator.CheckValidator.ModellingErrors(blockData);
            obj.expectedDiagnostics=obj.populateExpectedDiagnostics();
        end
    end
    methods(Access='private')
        function expectedDiagnosticsList=populateExpectedDiagnostics(obj)%#ok<MANU> 


            expectedDiagnosticsList={'EMLRT:runTime:OutOfBoundRangeNamed',...
            'Stateflow:Runtime:ArrayOutOfBoundError',...
            'Simulink:blocks:AssignmentInvInputElement',...
            'Simulink:blocks:AssignmentInvInputElementEnd',...
            'Simulink:blocks:SelIntegerOutOfBounds',...
            'Simulink:blocks:MPSwitchNonIntegerControlInput',...
            'Simulink:blocks:MPSwitchControlInputRangeError',...
            'Simulink:blocks:SelIntegerOutOfBounds',...
            };
        end
    end
end
