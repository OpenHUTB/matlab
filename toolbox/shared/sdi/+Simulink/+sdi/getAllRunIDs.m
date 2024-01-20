function runIDs=getAllRunIDs(varargin)

    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end
    Simulink.sdi.internal.flushStreamingBackend();
    runIDs=Simulink.sdi.Instance.engine.getAllRunIDs(varargin{:});
end