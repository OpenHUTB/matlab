classdef VMgrDiagnosticReporter<handle






    properties(Constant)
        Component=message('Simulink:VariantManagerUI:FrameTitlevm').getString();
    end

    properties
        ModelName;
    end

    methods(Hidden)
        function obj=VMgrDiagnosticReporter(modelName)
            obj.ModelName=modelName;
        end

        function reportAsError(obj,excep)
            Simulink.output.error(excep,"Component",obj.Component);
        end

        function reportAsWarning(obj,excep)
            Simulink.output.warning(excep,"Component",obj.Component);
        end

        function reportAsInfo(obj,excep)
            Simulink.output.info(excep,"Component",obj.Component);
        end

        function stage=createStage(obj,stageName,isUIMode)
            stage=Simulink.output.Stage(stageName,...
            'ModelName',obj.ModelName,...
            'UIMode',isUIMode);
        end
    end
end


