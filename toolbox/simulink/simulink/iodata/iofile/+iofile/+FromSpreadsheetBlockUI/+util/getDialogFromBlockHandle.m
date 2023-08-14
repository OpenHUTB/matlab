function dlgHandle=getDialogFromBlockHandle(blockH)





    dlgHandle=[];
    if ishandle(blockH)
        blkObj=get(blockH,'Object');
        listdlgHandles=DAStudio.ToolRoot.getOpenDialogs(blkObj.getDialogSource);

        for id=1:length(listdlgHandles)
            if strcmpi(listdlgHandles(id).dialogTag,'FromSpreadsheet')
                dlgHandle=listdlgHandles(id);
                break;
            end
        end
    end

