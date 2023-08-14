classdef StepperBlockDiagnostics


    properties(Constant,Access=public)


        AllowedSet=[...
        "Parameter Overflow","Simulink:Parameters:OutputValueGreaterThanPropagatedDesignMax";...
        "Fixedpoint Overflow","SimulinkFixedPoint:util:Overflowoccurred";...
        "Fixedpoint Saturation","SimulinkFixedPoint:util:Saturationoccurred";...
        "Stateflow Saturation","Stateflow:Runtime:DataSaturateError";...
        "Inf or NaN block output","Simulink:Engine:BlockOutputInfNanDetectedError"...
        ];
    end
    methods(Static,Access=public)
        function numd=NumAllowedDiagnostics

            sz=size(SLStudio.StepperBlockDiagnostics.AllowedSet);
            numd=sz(1);
        end
    end
end