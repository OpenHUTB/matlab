function setPCTDataQueueOnWorker(dc,mode)



    eng=Simulink.sdi.Instance.engine;


    Simulink.sdi.internal.flushStreamingBackend();
drawnow


    eng.PCTSupportMode=mode;


    if isempty(dc)
        return
    end



    bWasEnabled=Simulink.sdi.internal.isParallelPoolSetup();
    Simulink.sdi.internal.isParallelPoolSetup(true);
    eng.PCTDataQueueFromWorker=dc;



    eng.PCTDataQueueToWorker=parallel.pool.DataQueue();
    afterEach(eng.PCTDataQueueToWorker,@(x)onPCTWorkerMsg(eng,x));



    if~bWasEnabled
        try
            [~,worker]=parallel.internal.pool.PoolArrayManager.getCurrent();
            addlistener(worker,'ObjectBeingDestroyed',@(varargin)locCleanupWorker());
        catch me %#ok<NASGU>

        end
    end



    msg.Type='new_worker';
    msg.DataQueue=eng.PCTDataQueueToWorker;
    Simulink.sdi.internal.sendMsgFromPCTWorker(msg,false,eng);
end

function locCleanupWorker()



    sdi.Repository.closeRepositoryOnWorker();
    Simulink.sdi.Instance.setEngine([]);
end