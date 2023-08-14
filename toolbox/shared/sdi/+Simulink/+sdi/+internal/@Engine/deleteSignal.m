function deleteSignal(this,varargin)

    this.safeTransaction(@locDeleteSignal,this,varargin{:});
end


function locDeleteSignal(this,varargin)
    try
        if length(varargin)==2

            sigIDs=this.getSignalIDByIndex(varargin{1},varargin{2});
            runIDs=varargin{2};
        else

            sigIDs=int32(varargin{1});
            runIDs=int32.empty();
        end
    catch me %#ok<NASGU>

        return
    end





    numSigs=numel(sigIDs);
    MAX_CHANNELS_FOR_DEINTERLEAVE=40;
    if numSigs>MAX_CHANNELS_FOR_DEINTERLEAVE
        locDeinterleaveSignals(this,sigIDs);
    end


    if isempty(runIDs)
        runIDs=zeros([numSigs,1],'int32');
        for idx=1:numSigs
            runIDs(idx)=this.sigRepository.getSignalRunID(sigIDs(idx));
        end
    end


    runApp=this.sigRepository.getRunApp(runIDs(1));
    runAppStr=this.sigRepository.getRunAppAsString(runIDs(1));
    bIsSDI=any(strcmpi(runAppStr,{'sdi','SDIComparison'}));


    sigsToClear=int32.empty();
    runsToClear=int32.empty();
    if bIsSDI
        for idx=1:numSigs
            try
                if this.sigRepository.isSignalVisibleInSDI(sigIDs(idx))
                    sigsToClear(end+1)=sigIDs(idx);%#ok<AGROW>
                    runsToClear(end+1)=runIDs(idx);%#ok<AGROW>
                end
            catch me %#ok<NASGU>
                continue
            end
        end
    end


    if bIsSDI&&numSigs>1
        Simulink.sdi.internal.onPreSignalRunDelete('all',0);
    end


    this.sigRepository.remove(sigIDs);


    if bIsSDI
        if this.getRunCount()==0
            this.deleteAllRuns;
        end
        this.dirty=true;
    end


    if~isempty(sigsToClear)
        numSigs=numel(sigsToClear);
        sigsToClear=reshape(sigsToClear,[numSigs,1]);
        for idx=1:numSigs
            notify(this,'signalDeleteEvent',...
            Simulink.sdi.internal.SDIEvent('signalDeleteEvent',runsToClear(idx),...
            sigsToClear(idx),runApp));
        end
        Simulink.sdi.clearSignalsFromCanvas(sigsToClear);
    end
end


function locDeinterleaveSignals(this,sigIDs)
    numSigs=numel(sigIDs);
    for idx=1:numSigs
        Simulink.sdi.cacheDeinterleavedData(this.sigRepository,sigIDs(idx),false);
    end
end
