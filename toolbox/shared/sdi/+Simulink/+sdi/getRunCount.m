function runCount=getRunCount(varargin)







    args={'SDIRuns'};
    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
        args=varargin;
    end

    Simulink.sdi.internal.flushStreamingBackend();
    runCount=int32(Simulink.sdi.Instance.engine.getRunCount(args{:}));
end