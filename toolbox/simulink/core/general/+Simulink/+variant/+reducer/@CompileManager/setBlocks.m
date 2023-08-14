function setBlocks(obj,modelName,blocks)





    if isempty(obj.Blocks)
        obj.Blocks=blocks;
    else
        obj.Blocks=[obj.Blocks;blocks];
    end

    if obj.ModelName2ModelBlocksMap.isKey(modelName)


        obj.ModelName2ModelBlocksMap(modelName)=[obj.ModelName2ModelBlocksMap(modelName);blocks(strcmp(get_param(blocks,'BlockType'),'ModelReference'))];
    else
        obj.ModelName2ModelBlocksMap(modelName)=blocks(strcmp(get_param(blocks,'BlockType'),'ModelReference'));
    end
end


