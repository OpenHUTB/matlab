function ids=getAllSignalIDs(this,varargin)







    Simulink.HMI.synchronouslyFlushWorkerQueue(this.Repo);

    if isempty(varargin)
        varargin={'leaf'};
    end

    ids=this.Repo.getAllSignalIDs(this.id,varargin{:});
end
