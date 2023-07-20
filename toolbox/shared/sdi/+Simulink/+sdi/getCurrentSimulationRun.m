function ret=getCurrentSimulationRun(mdl,varargin)








    try
        [varargin{:}]=convertStringsToChars(varargin{:});
        mdl=convertStringsToChars(mdl);
        validateattributes(mdl,{'char','string'},{},'getCurrentSimulationRun','model',1);

        if(nargin==3&&varargin{2}==false)

            varargin={varargin{1}};

            Simulink.sdi.internal.partialFlushStreamingBackend(mdl,varargin{:});
        else

            Simulink.sdi.internal.flushStreamingBackend();
        end


        eng=Simulink.sdi.Instance.engine;
        ret=eng.safeTransaction(@locGetRun,mdl,varargin{:});
    catch me
        me.throwAsCaller;
    end
end

function run=locGetRun(mdl,varargin)
    run=Simulink.sdi.Run.empty();
    eng=Simulink.sdi.Instance.engine;
    runID=eng.getCurrentStreamingRunID(mdl,varargin{:});
    if runID

        run=Simulink.sdi.Instance.engine.getRun(runID);
    end
end