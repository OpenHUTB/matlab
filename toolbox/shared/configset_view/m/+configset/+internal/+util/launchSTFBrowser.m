function launchSTFBrowser(input,hDlg)





    if isa(input,'Simulink.ConfigSet')
        cs=input;
    else
        cs=getActiveConfigSet(input);
    end
    hSrc=cs.getComponent('Code Generation');
    if isempty(hSrc)
        return;
    end
    if nargin<2
        hDlg=[];
    end

    Progressbar=DAStudio.WaitBar;
    Progressbar.setWindowTitle(getString(message('RTW:configSet:RTWBrowseSTFInitializing')));
    Progressbar.setLabelText(getString(message('RTW:configSet:RTWBrowseSTFPleaseWait')));
    Progressbar.setCircularProgressBar(true);
    Progressbar.show();

    if isempty(hDlg)

        tb=RTW.TargetBrowser(cs);
        set(tb,'parentSrc',cs);
        dlg=DAStudio.Dialog(tb);
        set(tb,'ThisDlg',dlg);

    else

        hController=getDialogController(hSrc.getConfigSet);
        browser=RTW.TargetBrowser(hDlg,hSrc);
        set(hController,'TLCBrowser',browser);
        browserDlg=get(browser,'ThisDlg');


        getSelectedSTF(browser);

        if isempty(browserDlg)||~isa(browserDlg,'DAStudio.Dialog')
            browserDlg=DAStudio.Dialog(browser,'','DLG_STANDALONE');





            position=browserDlg.Position;
            position(4)=position(4)+50;
            browserDlg.Position=position;

            set(browser,'ThisDlg',browserDlg);
        end

        browserDlg.enableApplyButton(0);
        browserDlg.show;
    end

