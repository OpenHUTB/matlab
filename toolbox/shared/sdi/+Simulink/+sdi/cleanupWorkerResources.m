function cleanupWorkerResources()
    pool=Simulink.sdi.internal.getCurrentParallelPool();

    if~isempty(pool)
        f=parfevalOnAll(pool,@Simulink.sdi.internal.clearRepoOnWorker,0);
        wait(f);
    end
end
