function blockName=getBlockName(blockPath)





    modelName=downstream.tool.getTopLevelModelName(blockPath);
    if~bdIsLoaded(modelName)
        load_system(modelName);
    end
    nameStr=get_param(blockPath,'Name');
    blockName=strrep(nameStr,'/','//');

end

