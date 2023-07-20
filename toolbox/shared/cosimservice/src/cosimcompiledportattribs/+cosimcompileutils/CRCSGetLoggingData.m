function logStruct=CRCSGetLoggingData(blockPath)
    try
        logStruct=struct('logFilePath','','isError',false,'errorMsg','');
        targetDir=tempname;
        mkdir(targetDir);
        logFileName='cosim__logging__.mldatx';
        logFilePath=fullfile(targetDir,logFileName);

        repo=sdi.Repository(true);
        runIDs=repo.getAllRunIDs;
        if~isempty(runIDs)
            sigIds=repo.getAllSignalIDs(runIDs(end));
            for i=1:length(sigIds)
                s=Simulink.sdi.getSignal(sigIds(i));

                fullBlockPath_new=erase(s.FullBlockPath,'CosimMdl/');
                repo.setSignalBlockSource(s.ID,fullBlockPath_new);

                if contains(s.Domain,s.BlockName)
                    strs=split(s.Domain,'|');
                    domain_new=strs{end};
                    repo.setSignalDomainType(s.ID,[blockPath,'|',domain_new]);
                end
            end
            Simulink.sdi.save(logFilePath);
            logStruct.logFilePath=logFilePath;
        end
    catch eCause
        logStruct.isError=true;
        if ismethod(eCause,'json')
            logStruct.errorMsg=eCause.json;
        else
            logStruct.errorMsg=jsonencode(eCause);
        end
    end
end

