function enablePCTSupport(this,opt)


















    try
        isPCTWorker=~isempty(getCurrentWorker());
    catch me %#ok<NASGU>

        isPCTWorker=false;
    end
    if isPCTWorker
        return
    end



    bSetDefault=true;
    if islogical(opt)||isnumeric(opt)
        bSetDefault=false;
        opt=Simulink.sdi.getDefaultPCTSupportMode();
    end


    if isstring(opt)&&isscalar(opt)
        opt=char(opt);
    end
    if~strcmpi(opt,'shutdown')
        validatestring(opt,{'local','all','manual'});
    end
    opt=lower(opt);
    if strcmp(this.PCTSupportMode,opt)
        return
    end


    this.PCTSupportMode=opt;


    bEnable=~strcmpi(opt,'shutdown');
    bIsEnabled=isPCTSupportEnabled(this);
    if bEnable&&~bIsEnabled

        try
            s=parallel.internal.pool.PoolArrayManager.getCurrentPoolArrayManager();
            this.PCTPoolListener=...
            listener(s,'PoolAddedEvent',@(x,y)onPCTPoolAdded(this,x,y));
            setupParallelPool(this);
        catch me %#ok<NASGU>

            this.PCTPoolListener=[];
        end

    elseif bEnable&&bIsEnabled

        locUpdateWorkerMode(this);

    elseif~bEnable&&bIsEnabled

        delete(this.PCTPoolListener);
        this.PCTPoolListener=[];

        enableDisablePCTTimer(this);
        locCleanupWorkers(this);

        this.PCTDataQueueFromWorker=[];
        this.PCTDataQueueToWorker=[];
        this.PCTRequestedSignalStreams=[];
    end

    if bEnable&&bSetDefault
        Simulink.sdi.setDefaultPCTSupportMode(opt);
    end
end


function locUpdateWorkerMode(this)
    pool=Simulink.sdi.internal.getCurrentParallelPool();
    if~isempty(pool)&&isempty(getCurrentWorker())
        f=parfevalOnAll(...
        pool,...
        @Simulink.sdi.internal.setPCTDataQueueOnWorker,...
        0,...
        [],...
        this.PCTSupportMode);
        wait(f);
        for idx=1:length(f.Error)
            if~isempty(f.Error{idx})
                throw(f.Error{idx})
            end
        end
    end
end


function locCleanupWorkers(this)
    if~isempty(this.PCTDataQueueToWorker)
        msg.Type='disable_pct_support';
        for idx=1:getCount(this.PCTDataQueueToWorker)
            dc=getDataByIndex(this.PCTDataQueueToWorker,idx);
            try
                send(dc,msg);
            catch me %#ok<NASGU>

            end
        end
    end
end
