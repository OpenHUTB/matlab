


classdef ModelWorkspaceUtilsForSubsystemConversion<Simulink.ModelReference.Conversion.ModelWorkspaceUtils
    methods(Access=public)
        function this=ModelWorkspaceUtilsForSubsystemConversion(srcModel,destModel,varargin)
            this@Simulink.ModelReference.Conversion.ModelWorkspaceUtils(srcModel,destModel,varargin{:});
        end
    end

    methods(Access=protected)
        function copyModelFileWorkspace(this)
            if~isempty(this.UsedVariables)
                this.copyParametersUsedBySubsystem;
            end
        end
    end
end