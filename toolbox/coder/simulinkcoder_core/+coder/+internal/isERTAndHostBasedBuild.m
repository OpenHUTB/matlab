function isERTAndHostBased=isERTAndHostBasedBuild(configSet,lModelCompInfo,targetType)



    isERTTarget=isequal(get_param(configSet,'IsERTTarget'),'on')&&...
    ~strcmp(targetType,'SIM');
    if isERTTarget&&~isempty(lModelCompInfo.ToolchainInfo)
        isHostBasedBuild=lModelCompInfo.ToolchainInfo.SupportsBuildingMEXFuncs;
    else
        isHostBasedBuild=false;
    end
    isERTAndHostBased=isERTTarget&&isHostBasedBuild;
