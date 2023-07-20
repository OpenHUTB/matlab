function transmitWaveform(obj,~)




    refreshProperties(obj);
    txDialog=obj.pParameters.TxWaveformDialog;
    txDialog.interpChanged();

    if~obj.pInTransmission
        obj.pInTransmission=true;
        obj.massToolstripEnable(false);
        obj.pTransmitBtn.Enabled=true;
        obj.pTransmitBtn.Icon=matlab.ui.internal.toolstrip.Icon.END_24;
        obj.pTransmitBtn.Text=getString(message('comm:waveformGenerator:StopTransmit'));
        obj.pTransmitBtn.Description=getString(message('comm:waveformGenerator:StopTransmissionTT'));
        obj.pParameters.setPanelsEnable(false);
        if obj.useAppContainer
            obj.pProgressBar.Indeterminate=true;
        else
            javaMethodEDT('setIndeterminate',obj.pProgressBar,true);
        end
drawnow
    else
        obj.pParameters.RadioDialog.stopTransmission();
        txOutro(obj);
        return;
    end

    if obj.useAppContainer
        obj.pProgressBar.Enabled=true;
        obj.pProgressBar.Value=0;
    else
        javaMethodEDT('setValue',obj.pProgressBar,0);
        javaMethodEDT('setVisible',obj.pProgressBar,true);
    end


    obj.setStatus(getString(message('comm:waveformGenerator:SettingUpTx')));


    waveform=obj.pWaveform;


    obj.setStatus(getString(message('comm:waveformGenerator:PreparingTransmitter',obj.pCurrentHWType)));

    try
        obj.pParameters.RadioDialog.transmitWaveform(waveform);
    catch exc
        obj.setStatus(getString(message('comm:waveformGenerator:TransmissionFailed')));
        uiwait(errordlg(exc.message,getString(message('comm:waveformGenerator:DialogTitle')),'modal'));
        txOutro(obj);
        return;
    end
end

function txOutro(obj)

    obj.pInTransmission=false;
    obj.massToolstripEnable(true);
    obj.pTransmitBtn.Icon=matlab.ui.internal.toolstrip.Icon.RUN_24;
    obj.pTransmitBtn.Text=getString(message('comm:waveformGenerator:TransmitBtn'));
    obj.pTransmitBtn.Description=getString(message('comm:waveformGenerator:TransmitTT'));
    obj.setStatus(getString(message('comm:waveformGenerator:TransmissionStopped')));
    obj.pParameters.setPanelsEnable(true);
    if obj.useAppContainer
        obj.pProgressBar.Indeterminate=false;
        obj.pProgressBar.Enabled=false;
    else
        javaMethodEDT('setVisible',obj.pProgressBar,false);
        javaMethodEDT('setIndeterminate',obj.pProgressBar,false);
    end

end