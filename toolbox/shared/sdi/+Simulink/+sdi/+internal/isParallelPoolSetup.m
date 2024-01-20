function ret=isParallelPoolSetup(varargin)

    eng=Simulink.sdi.Instance.engine();
    ret=eng.isParallelPoolSetup(varargin{:});
end
