function setRadioDialog(obj,txName)




    obj.setStatus(getString(message('comm:waveformGenerator:InitializingDialog')));

    classPrefix='wirelessWaveformGenerator.transmitter.';
    switch txName
    case 'Instrument'
        classNameHW='InstrumentDialog';
        classNameWave='TxWaveformDialogICT';
    case 'Wireless Testbench'
        classNameHW='WTDialog';
        classNameWave='TxWaveformDialogWT';
    case 'Pluto'
        classNameHW='PlutoDialog';
        classNameWave='TxWaveformDialogPluto';
    case 'USRP B/N/X'
        classNameHW='USRPDialog';
        classNameWave='TxWaveformDialogUSRP';
    case 'USRP E'
        classNameHW='USRPEDialog';
        classNameWave='TxWaveformDialogSDR';
    case 'Zynq Based'
        classNameHW='ZynqDialog';
        classNameWave='TxWaveformDialogSDR';
    end

    classNameHW=[classPrefix,classNameHW];
    classNameWave=[classPrefix,classNameWave];

    if~isKey(obj.pParameters.DialogsMap,classNameHW)
        obj.pParameters.DialogsMap(classNameHW)=eval([classNameHW,'(obj.pParameters, obj.pRadioFig)']);
    end
    if~isKey(obj.pParameters.DialogsMap,classNameWave)
        obj.pParameters.DialogsMap(classNameWave)=eval([classNameWave,'(obj.pParameters, obj.pRadioFig)']);
    end

    radioDialog=obj.pParameters.DialogsMap(classNameHW);
    txWaveDialog=obj.pParameters.DialogsMap(classNameWave);
    obj.pParameters.RadioDialog=radioDialog;
    obj.pParameters.TxWaveformDialog=txWaveDialog;

    updateOutputFromRadio=~any(strcmp(txName,{'USRP E','Zynq Based'}));


    obj.pParameters.TxWaveformDialog.setRate(obj.pSampleRate,updateOutputFromRadio);

    obj.pSearchHWBtn.Enabled=supportScanning(radioDialog);
    if strcmp(txName,'USRP E')
        radioDialog.setTitle(getString(message('comm:waveformGenerator:USRPETitle')));
    elseif strcmp(txName,'Zynq Based')
        radioDialog.setTitle(getString(message('comm:waveformGenerator:ZynqTitle')));
    end
    setupDialog(radioDialog);
    txWaveDialog=obj.pParameters.DialogsMap(classNameWave);
    layoutUIControls(txWaveDialog);
    layoutPanels(radioDialog);

    obj.setStatus('');