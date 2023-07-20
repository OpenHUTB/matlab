classdef ConfigSetExportFunction<Simulink.ModelReference.Conversion.ConfigSet
    methods(Access=public)
        function this=ConfigSetExportFunction(varargin)
            this@Simulink.ModelReference.Conversion.ConfigSet(varargin);
        end
    end
    methods(Access=protected)
        function updateConfigSetParamsSolver(this,dstModel,isCopyContent)
            Simulink.ModelReference.Conversion.CopySolverInfoForExportedFcn(this.System,dstModel,isCopyContent);
        end

        function resolveConfigSetReferenceWarning(this,modelRefHandle,activeConfigSet,logger)%#ok
        end
    end
end