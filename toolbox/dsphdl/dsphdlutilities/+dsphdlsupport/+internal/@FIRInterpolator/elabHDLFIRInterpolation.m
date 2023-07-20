function elabHDLFIRInterpolation(this,FIRInterpImpl,blockInfo,hN)






    insignals=FIRInterpImpl.PirInputSignals;
    outsignals=FIRInterpImpl.PirOutputSignals;
    booleanT=pir_boolean_t;

    [FilterIn_DT,FilterOut_FPDT]=getFilterOutDT(this,blockInfo);

    dataIn=insignals(1);
    validIn=insignals(2);
    dataRate=dataIn.simulinkRate;
    dataInType=pirgetdatatypeinfo(dataIn.Type);
    DATAIN_VECSIZE=dataInType.dims;
    DATAIN_ISCOMPLEX=dataInType.iscomplex;

    dataOut=outsignals(1);
    validOut=outsignals(2);
    readyOut=outsignals(3);

    dataOutType=pirgetdatatypeinfo(dataOut.Type);
    DATAOUT_VECSIZE=dataOutType.dims;
    DATAOUT_ISCOMPLEX=dataOutType.iscomplex;

    filterOutType_cmplx=hdlcoder.tp_complex(FilterOut_FPDT);
    filterInType_cmplx=hdlcoder.tp_complex(FilterIn_DT);





    if blockInfo.inMode(2)
        syncReset=insignals(3);
        syncReset.SimulinkRate=dataRate;
    else
        syncReset=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','syncReset');
        syncReset.SimulinkRate=dataRate;
        if blockInfo.inResetSS


            syncReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;
        else


            pirelab.getConstComp(FIRInterpImpl,syncReset,false);
        end
    end


    if blockInfo.NumCycles==1
        if blockInfo.InputVectorSize==1
            filterVecType=pirelab.getPirVectorType(blockInfo.FIROutputype,blockInfo.FilterOrder*blockInfo.InputVectorSize);
        else
            filterVecType=pirelab.getPirVectorType(blockInfo.FIROutputype.BaseType,blockInfo.FilterOrder*blockInfo.InputVectorSize);
        end
    else
        filterVecType=pirelab.getPirVectorType(blockInfo.FIROutputype,ceil(blockInfo.InterpolationFactor/blockInfo.NumCycles));
    end
    blockInfo.filterVecType=filterVecType;


    firBlockInfo.inType=dataIn.Type;
    firBlockInfo.FIRFilterType=blockInfo.FIRFilterType;
    firBlockInfo.baseRate=dataRate;
    firBlockInfo.Numerator=blockInfo.Numerator;
    firBlockInfo.NumeratorQuantized=blockInfo.NumeratorQuantized;
    firBlockInfo.FilterStructure=blockInfo.FilterStructure;
    firBlockInfo.ResetInputPort=blockInfo.inMode(2);
    firBlockInfo.HDLGlobalReset=blockInfo.HDLGlobalReset;
    firBlockInfo.RoundingMethod=blockInfo.RoundingMethod;
    firBlockInfo.OverflowAction=blockInfo.OverflowAction;
    firBlockInfo.CoefficientsDataType=blockInfo.CoefficientsDataType;
    firBlockInfo.OutputDataType=blockInfo.OutputDataType;
    firBlockInfo.NumeratorSource='Property';
    firBlockInfo.inMode=blockInfo.inMode;
    firBlockInfo.inResetSS=false;
    firBlockInfo.CompiledInputDT=blockInfo.CompiledInputDT;
    firBlockInfo.CompiledInputSize=blockInfo.CompiledInputSize;
    firBlockInfo.XILINX_MAXOUTPUT_WORDLENGTH=48;
    firBlockInfo.ALTERA_MAXOUTPUT_WORDLENGTH=44;
    firBlockInfo.DELAYLINELIMIT2MAP2RAM=64;
    firBlockInfo.NumCycles=blockInfo.NumCycles;
    firBlockInfo.SerializationOption=blockInfo.SerializationOption;
    firBlockInfo.SymmetryOptimization=blockInfo.SymmetryOptimization;

    sFactor=blockInfo.NumCycles;




    numMults=ceil(numel(blockInfo.Numerator)/sFactor);
    subLength=size(blockInfo.Numerator,2);
    tableSubSize=ceil(subLength/numMults);


    InterleaveCoefficients=numMults<blockInfo.InterpolationFactor&&blockInfo.NumCycles>blockInfo.InterpolationFactor&&tableSubSize>=2;


    if~InterleaveCoefficients
        for ii=1:1:blockInfo.FilterOrder
            firBlockInfo.Numerator=blockInfo.Numerator(ii,:);
            inputWL=FIRInterpImpl.PirInputSignals(1).Type.BaseType.BaseType.WordLength;

            if isnumerictype(blockInfo.CoefficientsDataType)
                coeffsNumerictype=blockInfo.CoefficientsDataType;
            else
                coeffsNumerictype=numerictype([],inputWL);
            end


            firBlockInfo.NumeratorQuantized=fi(blockInfo.Numerator(ii,:),coeffsNumerictype,'OverflowAction','Saturate','RoundingMethod','Nearest');

            if isinf(sFactor)||sFactor>=length(firBlockInfo.Numerator)
                firBlockInfo.SharingFactor=length(firBlockInfo.Numerator);
            else
                firBlockInfo.SharingFactor=sFactor;
            end

            filterNet{ii}=createFilter(FIRInterpImpl,num2str(ii),firBlockInfo,ii);

            filtOut(ii)=FIRInterpImpl.addSignal2('Type',blockInfo.FIRFilterType(ii),'Name',['FIROutput',num2str(ii)]);
            filtValidOut(ii)=FIRInterpImpl.addSignal2('Type',booleanT,'Name',['FIRValid',num2str(ii)]);

            if blockInfo.inMode(2)
                if blockInfo.NumCycles==1
                    pirelab.instantiateNetwork(FIRInterpImpl,filterNet{ii},[dataIn,validIn,syncReset],...
                    [filtOut(ii),filtValidOut(ii)],...
                    'filterInstantiation');
                else
                    filtReadyOut(ii)=FIRInterpImpl.addSignal2('Type',booleanT,'Name',['FIRReady',num2str(ii)]);

                    pirelab.instantiateNetwork(FIRInterpImpl,filterNet{ii},[dataIn,validIn,syncReset],...
                    [filtOut(ii),filtValidOut(ii),filtReadyOut(ii)],...
                    'filterInstantiation');
                end
            else
                if blockInfo.NumCycles==1
                    pirelab.instantiateNetwork(FIRInterpImpl,filterNet{ii},[dataIn,validIn],...
                    [filtOut(ii),filtValidOut(ii)],...
                    'filterInstantiation');
                else
                    filtReadyOut(ii)=FIRInterpImpl.addSignal2('Type',booleanT,'Name',['FIRReady',num2str(ii)]);
                    pirelab.instantiateNetwork(FIRInterpImpl,filterNet{ii},[dataIn,validIn],...
                    [filtOut(ii),filtValidOut(ii),filtReadyOut(ii)],...
                    'filterInstantiation');
                end
            end

            filtCast(ii)=FIRInterpImpl.addSignal2('Type',blockInfo.FIROutputype,'Name',['FIROutputCast',num2str(ii)]);
            filtCastDB(ii)=FIRInterpImpl.addSignal2('Type',blockInfo.FIROutputype,'Name',['FIROutputCastDB',num2str(ii)]);

            pirelab.getDTCComp(FIRInterpImpl,filtOut(ii),filtCast(ii),blockInfo.RoundingMethod,blockInfo.OverflowAction);


        end
    else

        firBlockInfo.Numerator=blockInfo.Numerator(:,:);
        inputWL=FIRInterpImpl.PirInputSignals(1).Type.BaseType.BaseType.WordLength;

        if isnumerictype(blockInfo.CoefficientsDataType)
            coeffsNumerictype=blockInfo.CoefficientsDataType;
        else
            coeffsNumerictype=numerictype([],inputWL);
        end

        numMults=ceil(numel(blockInfo.Numerator)/sFactor);
        numMuxInputs=ceil(size(blockInfo.Numerator,2)/numMults);

        firBlockInfo.NumeratorQuantized=fi(blockInfo.Numerator(:,:),coeffsNumerictype,'OverflowAction','Saturate','RoundingMethod','Nearest');
        firBlockInfo.SharingFactor=blockInfo.InterpolationFactor*numMuxInputs;


        ctrlType=pir_boolean_t();
        if blockInfo.inMode(2)

            filterNet=pirelab.createNewNetwork(...
            'Network',FIRInterpImpl,...
            'Name','FIRFilterInterleave',...
            'InportNames',{'In','valid','syncReset'},...
            'InportTypes',[firBlockInfo.inType,ctrlType,ctrlType],...
            'InportRates',[firBlockInfo.baseRate,firBlockInfo.baseRate,firBlockInfo.baseRate],...
            'OutportNames',{'filterout','validOut','readyOut'},...
            'OutportTypes',[blockInfo.FIROutputype,ctrlType,ctrlType]);


        else

            filterNet=pirelab.createNewNetwork(...
            'Network',FIRInterpImpl,...
            'Name','FIRFilterInterleave',...
            'InportNames',{'In','valid'},...
            'InportTypes',[firBlockInfo.inType,ctrlType],...
            'InportRates',[firBlockInfo.baseRate,firBlockInfo.baseRate],...
            'OutportNames',{'filterout','validOut','readyOut'},...
            'OutportTypes',[blockInfo.FIROutputype,ctrlType,ctrlType]);


        end


        filterNet.addComment('FIR Filter');



        this=dsphdlsupport.internal.FIRFilter;
        filterInterleaveNet=elaborateTopLevel(this,FIRInterpImpl,filterNet,firBlockInfo);

        filtOut=FIRInterpImpl.addSignal2('Type',blockInfo.FIROutputype,'Name','FIROutput');
        filtValidOut=FIRInterpImpl.addSignal2('Type',booleanT,'Name','FIRValid');

        if blockInfo.inMode(2)

            filtReadyOut=FIRInterpImpl.addSignal2('Type',booleanT,'Name','FIRReady');

            pirelab.instantiateNetwork(FIRInterpImpl,filterInterleaveNet,[dataIn,validIn,syncReset],...
            [filtOut,filtValidOut,filtReadyOut],...
            'filterInstantiation');

        else

            filtReadyOut=FIRInterpImpl.addSignal2('Type',booleanT,'Name','FIRReady');
            pirelab.instantiateNetwork(FIRInterpImpl,filterInterleaveNet,[dataIn,validIn],...
            [filtOut,filtValidOut,filtReadyOut],...
            'filterInstantiation');

        end

        numMults=ceil(numel(blockInfo.Numerator)/blockInfo.NumCycles);
        usedCoeff=blockInfo.Numerator;
        numFilter=size(usedCoeff,1);
        subLength=size(usedCoeff,2);
        tableSubSize=ceil(subLength/numMults);
        fullySerialFilter=numMults==1;
        latencyInterleave=6+numMults-fullySerialFilter+tableSubSize;
        latencyFullySerial=6-1+subLength;

        dly=latencyFullySerial-latencyInterleave+1+fullySerialFilter;
        hDriver=hdlcurrentdriver;
        synthesisTool=hDriver.getParameter('SynthesisTool');

        filtCast=FIRInterpImpl.addSignal2('Type',blockInfo.FIROutputype,'Name','FIROutputCast');
        filtCastDB=FIRInterpImpl.addSignal2('Type',blockInfo.FIROutputype,'Name','FIROutputCastDB');

        pirelab.getWireComp(FIRInterpImpl,filtOut,filtCast);
        pirelab.getWireComp(FIRInterpImpl,filtCast,filtCastDB);
        pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,filtCastDB,dataOut,'',syncReset,dly+strcmpi(synthesisTool,'Altera Quartus II'));
        pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,filtValidOut,validOut,'',syncReset,dly+strcmpi(synthesisTool,'Altera Quartus II'));
        pirelab.getWireComp(FIRInterpImpl,filtReadyOut,readyOut);



    end

    if~InterleaveCoefficients
        for ii=1:1:blockInfo.FilterOrder

            if blockInfo.NumCycles==1

                if blockInfo.FIRDelay(ii)==0
                    pirelab.getWireComp(FIRInterpImpl,filtCast(ii),filtCastDB(ii));
                else
                    pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,filtCast(ii),filtCastDB(ii),filtValidOut(ii),syncReset,blockInfo.FIRDelay(ii));
                end

            else

                if blockInfo.FIRDelay(ii)>1
                    validPipeline(ii)=FIRInterpImpl.addSignal2('Type',booleanT,'Name',['ValidPipeline',num2str(ii)]);
                    filtCastDBP(ii)=FIRInterpImpl.addSignal2('Type',blockInfo.FIROutputype,'Name',['FIROutputCastDBP',num2str(ii)]);
                    pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,filtCast(ii),filtCastDBP(ii),'',syncReset,blockInfo.FIRDelay(ii)-1);
                    pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,filtValidOut(ii),validPipeline(ii),'',syncReset,blockInfo.FIRDelay(ii)-1);
                    pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,filtCastDBP(ii),filtCastDB(ii),validPipeline(ii),syncReset,1);
                else
                    pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,filtCast(ii),filtCastDB(ii),filtValidOut(ii),syncReset,1);
                end

            end


        end
    end



    if~InterleaveCoefficients
        if blockInfo.NumCycles==1
            filterVec=FIRInterpImpl.addSignal2('Type',filterVecType,'Name','FIRVector');
            filterVecREG=FIRInterpImpl.addSignal2('Type',filterVecType,'Name','FIRVector');
            constZero=FIRInterpImpl.addSignal2('Type',filterVecType,'Name','FIRVector');
            pirelab.getConstComp(FIRInterpImpl,constZero,0);
            readyConst=FIRInterpImpl.addSignal2('Type',booleanT,'Name','readyConst');
            readyConst.SimulinkRate=dataRate;
            readyZero=FIRInterpImpl.addSignal2('Type',booleanT,'Name','readyZero');
            readyZero.SimulinkRate=dataRate;
            readySwitch=FIRInterpImpl.addSignal2('Type',booleanT,'Name','readySwitch');
            readySwitch.SimulinkRate=dataRate;
            pirelab.getConstComp(FIRInterpImpl,readyConst,true);
            pirelab.getConstComp(FIRInterpImpl,readyZero,false);
            pirelab.getSwitchComp(FIRInterpImpl,[readyConst,readyZero],readySwitch,syncReset);

            if blockInfo.InputVectorSize==1
                pirelab.getConcatenateComp(FIRInterpImpl,filtCastDB(:),filterVec,'Multidimensional array','1');
            else
                for ii=1:1:blockInfo.InterpolationFactor
                    filterScalarType=blockInfo.FIROutputype.BaseType;
                    filterOutScalar(:,ii)=filtCastDB(ii).split.PirOutputSignals;
                end

                for ii=1:1:blockInfo.InputVectorSize

                    for jj=1:1:blockInfo.InterpolationFactor
                        OutputReg(((ii-1)*blockInfo.InterpolationFactor)+jj,1)=FIRInterpImpl.addSignal2('Type',filtCastDB(1).Type.BaseType...
                        ,'Name','FIRVector');
                        pirelab.getWireComp(FIRInterpImpl,filterOutScalar(ii,jj),OutputReg(((ii-1)*blockInfo.InterpolationFactor)+jj,1));
                    end
                end
                pirelab.getConcatenateComp(FIRInterpImpl,OutputReg,filterVec,'Multidimensional array','1');
            end

            pirelab.getSwitchComp(FIRInterpImpl,[constZero,filterVec],filterVecREG,filtValidOut(blockInfo.FIRMaxDelay));
            pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,filterVecREG,dataOut,'',syncReset,1);
            pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,filtValidOut(blockInfo.FIRMaxDelay),validOut,'',syncReset,1);
            pirelab.getUnitDelayComp(FIRInterpImpl,readySwitch,readyOut,'',1);



        else

            if blockInfo.InterpolationFactor>=blockInfo.NumCycles||ceil(log2(blockInfo.NumCycles/blockInfo.InterpolationFactor))==1
                sharingCounterType=pir_ufixpt_t(2,0);
            else
                sharingCounterType=pir_ufixpt_t(ceil(log2(blockInfo.NumCycles/blockInfo.InterpolationFactor)),0);
            end

            sharingMUXType=pir_ufixpt_t(ceil(log2(blockInfo.InterpolationFactor)),0);
            sharingCounter=FIRInterpImpl.addSignal2('Type',sharingCounterType,'Name','sharingCounter');
            validSharing=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','validSharing');
            validSharing.SimulinkRate=dataRate;
            validOutTerm=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','validOutTerm');
            validOutTerm.SimulinkRate=dataRate;
            sharingSEL=FIRInterpImpl.addSignal2('Type',sharingMUXType,'Name','sharingSEL');
            sharingSELREG=FIRInterpImpl.addSignal2('Type',sharingMUXType,'Name','sharingSELREG');
            outputSharing=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','outputSharing');
            outputSharingEn1=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','outputSharingEn1');
            outputSharingEn1.SimulinkRate=dataRate;
            outputSharingEn2=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','outputSharingEn2');
            outputSharingEn2.SimulinkRate=dataRate;
            outputSharingRstTerm1=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','outputSharingRSTTerm1');
            outputSharingRstTerm2=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','outputSharingRSTTerm2');
            outputSharingRstTerm3=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','outputSharingRSTTerm3');
            sharingReset=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','sharingReset');
            SharingCount0=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','SharingCount0');
            SharingCount0.SimulinkRate=dataRate;
            SharingSEL0=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','SharingSEL0');
            SharingSEL0.SimulinkRate=dataRate;
            SharingCount0Output=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','SharingCount0Output');
            SharingCount0Output.SimulinkRate=dataRate;
            counterEnTerm=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','counterEnTerm');
            counterEn=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','counterEn');
            counterRST=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','counterRST');
            filtReadyNot=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','filtReadyNot');
            readyREG=FIRInterpImpl.addSignal2('Type',pir_boolean_t,'Name','readyREG');


            pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,filtValidOut(blockInfo.FIRMaxDelay),outputSharing,filtValidOut(blockInfo.FIRMaxDelay),sharingReset,1,'OutputSharing');
            pirelab.getCompareToValueComp(FIRInterpImpl,sharingCounter,SharingCount0,'==',0);
            pirelab.getCompareToValueComp(FIRInterpImpl,sharingSEL,SharingSEL0,'==',0);
            pirelab.getLogicComp(FIRInterpImpl,[SharingCount0,SharingSEL0],outputSharingRstTerm1,'and');
            pirelab.getLogicComp(FIRInterpImpl,filtValidOut(blockInfo.FIRMaxDelay),outputSharingRstTerm2,'not');
            pirelab.getLogicComp(FIRInterpImpl,[outputSharingRstTerm1,outputSharingRstTerm2],outputSharingRstTerm3,'and');
            pirelab.getLogicComp(FIRInterpImpl,[syncReset,outputSharingRstTerm3],sharingReset,'or');
            pirelab.getLogicComp(FIRInterpImpl,[SharingCount0,counterEn],validSharing,'and');
            pirelab.getLogicComp(FIRInterpImpl,outputSharingRstTerm1,outputSharingEn1,'not');
            pirelab.getLogicComp(FIRInterpImpl,sharingReset,counterRST,'not');
            pirelab.getLogicComp(FIRInterpImpl,[outputSharingEn1,filtValidOut(blockInfo.FIRMaxDelay)],outputSharingEn2,'or');
            pirelab.getLogicComp(FIRInterpImpl,[outputSharing,filtValidOut(blockInfo.FIRMaxDelay)],counterEnTerm,'or');
            pirelab.getLogicComp(FIRInterpImpl,[counterEnTerm,counterRST],counterEn,'and');



            readyConst=FIRInterpImpl.addSignal2('Type',booleanT,'Name','readyConst');
            readyConst.SimulinkRate=dataRate;
            pirelab.getConstComp(FIRInterpImpl,readyConst,true);

            if blockInfo.NumCycles>=blockInfo.InterpolationFactor
                maxSharingCount=floor(blockInfo.NumCycles/blockInfo.InterpolationFactor)-1;
            else
                maxSharingCount=0;
            end
            if blockInfo.ResetInputPort||blockInfo.inResetSS
                pirelab.getCounterComp(FIRInterpImpl,[syncReset,counterEn],sharingCounter,...
                'Count limited',...
                0.0,...
                1.0,...
                maxSharingCount,...
                true,...
                false,...
                true,...
                false,...
                'SharingCounter');

                if blockInfo.NumCycles>=blockInfo.InterpolationFactor
                    maxSharingSEL=blockInfo.InterpolationFactor-1;
                else
                    maxSharingSEL=blockInfo.NumCycles-1;
                end

                pirelab.getCounterComp(FIRInterpImpl,[syncReset,validSharing],sharingSEL,...
                'Count limited',...
                0.0,...
                1.0,...
                maxSharingSEL,...
                true,...
                false,...
                true,...
                false,...
                'SharingSEL');
            else
                pirelab.getCounterComp(FIRInterpImpl,counterEn,sharingCounter,...
                'Count limited',...
                0.0,...
                1.0,...
                maxSharingCount,...
                false,...
                false,...
                true,...
                false,...
                'SharingCounter');

                if blockInfo.NumCycles>=blockInfo.InterpolationFactor
                    maxSharingSEL=blockInfo.InterpolationFactor-1;
                else
                    maxSharingSEL=blockInfo.NumCycles-1;
                end

                pirelab.getCounterComp(FIRInterpImpl,validSharing,sharingSEL,...
                'Count limited',...
                0.0,...
                1.0,...
                maxSharingSEL,...
                false,...
                false,...
                true,...
                false,...
                'SharingSEL');



            end
            pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,sharingSEL,sharingSELREG,validSharing,syncReset,1,'OutputSharing');
            pirelab.getLogicComp(FIRInterpImpl,[validSharing,filtValidOut(blockInfo.FIRMaxDelay)],validOutTerm,'or');
            pirelab.getIntDelayEnabledResettableComp(FIRInterpImpl,validOutTerm,validOut,'',syncReset,1,'OutputSharing');


            if blockInfo.NumCycles>=blockInfo.InterpolationFactor
                dataSelect=FIRInterpImpl.addSignal2('Type',blockInfo.FIROutputype,'Name','dataSelect');
                dataZero=FIRInterpImpl.addSignal2('Type',blockInfo.FIROutputype,'Name','dataZero');
                dataZero.SimulinkRate=dataRate;
                pirelab.getConstComp(FIRInterpImpl,dataZero,0);
                pirelab.getMultiPortSwitchComp(FIRInterpImpl,[sharingSELREG,filtCastDB],dataSelect,1);
            else
                sharingConst=(ceil(blockInfo.InterpolationFactor/blockInfo.NumCycles));
                for ii=1:1:blockInfo.NumCycles
                    filterVec(ii)=FIRInterpImpl.addSignal2('Type',filterVecType,'Name','FIRVector');
                    pirelab.getConcatenateComp(FIRInterpImpl,filtCastDB(((ii-1)*sharingConst+1):ii*sharingConst),filterVec(ii),'Multidimensional array','1');
                end
                dataZero=FIRInterpImpl.addSignal2('Type',filterVecType,'Name','dataZero');
                dataZero.SimulinkRate=dataRate;
                pirelab.getConstComp(FIRInterpImpl,dataZero,0);
                dataSelect=FIRInterpImpl.addSignal2('Type',filterVecType,'Name','dataSelect');
                pirelab.getMultiPortSwitchComp(FIRInterpImpl,[sharingSELREG,filterVec],dataSelect,1);
            end

            pirelab.getMultiPortSwitchComp(FIRInterpImpl,[validOut,[dataZero,dataSelect]],dataOut,1);
            pirelab.getLogicComp(FIRInterpImpl,filtReadyOut(blockInfo.FIRMaxDelay),filtReadyNot,'not');
            pirelab.getWireComp(FIRInterpImpl,filtReadyNot,readyREG);
            pirelab.getLogicComp(FIRInterpImpl,readyREG,readyOut,'not');


        end
    end

end
function filterNet=createFilter(topNet,name,blockInfo,ii)
    ctrlType=pir_boolean_t();
    if blockInfo.inMode(2)
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
