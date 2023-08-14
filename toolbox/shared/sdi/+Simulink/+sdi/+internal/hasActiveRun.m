function isActive=hasActiveRun(modelName,varargin)































    isActive=Simulink.sdi.Instance.engine.hasActiveRun(modelName,varargin{:});
end

