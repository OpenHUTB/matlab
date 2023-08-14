function refresh(modelPath)






    modelPath=convertStringsToChars(modelPath);
    isModelBlock=strcmp(get_param(modelPath,'Type'),'block')&&...
    strcmp(get_param(modelPath,'BlockType'),'ModelReference');
    if(~isModelBlock)
        DAStudio.error('Simulink:modelReference:RefreshRequiresModelBlock');
    end

    obj=get_param(modelPath,'Object');
    obj.refreshModelBlock();
end