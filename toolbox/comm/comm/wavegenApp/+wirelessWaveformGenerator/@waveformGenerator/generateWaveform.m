function generateWaveform(obj,tab,visualize)




    if~obj.pInGeneration
        obj.massToolstripEnable(false);
        obj.pWaveform=[];
        obj.pThrewValidationError=false;
        refreshProperties(obj);
        if obj.pThrewValidationError
            genOutro(obj);
            return;
        end

        obj.pInGeneration=true;
        obj.pGenerateBtn.Enabled=true;
        obj.pGenerateBtn.Icon=matlab.ui.internal.toolstrip.Icon.END_24;
        obj.pGenerateBtn.Text=getString(message('comm:waveformGenerator:CancelGeneration'));
        obj.pGenerateBtn.Description=getString(message('comm:waveformGenerator:CancelGenerationTT'));
        obj.pParameters.setPanelsEnable(false);
        drawnow nocallbacks


    else
        genOutro(obj);
        if obj.useAppContainer
            obj.pProgressBar.Enabled=false;
        else
            javaMethodEDT('setVisible',obj.pProgressBar,false);
        end
        return;
    end

    if visualize
        obj.setStatus(getString(message('comm:waveformGenerator:SettingUpScopes')));
    else
        obj.hideAllScopes();
    end

    obj.setStatus(getString(message('comm:waveformGenerator:GeneratingWaveform',obj.pCurrentWaveformType)));

    try
        if~strcmp(obj.pCurrentWaveformType,'UNKNOWN')

            if obj.useAppContainer
                obj.pProgressBar.Enabled=true;
                obj.pProgressBar.Value=0;
            else
                javaMethodEDT('setValue',obj.pProgressBar,0);
                javaMethodEDT('setVisible',obj.pProgressBar,true);
            end

            waveform=obj.pParameters.CurrentDialog.generateWaveform();
            if~isempty(waveform)
                waveform=obj.pParameters.FilteringDialog.filter(waveform);
                customVisualizations(obj.pParameters.CurrentDialog);
            end

            obj.pSampleRate=getSampleRate(obj.pParameters.CurrentDialog)*double(obj.pParameters.FilteringDialog.Sps);
        end

        waveform=obj.impairWaveform(waveform,obj.pSampleRate);
    catch e
        obj.pParameters.CurrentDialog.errorFromException(e);
        genOutro(obj);
        return;
    end
    if~isempty(obj.pParameters.TxWaveformDialog)
        obj.pParameters.TxWaveformDialog.setRate(obj.pSampleRate);
    end

    obj.pWaveform=waveform;
    obj.pWaveformConfiguration=obj.pParameters.CurrentDialog.getConfigurationForSave();
    stepLen=100;
    if~isempty(waveform)
        obj.visualizeWaveform(waveform,stepLen);
    end


    obj.setStatus(getString(message('comm:waveformGenerator:GeneratedWaveform',obj.pCurrentWaveformType)));


    genOutro(obj);


    obj.pExportBtn.Enabled=true;
    obj.pExport2File.Enabled=true;
    obj.pExport2WS.Enabled=true;
    obj.pNewSessionBtn.Enabled=true;


    if obj.pImpairBtn.Value
        obj.cacheImpairments;
    end


    reset(obj);
    release(obj);

    function genOutro(obj)

        obj.pInGeneration=false;
        obj.massToolstripEnable(true);
        obj.pGenerateBtn.Icon=matlab.ui.internal.toolstrip.Icon.RUN_24;
        obj.pGenerateBtn.Text=getString(message('comm:waveformGenerator:GenerateBtn'));
        obj.pGenerateBtn.Description=getString(message('comm:waveformGenerator:GenerateTT'));
        obj.pParameters.setPanelsEnable(true);
        radioDialog=obj.pParameters.RadioDialog;
        if~isempty(radioDialog)&&(~supportScanning(radioDialog)||isConnected(radioDialog.HardwareInterface))
            obj.pTransmitBtn.Enabled=true;
            obj.pExportTxBtn.Enabled=true;
        end



