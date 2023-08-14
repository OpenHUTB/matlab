function updatedependency=AllowedUnitSystemsButton(cs,msg)




    hSrc=cs.getComponent('Diagnostics');
    hController=cs.getDialogController;
    browser=hController.AllowedUnitSystemsWindow;

    if isempty(browser)
        browser=Simulink.ConfigSetAllowedUnitSystems(hSrc);
        set(hController,'AllowedUnitSystemsWindow',browser);
    end
    hDlg=msg.dialog;
    set(browser,'ParentDlg',hDlg);

    allowedUnitSys=cs.get_param('AllowedUnitSystems');

    set(browser,'unitSysCopy',allowedUnitSys);
    browserDlg=get(browser,'ThisDlg');
    if isempty(browserDlg)||~isa(browserDlg,'DAStudio.Dialog')
        browserDlg=DAStudio.Dialog(browser,'','DLG_STANDALONE');
        set(browser,'ThisDlg',browserDlg);
        browserDlg.connect(hDlg,'up');
    end

    browserDlg.show;

    updatedependency=false;
