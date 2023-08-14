classdef SignalRangeError<Sldv.Validator.CheckValidator.ErrorDetectionCheck






    methods
        function obj=SignalRangeError(blockData)
            obj@Sldv.Validator.CheckValidator.ErrorDetectionCheck(blockData);
            obj.expectedDiagnostics=obj.populateExpectedDiagnostics();
        end
    end
    methods(Access='private')
        function expectedDiagnosticsList=populateExpectedDiagnostics(obj)%#ok<MANU> 


            expectedDiagnosticsList={'Simulink:Parameters:OutputArrayValueLessThanPropagatedDesignMin',...
            'Simulink:Parameters:OutputReValueLessThanPropagatedDesignMin',...
            'Simulink:Parameters:OutputValueGreaterThanPropagatedDesignMax',...
            'Simulink:Parameters:OutputValueInConsistentWithBusDesignMinMaxMsg',...
'Simulink:Parameters:OutputValueLessThanPropagatedDesignMin'
            };
        end
    end
end
