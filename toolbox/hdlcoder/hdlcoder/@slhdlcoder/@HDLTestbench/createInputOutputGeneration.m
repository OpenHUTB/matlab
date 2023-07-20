function[snkCompareSigs,snkEnables]=createInputOutputGeneration(this,hD,...
    tbpir,tb_enb_delay,globalSigs,snkDone,dutPkgName)




    multiFileTB=hD.getParameter('multifiletestbench');
    holdTime=hD.getParameter('force_hold_time');
    initInputs=hD.getParameter('initializetestbenchinputs');
    tbrefPostfix=hD.getParameter('testbenchreferencepostfix');
    resetValue=hD.getParameter('force_reset_value');
    reset=globalSigs(2);

    topN=tbpir.getTopNetwork;
    tb_enb_delay=topN.findSignal('name','tb_enb_delay');


    dataPkgName=[this.TestBenchName,hD.getParameter('tbdata_postfix')];
    hN=tbpir.addNetwork;
    hN.Name=dataPkgName;
    if~isempty(dutPkgName)
        hN.addCustomLibraryPackage('work',dutPkgName);
    end

    useFloatLib=targetcodegen.targetCodeGenerationUtils.isFloatingPointMode();
    useTextIO=this.isTextIOSupported(true);
    if useTextIO
        hN.addCustomLibraryPackage('STD','textio');
        hN.addCustomLibraryPackage('IEEE','std_logic_textio');
        if~multiFileTB


            topN.addCustomLibraryPackage('STD','textio');
            topN.addCustomLibraryPackage('IEEE','std_logic_textio');
        end
        hP=hN.addInputPort(tb_enb_delay.Name);
        local_tb_enb_delay=hN.addSignal(tb_enb_delay);
        local_tb_enb_delay.addDriver(hP);
        enbSigs=tb_enb_delay;
    else
        local_tb_enb_delay=[];
        enbSigs=[];
    end

    if useFloatLib
        hN.addCustomLibraryPackage('IEEE','float_pkg');
        topN.addCustomLibraryPackage('IEEE','float_pkg');
    end

    inputSigs=[];
    instInputs=[];
    instInputIdx=0;
    snkCompareSigs=[];
    snkEnables=[];
    inSrc=this.InportSrc;
    numInSrc=numel(inSrc);
    outSnk=this.OutportSnk;
    gp=pir;
    dutBaseRate=gp.DutBaseRate;
    if dutBaseRate<0
        dutBaseRate=0;
    end


    for ii=1:numInSrc
        port=inSrc(ii);
        [addrSig,enbSig,dataIsConst]=createDataSourceOrSink(this,hN,topN,...
        port,'in',instInputIdx,initInputs,local_tb_enb_delay);
        allDataIsConst=all(dataIsConst);
        if useTextIO
            addrSigDelay=topN.addSignal(addrSig);
            addrSigDelay.Name=[addrSig.Name,'_delay'];
            pirelab.getTBTimeDelayComp(topN,addrSig,addrSigDelay,1);
        else
            addrSigDelay=addrSig;
        end
        inputSigs=[inputSigs,addrSig];%#ok<AGROW>
        enbSigs=[enbSigs,enbSig];%#ok<AGROW>
        if~allDataIsConst
            instInputs=[instInputs,addrSigDelay];%#ok<AGROW>
            instInputIdx=instInputIdx+1;
        end

        forceName=this.getHDLSignals('force',port);
        numForce=numel(forceName);
        forceName=this.getHDLSignals('in',port);

        addTimeZeroHoldReg=this.holdInputDataBetweenSamples;


        for jj=1:numForce
            hS=hN.findSignal('name',forceName{jj});
            hS.SimulinkRate=dutBaseRate;
            if port.dataIsComplex
                baseName=port.HDLPortName{1}{jj};
            else
                if iscell(port.HDLPortName{1})
                    baseName=port.HDLPortName{1}{jj};
                else
                    baseName=port.HDLPortName{jj};
                end
            end



            hOffsetS=hN.addSignal(hS);
            hOffsetS.Name=[baseName,'_offset'];
            hOffsetS.Reg=true;
            hRawS=hN.addSignal(hS);
            if useTextIO&&~initInputs&&~dataIsConst(jj)
                hRawS.Reg=true;
            end

            hRawS.SimulinkRate=dutBaseRate;


            hP=hS.getDrivers;
            hS.disconnectDriver(hP);
            hRawS.addDriver(hP);

            hFinalS=hN.addSignal(hS);
            hFinalS.SimulinkRate=dutBaseRate;
            hP=hS.getReceivers;
            hS.disconnectReceiver(hP);
            hFinalS.addReceiver(hP);
            hS.Name=['holdData_',baseName];
            if~initInputs&&~addTimeZeroHoldReg
                hS.Reg=false;
            end

            compName=['stimuli_',port.loggingPortName];
            if addTimeZeroHoldReg
                hRawS.Name=['rawData_',baseName];
                if initInputs
                    initialVal={};
                else
                    initialVal={'initialvalue','x'};
                end


                [clk,~,rst]=hN.getClockBundle(hRawS,1,1,0);
                hC=hN.addComponent2('kind','register','name',compName,...
                'datainput',hRawS,'dataoutput',hS,...
                'clock',clk,'reset',rst,...
                initialVal{:},...
                'blockcomment',['holdData reg for ',port.loggingPortName]);
            end


            [enbSig,addedSig]=addRdEnbToNetwork(hN,port.dataRdEnb);
            if addedSig
                enbSigs=[enbSigs,port.dataRdEnb];%#ok<AGROW>
            end
            if initInputs

                [local_tb_enb_delay,addedSig]=addRdEnbToNetwork(hN,tb_enb_delay);
                if addedSig
                    enbSigs=[enbSigs,tb_enb_delay];%#ok<AGROW>
                end
                hC=pirelab.getTBStimulusSwitchComp(hN,[hS,hRawS],hOffsetS,...
                [enbSig,local_tb_enb_delay],compName);
            else
                hC=pirelab.getTBStimulusSwitchComp(hN,[hS,hRawS],hOffsetS,...
                enbSig,compName);
            end
            if~addTimeZeroHoldReg
                hT=hS.Type.BaseType;
                if(hT.isFloatType&&~targetcodegen.targetCodeGenerationUtils.isNFPMode)||...
                    hT.isEnumType

                    hC=pirelab.getConstComp(hN,hS,0.0,...
                    ['const_zero_',port.loggingPortName]);
                else
                    hC=pirelab.getConstSpecialComp(hN,hS,'X',...
                    ['constX_',port.loggingPortName]);
                end
            end

            if hFinalS.Type.isFloatType
                hFinalS.Reg=true;
            end

            hC=pirelab.getTBTimeDelayComp(hN,hOffsetS,hFinalS,holdTime);
        end
    end


    for ii=1:numel(outSnk)
        port=outSnk(ii);
        [addrSig,enbSig,dataIsConst]=createDataSourceOrSink(this,hN,topN,...
        port,'expected',instInputIdx,initInputs,local_tb_enb_delay);
        allDataIsConst=all(dataIsConst);
        enbSigs=[enbSigs,enbSig];%#ok<AGROW>
        if useTextIO
            addrSigDelay=topN.addSignal(addrSig);
            addrSigDelay.Name=[addrSig.Name,'_delay'];
            pirelab.getTBTimeDelayComp(topN,addrSig,addrSigDelay,1);
        else
            addrSigDelay=addrSig;
        end
        inputSigs=[inputSigs,addrSig];%#ok<AGROW>
        if~allDataIsConst
            instInputs=[instInputs,addrSigDelay];%#ok<AGROW>
            instInputIdx=instInputIdx+1;
        end
        sigNames=this.getHDLSignals('out',port);
        refNames=cellfun(@(x)[x,tbrefPostfix],sigNames,'UniformOutput',false);
        for jj=1:numel(sigNames)
            outSig=topN.findSignal('name',sigNames{jj});
            refSig=topN.findSignal('name',refNames{jj});
            if isempty(refSig)
                refSig=topN.addSignal(outSig.Type,refNames{jj});
                refSig.Preserve(true);
                refSig.SimulinkRate=outSig.SimulinkRate;
            end

            snkCompareSigs=[snkCompareSigs,refSig];%#ok<AGROW>

            enbSig=topN.findSignal('name',port.ClockEnable.Name);
            if isempty(enbSig)



                phaseSel=port.dataRdEnb;
                enbSig=topN.addSignal(phaseSel.Type,port.ClockEnable.Name);
                enbSig.Preserve(true);
                hC=pirelab.getLogicComp(topN,[phaseSel,tb_enb_delay,globalSigs(3)],...
                enbSig,'and');
            end
            snkEnables=[snkEnables,enbSig];%#ok<AGROW>
        end
    end



    dataForDUT=hdlhandles(numel(hN.PirOutputPorts),1);
    inIdx=1;

    for ii=1:numInSrc
        port=inSrc(ii);
        isVectorData=prod(port.VectorPortSize)>1&&~this.ScalarizeDUTPorts;
        dataSigName=this.getHDLSignals('in',port);
        numDataSig=numel(dataSigName);


        if port.dataIsComplex
            expectedNumNames=2;
        else
            expectedNumNames=1;
        end
        if~isVectorData
            expectedNumNames=expectedNumNames*port.VectorPortSize;
        end

        if expectedNumNames==numDataSig

            for jj=1:numDataSig
                dataForDUT(inIdx)=topN.findSignal('name',dataSigName{jj});
                inIdx=inIdx+1;
            end
        else




            hT=topN.findSignal('name',dataSigName{1}).Type;
            forceSigName=this.getHDLSignals('force',port);
            numForce=numel(forceSigName);
            forceSig=hdlhandles(numForce,1);
            for jj=1:numForce
                forceSig(jj)=topN.addSignal(hT,forceSigName{jj});
                dataForDUT(inIdx)=forceSig(jj);
                inIdx=inIdx+1;
            end
            for jj=1:numDataSig
                inSig=topN.findSignal('name',dataSigName{jj});
                forceIdx=1+mod(jj-1,numForce);
                hC=pirelab.getWireComp(topN,forceSig(forceIdx),inSig);
            end
        end
    end


    if~isempty(snkCompareSigs)
        dataForDUT(inIdx:inIdx+numel(snkCompareSigs)-1)=snkCompareSigs;
    end


    outSigInfo=hN.PirOutputSignals;
    for ii=1:numel(dataForDUT)
        inSig=dataForDUT(ii);
        outSig=outSigInfo(ii);
        outSig.SimulinkRate=inSig.SimulinkRate;
    end



    hNIC=pirelab.instantiateNetwork(topN,hN,[instInputs,enbSigs],...
    dataForDUT,hN.Name);
    clear instInputs;

    if~multiFileTB
        hN.setFlattenHierarchy('on');
        hNIC.flatten(true);
    end


    bitT=topN.getType('FixedPoint','Signed',0,'WordLength',1,'FractionLength',0);

    tb_enb_delay=topN.findSignal('name','tb_enb_delay');
    sigIdx=1;
    lastCnt=0;
    lastAddrSig=inputSigs(sigIdx);

    if resetValue==0
        resetSig=reset;
    else
        resetSig=topN.findSignal('name','resetn');
    end

    creatingInputs=true;
    srcDoneSigs=hdlhandles(numInSrc,1);
    for ii=1:numInSrc
        inCnt=inSrc(ii).datalength-1;
        createAddrCounterAndDoneLogic(inSrc(ii),inputSigs(sigIdx));

        if this.isCEasDataValid

            lastAddr=topN.addSignal(bitT,[inSrc(ii).loggingPortName,'_lastAddr']);
            hC=pirelab.getCompareToValueComp(topN,inputSigs(sigIdx),lastAddr,...
            '>=',inCnt,[inSrc(ii).loggingPortName,'_addrCmp'],inCnt==0);
            srcDoneSigs(ii)=topN.addSignal(bitT,[inSrc(ii).loggingPortName,'_done']);
            hC=pirelab.getLogicComp(topN,[lastAddr,resetSig],srcDoneSigs(ii),'and');
        end
        sigIdx=sigIdx+1;
    end
    if this.isCEasDataValid&&~isempty(srcDoneSigs)
        srcDone=topN.findSignal('name','srcDone');
        hC=pirelab.getLogicComp(topN,srcDoneSigs,srcDone,'and');
    end



    creatingInputs=false;lastCnt=0;
    if numel(outSnk)==0
        pirelab.getConstComp(topN,snkDone,true);
    else
        snkDoneSigs=hdlhandles(numel(outSnk),1);
        for ii=1:numel(outSnk)
            inCnt=outSnk(ii).datalength-1;
            createAddrCounterAndDoneLogic(outSnk(ii),inputSigs(sigIdx));

            lastAddr=topN.addSignal(bitT,[outSnk(ii).loggingPortName,'_lastAddr']);
            hC=pirelab.getCompareToValueComp(topN,inputSigs(sigIdx),lastAddr,...
            '>=',inCnt,[outSnk(ii).loggingPortName,'_addrCmp'],inCnt==0);
            snkDoneSigs(ii)=topN.addSignal(bitT,[outSnk(ii).loggingPortName,'_done']);
            hC=pirelab.getLogicComp(topN,[lastAddr,resetSig],snkDoneSigs(ii),'and');
            sigIdx=sigIdx+1;
        end

        createSnkDoneLogic(this,topN,snkDoneSigs,snkDone,globalSigs);
    end




    function createAddrCounterAndDoneLogic(port,addrSig)




        if inCnt==0

        elseif inCnt~=lastCnt||~lastAddrSig.Type.isEqual(addrSig.Type)...
            ||lastAddrSig.SimulinkRate~=addrSig.SimulinkRate

            cntActive=topN.addSignal(bitT,[port.loggingPortName,'_active']);
            hC=pirelab.getCompareToValueComp(topN,addrSig,cntActive,...
            '~=',inCnt);%#ok<SETNU>
            cntEnb=topN.addSignal(bitT,[port.loggingPortName,'_enb']);
            if creatingInputs
                hC=pirelab.getLogicComp(topN,...
                [port.dataRdEnb,tb_enb_delay,cntActive],cntEnb,'and');
            else
                ce_out=topN.findSignal('name',port.ClockEnable.Name);
                hC=pirelab.getLogicComp(topN,[ce_out,cntActive],cntEnb,'and');
            end
            hC=pirelab.getCounterLimitedComp(topN,addrSig,inCnt,...
            addrSig.SimulinkRate,port.SLBlockName,0,false,cntEnb);
            lastCnt=inCnt;
            lastAddrSig=addrSig;
        else



            hC=pirelab.getWireComp(topN,lastAddrSig,addrSig,...
            addrSig.Name);
        end
    end
end


function[topSigIn,enbSigIn,dataIsConst]=createDataSourceOrSink(this,hN,topN,...
    port,constSuffix,instInputIdx,initInputs,local_tb_enb_delay)
    if(strcmp(port.PortSLType,'bus'))
        baseDataT=recordextraction(port);
    else
        baseDataT=pirelab.convertSLType2PirType(port.PortSLType);
    end
    isStringData=strcmp(port.PortSLType,'str');


    if isStringData
        port.VectorPortSize=port.dataWidth;
    end

    isVectorData=prod(port.VectorPortSize)>1&&~this.ScalarizeDUTPorts;


    if this.isTextIOSupported

        largeVecLimit=1;
    else
        largeVecLimit=64;
    end
    isMatrixData=(numel(port.VectorPortSize)>1);

    isLargeVectorData=isVectorData&&(prod(port.VectorPortSize)>largeVecLimit||isMatrixData);

    if isVectorData
        if isMatrixData
            dataT=hN.getType('Array','BaseType',baseDataT,...
            'Dimensions',port.VectorPortSize);
        else

            dataT=hN.getType('Array','BaseType',baseDataT,...
            'Dimensions',prod(port.VectorPortSize));
        end

    else
        dataT=baseDataT;
    end
    if port.dataIsComplex
        tableData=[port.data,port.data_im];
    elseif isStringData
        [rowSize,colSize]=size(port.data);
        if port.VectorPortSize>colSize
            tableData=[port.data,zeros(rowSize,port.VectorPortSize-colSize)];
        else
            tableData=port.data;
        end
    else
        tableData=port.data;
    end


    if strcmp(constSuffix,'in')
        outName=this.getHDLSignals('force',port);
    else
        outName=this.getHDLSignals(constSuffix,port);
    end
    if iscell(outName)
        numOutSigs=numel(outName);
    else
        numOutSigs=1;
        outName={outName};
    end











    if strcmp(constSuffix,'in')
        outName=this.getHDLSignals('in',port);
        outName=outName(1:numOutSigs);
    end
    hSigOut=hdlhandles(numOutSigs,1);
    muxComp=hdlhandles(numOutSigs,1);
    for ii=1:numOutSigs
        hSigOut(ii)=hN.addSignal(dataT,outName{ii});
        hSigOut(ii).SimulinkRate=getDUTPortSampleTime(port);
        hP=hN.addOutputPort(outName{ii});
        hSigOut(ii).addReceiver(hP);

        if isVectorData&&~isLargeVectorData
            muxComp(ii)=pirelab.getMuxOnOutput(hN,hSigOut(ii));
        end
    end


    inName=[port.loggingPortName,'_addr'];
    addrWordLen=max(1,ceil(log2(port.datalength)));
    addrT=hN.getType('FixedPoint','Signed',0,'WordLength',addrWordLen);
    hSigIn=hN.addSignal(addrT,inName);
    hSigIn.SimulinkRate=hSigOut(1).SimulinkRate;
    hP=hN.addInputPort(instInputIdx,'data',inName);
    hSigIn.addDriver(hP);


    topSigIn=topN.addSignal(addrT,inName);
    topSigIn.SimulinkRate=getDUTPortSampleTime(port);
    enbSigIn=[];
    dataIsConst=logical([]);
    isInput=strcmp(constSuffix,'in');
    initThisInput=isInput&&initInputs;

    dataRdEnb=getPortReadEnb(this,port,topN,isInput);

    useTextIO=this.isTextIOSupported;


    if isVectorData
        if port.dataIsComplex
            for ii=1:numOutSigs
                if isMatrixData


                    dStart=(port.VectorPortSize(2)*(ii-1))+1;
                    dEnd=port.VectorPortSize(2)*ii;
                    if numel(port.VectorPortSize)==2


                        LUTData=tableData(:,dStart:dEnd,:);
                    else
                        assert(numel(port.VectorPortSize)<=3,'Unsupported Matrix Dimensions');


                        LUTData=tableData(:,dStart:dEnd,:,:);
                    end
                else

                    dStart=(port.VectorPortSize*(ii-1))+1;
                    dEnd=port.VectorPortSize*ii;
                    LUTData=tableData(:,dStart:dEnd);
                end
                if isLargeVectorData
                    useConst=logical(port.dataIsConstant||isscalar(LUTData));
                    dataIsConst(end+1)=useConst;%#ok<AGROW>
                    [outTemp,enbSig,addedSig]=createDataComp(this,...
                    hN,hSigIn,hSigOut(ii),LUTData,isInput,initThisInput,useConst,...
                    [],hSigOut(ii).Name,dataRdEnb,local_tb_enb_delay);
                    if addedSig
                        enbSigIn=[enbSigIn,dataRdEnb];%#ok<AGROW>
                    end

                    if initThisInput
                        if ii==1


                            constZero=hN.addSignal(hSigOut(ii).Type,'const_zero');
                            pirelab.getConstComp(hN,constZero,0);
                            [enbSig,addedSig]=addRdEnbToNetwork(hN,dataRdEnb);

                            if addedSig
                                enbSigIn=[enbSigIn,dataRdEnb];%#ok<AGROW>
                            end
                        end
                        pirelab.getSwitchComp(hN,[constZero,outTemp],hSigOut(ii),...
                        enbSig,'zero');
                    end
                else

                    outScalars=muxComp(ii).PirInputSignals;
                    for jj=1:numel(outScalars)
                        dIdx=(ii-1)*port.VectorPortSize+jj;
                        LUTData=tableData(:,dIdx);
                        if port.dataIsConstant||all(LUTData==LUTData(1))
                            LUTData=LUTData(1);
                        end
                        outScalars(jj).SimulinkRate=getDUTPortSampleTime(port);

                        useConst=logical(port.dataIsConstant||isscalar(LUTData));
                        dataIsConst(end+1)=useConst;%#ok<AGROW>
                        [outTemp,~,addedSig]=createDataComp(this,...
                        hN,hSigIn,outScalars(jj),LUTData,isInput,initThisInput,...
                        useConst,[],outScalars(jj).Name,dataRdEnb,...
                        local_tb_enb_delay);
                        if addedSig
                            enbSigIn=[enbSigIn,dataRdEnb];%#ok<AGROW>
                        end

                        if initThisInput
                            if jj==1


                                constZero=hN.addSignal(outScalars(jj).Type,'const_zero');
                                pirelab.getConstComp(hN,constZero,0);
                                [enbSig,addedSig]=addRdEnbToNetwork(hN,dataRdEnb);
                                if addedSig

                                    enbSigIn=[enbSigIn,dataRdEnb];%#ok<AGROW>
                                end
                            end
                            pirelab.getSwitchComp(hN,[constZero,outTemp],outScalars(jj),...
                            enbSig,'zero');
                        end
                    end
                end
            end
        else

            if isLargeVectorData

                useConst=logical(port.dataIsConstant||isscalar(tableData));
                dataIsConst(end+1)=useConst;
                [outTemp,enbSig,addedSig]=createDataComp(this,...
                hN,hSigIn,hSigOut,tableData,isInput,initThisInput,useConst,...
                [],hSigOut.Name,dataRdEnb,local_tb_enb_delay);
                if addedSig
                    enbSigIn=[enbSigIn,dataRdEnb];
                end

                if initThisInput
                    if ii==1


                        constZero=hN.addSignal(hSigOut.Type,'const_zero');
                        pirelab.getConstComp(hN,constZero,0);
                        [enbSig,addedSig]=addRdEnbToNetwork(hN,dataRdEnb);
                        if addedSig

                            enbSigIn=[enbSigIn,dataRdEnb];
                        end
                    end
                    pirelab.getSwitchComp(hN,[constZero,outTemp],hSigOut,...
                    enbSig,'zero');
                end
            else

                outScalars=muxComp.PirInputSignals;
                for ii=1:numel(outScalars)
                    LUTData=tableData(:,ii);
                    if port.dataIsConstant||all(LUTData==LUTData(1))
                        LUTData=LUTData(1);
                    end
                    outScalars(ii).SimulinkRate=getDUTPortSampleTime(port);

                    useConst=logical(port.dataIsConstant||isscalar(LUTData));
                    dataIsConst(end+1)=useConst;%#ok<AGROW>
                    [outTemp,~,addedSig]=createDataComp(this,...
                    hN,hSigIn,outScalars(ii),LUTData,isInput,initThisInput,useConst,...
                    [],outScalars(ii).Name,dataRdEnb,local_tb_enb_delay);
                    if addedSig
                        enbSigIn=[enbSigIn,dataRdEnb];%#ok<AGROW>
                    end

                    if initThisInput
                        if ii==1


                            constZero=hN.addSignal(outScalars(ii).Type,'const_zero');
                            pirelab.getConstComp(hN,constZero,0);
                            [swEnbSig,addedSig]=addRdEnbToNetwork(hN,dataRdEnb);
                            if addedSig

                                enbSigIn=[enbSigIn,dataRdEnb];%#ok<AGROW>
                            end
                        end
                        pirelab.getSwitchComp(hN,[constZero,outTemp],outScalars(ii),...
                        swEnbSig,'zero');
                    end
                end
            end
        end
    else


        if(isMatrixData&&this.ScalarizeDUTPorts)
            vecalign=[];
            if port.dataIsComplex||prod(port.VectorPortSize)==numOutSigs

                for ii=1:port.datalength
                    if numel(port.VectorPortSize)==2
                        tempData=reshape(tableData(:,:,ii),1,[]);
                    else

                        if port.dataIsComplex
                            drealEnd=port.VectorPortSize(2);
                            dimgEnd=port.VectorPortSize(2)*2;
                            realData=reshape(tableData(:,1:drealEnd,:,ii),1,[]);
                            imgdData=reshape(tableData(:,drealEnd+1:dimgEnd,:,ii),1,[]);
                            tempData=[realData,imgdData];
                        else

                            tempData=reshape(tableData(:,:,:,ii),1,[]);
                        end
                    end
                    vecalign=[vecalign;tempData];%#ok<AGROW>
                end
                tableData=vecalign;
            end
        end
        for ii=1:numOutSigs
            hSigIn.SimulinkRate=0;
            hSigOut(ii).SimulinkRate=0;
            if port.dataIsComplex||prod(port.VectorPortSize)==numOutSigs
                LUTData=tableData(:,ii);
            elseif strcmp(port.PortSLType,'str')

                dim=size(port.data,2);
                if ii>dim
                    LUTData=0;
                else
                    LUTData=tableData(:,ii);
                end
            else

                LUTData=tableData(:,1);
            end
            if port.dataIsConstant||(~(strcmp(port.PortSLType,'bus'))&&all(LUTData==LUTData(1)))
                LUTData=LUTData(1);
            end

            useConst=logical(port.dataIsConstant||(isscalar(LUTData)&&~isstruct(LUTData)));
            dataIsConst(end+1)=useConst||useTextIO&&numel(LUTData)==1&&~isstruct(LUTData);%#ok<AGROW>
            [outTemp,~,addedSig]=createDataComp(this,hN,...
            hSigIn,hSigOut(ii),LUTData,isInput,initThisInput,useConst,...
            outName{ii},hSigOut(ii).Name,dataRdEnb,local_tb_enb_delay);
            if addedSig
                enbSigIn=[enbSigIn,dataRdEnb];%#ok<AGROW>
            end

            if initThisInput
                constZero=hN.addSignal(hSigOut(ii).Type,'const_zero');

                if(hSigOut(ii).Type.isRecordType)
                    constzerostruct=getConstZeroStruct(LUTData(1,:));
                    pirelab.getConstComp(hN,constZero,constzerostruct);
                else
                    pirelab.getConstComp(hN,constZero,0);
                end
                [enbSig,addedSig]=addRdEnbToNetwork(hN,dataRdEnb);
                if addedSig

                    enbSigIn=[enbSigIn,dataRdEnb];%#ok<AGROW>
                end
                pirelab.getSwitchComp(hN,[constZero,outTemp],hSigOut(ii),...
                enbSig,'zero');
            end
        end
    end

    if all(dataIsConst)
        hP=hSigIn.getDrivers;
        hSigIn.disconnectDriver(hP);
        hN.removeSignal(hSigIn);
        for ii=1:hN.NumberOfPirInputPorts
            if strcmp(hN.PirInputPorts(ii).Name,hP.Name)
                hN.removeInputPort(ii-1);
                break;
            end
        end
    end
end



function[outTemp,enbSig,addedSig]=createDataComp(this,hN,...
    hSigIn,hSigOut,LUTData,isInput,initThisInput,useConst,compName,commentName,...
    rdEnb,local_tb_enb_delay)

    if initThisInput
        outTemp=hN.addSignal(hSigOut);
        outTemp.Name=[hSigOut.Name,'raw'];
    else
        outTemp=hSigOut;
    end
    if isempty(compName)
        compName=outTemp.Name;
    end
    enbSig=[];
    addedSig=false;
    hT=outTemp.Type;
    ldims=1;
    if hT.isArrayType

        [ldims,hT]=pirelab.getVectorTypeInfo(hT);
    end
    lutSz=numel(LUTData)/prod(ldims);

    if useConst
        if(numel(ldims)>1)
            if numel(ldims)==2
                hC=pirelab.getConstComp(hN,outTemp,LUTData(:,:,1),compName);
            else
                hC=pirelab.getConstComp(hN,outTemp,LUTData(:,:,:,1),compName);
            end
        else
            hC=pirelab.getConstComp(hN,outTemp,LUTData(1,:),compName);
        end
    else
        if this.isTextIOSupported&&numel(LUTData)==1&&~isstruct(LUTData)


            hC=pirelab.getConstComp(hN,outTemp,LUTData(1,:),compName);
        elseif(this.isTextIOSupported&&(numel(LUTData)>1||isstruct(LUTData)))

            if(hT.isRecordType)
                formattedData=getFormattedData(this,hT,LUTData,lutSz,1);
            else

                if hT.isFloatType
                    sign=1;
                    size=0;
                    bp=0;

                    if targetcodegen.targetCodeGenerationUtils.isFloatingPointMode()
                        sign=0;
                        [LUTData,size]=castToFpType(hT,LUTData,ldims);
                    end
                elseif hT.isLogicType
                    sign=0;
                    size=hT.WordLength;
                    bp=0;
                else
                    sign=hT.Signed;
                    size=hT.WordLength;
                    bp=hT.FractionLength;
                end

                formattedData=[];

                if numel(ldims)>1
                    for jj=1:lutSz
                        if numel(ldims)==2
                            fdata=this.formatDataAsText(LUTData(:,:,jj),sign,size,bp);
                        else
                            fdata=this.formatDataAsText(LUTData(:,:,:,jj),sign,size,bp);
                        end
                        formattedData=[formattedData;fdata];%#ok<AGROW>
                    end
                else
                    formattedData=this.formatDataAsText(LUTData,sign,size,bp);
                end
            end
            fileName=[hSigOut.Name,'.dat'];
            writeDataFile(this,fileName,formattedData);
            [enbSig,addedSig]=addRdEnbToNetwork(hN,rdEnb);
            if isInput
                inSigs=[hSigIn,local_tb_enb_delay,enbSig];
            else
                if this.getInputDataInterval>1
                    inSigs=[hSigIn,local_tb_enb_delay];
                else
                    inSigs=[hSigIn,local_tb_enb_delay,enbSig];
                end
            end
            outSigs=outTemp;
            if~isempty(strfind(this.targetLang,'Verilog'))
                outSigs.Reg=true;
                intT=hN.getType('FixedPoint','Signed',1,'WordLength',32);
                filePtrSig=hN.addSignal(intT,['fp_',hSigOut.Name]);
                filePtrSig.Preserve(true);
                filePtrSig.Reg=true;
                statusSig=hN.addSignal(intT,['status_',hSigOut.Name]);
                statusSig.Preserve(true);
                statusSig.Reg=true;
                inSigs(end+1)=filePtrSig;
                outSigs(end+1)=statusSig;
            end
            hC=pirelab.getTBFileReaderComp(hN,inSigs,outSigs,fileName,...
            [hSigOut.Name,'_fileread']);
        else


            convertLUTData=~(outTemp.Type.isEnumType||...
            outTemp.Type.isFloatType);
            if convertLUTData
                hS=hN.addSignal(outTemp);
                hS.Type=this.getPirTypeForTBData(outTemp.Type);
            else
                hS=outTemp;
            end
            hC=pirelab.getDirectLookupComp(hN,hSigIn,hS,...
            LUTData,compName);
            if convertLUTData
                pirelab.getDTCComp(hN,hS,outTemp,'Floor','Wrap','SI');
            end
        end
    end
    hC.addComment(['Data source for ',commentName]);
end

function[datatmp,size]=castToFpType(type,LUTData,dims)
    lutSz=numel(LUTData)/prod(dims);

    if numel(dims)==2
        dataTmpsz=[dims(1),dims(2),lutSz];
    elseif numel(dims)==3
        dataTmpsz=[dims(1),dims(2),dims(3),lutSz];
    else
        dataTmpsz=[lutSz,dims];
    end

    if type.isDoubleType
        size=64;
        datatmp=zeros(dataTmpsz,'uint64');
    elseif type.isHalfType
        size=16;
        datatmp=zeros(dataTmpsz,'uint16');
    else
        size=32;
        datatmp=zeros(dataTmpsz,'uint32');
    end

    for ii=1:lutSz
        if numel(dims)==2
            for jj=1:dims(2)

                if type.isDoubleType

                    datatmp(:,jj,ii)=typecast(double(LUTData(:,jj,ii)),'uint64');
                elseif type.isHalfType



                    datatmp(:,jj,ii)=half(LUTData(:,jj,ii)).storedInteger;
                else

                    datatmp(:,jj,ii)=typecast(single(LUTData(:,jj,ii)),'uint32');
                end
            end
        elseif numel(dims)==3
            for jj=1:dims(2)
                for kk=1:dims(3)

                    if type.isDoubleType

                        datatmp(:,jj,kk,ii)=typecast(double(LUTData(:,jj,kk,ii)),'uint64');
                    elseif type.isHalfType



                        datatmp(:,jj,kk,ii)=half(LUTData(:,jj,kk,ii)).storedInteger;
                    else

                        datatmp(:,jj,kk,ii)=typecast(single(LUTData(:,jj,kk,ii)),'uint32');
                    end
                end
            end
        else
            if type.isDoubleType
                datatmp(ii,:)=typecast(double(LUTData(ii,:)),'uint64');
            elseif type.isHalfType
                datatmp(ii,:)=half(LUTData(ii,:)).storedInteger;
            else
                datatmp(ii,:)=typecast(single(LUTData(ii,:)),'uint32');
            end
        end
    end

end


function ST=getDUTPortSampleTime(port)
    ST=port.SLSampleTime;
    if isnan(ST)
        ST=port.HDLSampleTime;
    end
end






function[enbSig,addedSig]=addRdEnbToNetwork(hN,rdEnb)
    enbSig=hN.findSignal('name',rdEnb.Name);
    if isempty(enbSig)
        hP=hN.addInputPort(rdEnb.Name);
        enbSig=hN.addSignal(rdEnb.Type,rdEnb.Name);
        enbSig.addDriver(hP);
        addedSig=true;
    else
        addedSig=false;
    end
end




function writeDataFile(this,fName,LUTData)
    dataFilePath=fullfile(this.CodeGenDirectory,fName);
    msg=message('HDLShared:hdlshared:gentbdatafile',...
    hdlgetfilelink(dataFilePath));
    hdldisp(msg.getString,1);
    charsPerLine=numel(LUTData(1,:));
    fmtString=[repmat('%c',1,charsPerLine),'\n'];
    fid=fopen(dataFilePath,'wt');
    fprintf(fid,fmtString,LUTData');
    fclose(fid);
end



function createSnkDoneLogic(this,topN,snkDoneSigs,snkDone,globalSigs)
    bitT=topN.getType('FixedPoint','Signed',0,'WordLength',1,'FractionLength',0);
    numOut=numel(snkDoneSigs);
    checkDoneSigs=hdlhandles(1,numOut);
    for ii=1:numOut
        port=this.OutportSnk(ii);
        checkDoneEnb=topN.addSignal(bitT,sprintf('%s_enb',snkDoneSigs(ii).Name));
        pirelab.getLogicComp(topN,[snkDoneSigs(ii),port.dataRdEnb],...
        checkDoneEnb,'and');
        checkDoneSigs(ii)=topN.addSignal(bitT,sprintf('check%d_done',ii));
        checkDoneName=sprintf('checkDone_%d',ii);
        topN.addComponent2('kind','register','name',...
        checkDoneName,'datainput',snkDoneSigs(ii),'dataoutput',...
        checkDoneSigs(ii),'clock',globalSigs(1),'reset',globalSigs(2),...
        'clockenable',checkDoneEnb,...
        'blockcomment','Delay to allow last sim cycle to complete');
    end

    pirelab.getLogicComp(topN,checkDoneSigs,snkDone,'and');
end



function dataRdEnb=getPortReadEnb(this,port,topN,isInput)
    if~isInput&&this.isTextIOSupported


        dataRdEnb=topN.findSignal('name',port.ClockEnable.Name);
    else
        dataRdEnb=[];
    end
    if isempty(dataRdEnb)
        dataRdEnb=port.dataRdEnb;
    end
end

function baseDataT=recordextraction(port)
    idx=hdlsignalfindname(port.HDLPortName{1});
    baseDataT=idx.Type;
end



function[formattedData,idx]=getFormattedData(this,hT1,LUTData1,lutSz,idx)
    f=[];
    fields=fieldnames(LUTData1);
    for i=1:numel(fields)
        ldims=1;
        elemVal=LUTData1.(fields{i});
        if(isstruct(elemVal))
            [f1,idx]=getFormattedData(this,hT1,[LUTData1.(fields{i})],lutSz,idx);
            f=[f,f1];
        else
            LUTData=elemVal;
            hT=hT1.MemberTypesFlattened(idx);
            if hT.isArrayType

                [ldims,hT]=pirelab.getVectorTypeInfo(hT);
            end
            lutSz=numel(LUTData)/prod(ldims);
            idx=idx+1;
            if hT.isFloatType
                sign=1;
                size=0;
                bp=0;
                if numel(ldims)>1
                    dataTmpsz=[ldims(1),ldims(2),lutSz];
                else
                    dataTmpsz=[lutSz,ldims];
                end

                if targetcodegen.targetCodeGenerationUtils.isFloatingPointMode()
                    sign=0;
                    if hT.isDoubleType
                        size=64;
                        datatmp=zeros(dataTmpsz,'uint64');
                        for ii=1:lutSz
                            if numel(ldims)>1
                                for jj=1:ldims(2)
                                    datatmp(:,jj,ii)=typecast(double(LUTData(:,jj,ii)),'uint64');
                                end
                            else
                                datatmp(ii,:)=typecast(double(LUTData(ii,:)),'uint64');
                            end
                        end
                    elseif hT.isHalfType
                        size=16;
                        datatmp=zeros(dataTmpsz,'uint16');
                        for ii=1:lutSz



                            if numel(ldims)>1
                                for jj=1:ldims(2)
                                    datatmp(:,jj,ii)=half(LUTData(:,jj,ii)).storedInteger;
                                end
                            else
                                datatmp(ii,:)=half(LUTData(ii,:)).storedInteger;
                            end
                        end
                    else
                        size=32;
                        datatmp=zeros(dataTmpsz,'uint32');
                        for ii=1:lutSz
                            if numel(ldims)>1
                                for jj=1:ldims(2)
                                    datatmp(:,jj,ii)=typecast(single(LUTData(:,jj,ii)),'uint32');
                                end
                            else
                                datatmp(ii,:)=typecast(single(LUTData(ii,:)),'uint32');
                            end
                        end
                    end
                    LUTData=datatmp;
                end
            elseif hT.isLogicType
                sign=0;
                size=hT.WordLength;
                bp=0;
            else
                sign=hT.Signed;
                size=hT.WordLength;
                bp=hT.FractionLength;
            end
            formattedData=[];

            if numel(ldims)>1
                for jj=1:lutSz
                    fdata=this.formatDataAsText(LUTData(:,:,jj),sign,size,bp);
                    formattedData=[formattedData;fdata];%#ok<AGROW>
                end
            else
                formattedData=this.formatDataAsText(LUTData,sign,size,bp);
            end
            f=[f,formattedData];
        end
    end
    formattedData=f;
end
function constzerostruct=getConstZeroStruct(LUTData)
    fields=fieldnames(LUTData);
    for i=1:numel(fields)
        elemVal=LUTData.(fields{i});
        if(isstruct(elemVal))
            elemVal=getConstZeroStruct(elemVal);
        else
            elemVal(:)=0;
        end
        constzerostruct.(fields{i})=elemVal;
    end
end
