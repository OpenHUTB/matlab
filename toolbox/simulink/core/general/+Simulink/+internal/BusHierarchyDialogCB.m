




function[status,errMsg]=BusHierarchyDialogCB(SigHierDialog)
    status=1;
    errMsg='';
    if isa(SigHierDialog.Dialog,'DAStudio.Dialog')
        delete(SigHierDialog);
    end
end
