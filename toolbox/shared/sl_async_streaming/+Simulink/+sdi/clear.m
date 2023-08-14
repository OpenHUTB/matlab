function clear(varargin)









    if sdi.Repository.hasBeenCreated()
        try

            repo=sdi.Repository(1);
            Simulink.HMI.synchronouslyFlushWorkerQueue(repo);


            fw=Simulink.sdi.internal.AppFramework.getSetFramework();
            fw.clear(varargin{:});
        catch me
            throwAsCaller(me);
        end
    end
end
