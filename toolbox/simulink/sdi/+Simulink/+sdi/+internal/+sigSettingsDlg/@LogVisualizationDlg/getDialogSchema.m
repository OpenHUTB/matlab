function dlg=getDialogSchema(this)



    tabContainer.Name='tabContainer';
    tabContainer.Type='tab';
    tabContainer.Tag=this.TAB_CONTAINER_TAG;


    visualizationProps=getDialogSchema@Simulink.HMI.BrowserDlg(this);
    vizualizationTab=getLoggingAndVisualizationTab(this,visualizationProps);
    tabContainer.Tabs={vizualizationTab};


    dataAccessTab=this.getDataAccessTab();
    if~isempty(dataAccessTab)
        tabContainer.Tabs{end+1}=dataAccessTab;
    end


    tolerancesTab=this.getTolerancesTab();
    if~isempty(tolerancesTab)
        tabContainer.Tabs{end+1}=tolerancesTab;
    end


    dlg.DialogTitle=visualizationProps.DialogTitle;
    dlg.Items={tabContainer};
    dlg.DialogTag=locGetDlgTag(this);

    dlg.PreApplyMethod='preApplyCB';
    dlg.PreApplyArgs={'%dialog'};
    dlg.PreApplyArgsDT={'handle'};

    dlg.PostApplyMethod='applyCB';
    dlg.PostApplyArgs={'%dialog'};
    dlg.PostApplyArgsDT={'handle'};

    dlg.CloseMethod='closeCB';
    dlg.CloseMethodArgs={'%dialog'};
    dlg.CloseMethodArgsDT={'handle'};

    dlg.HelpMethod='helpview';
    dlg.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'vis_properties_dialog'};

    dlg.StandaloneButtonSet={'OK','Cancel','Help','Apply'};
    dlg.IsScrollable=visualizationProps.IsScrollable;
    dlg.DispatcherEvents=visualizationProps.DispatcherEvents;
    dlg.ExplicitShow=visualizationProps.ExplicitShow;
    dlg.IgnoreESCClose=visualizationProps.IgnoreESCClose;
    dlg.Geometry=visualizationProps.Geometry;

    locCreateModelCloseListener(this);
end


function ret=locGetDlgTag(this)
    ret='slinstrprop';
    if~isempty(this.Context)&&this.Context{1}.portH
        hBD=bdroot(this.Context{1}.portH);
        ret=[ret,'_',get(hBD,'Name')];
    end
end


function locCreateModelCloseListener(this)
    if~isempty(this.Context)&&this.Context{1}.portH
        hBD=bdroot(this.Context{1}.portH);
        this.ModelCloseListener=Simulink.listener(...
        hBD,...
        'CloseEvent',...
        @(bd,lo)delete(this));
    end
end
