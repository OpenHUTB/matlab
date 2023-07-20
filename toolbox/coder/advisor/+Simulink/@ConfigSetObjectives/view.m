function view(obj,cs)





    obj.ParentSrc=cs;
    obj.opCopy=get_param(obj.ParentSrc,'ObjectivePriorities');

    dlg=obj.ThisDlg;
    if isempty(dlg)||~isa(dlg,'DAStudio.Dialog')

        dlg=DAStudio.Dialog(obj,'','DLG_STANDALONE');
        obj.ThisDlg=dlg;
        if~isempty(obj.ParentSrc.getDialogHandle)

            dlg.connect(obj.ParentSrc.getDialogHandle,'up');
        end
    else

        dlg.show;
    end

end
