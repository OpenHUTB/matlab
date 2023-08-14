function valuesToSendUI=updateRepositoryDataSource(sigIds,fileName,fullFileLocation)



    nSigs=length(sigIds);
    valuesToSendUI=[];


    repoUtil=starepository.RepositoryUtility;

    for kIdx=1:nSigs


        repoUtil.setMetaDataByName(sigIds(kIdx),'FileName',fileName);

        repoUtil.setMetaDataByName(sigIds(kIdx),'LastKnownFullFile',fullFileLocation);


        thisSig.ID=sigIds(kIdx);
        thisSig.FileName=fileName;
        thisSig.FullFile=fullFileLocation;



        valuesToSendUI=[valuesToSendUI,thisSig];%#ok<*AGROW>

        childIds=repoUtil.getChildrenIds(sigIds(kIdx));
        if~isempty(childIds)
            childValues=updateRepositoryDataSource(childIds,fileName,fullFileLocation);
            valuesToSendUI=[valuesToSendUI,childValues];
        end

    end