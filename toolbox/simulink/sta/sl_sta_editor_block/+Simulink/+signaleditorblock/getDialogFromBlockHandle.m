function listdlgHandles=getDialogFromBlockHandle(blockH)





    listdlgHandles=[];
    if ishandle(blockH)
        blkObj=get(blockH,'Object');
        listdlgHandles=DAStudio.ToolRoot.getOpenDialogs(blkObj.getDialogSource);
    end

