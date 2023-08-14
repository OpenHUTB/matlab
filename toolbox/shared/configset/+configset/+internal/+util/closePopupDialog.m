function closePopupDialog(hDlg,hController,page)





    hSrc=hController.getSourceObject;

    hConfigSet=hSrc.getConfigSet;
    if~isempty(hConfigSet)
        dialogCS=hConfigSet.getConfigSetSource.getDialogController;
        dialogCS.HighlightedWidgets={};
        dialogCS.PanesToExpand={};
    end

    if isempty(page)||isequal(page,'Optimization')
        if isa(hSrc,'Simulink.OptimizationCC')
            optCC=hSrc;
        elseif isa(hConfigSet,'Simulink.ConfigSetRoot')
            optCC=hConfigSet.getComponent('Optimization');
        else
            optCC=[];
        end
        if~isempty(optCC)
            config_dlg_configure_param('ParentClose',hDlg,optCC);
        end
    end

    if isempty(page)||isequal(page,'RTW')
        browser=hController.TLCBrowser;
        if isempty(browser)
            if~isempty(hConfigSet)
                hCSController=getDialogController(hConfigSet);
                browser=hCSController.TLCBrowser;
            end
        end
        if~isempty(browser)&&isa(browser,'RTW.TargetBrowser')
            browserDlg=get(browser,'ThisDlg');
            if~isempty(browserDlg)&&isa(browserDlg,'DAStudio.Dialog')
                browserDlg.connect([],'up');
                delete(browserDlg);
                set(browser,'ThisDlg',[]);
            end
            browser.delete;
        end
        hController.TLCBrowser=[];
        if isa(hSrc,'Simulink.BaseConfig')
            coder.internal.configDlgBlk2CodeConf('ParentClose',hDlg,hSrc);
            coder.internal.configDlgCodeCoverageConf('ParentClose',hDlg,hSrc);
        end

        loc_clearModelSelectorObjects(hController);
    end

    if~isempty(hConfigSet)
        slcovcc=hConfigSet.getComponent('Simulink Coverage');
    elseif isa(hSrc,'SlCovCC.ConfigComp')
        slcovcc=hSrc;
    else
        slcovcc=[];
    end
    if~isempty(slcovcc)
        slcovcc.parentCloseCallback();
    end

    function loc_clearModelSelectorObjects(hController)

        for idx=1:length(hController.ModelSelectorObjs)
            delete(hController.ModelSelectorObjs{idx});
        end
        hController.ModelSelectorObjs={};


