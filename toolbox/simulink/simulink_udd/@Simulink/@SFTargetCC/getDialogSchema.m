function dlgstruct=getDialogSchema(h,name)



    if strcmp(name,'Target Options')
        dlgstruct=getTargetOptionsDlg(h,name);
    elseif strcmp(name,'Coder Options')
        dlgstruct=getCoderOptionsDlg(h,name);
    else
        dlgstruct=getTargetDlg(h,name);
    end
