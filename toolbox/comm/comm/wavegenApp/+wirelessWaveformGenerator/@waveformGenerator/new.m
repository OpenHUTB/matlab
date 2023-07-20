function new(obj,~)



    if obj.useAppContainer
        obj.pProgressBar.Enabled=false;
    else
        javaMethodEDT('setVisible',obj.pProgressBar,false);
    end

    obj.pWaveform=[];
    obj.pSampleRate=[];

    obj.pParametersFig.Visible='on';

    restoreDefaults(obj.pParameters.CurrentDialog);
    if~isempty(obj.pParameters.GenerationDialog)
        restoreDefaults(obj.pParameters.GenerationDialog);
    end

    obj.waveformTypeChange(obj.pFirstWaveformType);

    if obj.useAppContainer
        freezeApp(obj);
    else
        obj.ToolGroup.setWaiting(true);
    end
    dialog=obj.pParameters.CurrentDialog;

    if~isempty(obj.pParameters.ModulatorDialog)
        restoreDefaults(obj.pParameters.ModulatorDialog);
    end

    if~isempty(obj.pParameters.GenerationDialog)
        restoreDefaults(obj.pParameters.GenerationDialog);
    end

    restoreDefaults(dialog);

    if~isempty(obj.pParameters.FilteringDialog)
        restoreDefaults(obj.pParameters.FilteringDialog);
    end

    if~obj.useAppContainer
        panels=obj.pParameters.CurrentDialog.getPanels();
        for idx=1:length(panels)
            set(panels(idx),'Visible','off');
            remove(obj.pParameters.Layout,idx,1);
        end
        add(obj.pParameters.Layout,dialog.getPanels,1,1,...
        'MinimumWidth',dialog.getWidth,...
        'Fill','Horizontal',...
        'MinimumHeight',dialog.getHeight,...
        'Anchor','North')
        dialog.setPanelVisible();
        dialog.layoutPanels();
    end
    obj.pParameters.CurrentDialog=dialog;

    obj.pImpairBtn.Value=false;
    if~isempty(obj.pParameters.ImpairDialog)
        if obj.useAppContainer
            impairPanel=obj.AppContainer.getPanel(getString(message('comm:waveformGenerator:ImpairmentsFig')));
            impairPanel.Opened=false;

            wavegenPanel=obj.AppContainer.getPanel(getString(message('comm:waveformGenerator:WaveformFig')));
            wavegenPanel.Collapsed=false;
        else
            obj.pImpairmentsFig.Visible='off';
        end
        obj.pParameters.ImpairDialog.restoreDefaults();
    end

    obj.pNewSessionBtn.Enabled=false;
    obj.pTransmitBtn.Enabled=false;
    obj.pExport2WS.Enabled=false;
    obj.pExport2File.Enabled=false;
    obj.pGenerateBtn.Enabled=true;
    gallery=find(obj.pWavegenTab,'waveformGallery');
    gallery.Enabled=true;

    obj.pCCDFBurstMode=false;
    obj.defaultLayout();
    clearScopes(obj);

    reset(obj);


    if obj.useAppContainer
        unfreezeApp(obj);
    else
        obj.ToolGroup.setWaiting(false);
    end