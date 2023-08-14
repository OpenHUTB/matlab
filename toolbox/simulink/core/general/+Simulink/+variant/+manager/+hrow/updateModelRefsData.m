function mdlRefBlocksData=updateModelRefsData(blockPath,rootPath,mdlRefBlocksData)




    isProtected=strcmp(get_param(blockPath,'ProtectedModel'),'on');
    if isProtected
        modelName=get_param(blockPath,'ModelFile');
        modelName=strtok(modelName,'.');
    else
        modelName=get_param(blockPath,'ModelName');
    end
    mdlRefBlock.ModelName=modelName;
    mdlRefBlock.RootPathPrefix=rootPath;
    mdlRefBlock.IsProtected=isProtected;
    if isempty(mdlRefBlocksData)
        mdlRefBlocksData=mdlRefBlock;
    else
        mdlRefPathNames={mdlRefBlocksData.RootPathPrefix};
        if isempty(find(strcmp(rootPath,mdlRefPathNames),1))
            mdlRefBlocksData(end+1)=mdlRefBlock;
        end
    end

end
