function readAllSignalValues(this,runIDs,sigIDs)




    this.SignalValuesCache=Simulink.sdi.Map(int32(0),?timeseries);


    repo=sdi.Repository(1);
    for idx=1:numel(runIDs)
        locCacheRun(this,repo,runIDs(idx));
    end


    for idx=1:numel(sigIDs)
        sig=Simulink.sdi.Signal(repo,sigIDs(idx));
        ts=sig.Values;
        if isa(ts,'timeseries')
            this.SignalValuesCache.insert(sig.ID,ts)
        end
    end
end


function locCacheRun(this,repo,runID)
    KEEP_HIER=true;
    NOT_STREAM_ONLY=false;
    ALL_DOMAINS='';
    ALL_SIGS=int32.empty();
    ALL_CHUNKS=int32.empty();
    ALL_TIMES=double.empty();

    out=Simulink.sdi.exportRunData(...
    repo,...
    runID,...
    KEEP_HIER,...
    NOT_STREAM_ONLY,...
    ALL_DOMAINS,...
    ALL_SIGS,...
    ALL_CHUNKS,...
    ALL_TIMES);

    sigs=out.Streamed;
    for idx=1:numel(out.Logged)
        sigs=[sigs;out.Logged(idx).Signals];%#ok<AGROW> 
    end

    for idx=1:numel(sigs)
        if isa(sigs(idx).Values,'timeseries')
            this.SignalValuesCache.insert(sigs(idx).ID,sigs(idx).Values)
        end
    end
end
