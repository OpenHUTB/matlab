function newNet=elaborateDelayLineShortReverseResettable(~,net,numElements,dlyLineLen,dataInType,rdAddrType)









    dataRate=net.PirInputSignals(1).SimulinkRate;

    newNet=pirelab.createNewNetwork(...
    'Network',net,...
    'Name','Addressable Delay Line',...
    'InportNames',{'dataIn','wrEn','wrAddr','rdAddr','lutAddr','syncReset'},...
    'InportTypes',[dataInType,pir_boolean_t,rdAddrType,rdAddrType,rdAddrType,pir_boolean_t],...
    'InportRates',repmat(dataRate,1,6),...
    'OutportNames',{'delayLineEnd','dataOut'},...
    'OutportTypes',[dataInType,dataInType]);

    newNet.addComment('Addressable Delay Line');





    dataIn=newNet.PirInputSignals(1);
    wrEn=newNet.PirInputSignals(2);
    wrAddr=newNet.PirInputSignals(3);
    rdAddr=newNet.PirInputSignals(4);
    lutAddr=newNet.PirInputSignals(5);
    syncReset=newNet.PirInputSignals(6);

    delayLineEnd=newNet.PirOutputSignals(1);
    dataOut=newNet.PirOutputSignals(2);






    if dlyLineLen>3
        if((numElements-dlyLineLen)<=2)



            delayedSignals=newNet.addSignal(dataIn.Type,'delayedSignals');%#ok<AGROW>
            constZero=newNet.addSignal(dataIn.Type,'constZero');%#ok<AGROW>
            pirelab.getConstComp(newNet,constZero,0);
            saveLast=newNet.addSignal(pir_boolean_t,'saveLast');%#ok<AGROW>
            wrEnREG=newNet.addSignal(pir_boolean_t,'wrEnREG');%#ok<AGROW>
            wrEnN=newNet.addSignal(pir_boolean_t,'wrEnN');%#ok<AGROW>
            dataEndEn=newNet.addSignal(pir_boolean_t,'dataEndEn');%#ok<AGROW>
            dataEndEnS=newNet.addSignal(pir_boolean_t,'dataEndEnS');%#ok<AGROW>
            wrAddrREG=newNet.addSignal(rdAddrType,'wrAddrREG');%#ok<AGROW>
            rdAddrLookAhead=newNet.addSignal(rdAddrType,'rdAddrLookAhead');%#ok<AGROW>
            rdAddrShort=newNet.addSignal(rdAddrType,'rdAddrShort');%#ok<AGROW>
            LookAheadConst=newNet.addSignal(rdAddrType,'LookAhead');%#ok<AGROW>
            countReached=newNet.addSignal(pir_boolean_t,'countReached');%#ok<AGROW>
            LookAheadWrapConst=newNet.addSignal(rdAddrType,'LookAheadWrap');%#ok<AGROW>
            detectWrap=newNet.addSignal(pir_boolean_t,'detectWrap');%#ok<AGROW>


            pirelab.getConstComp(newNet,LookAheadConst,numElements-dlyLineLen-1);
            pirelab.getConstComp(newNet,LookAheadWrapConst,0);
            pirelab.getAddComp(newNet,[rdAddr,LookAheadConst],rdAddrShort);
            pirelab.getCompareToValueComp(newNet,rdAddr,detectWrap,'>',dlyLineLen);
            pirelab.getSwitchComp(newNet,[rdAddrShort,LookAheadWrapConst],rdAddrLookAhead,detectWrap);

            pirelab.getSimpleDualPortRamComp(newNet,[dataIn,wrAddr,wrEn,rdAddrLookAhead],...
            delayedSignals);

            pirelab.getIntDelayEnabledResettableComp(newNet,wrEn,wrEnREG,'',syncReset,1,'dataOutReg');


            pirelab.getCompareToValueComp(newNet,lutAddr,countReached,'>=',dlyLineLen);
            pirelab.getWireComp(newNet,[delayedSignals],dataOut);



            pirelab.getIntDelayEnabledResettableComp(newNet,wrAddr,wrAddrREG,'','',1,'dataOutReg');
            pirelab.getRelOpComp(newNet,[wrAddr,wrAddrREG],saveLast,'~=');
            pirelab.getIntDelayEnabledResettableComp(newNet,saveLast,dataEndEn,'','',1,'dataOutReg');
            pirelab.getLogicComp(newNet,dataEndEn,wrEnN,'not');
            pirelab.getLogicComp(newNet,[saveLast,wrEnN],dataEndEnS,'and');
            pirelab.getIntDelayEnabledResettableComp(newNet,delayedSignals,delayLineEnd,dataEndEnS,syncReset,1,'dataOutReg');
        else


            delayEn=wrEn;
            delayOut=dataIn;
            for k=1:dlyLineLen

                idxStr=int2str(k-1);

                delayedSignals(k)=newNet.addSignal(dataIn.Type,['delayedSignals',idxStr]);%#ok<AGROW>
                pirelab.getIntDelayEnabledResettableComp(newNet,delayOut,delayedSignals(k),delayEn,syncReset,1,['delay',idxStr]);

                delayOut=delayedSignals(k);


            end

            zeroConst=newNet.addSignal(dataIn.Type,'ZEROCONST');
            pirelab.getConstComp(newNet,zeroConst,0);
            zeroVect=[];
            for loop=1:numElements-dlyLineLen
                zeroVect=[zeroVect,zeroConst];%#ok<AGROW>
            end

            switchDataOut=newNet.addSignal(dataIn.Type,'switchDataOut');

            pirelab.getSwitchComp(newNet,fliplr([zeroVect,delayedSignals]),switchDataOut,lutAddr,'delaySelector');

            pirelab.getIntDelayEnabledResettableComp(newNet,switchDataOut,dataOut,'',syncReset,1,'dataOutReg');

            pirelab.getWireComp(newNet,delayOut,delayLineEnd);



        end

    else

        delayEn=wrEn;
        delayOut=dataIn;
        for k=1:dlyLineLen

            idxStr=int2str(k-1);

            delayedSignals(k)=newNet.addSignal(dataIn.Type,['delayedSignals',idxStr]);%#ok<AGROW>
            pirelab.getIntDelayEnabledResettableComp(newNet,delayOut,delayedSignals(k),delayEn,syncReset,1,['delay',idxStr]);

            delayOut=delayedSignals(k);


        end

        zeroConst=newNet.addSignal(dataIn.Type,'ZEROCONST');
        pirelab.getConstComp(newNet,zeroConst,0);
        zeroVect=[];
        for loop=1:numElements-dlyLineLen
            zeroVect=[zeroVect,zeroConst];%#ok<AGROW>
        end

        switchDataOut=newNet.addSignal(dataIn.Type,'switchDataOut');

        pirelab.getSwitchComp(newNet,fliplr([zeroVect,delayedSignals]),switchDataOut,rdAddr,'delaySelector');

        pirelab.getIntDelayEnabledResettableComp(newNet,switchDataOut,dataOut,'',syncReset,1,'dataOutReg');

        pirelab.getWireComp(newNet,delayOut,delayLineEnd);



    end
end
