function show(aObj)




    if isempty(aObj.fDialogHandle)
        dlg=DAStudio.Dialog(aObj);

        dlg.position(3)=800;
        aObj.fDialogHandle=dlg;
    else
        aObj.fDialogHandle.show;
    end
