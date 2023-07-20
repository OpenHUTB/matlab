


function onFileChange(obj,codeLanguage,file)
    mrmgr=slci.manualreview.Manager.getInstance();
    mr=mrmgr.getManualReview(obj.fStudio);
    if mr.hasDialog...
        &&~strcmpi(file,mr.getDialog.getCurrentFile)

        mr.getDialog.reloadTable(codeLanguage,file);
    end
end