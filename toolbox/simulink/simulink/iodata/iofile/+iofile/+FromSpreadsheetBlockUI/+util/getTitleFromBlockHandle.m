function title=getTitleFromBlockHandle(blockH)





    dlgHandle=iofile.FromSpreadsheetBlockUI.util.getDialogFromBlockHandle(blockH);
    title='';
    if~isa(dlgHandle,'DAStudio.Dialog')
        return;
    end

    ddgTitle=dlgHandle.getTitle;
    strTitle=string(ddgTitle);
    title=char(strTitle.extractAfter(': '));

end

