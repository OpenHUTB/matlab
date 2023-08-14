function enablePCTSupport(varargin)























    eng=Simulink.sdi.Instance.engine();
    try
        enablePCTSupport(eng,varargin{:});
    catch me
        me.throwAsCaller();
    end
end
