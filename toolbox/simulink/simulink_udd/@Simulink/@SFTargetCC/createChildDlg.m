function createChildDlg(h,name)



    if strcmp(name,'Target Options')
        dlgProp='TargetOptionsDlg';
    elseif strcmp(name,'Coder Options')
        dlgProp='CoderOptionsDlg';
    else
        dlgProp=[];
    end

    if~isempty(dlgProp)
        hDlg=get(h,dlgProp);
        if isempty(hDlg)|~isa(hDlg,'DAStudio.Dialog')
            hDlg=DAStudio.Dialog(h,name,'DLG_STANDALONE');
            set(h,dlgProp,hDlg);
        else
            hDlg.show;
        end
    end