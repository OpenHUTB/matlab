function clear(~,varargin)

    Simulink.sdi.Instance.engine.clear(varargin{:});
    Simulink.sdi.cleanupWorkerResources
end
