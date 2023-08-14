function newNet=elaborateDelayLineShort(~,net,numElements,dlyLineLen,dataInType,rdAddrType)









    dataRate=net.PirInputSignals(1).SimulinkRate;

    newNet=pirelab.createNewNetwork(...
    'Network',net,...
    'Name','Addressable Delay Line',...
    'InportNames',{'dataIn','wrEn','wrAddr','rdAddr','lutAddr'},...
    'InportTypes',[dataInType,pir_boolean_t,rdAddrType,rdAddrType,rdAddrType],...
    'InportRates',repmat(dataRate,1,5),...
    'OutportNames',{'delayLineEnd','dataOut'},...
    'OutportTypes',[dataInType,dataInType]);

    newNet.addComment('Addressable Delay Line');





    dataIn=newNet.PirInputSignals(1);
    wrEn=newNet.PirInputSignals(2);
    wrAddr=newNet.PirInputSignals(3);
    rdAddr=newNet.PirInputSignals(4);
    lutAddr=newNet.PirInputSignals(5);

    delayLineEnd=newNet.PirOutputSignals(1);
    dataOut=newNet.PirOutputSignals(2);




    syncReset='';


    if dlyLineLen>3
        delayedSignals=newNet.addSignal(dataIn.Type,'delayedSignals');%#ok<AGROW>
        delayedSignalsREG=newNet.addSignal(dataIn.Type,'delayedSignals');%#ok<AGROW>
        saveLast=newNet.addSignal(pir_boolean_t,'saveLast');%#ok<AGROW>
        wrEnN=newNet.addSignal(pir_boolean_t,'wrEnN');%#ok<AGROW>
        dataEndEn=newNet.addSignal(pir_boolean_t,'dataEndEn');%#ok<AGROW>
        dataEndEnS=newNet.addSignal(pir_boolean_t,'dataEndEnS');%#ok<AGROW>
        zeroSW=newNet.addSignal(pir_boolean_t,'zeroSW');%#ok<AGROW>
        zeroConst=newNet.addSignal(dataIn.Type,'zeroConst');%#ok<AGROW>
        lutAddrREG=newNet.addSignal(rdAddrType,'lutAddrREG');%#ok<AGROW>


        pirelab.getSimpleDualPortRamComp(newNet,[dataIn,wrAddr,wrEn,rdAddr],...
        delayedSignals);

        pirelab.getConstComp(newNet,zeroConst,0);
        pirelab.getIntDelayEnabledResettableComp(newNet,lutAddr,lutAddrREG,'',syncReset,1,'lutREG');
        pirelab.getCompareToValueComp(newNet,lutAddrREG,zeroSW,'>=',dlyLineLen);
        pirelab.getSwitchComp(newNet,[delayedSignals,zeroConst],dataOut,zeroSW);
        pirelab.getUnitDelayComp(newNet,delayedSignals,delayedSignalsREG);
        pirelab.getIntDelayEnabledResettableComp(newNet,delayedSignals,delayedSignalsREG,'',syncReset,numElements-dlyLineLen,'dataOutReg');
        pirelab.getRelOpComp(newNet,[wrAddr,rdAddr],saveLast,'==');
        pirelab.getIntDelayEnabledResettableComp(newNet,saveLast,dataEndEn,'','',1,'dataOutReg');
        pirelab.getLogicComp(newNet,dataEndEn,wrEnN,'not');
        pirelab.getLogicComp(newNet,[saveLast,wrEnN],dataEndEnS,'and');
        pirelab.getIntDelayEnabledResettableComp(newNet,delayedSignalsREG,delayLineEnd,dataEndEnS,syncReset,1,'dataOutReg');
    else

        syncReset='';
        delayOut=dataIn;


        delayEn=wrEn;

        for k=1:dlyLineLen

            idxStr=int2str(k-1);

            delayedSignals(k)=newNet.addSignal(dataIn.Type,['delayedSignals',idxStr]);%#ok<SAGROW>
            pirelab.getIntDelayEnabledResettableComp(newNet,delayOut,delayedSignals(k),delayEn,syncReset,1,['delay',idxStr]);

            delayOut=delayedSignals(k);


            delayEn=wrEn;

        end

        zeroConst=newNet.addSignal(dataIn.Type,'ZEROCONST');
        pirelab.getConstComp(newNet,zeroConst,0);
        zeroVect=[];
        for loop=1:numElements-dlyLineLen
            zeroVect=[zeroVect,zeroConst];%#ok<AGROW>
        end

        switchDataOut=newNet.addSignal(dataIn.Type,'switchDataOut');

        pirelab.getSwitchComp(newNet,[delayedSignals,zeroVect],switchDataOut,rdAddr,'delaySelector');

        pirelab.getIntDelayEnabledResettableComp(newNet,switchDataOut,dataOut,'',syncReset,1,'dataOutReg');

        pirelab.getWireComp(newNet,delayOut,delayLineEnd);

    end



end




















