function throwWarningIfUsingWrongLibrary(modelName,blockPath)




    editor=learning.simulink.getEditorFromModel(modelName);
    notificationBarExists=~isempty(editor.getActiveNotification);
    if notificationBarExists
        return;
    end

    blockPathSplit=strsplit(blockPath,'/');
    blockType=blockPathSplit{end};
    blockLib=strrep(blockPath,['/',blockType],'');
    findOptions=Simulink.FindOptions('RegExp',true);
    matchingBlockHandles=Simulink.findBlocks(modelName,'ReferenceBlock',...
    ['\/',blockType],findOptions);
    for i=1:length(matchingBlockHandles)
        currentBlockPath=get_param(matchingBlockHandles(i),'ReferenceBlock');
        currentBlockLib=strrep(currentBlockPath,['/',blockType],'');
        if~isequal(blockLib,currentBlockLib)
            warningString=message('learning:simulink:resources:wrongLibrary',...
            blockPath,currentBlockPath).getString();
            warningID='wrongLib';
            editor.deliverWarnNotification(warningID,warningString);
        end
    end
end
