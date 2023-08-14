function setupParallelPool(this)




    pool=Simulink.sdi.internal.getCurrentParallelPool();
    if~isempty(pool)&&~isa(pool,'parallel.ThreadPool')&&isempty(getCurrentWorker())


        this.PCTDataQueueFromWorker=parallel.pool.DataQueue();
        afterEach(this.PCTDataQueueFromWorker,@(x)onPCTWorkerMsg(this,x));
        this.PCTDataQueueToWorker=Simulink.sdi.Map(int64(0),?handle);



        f=parfevalOnAll(...
        pool,...
        @Simulink.sdi.internal.setPCTDataQueueOnWorker,...
        0,...
        this.PCTDataQueueFromWorker,...
        this.PCTSupportMode);
        wait(f);


        for idx=1:length(f.Error)
            if~isempty(f.Error{idx})
                throw(f.Error{idx})
            end
        end


        enableDisablePCTTimer(this);
    end
end

