function setParametersDialog(obj,className)




    obj.setStatus(getString(message('comm:waveformGenerator:InitializingDialog')));

    if isKey(obj.pParameters.DialogsMap,className)
        dialog=obj.pParameters.DialogsMap(className);
    end
    if~isKey(obj.pParameters.DialogsMap,className)||~ishghandle(obj.pParameters.DialogsMap(className).getPanels)||~ishghandle(dialog.Figure)
        obj.pParameters.DialogsMap(className)=eval([className,'(obj.pParameters)']);
        dialog=obj.pParameters.DialogsMap(className);
    end

    if~isempty(obj.pParameters.CurrentDialog)&&~strcmp(class(obj.pParameters.CurrentDialog),class(dialog))

        outro(obj.pParameters.CurrentDialog,dialog);
    end
    obj.pParameters.CurrentDialog=dialog;

    if~obj.pParameters.FilteringDialog.keepFiltering


        obj.pParameters.FilteringDialog.FilteringDropDown={'None','Custom'};

        if ishghandle(obj.pParameters.FilteringDialog.FilteringGUI)

            if obj.useAppContainer
                obj.pParameters.FilteringDialog.FilteringGUI.Items={'None','Custom'};
                obj.pParameters.FilteringDialog.FilteringGUI.Value='None';
            else
                obj.pParameters.FilteringDialog.FilteringGUI.Value=1;
                obj.pParameters.FilteringDialog.FilteringGUI.String={'None','Custom'};
                set([obj.pParameters.FilteringDialog.getPanels,...
                obj.pParameters.FilteringDialog.TitleGUI],'Visible','on');
            end
            obj.pParameters.FilteringDialog.filteringChanged();
        end
    else

        obj.pParameters.FilteringDialog.keepFiltering=false;
    end


    obj.pPlotConstellation=dialog.constellationEnabled();
    obj.pPlotSpectrum=dialog.spectrumEnabled();
    obj.pPlotTimeScope=dialog.timeScopeEnabled();
    obj.pPlotEyeDiagram=dialog.offersEyeDiagram()&&dialog.eyeEnabled();
    obj.pPlotCCDF=dialog.offersCCDF()&&dialog.ccdfEnabled();
    obj.pCCDFBurstMode=false;
    defaultVisualLayout(obj.pParameters.CurrentDialog);

    setupDialog(obj.pParameters.CurrentDialog);


    if isKey(obj.pParameters.DialogsMap,'wirelessWaveformGenerator.transmitter.TxWaveformDialogICT')
        txDialog=obj.pParameters.DialogsMap('wirelessWaveformGenerator.transmitter.TxWaveformDialogICT');
        txDialog.TukeyWindowingLabel.Visible=~dialog.hasWindowing();
        txDialog.TukeyWindowingGUI.Visible=~dialog.hasWindowing();
    end

    if ishghandle(dialog.TitleGUI)
        dialog.TitleGUI.Visible='on';
        dialog.getPanels.Visible='on';
    end

    obj.setScopeLayout();
    if~isempty(obj.pConstellation)
        obj.pConstellation.ShowTrajectory=dialog.showConstellationTrajectory();
    end

    if ishghandle(obj.pParameters.FilteringDialog.FilteringGUI)
        obj.pParameters.FilteringDialog.layoutUIControls();
    end
    obj.pParameters.CurrentDialog.layoutPanels();

    if~isempty(obj.pParameters.ImpairDialog)&&obj.pImpairBtn.Value
        sr=obj.pParameters.CurrentDialog.getSampleRate();
        obj.pParameters.ImpairDialog.PhaseNoiseFrequencies=[0.2*sr,0.4*sr];
    end

    obj.setStatus('');