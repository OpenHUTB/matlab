function fullyLoadCache(this,startIdx)




    fullFlushIfNeeded(this);

    if~isempty(this.DatasetRef)
        if nargin<2
            startIdx=1;
        end
        Simulink.sdi.internal.safeTransaction(@locFullyLoadCache,this,startIdx);
    end
end


function locFullyLoadCache(this,startIdx)
    startIdx=min(startIdx);


    if~this.HasAnyElementBeenCached&&startIdx==1
        ds=fullExport(this.DatasetRef);
        if isempty(ds)
            this.ElementCache=...
            Simulink.SimulationData.Storage.RamDatasetStorage();
        else
            this.ElementCache=ds.getStorage();
        end
        this.HasAnyElementBeenCached=true;
    else
        len=this.numElements;
        for idx=startIdx:len
            cacheElementIfNeeded(this,idx);
        end
    end


    if startIdx==1
        this.HasAnyElementBeenCached=true;
        this.DatasetRef=[];
        if~isempty(this.PreDeleteListener)
            delete(this.PreDeleteListener);
            this.PreDeleteListener=[];
        end
    end
end
