function setModelLibName(lBuildInfo,lModelName,lModelReferenceTargetType)




    tmpModelLibName=coder.internal.getModelLibName...
    (lModelName,lModelReferenceTargetType);

    groupBuildArg=coder.make.internal.BuildInfoGroup.BuildArgGroup;



    cur_keys=get(lBuildInfo.BuildArgs,'Key');
    if~isempty(cur_keys)&&any(ismember(cur_keys,'MODELLIB'))&&~strcmp(lModelReferenceTargetType,'NONE')
        removeBuildArgs(lBuildInfo,'MODELLIB');
    end

    addBuildArgs(lBuildInfo,'MODELLIB',tmpModelLibName,groupBuildArg);

