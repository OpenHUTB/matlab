function newNet=elaborateDelayLine(~,net,numElements,dataInType,rdAddrType,params)









    dataRate=net.PirInputSignals(1).SimulinkRate;

    newNet=pirelab.createNewNetwork(...
    'Network',net,...
    'Name','Addressable Delay Line',...
    'InportNames',{'dataIn','wrEn','wrAddr','rdAddr'},...
    'InportTypes',[dataInType,pir_boolean_t,rdAddrType,rdAddrType],...
    'InportRates',repmat(dataRate,1,4),...
    'OutportNames',{'delayLineEnd','dataOut'},...
    'OutportTypes',[dataInType,dataInType]);

    newNet.addComment('Addressable Delay Line');





    dataIn=newNet.PirInputSignals(1);
    wrEn=newNet.PirInputSignals(2);
    wrAddr=newNet.PirInputSignals(3);
    rdAddr=newNet.PirInputSignals(4);

    delayLineEnd=newNet.PirOutputSignals(1);
    dataOut=newNet.PirOutputSignals(2);




    syncReset='';



    delayedSignals=newNet.addSignal(dataIn.Type,'delayedSignals');%#ok<AGROW>
    saveLast=newNet.addSignal(pir_boolean_t,'saveLast');%#ok<AGROW>
    wrEnN=newNet.addSignal(pir_boolean_t,'wrEnN');%#ok<AGROW>
    dataEndEn=newNet.addSignal(pir_boolean_t,'dataEndEn');%#ok<AGROW>
    dataEndEnS=newNet.addSignal(pir_boolean_t,'dataEndEnS');%#ok<AGROW>

    if numElements>2
        pirelab.getSimpleDualPortRamComp(newNet,[dataIn,wrAddr,wrEn,rdAddr],...
        delayedSignals);
        pirelab.getWireComp(newNet,delayedSignals,dataOut);
        pirelab.getRelOpComp(newNet,[wrAddr,rdAddr],saveLast,'==');
        pirelab.getIntDelayEnabledResettableComp(newNet,saveLast,dataEndEn,'',syncReset,1,'dataOutReg');
        pirelab.getLogicComp(newNet,dataEndEn,wrEnN,'not');
        pirelab.getLogicComp(newNet,[saveLast,wrEnN],dataEndEnS,'and');
        pirelab.getIntDelayEnabledResettableComp(newNet,delayedSignals,delayLineEnd,dataEndEnS,syncReset,1,'dataOutReg');
    else

        delayOut=dataIn;


        delayEn=wrEn;

        for k=1:numElements

            idxStr=int2str(k-1);

            delayedSignals(k)=newNet.addSignal(dataIn.Type,['delayedSignals',idxStr]);%#ok<SAGROW>
            pirelab.getIntDelayEnabledResettableComp(newNet,delayOut,delayedSignals(k),delayEn,syncReset,1,['delay',idxStr]);

            delayOut=delayedSignals(k);


            delayEn=wrEn;

        end



        switchDataOut=newNet.addSignal(dataIn.Type,'switchDataOut');

        pirelab.getSwitchComp(newNet,delayedSignals,switchDataOut,rdAddr,'delaySelector');

        pirelab.getIntDelayEnabledResettableComp(newNet,switchDataOut,dataOut,'',syncReset,1,'dataOutReg');

        pirelab.getWireComp(newNet,delayOut,delayLineEnd);
    end





end



