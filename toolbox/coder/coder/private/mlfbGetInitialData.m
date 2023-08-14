function data=mlfbGetInitialData(blockId)





    code=coder.internal.gui.GuiUtils.getFunctionBlockCode(blockId);
    projectXml='';
    globalProjectXml='';

    data=struct(...
    'code',code,...
    'projectXml',projectXml,...
    'globalProjectXml',globalProjectXml,...
    'locked',coder.internal.gui.GuiUtils.isBlockLocked(blockId));
end