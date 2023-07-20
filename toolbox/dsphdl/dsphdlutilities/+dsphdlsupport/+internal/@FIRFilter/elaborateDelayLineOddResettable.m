function newNet=elaborateDelayLineOddResettable(~,net,numElements,dataInType,rdAddrType)









    dataRate=net.PirInputSignals(1).SimulinkRate;

    newNet=pirelab.createNewNetwork(...
    'Network',net,...
    'Name','Addressable Delay Line',...
    'InportNames',{'dataIn','validIn','shiftEn','rdAddr','syncReset'},...
    'InportTypes',[dataInType,pir_boolean_t,pir_boolean_t,rdAddrType,pir_boolean_t],...
    'InportRates',repmat(dataRate,1,5),...
    'OutportNames',{'delayLineEnd','dataOut'},...
    'OutportTypes',[dataInType,dataInType]);

    newNet.addComment('Addressable Delay Line');





    dataIn=newNet.PirInputSignals(1);
    validIn=newNet.PirInputSignals(2);
    shiftEn=newNet.PirInputSignals(3);
    rdAddr=newNet.PirInputSignals(4);
    syncReset=newNet.PirInputSignals(5);

    delayLineEnd=newNet.PirOutputSignals(1);
    dataOut=newNet.PirOutputSignals(2);





    delayOut=dataIn;


    delayEn=validIn;
    dlyLineLen=1;
    for k=1:dlyLineLen

        idxStr=int2str(k-1);

        delayedSignals(k)=newNet.addSignal(dataIn.Type,['delayedSignals',idxStr]);%#ok<AGROW>
        pirelab.getIntDelayEnabledResettableComp(newNet,delayOut,delayedSignals(k),delayEn,syncReset,1,['delay',idxStr]);

        delayOut=delayedSignals(k);


        delayEn=shiftEn;

    end

    zeroConst=newNet.addSignal(dataIn.Type,'ZEROCONST');
    pirelab.getConstComp(newNet,zeroConst,0);
    zeroVect=[];
    for loop=1:numElements-dlyLineLen
        zeroVect=[zeroVect,zeroConst];%#ok<AGROW>
    end

    rdCompare=newNet.addSignal(pir_boolean_t,'rdCompare');
    pirelab.getCompareToValueComp(newNet,rdAddr,rdCompare,'>',0);

    switchDataOut=newNet.addSignal(dataIn.Type,'switchDataOut');

    pirelab.getSwitchComp(newNet,[delayedSignals,zeroConst],switchDataOut,rdCompare,'delaySelector');

    pirelab.getIntDelayEnabledResettableComp(newNet,switchDataOut,dataOut,'',syncReset,1,'dataOutReg');

    pirelab.getWireComp(newNet,delayOut,delayLineEnd);

end




















