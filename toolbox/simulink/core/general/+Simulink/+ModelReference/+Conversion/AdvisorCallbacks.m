classdef AdvisorCallbacks<handle
    methods(Static,Access=public)
        function inputParametersCallbackFcn(taskObj)
            params=taskObj.getInputParameters;
            checkSimulationResults=params{Simulink.ModelReference.Conversion.GuiParameters.CheckSimulationResults};
            stopTime=params{Simulink.ModelReference.Conversion.GuiParameters.StopTime};
            absoluteTolerance=params{Simulink.ModelReference.Conversion.GuiParameters.AbsoluteTolerance};
            relativeTolerance=params{Simulink.ModelReference.Conversion.GuiParameters.RelativeTolerance};


            replaceSubsystem=params{Simulink.ModelReference.Conversion.GuiParameters.ReplaceSubsystem};
            copyCodeMappings=params{Simulink.ModelReference.Conversion.GuiParameters.CopyCodeMappings};
            if replaceSubsystem.Value
                checkSimulationResults.Enable=true;
                isEnabled=checkSimulationResults.Value;
                stopTime.Enable=isEnabled;
                absoluteTolerance.Enable=isEnabled;
                relativeTolerance.Enable=isEnabled;
            else
                checkSimulationResults.Enable=false;
                stopTime.Enable=false;
                absoluteTolerance.Enable=false;
                relativeTolerance.Enable=false;
            end
        end
    end
end
