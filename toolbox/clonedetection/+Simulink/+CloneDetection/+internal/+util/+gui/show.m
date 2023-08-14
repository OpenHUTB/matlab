function show(aObj)




    if isempty(aObj.fDialogHandle)
        dlg=DAStudio.Dialog(aObj);
        aObj.fDialogHandle=dlg;
    else
        aObj.fDialogHandle.show;
    end
end
