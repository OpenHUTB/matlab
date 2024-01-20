function clearRepoOnWorker()

    repo=sdi.Repository(1);
    newMsg.Type='update_worker_instanceID';
    newMsg.OldInstanceID=repo.getInstanceID();

    sdi.Repository.clearRepositoryFile();

    try
        Simulink.sdi.internal.sendMsgFromPCTWorker(newMsg,false);
    catch me %#ok<NASGU> 
    end
end
