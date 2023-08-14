function sourceNameChange(hSrc,index)





    if index==1
        configset.internal.util.refreshHTMLView(hSrc);
    elseif index==2
        configset.internal.reference.refresh(hSrc);
    end

    dlg=hSrc.getDialogHandle;
    if isa(dlg,'DAStudio.Dialog')
        web=dlg.getDialogSource;
        web.enableApplyButton(true);
    end