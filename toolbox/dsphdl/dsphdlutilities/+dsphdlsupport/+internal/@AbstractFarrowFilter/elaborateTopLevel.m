function newNet=elaborateTopLevel(this,hN,hC,blockInfo)








    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');
    booleanT=pir_boolean_t();
    if blockInfo.ResetInputPort&&strcmpi(blockInfo.Mode,'Input port')
        inportNames={'dataIn','validIn','rate','syncReset'};
    elseif blockInfo.ResetInputPort
        inportNames={'dataIn','validIn','syncReset'};
    elseif strcmpi(blockInfo.Mode,'Input port')
        inportNames={'dataIn','validIn','rate'};
    else
        inportNames={'dataIn','validIn'};
    end

    outportNames={'dataOut','validOut'};
    if length(hC.PirOutputPorts)==3
        outportNames={'dataOut','validOut','ready'};
    end

    newNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportNames,...
    'OutportNames',outportNames);





    dataIn=newNet.PirInputSignals(1);
    validIn=newNet.PirInputSignals(2);

    if strcmpi(blockInfo.Mode,'Input port')
        rate=newNet.PirInputSignals(3);
        rateChange=newNet.addSignal(blockInfo.FractionalDelayDataType,'rateChange');
        pirelab.getDTCComp(newNet,rate,rateChange);
    end

    dataRate=dataIn.simulinkRate;
    dinType=pirgetdatatypeinfo(dataIn.Type);
    isInputComplex=dinType.iscomplex;

    if blockInfo.inResetSS
        newNet.setTreatNetworkAsResettableBlock;
    end

    if blockInfo.ResetInputPort&&~blockInfo.inResetSS
        if strcmpi(blockInfo.Mode,'Property')
            syncReset=newNet.PirInputSignals(3);
        else
            syncReset=newNet.PirInputSignals(4);
        end
    else
        syncReset=newNet.addSignal2('Type',booleanT,'Name','syncReset');
        syncReset.SimulinkRate=dataRate;

        if blockInfo.inResetSS


            syncReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
            blockInfo.ResetInputPort=true;
        else


            pirelab.getConstComp(newNet,syncReset,0);
        end
    end



    dataOut=newNet.PirOutputSignals(1);
    validOut=newNet.PirOutputSignals(2);
    if length(newNet.PirOutputSignals)>2
        ready=newNet.PirOutputSignals(3);
    else

        ready=newNet.addSignal(pir_boolean_t,'ready');
        ready.SimulinkRate=dataRate;
    end






    inputRate=dataIn.SimulinkRate;
    dataOut.SimulinkRate=inputRate;
    validOut.SimulinkRate=inputRate;
    ready.SimulinkRate=inputRate;


    inSignals=[dataIn,validIn];




    filterVecType=pirelab.getPirVectorType(blockInfo.FIROutputype,blockInfo.FilterOrder);
    blockInfo.filterVecType=filterVecType;

    firBlockInfo.inType=dataIn.Type;
    firBlockInfo.FIRFilterType=blockInfo.FIRFilterType;
    firBlockInfo.baseRate=inputRate;

    if blockInfo.NumCycles==1
        firBlockInfo.FilterStructure=blockInfo.FilterStructure;
    else
        firBlockInfo.FilterStructure='Partly serial systolic';
    end

    firBlockInfo.ResetInputPort=blockInfo.ResetInputPort;
    firBlockInfo.HDLGlobalReset=blockInfo.HDLGlobalReset;
    firBlockInfo.RoundingMethod=blockInfo.RoundingMethod;
    firBlockInfo.OverflowAction=blockInfo.OverflowAction;
    firBlockInfo.CoefficientsDataType=blockInfo.CoefficientsDataType;
    firBlockInfo.OutputDataType='Full precision';
    firBlockInfo.Mode=blockInfo.Mode;
    firBlockInfo.NumeratorSource='Property';
    firBlockInfo.inMode=blockInfo.inMode;
    firBlockInfo.inResetSS=false;
    firBlockInfo.CompiledInputDT=resolveDT(hC,'SysObj');
    firBlockInfo.CompiledInputSize=getVecSize(hC.PirInputSignal(1));
    firBlockInfo.XILINX_MAXOUTPUT_WORDLENGTH=48;
    firBlockInfo.ALTERA_MAXOUTPUT_WORDLENGTH=44;
    firBlockInfo.DELAYLINELIMIT2MAP2RAM=64;
    firBlockInfo.SymmetryOptimization=blockInfo.SymmetryOptimization;
    firBlockInfo.NumCycles=blockInfo.NumCycles;
    firBlockInfo.SerializationOption='Minimum number of cycles between valid input samples';
    sFactor=blockInfo.NumCycles;


    for ii=1:1:blockInfo.FilterOrder
        firBlockInfo.Numerator=blockInfo.Numerator(:,ii)';
        if isinf(sFactor)||sFactor>=length(firBlockInfo.Numerator)
            firBlockInfo.SharingFactor=length(firBlockInfo.Numerator);
        else
            firBlockInfo.SharingFactor=sFactor;
        end


        inputWL=newNet.PirInputSignals(1).Type.BaseType.BaseType.WordLength;

        if isnumerictype(blockInfo.CoefficientsDataType)
            coeffsNumerictype=blockInfo.CoefficientsDataType;
        else
            coeffsNumerictype=numerictype([],inputWL);
        end


        firBlockInfo.NumeratorQuantized=fi(blockInfo.Numerator(:,ii)',coeffsNumerictype,'OverflowAction','Saturate','RoundingMethod','Nearest');


        filterNet{ii}=createFilter(newNet,num2str(ii),firBlockInfo,ii);

        filtOut(ii)=newNet.addSignal2('Type',blockInfo.FIRFilterType(ii),'Name',['FIROutput',num2str(ii)]);
        filtValidOut(ii)=newNet.addSignal2('Type',booleanT,'Name',['FIRValid',num2str(ii)]);

        if blockInfo.ResetInputPort||blockInfo.inResetSS
            if blockInfo.NumCycles==1
                pirelab.instantiateNetwork(newNet,filterNet{ii},[dataIn,validIn,syncReset],...
                [filtOut(ii),filtValidOut(ii)],...
                'filterInstantiation');
            else
                filtReadyOut(ii)=newNet.addSignal2('Type',booleanT,'Name',['FIRReady',num2str(ii)]);
                pirelab.instantiateNetwork(newNet,filterNet{ii},[dataIn,validIn,syncReset],...
                [filtOut(ii),filtValidOut(ii),filtReadyOut(ii)],...
                'filterInstantiation');
            end
        else
            if blockInfo.NumCycles==1
                pirelab.instantiateNetwork(newNet,filterNet{ii},[dataIn,validIn],...
                [filtOut(ii),filtValidOut(ii)],...
                'filterInstantiation');
            else
                filtReadyOut(ii)=newNet.addSignal2('Type',booleanT,'Name',['FIRReady',num2str(ii)]);
                pirelab.instantiateNetwork(newNet,filterNet{ii},[dataIn,validIn],...
                [filtOut(ii),filtValidOut(ii),filtReadyOut(ii)],...
                'filterInstantiation');
            end
        end

        filtCast(ii)=newNet.addSignal2('Type',blockInfo.FIROutputype,'Name',['FIROutputCast',num2str(ii)]);
        filtCastDB(ii)=newNet.addSignal2('Type',blockInfo.FIROutputype,'Name',['FIROutputCastDB',num2str(ii)]);

        pirelab.getDTCComp(newNet,filtOut(ii),filtCast(ii));


        if blockInfo.NumCycles==1
            if blockInfo.FIRDelay(ii)==0
                pirelab.getWireComp(newNet,filtCast(ii),filtCastDB(ii));
            else
                pirelab.getIntDelayEnabledResettableComp(newNet,filtCast(ii),filtCastDB(ii),filtValidOut(ii),syncReset,blockInfo.FIRDelay(ii));
            end

        else

            if blockInfo.FIRDelay(ii)>1
                validPipeline(ii)=newNet.addSignal2('Type',booleanT,'Name',['ValidPipeline',num2str(ii)]);
                filtCastDBP(ii)=newNet.addSignal2('Type',blockInfo.FIROutputype,'Name',['FIROutputCastDBP',num2str(ii)]);
                pirelab.getIntDelayEnabledResettableComp(newNet,filtCast(ii),filtCastDBP(ii),'',syncReset,blockInfo.FIRDelay(ii)-1);
                pirelab.getIntDelayEnabledResettableComp(newNet,filtValidOut(ii),validPipeline(ii),'',syncReset,blockInfo.FIRDelay(ii)-1);
                pirelab.getIntDelayEnabledResettableComp(newNet,filtCastDBP(ii),filtCastDB(ii),validPipeline(ii),syncReset,1);
            else
                pirelab.getIntDelayEnabledResettableComp(newNet,filtCast(ii),filtCastDB(ii),filtValidOut(ii),syncReset,1);
            end



        end

    end




    filterVec=newNet.addSignal2('Type',filterVecType,'Name','FIRVector');
    filterVecREG=newNet.addSignal2('Type',filterVecType,'Name','FIRVector');
    pirelab.getConcatenateComp(newNet,filtCastDB,filterVec,'Multidimensional array','1');
    if blockInfo.NumCycles==1

        pirelab.getUnitDelayComp(newNet,filterVec,filterVecREG);
    else
        pirelab.getWireComp(newNet,filterVec,filterVecREG);

    end



    sigInfo.booleanT=booleanT;
    sigInfo.filterVecType=filterVecType;
    countType=pir_fixpt_t(0,4,0);
    readySC=newNet.addSignal2('Type',booleanT,'Name','READYsc');
    readyOut=newNet.addSignal2('Type',booleanT,'Name','readyOut');
    readyFilt=newNet.addSignal2('Type',booleanT,'Name','readyFilt');
    readyREG=newNet.addSignal2('Type',booleanT,'Name','readyREG');
    nextSampleSC=newNet.addSignal2('Type',booleanT,'Name','nextSampleSC');
    nextSampleREG=newNet.addSignal2('Type',booleanT,'Name','nextSampleREG');
    interpSC=newNet.addSignal2('Type',booleanT,'Name','interpSC');
    readyForSample=newNet.addSignal2('Type',booleanT,'Name','readyForSample');


    NewSample=newNet.addSignal2('Type',filterVecType,'Name','NewSample');
    NewValid=newNet.addSignal2('Type',booleanT,'Name','NewValid');
    FilterValidREG=newNet.addSignal2('Type',booleanT,'Name','FilterValidREG');
    SampleCount=newNet.addSignal2('Type',countType,'Name','SampleCount');

    pirelab.getIntDelayEnabledResettableComp(newNet,filtValidOut(blockInfo.FIRMaxDelay),FilterValidREG,'',syncReset,1);
    pirelab.getIntDelayEnabledResettableComp(newNet,nextSampleSC,nextSampleREG,'',syncReset,1);


    sampleBufferNet=this.elaborateSampleBuffer(newNet,blockInfo,sigInfo,inputRate);



    if blockInfo.ResetInputPort
        pirelab.instantiateNetwork(newNet,sampleBufferNet,[filterVecREG,FilterValidREG,nextSampleREG,readyForSample,interpSC,syncReset],...
        [NewSample,NewValid,SampleCount],...
        'SampleBufferInst');
    else
        pirelab.instantiateNetwork(newNet,sampleBufferNet,[filterVecREG,FilterValidREG,nextSampleREG,readyForSample,interpSC],...
        [NewSample,NewValid,SampleCount],...
        'SampleBufferInst');
    end




    filterVecSCREG=newNet.addSignal2('Type',filterVecType,'Name','FIRVectorSCREG');
    fracDelaySCREG=newNet.addSignal2('Type',blockInfo.FractionalDelayDataType,'Name','FracDelaySCREG');
    filterVecSC=newNet.addSignal2('Type',filterVecType,'Name','FIRVectorSC');
    fracDelaySC=newNet.addSignal2('Type',blockInfo.FractionalDelayDataType,'Name','FracDelaySC');
    validSCREG=newNet.addSignal2('Type',booleanT,'Name','validSCREG');
    validSC=newNet.addSignal2('Type',booleanT,'Name','validSC');



    sampleControlNet=this.elaborateSampleController(newNet,blockInfo,sigInfo,inputRate);




    if blockInfo.ResetInputPort
        if strcmpi(blockInfo.Mode,'Property')
            pirelab.instantiateNetwork(newNet,sampleControlNet,[NewSample,NewValid,SampleCount,syncReset],...
            [filterVecSC,fracDelaySC,validSC,readySC,nextSampleSC,interpSC,readyForSample],...
            'SampleControllerInst');
        else
            pirelab.instantiateNetwork(newNet,sampleControlNet,[NewSample,NewValid,SampleCount,rateChange,syncReset],...
            [filterVecSC,fracDelaySC,validSC,readySC,nextSampleSC,interpSC,readyForSample],...
            'SampleControllerInst');
        end
    else
        if strcmpi(blockInfo.Mode,'Property')
            pirelab.instantiateNetwork(newNet,sampleControlNet,[NewSample,NewValid,SampleCount],...
            [filterVecSC,fracDelaySC,validSC,readySC,nextSampleSC,interpSC,readyForSample],...
            'SampleControllerInst');
        else
            pirelab.instantiateNetwork(newNet,sampleControlNet,[NewSample,NewValid,SampleCount,rateChange],...
            [filterVecSC,fracDelaySC,validSC,readySC,nextSampleSC,interpSC,readyForSample],...
            'SampleControllerInst');
        end
    end

    syncResetN=newNet.addSignal2('Type',booleanT,'Name','syncResetN');

    if blockInfo.NumCycles==1
        pirelab.getUnitDelayComp(newNet,readyFilt,readyREG,'readyREG',0);
        pirelab.getLogicComp(newNet,syncReset,syncResetN,'not');
        pirelab.getLogicComp(newNet,[readySC,syncResetN],readyOut,'and');
        pirelab.getLogicComp(newNet,readyOut,readyFilt,'not');
        pirelab.getLogicComp(newNet,readyREG,ready,'not');
    else
        readyREGNot=newNet.addSignal2('Type',booleanT,'Name','readyREGNot');
        readyREGP=newNet.addSignal2('Type',booleanT,'Name','readyREGP');
        pirelab.getUnitDelayComp(newNet,readyFilt,readyREG,'readyREG',0);
        pirelab.getLogicComp(newNet,[readySC,syncReset],readyOut,'or');
        pirelab.getLogicComp(newNet,readyOut,readyFilt,'not');
        pirelab.getLogicComp(newNet,readyREG,readyREGNot,'not');
        pirelab.getLogicComp(newNet,[readyREGNot,filtReadyOut(blockInfo.FIRMaxDelay)],readyREGP,'and');
        pirelab.getWireComp(newNet,readyREGP,ready);


    end



    sumProductNet=this.elaborateSumProductChain(newNet,blockInfo,sigInfo,inputRate);


    sumProdDataOut=newNet.addSignal2('Type',blockInfo.OutputDataType,'Name','SumProdDataOut');
    sumProdValidOut=newNet.addSignal2('Type',booleanT,'Name','SumProdValidOut');

    pirelab.getWireComp(newNet,filterVecSC,filterVecSCREG);

    if blockInfo.ResetInputPort
        pirelab.getUnitDelayEnabledResettableComp(newNet,validSC,validSCREG,'',syncReset,'validSCREG',0,'',true','',-1,true);
    else
        pirelab.getUnitDelayComp(newNet,validSC,validSCREG);
    end
    pirelab.getUnitDelayComp(newNet,fracDelaySC,fracDelaySCREG);

    if blockInfo.ResetInputPort
        pirelab.instantiateNetwork(newNet,sumProductNet,[filterVecSCREG,validSCREG,fracDelaySCREG,syncReset],...
        [sumProdDataOut,sumProdValidOut],...
        'SumProductNet');
    else
        pirelab.instantiateNetwork(newNet,sumProductNet,[filterVecSCREG,validSCREG,fracDelaySCREG],...
        [sumProdDataOut,sumProdValidOut],...
        'SumProductNet');
    end




    if blockInfo.ResetInputPort
        pirelab.getUnitDelayEnabledResettableComp(newNet,sumProdDataOut,dataOut,'',syncReset,'DataOutREG',0,'',true','',-1,true);
        pirelab.getUnitDelayEnabledResettableComp(newNet,sumProdValidOut,validOut,'',syncReset,'ValidOutREG',0,'',true','',-1,true);
    else
        pirelab.getUnitDelayComp(newNet,sumProdDataOut,dataOut);
        pirelab.getUnitDelayComp(newNet,sumProdValidOut,validOut);

    end
end








function pirt=numerictype2pirtype(nt)

    pirt=pir_fixpt_t(nt.SignednessBool,nt.WordLength,-nt.FractionLength);
end

function filterNet=createFilter(topNet,name,blockInfo,ii)
    ctrlType=pir_boolean_t();
    if blockInfo.ResetInputPort
        if blockInfo.NumCycles==1
            REFNet=pirelab.createNewNetwork(...
            'Network',topNet,...
            'Name',['FIRFilter',name],...
            'InportNames',{[name,'In'],'valid','syncReset'},...
            'InportTypes',[blockInfo.inType,ctrlType,ctrlType],...
            'InportRates',[blockInfo.baseRate,blockInfo.baseRate,blockInfo.baseRate],...
            'OutportNames',{['filter',name,'out'],'validOut'},...
            'OutportTypes',[blockInfo.FIRFilterType{ii},ctrlType]);
        else
            REFNet=pirelab.createNewNetwork(...
            'Network',topNet,...
            'Name',['FIRFilter',name],...
            'InportNames',{[name,'In'],'valid','syncReset'},...
            'InportTypes',[blockInfo.inType,ctrlType,ctrlType],...
            'InportRates',[blockInfo.baseRate,blockInfo.baseRate,blockInfo.baseRate],...
            'OutportNames',{['filter',name,'out'],'validOut','readyOut'},...
            'OutportTypes',[blockInfo.FIRFilterType{ii},ctrlType,ctrlType]);
        end
    else
        if blockInfo.NumCycles==1
            REFNet=pirelab.createNewNetwork(...
            'Network',topNet,...
            'Name',['FIRFilter',name],...
            'InportNames',{[name,'In'],'valid'},...
            'InportTypes',[blockInfo.inType,ctrlType],...
            'InportRates',[blockInfo.baseRate,blockInfo.baseRate],...
            'OutportNames',{['filter',name,'out'],'validOut'},...
            'OutportTypes',[blockInfo.FIRFilterType{ii},ctrlType]);
        else
            REFNet=pirelab.createNewNetwork(...
            'Network',topNet,...
            'Name',['FIRFilter',name],...
            'InportNames',{[name,'In'],'valid'},...
            'InportTypes',[blockInfo.inType,ctrlType],...
            'InportRates',[blockInfo.baseRate,blockInfo.baseRate],...
            'OutportNames',{['filter',name,'out'],'validOut','readyOut'},...
            'OutportTypes',[blockInfo.FIRFilterType{ii},ctrlType,ctrlType]);
        end
    end

    REFNet.addComment(['FIR Filter',name]);



    this=dsphdlsupport.internal.FIRFilter;
    filterNet=elaborateTopLevel(this,topNet,REFNet,blockInfo);
end


function DT=resolveDT(DT,Mode)
    if strcmpi(Mode,'block')
        DT=hdlgetallfromsltype(DT);
        DT=numerictype(DT.signed,DT.size,DT.bp);
    else
        DT=DT.PirInputSignals(1).Type.BaseType;
        DT=numerictype(DT.Signed,DT.WordLength,-DT.FractionLength);
    end
end


function vecSize=getVecSize(dataIn)
    dInType=pirgetdatatypeinfo(dataIn.Type);
    vecSize=dInType.dims;
end
