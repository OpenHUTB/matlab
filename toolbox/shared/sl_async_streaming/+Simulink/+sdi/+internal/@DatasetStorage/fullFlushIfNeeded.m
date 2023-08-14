function fullFlushIfNeeded(this)


    if(isempty(this.ElementCache))
        repo=sdi.Repository(1);
        Simulink.HMI.synchronouslyFlushWorkerQueue(repo);
        if this.RunID
            this.ElementCache=Simulink.sdi.DatasetCache(this.DatasetRef.numElements);
        end
    end
end
