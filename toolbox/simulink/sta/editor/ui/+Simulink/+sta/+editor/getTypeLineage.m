function typeLineage=getTypeLineage(sigID,typeLineage)



    repoUtil=starepository.RepositoryUtility;

    sigDataFormat=repoUtil.getMetaDataByName(sigID,'dataformat');
    if isempty(sigDataFormat)
        sigDataFormat='';
    end
    tempCell{1}=sigDataFormat;

    typeLineage=[typeLineage,tempCell];
    parentID=repoUtil.repo.getSignalParent(sigID);

    if~isempty(parentID)&&parentID~=0
        typeLineage=Simulink.sta.editor.getTypeLineage(parentID,typeLineage);
    end