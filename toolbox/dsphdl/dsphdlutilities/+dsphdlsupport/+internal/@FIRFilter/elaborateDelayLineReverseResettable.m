function newNet=elaborateDelayLineReverseResettable(~,net,numElements,oddSymm,numMults,dataInType,rdAddrType)









    dataRate=net.PirInputSignals(1).SimulinkRate;

    newNet=pirelab.createNewNetwork(...
    'Network',net,...
    'Name','Addressable Delay Line',...
    'InportNames',{'dataIn','wrEn','wrAddr','rdAddr','syncReset'},...
    'InportTypes',[dataInType,pir_boolean_t,rdAddrType,rdAddrType,pir_boolean_t],...
    'InportRates',repmat(dataRate,1,5),...
    'OutportNames',{'delayLineEnd','dataOut'},...
    'OutportTypes',[dataInType,dataInType]);

    newNet.addComment('Addressable Delay Line');





    dataIn=newNet.PirInputSignals(1);
    wrEn=newNet.PirInputSignals(2);
    wrAddr=newNet.PirInputSignals(3);
    rdAddr=newNet.PirInputSignals(4);
    syncReset=newNet.PirInputSignals(5);

    delayLineEnd=newNet.PirOutputSignals(1);
    dataOut=newNet.PirOutputSignals(2);








    delayedSignals=newNet.addSignal(dataIn.Type,'delayedSignals');%#ok<AGROW>
    constZero=newNet.addSignal(dataIn.Type,'constZero');%#ok<AGROW>
    pirelab.getConstComp(newNet,constZero,0);
    saveLast=newNet.addSignal(pir_boolean_t,'saveLast');%#ok<AGROW>
    wrEnREG=newNet.addSignal(pir_boolean_t,'wrEnREG');%#ok<AGROW>
    wrEnN=newNet.addSignal(pir_boolean_t,'wrEnN');%#ok<AGROW>
    dataEndEn=newNet.addSignal(pir_boolean_t,'dataEndEn');%#ok<AGROW>
    dataEndEnS=newNet.addSignal(pir_boolean_t,'dataEndEnS');%#ok<AGROW>
    wrAddrREG=newNet.addSignal(rdAddrType,'wrAddrREG');%#ok<AGROW>


    if numElements>3
        pirelab.getSimpleDualPortRamComp(newNet,[dataIn,wrAddr,wrEn,rdAddr],...
        delayedSignals);

        pirelab.getIntDelayEnabledResettableComp(newNet,wrEn,wrEnREG,'',syncReset,1,'dataOutReg');


        if oddSymm&&numMults==1
            pirelab.getSwitchComp(newNet,[delayedSignals,constZero],dataOut,wrEnREG,'delaySelector');
        else
            pirelab.getUnitDelayComp(newNet,delayedSignals,dataOut);
        end


        pirelab.getIntDelayEnabledResettableComp(newNet,wrAddr,wrAddrREG,'','',1,'dataOutReg');
        pirelab.getRelOpComp(newNet,[wrAddr,wrAddrREG],saveLast,'~=');
        pirelab.getIntDelayEnabledResettableComp(newNet,saveLast,dataEndEn,'','',1,'dataOutReg');
        pirelab.getLogicComp(newNet,dataEndEn,wrEnN,'not');
        pirelab.getLogicComp(newNet,[saveLast,wrEnN],dataEndEnS,'and');
        pirelab.getIntDelayEnabledResettableComp(newNet,delayedSignals,delayLineEnd,dataEndEnS,syncReset,2,'dataOutReg');

    else


        delayEn=wrEn;
        delayOut=dataIn;
        for k=1:numElements

            idxStr=int2str(k-1);

            delayedSignals(k)=newNet.addSignal(dataIn.Type,['delayedSignals',idxStr]);%#ok<AGROW>
            pirelab.getIntDelayEnabledResettableComp(newNet,delayOut,delayedSignals(k),delayEn,syncReset,1,['delay',idxStr]);

            delayOut=delayedSignals(k);


        end


        switchDataOut=newNet.addSignal(dataIn.Type,'switchDataOut');

        pirelab.getSwitchComp(newNet,fliplr(delayedSignals),switchDataOut,rdAddr,'delaySelector');

        pirelab.getIntDelayEnabledResettableComp(newNet,switchDataOut,dataOut,'',syncReset,1,'dataOutReg');

        pirelab.getWireComp(newNet,delayOut,delayLineEnd);



    end

end


















