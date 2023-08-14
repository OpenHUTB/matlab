function moduloNet=elabModulo(this,topNet,blockInfo,inSignals,outSignals,rate)




    inportNames=cell(1);
    outportNames=cell(1);

    inportNames{1}='modInp';
    inDataRate=rate;
    outportNames{1}='modOut';

    uint16=pir_fixpt_t(0,16,0);


    inTypes(1)=inSignals.Type;
    outTypes(1)=outSignals.Type;

    moduloNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','moduloNet',...
    'InportNames',inportNames,...
    'InportTypes',inTypes,...
    'InportRates',inDataRate,...
    'OutportNames',outportNames,...
    'OutportTypes',outTypes...
    );

    modInp=moduloNet.PirInputSignals(1);
    modOut=moduloNet.PirOutputSignals(1);

    mod17Bit=newDataSignal(moduloNet,inTypes,'mod17Bit',rate);
    inpShifted=newDataSignal(moduloNet,inTypes,'inpShifted',rate);
    inpRem=newDataSignal(moduloNet,inTypes,'inpRem',rate);
    inpRem1=newDataSignal(moduloNet,inTypes,'inpRem1',rate);
    inpRemCompare=newControlSignal(moduloNet,'inpRemCompare',rate);
    modInp32Bit=newDataSignal(moduloNet,inTypes,'modInp32Bit',rate);
    pirelab.getDTCComp(moduloNet,modInp,modInp32Bit);
    if strcmp(blockInfo.FECFrameType,'Normal')
        N_long=newDataSignal(moduloNet,uint16,'N_long',rate);
        pirelab.getConstComp(moduloNet,N_long,2^16-1);
        inpReduced=newDataSignal(moduloNet,pir_ufixpt_t(16,0),'inpReduced',rate);
        inpSliced=newDataSignal(moduloNet,pir_ufixpt_t(16,0),'inpSliced',rate);

        pirelab.getBitSliceComp(moduloNet,modInp32Bit,inpSliced,15,0);
        pirelab.getBitShiftComp(moduloNet,modInp32Bit,inpShifted,'srl',16,0);
        pirelab.getBitSliceComp(moduloNet,inpShifted,inpReduced,15,0);
        pirelab.getAddComp(moduloNet,[inpSliced,inpReduced],inpRem,'Floor','Wrap');
        pirelab.getRelOpComp(moduloNet,[inpRem,N_long],inpRemCompare,'>');
        pirelab.getSubComp(moduloNet,[inpRem,N_long],inpRem1,'Floor','Wrap');
        pirelab.getSwitchComp(moduloNet,[inpRem,inpRem1],mod17Bit,inpRemCompare);
        modOutTemp=newDataSignal(moduloNet,uint16,'modOutTemp',rate);
        pirelab.getDTCComp(moduloNet,mod17Bit,modOutTemp);
        pirelab.getWireComp(moduloNet,modOutTemp,modOut);
    else
        N_long=newDataSignal(moduloNet,uint16,'N_long',rate);
        pirelab.getConstComp(moduloNet,N_long,2^14-1);
        inpReduced=newDataSignal(moduloNet,pir_ufixpt_t(14,0),'inpReduced',rate);
        inpSliced=newDataSignal(moduloNet,pir_ufixpt_t(14,0),'inpSliced',rate);

        pirelab.getBitSliceComp(moduloNet,modInp32Bit,inpSliced,13,0);
        pirelab.getBitShiftComp(moduloNet,modInp32Bit,inpShifted,'srl',14,0);
        pirelab.getBitSliceComp(moduloNet,inpShifted,inpReduced,13,0);
        pirelab.getAddComp(moduloNet,[inpSliced,inpReduced],inpRem,'Floor','Wrap');
        pirelab.getRelOpComp(moduloNet,[inpRem,N_long],inpRemCompare,'>');
        pirelab.getSubComp(moduloNet,[inpRem,N_long],inpRem1,'Floor','Wrap');
        pirelab.getSwitchComp(moduloNet,[inpRem,inpRem1],mod17Bit,inpRemCompare);
        modOutTemp=newDataSignal(moduloNet,pir_fixpt_t(0,16,0),'modOutTemp',rate);
        pirelab.getDTCComp(moduloNet,mod17Bit,modOutTemp);
        pirelab.getWireComp(moduloNet,modOutTemp,modOut);
    end


end

function signal=newControlSignal(topNet,name,rate)
    controlType=pir_ufixpt_t(1,0);
    signal=topNet.addSignal(controlType,name);
    signal.SimulinkRate=rate;
end

function signal=newDataSignal(topNet,inType,name,rate)
    signal=topNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end