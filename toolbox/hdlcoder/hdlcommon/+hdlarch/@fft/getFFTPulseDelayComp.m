function pdComp=getFFTPulseDelayComp(hN,hSignalsIn,hSignalsOut,...
    delayNumber,compName)












    thresholdSize=32;

    if(nargin<5)
        compName='shift_reg';
    end

    if delayNumber>=thresholdSize



        pdComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'InputSignals',hSignalsIn,...
        'OutputSignals',hSignalsOut,...
        'EMLFileName','hdleml_fft_pulsedelay',...
        'EMLParams',{delayNumber});
    else


        pdComp=pirelab.getIntDelayComp(hN,hSignalsIn,hSignalsOut,delayNumber,compName);
    end

