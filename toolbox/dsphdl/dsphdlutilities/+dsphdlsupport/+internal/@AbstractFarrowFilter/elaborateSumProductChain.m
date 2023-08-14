function sumProductNet=elaborateSumProductChain(this,topNet,blockInfo,sigInfo,dataRate)







    booleanT=sigInfo.booleanT;
    filterVecType=sigInfo.filterVecType;

    multiplicandTypemask=blockInfo.MultiplicandDataType;
    fracdelayType=blockInfo.FractionalDelayDataType;
    multiplicandS=multiplicandTypemask.Signed;

    if multiplicandS==0
        multiplicandWL=multiplicandTypemask.WordLength+1;
    else
        multiplicandWL=multiplicandTypemask.WordLength;
    end

    multiplicandFL=(multiplicandTypemask.FractionLength);
    multiplicandType=pir_fixpt_t(1,multiplicandWL,multiplicandFL);
    outType=blockInfo.OutputDataType;

    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');

    targetWL=1;
    if strcmpi(blockInfo.synthesisTool,'Xilinx Vivado')||strcmpi(blockInfo.synthesisTool,'Xilinx ISE')
        targetWL=blockInfo.XILINX_MAXOUTPUT_WORDLENGTH;
    elseif strcmpi(blockInfo.synthesisTool,'Altera Quartus II')
        targetWL=blockInfo.ALTERA_MAXOUTPUT_WORDLENGTH;
    end


    if isa(outType,'hdlcoder.tp_complex')
        outWL=outType.BaseType.WordLength;
        outFL=outType.BaseType.FractionLength;
        if outType.BaseType.Signed==0
            outWL=outWL+1;
        end
        outTypeT=(pir_fixpt_t(1,outWL,outFL));
        outTypeTC=pir_complex_t(outTypeT);
        outTypeRe=pir_fixpt_t(1,outWL,outFL);
        firType=blockInfo.FIROutputype;
        firWL=firType.BaseType.WordLength;
        firFL=firType.BaseType.FractionLength*-1;
        firsigned=firType.BaseType.Signed;
        firTypeRe=(pir_fixpt_t(firsigned,firWL,-firFL));
        firTargetType=(pir_fixpt_t(firsigned,max(targetWL,firWL),-firFL));
        multiplierOutputWL=outWL+multiplicandWL;
        multiplierOutputFL=outFL-multiplicandFL;
        multiplierOutputType=(pir_fixpt_t(1,multiplierOutputWL,multiplierOutputFL));
        addOutWL=max([multiplierOutputWL,firWL])+ceil(log2(blockInfo.FilterOrder)+1);
        addOutFL=max([multiplierOutputFL*-1,firFL]);
        addOutputType=(pir_fixpt_t(firsigned,addOutWL,addOutFL*-1));
        targetFL=multiplicandFL+outFL;
        targetOutputType=pir_fixpt_t(1,max(addOutWL,targetWL),targetFL);
        filterVecTypeBT=filterVecType.BaseType.BaseType;
        dim=filterVecType.Dimensions;
        filterVecTypeRe=pirelab.getPirVectorType(filterVecTypeBT,[dim,1],1);
        dspOutWL=max(addOutWL,targetWL);
    else
        outWL=outType.WordLength;
        outFL=outType.FractionLength;
        if outType.Signed==0
            outWL=outWL+1;
        end
        outTypeT=pir_fixpt_t(1,outWL,outFL);
        firType=blockInfo.FIROutputype;
        firWL=firType.WordLength;
        firFL=firType.FractionLength*-1;
        firsigned=firType.Signed;
        firTargetType=pir_fixpt_t(firType.Signed,max(targetWL,firWL),-firFL);
        multiplierOutputWL=outWL+multiplicandWL;
        multiplierOutputFL=outFL-multiplicandFL;
        multiplierOutputType=pir_fixpt_t(1,multiplierOutputWL,multiplierOutputFL);
        addOutWL=max([multiplierOutputWL,firWL])+ceil(log2(blockInfo.FilterOrder));
        addOutFL=max([multiplierOutputFL*-1,firFL]);
        addOutputType=pir_fixpt_t(1,addOutWL,addOutFL*-1);
        targetFL=multiplicandFL+outFL;
        targetOutputType=pir_fixpt_t(1,max(addOutWL,targetWL),targetFL);
        dspOutWL=max(addOutWL,targetWL);
    end

    if blockInfo.ResetInputPort
        inPortNames={'dataIn','validIn','fracDelay','syncReset'};
        inPortTypes=[filterVecType,booleanT,fracdelayType,booleanT];
        inPortRates=[dataRate,dataRate,dataRate,dataRate];
    else
        inPortNames={'dataIn','validIn','fracDelay'};
        inPortTypes=[filterVecType,booleanT,fracdelayType];
        inPortRates=[dataRate,dataRate,dataRate];
    end
    outPortNames={'dataOut','validOut'};
    outPortTypes=[outType,booleanT];

    sumProductNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','SumProductChain',...
    'InportNames',inPortNames,...
    'InportTypes',inPortTypes,...
    'InportRates',inPortRates,...
    'OutportNames',outPortNames,...
    'OutportTypes',outPortTypes...
    );

    inSignals=sumProductNet.PirInputSignals;
    dataIn=inSignals(1);
    validIn=inSignals(2);
    fracDelay=inSignals(3);

    outSignals=sumProductNet.PirOutputSignals;
    dataOut=outSignals(1);
    validOut=outSignals(2);

    if blockInfo.ResetInputPort
        syncReset=inSignals(4);
    else
        syncReset=sumProductNet.addSignal2('Type',booleanT,'Name','syncRST');
        syncReset.SimulinkRate=dataRate;
        pirelab.getConstComp(sumProductNet,syncReset,0);
    end

    if isa(outType,'hdlcoder.tp_complex')

        dataInRe=sumProductNet.addSignal2('Type',filterVecTypeRe,'Name','dataInRe');
        dataInIm=sumProductNet.addSignal2('Type',filterVecTypeRe,'Name','dataInIm');

        for ii=1:1:blockInfo.FilterOrder

            dataVectorInRe(ii)=sumProductNet.addSignal2('Type',firTypeRe,'Name',['dataVectorInRe',num2str(ii)]);
            dataVectorInIm(ii)=sumProductNet.addSignal2('Type',firTypeRe,'Name',['dataVectorInIm',num2str(ii)]);
            dataVectorCastRe(ii)=sumProductNet.addSignal2('Type',targetOutputType,'Name',['dataVectorCastRe',num2str(ii)]);
            dataVectorCastIm(ii)=sumProductNet.addSignal2('Type',targetOutputType,'Name',['dataVectorCastIm',num2str(ii)]);

            fracDelayCast=sumProductNet.addSignal2('Type',multiplicandType,'Name',['fracDelayCast',num2str(ii)]);
            multIn(ii)=sumProductNet.addSignal2('Type',outType,'Name',['multInRe',num2str(ii)]);
            multInRe(ii)=sumProductNet.addSignal2('Type',outTypeT,'Name',['multInRe',num2str(ii)]);
            multInIm(ii)=sumProductNet.addSignal2('Type',outTypeT,'Name',['multInIm',num2str(ii)]);
            multOutRe(ii)=sumProductNet.addSignal2('Type',targetOutputType,'Name',['multOutRe',num2str(ii)]);
            multOutIm(ii)=sumProductNet.addSignal2('Type',targetOutputType,'Name',['multOutIm',num2str(ii)]);
            addOutRe(ii)=sumProductNet.addSignal2('Type',addOutputType,'Name',['addOutRe',num2str(ii)]);
            addOutIm(ii)=sumProductNet.addSignal2('Type',addOutputType,'Name',['addOutIm',num2str(ii)]);
            dOutRe(ii)=sumProductNet.addSignal2('Type',outTypeT,'Name','dOutRe');
            dOutIm(ii)=sumProductNet.addSignal2('Type',outTypeT,'Name','dOutIm');
            dOut(ii).SimulinkRate=dataRate;
        end


        productSum=elabProductSum(this,sumProductNet,blockInfo,dataRate,...
        multInRe(1),fracDelayCast,dataVectorCastRe(1),syncReset,dOutRe(1),multOutRe(1),...
        outWL,outFL,...
        multiplicandWL,multiplicandFL,...
        dspOutWL,targetFL);%#ok<*NASGU>

        pirelab.getComplex2RealImag(sumProductNet,dataIn,[dataInRe,dataInIm]);
        pirelab.getDemuxComp(sumProductNet,dataInRe,dataVectorInRe);
        pirelab.getDemuxComp(sumProductNet,dataInIm,dataVectorInIm);

        pirelab.getDTCComp(sumProductNet,fracDelay,fracDelayCast,blockInfo.RoundingMethod,blockInfo.OverflowAction);

        for ii=1:1:blockInfo.FilterOrder-1

            if ii==1
                pirelab.getDTCComp(sumProductNet,dataVectorInRe(1),multInRe(1),blockInfo.RoundingMethod,blockInfo.OverflowAction);
                pirelab.getDTCComp(sumProductNet,dataVectorInIm(1),multInIm(1),blockInfo.RoundingMethod,blockInfo.OverflowAction);
            end




            dataVectorREGRe(ii)=sumProductNet.addSignal2('Type',firTypeRe,'Name',['dataVectorREGRe',num2str(ii)]);
            dataVectorREGIm(ii)=sumProductNet.addSignal2('Type',firTypeRe,'Name',['dataVectorREGIm',num2str(ii)]);
            pirelab.getDTCComp(sumProductNet,dataVectorREGRe(ii),dataVectorCastRe(ii));
            pirelab.getDTCComp(sumProductNet,dataVectorREGIm(ii),dataVectorCastIm(ii));
            fracDelayREG(ii)=sumProductNet.addSignal2('Type',multiplicandType,'Name',['fracDelayREG',num2str(ii)]);

            pirelab.getIntDelayComp(sumProductNet,dataVectorInRe(ii+1),dataVectorREGRe(ii),ii*3+((ii-1)));
            pirelab.getIntDelayComp(sumProductNet,dataVectorInIm(ii+1),dataVectorREGIm(ii),ii*3+((ii-1)));

            if ii==1
                pirelab.getWireComp(sumProductNet,fracDelayCast,fracDelayREG(1));
            else
                pirelab.getIntDelayComp(sumProductNet,fracDelayREG(ii-1),fracDelayREG(ii),4);
            end

            pirelab.instantiateNetwork(sumProductNet,productSum,...
            [multInRe(ii),fracDelayREG(ii),dataVectorCastRe(ii),syncReset],...
            [dOutRe(ii),multOutRe(ii)],...
            ['ProductSumRe',int2str(ii)]);

            pirelab.instantiateNetwork(sumProductNet,productSum,...
            [multInIm(ii),fracDelayREG(ii),dataVectorCastIm(ii),syncReset],...
            [dOutIm(ii),multOutIm(ii)],...
            ['ProductSumIm',int2str(ii)]);


            pirelab.getDTCComp(sumProductNet,multOutRe(ii),multInRe(ii+1),blockInfo.RoundingMethod,blockInfo.OverflowAction);
            pirelab.getDTCComp(sumProductNet,multOutIm(ii),multInIm(ii+1),blockInfo.RoundingMethod,blockInfo.OverflowAction);
        end
    else
        for ii=1:1:blockInfo.FilterOrder
            dataVectorIn(ii)=sumProductNet.addSignal2('Type',firType,'Name',['dataVectorIn',num2str(ii)]);
            dataVectorCast(ii)=sumProductNet.addSignal2('Type',targetOutputType,'Name',['dataVectorCast',num2str(ii)]);
            fracDelayCast=sumProductNet.addSignal2('Type',multiplicandType,'Name',['fracDelayCast',num2str(ii)]);
            multIn(ii)=sumProductNet.addSignal2('Type',outTypeT,'Name',['multIn',num2str(ii)]);
            multOut(ii)=sumProductNet.addSignal2('Type',targetOutputType,'Name',['multOut',num2str(ii)]);
            addOut(ii)=sumProductNet.addSignal2('Type',addOutputType,'Name',['addOut',num2str(ii)]);
            dOut(ii)=sumProductNet.addSignal2('Type',outTypeT,'Name','dOut');
            dOut(ii).SimulinkRate=dataRate;
        end


        productSum=elabProductSum(this,sumProductNet,blockInfo,dataRate,...
        multIn(1),fracDelayCast,dataVectorCast(1),syncReset,dOut(1),multOut(1),...
        outWL,outFL,...
        multiplicandWL,multiplicandFL,...
        dspOutWL,targetFL);%#ok<*NASGU>

        pirelab.getDemuxComp(sumProductNet,dataIn,dataVectorIn);
        pirelab.getDTCComp(sumProductNet,fracDelay,fracDelayCast,blockInfo.RoundingMethod,blockInfo.OverflowAction);

        for ii=1:1:blockInfo.FilterOrder-1

            if ii==1
                pirelab.getDTCComp(sumProductNet,dataVectorIn(1),multIn(1),blockInfo.RoundingMethod,blockInfo.OverflowAction);
            end




            dataVectorREG(ii)=sumProductNet.addSignal2('Type',firType,'Name',['dataVectorREG',num2str(ii)]);
            pirelab.getDTCComp(sumProductNet,dataVectorREG(ii),dataVectorCast(ii));
            fracDelayREG(ii)=sumProductNet.addSignal2('Type',multiplicandType,'Name',['fracDelayREG',num2str(ii)]);

            pirelab.getIntDelayComp(sumProductNet,dataVectorIn(ii+1),dataVectorREG(ii),ii*3+((ii-1)));

            if ii==1
                pirelab.getWireComp(sumProductNet,fracDelayCast,fracDelayREG(1));
            else
                pirelab.getIntDelayEnabledResettableComp(sumProductNet,fracDelayREG(ii-1),fracDelayREG(ii),'',syncReset,4);
            end

            pirelab.instantiateNetwork(sumProductNet,productSum,...
            [multIn(ii),fracDelayREG(ii),dataVectorCast(ii),syncReset],...
            [dOut(ii),multOut(ii)],...
            ['ProductSum',int2str(ii)]);

            pirelab.getDTCComp(sumProductNet,multOut(ii),multIn(ii+1),blockInfo.RoundingMethod,blockInfo.OverflowAction);
        end


    end


    validSwitch=sumProductNet.addSignal2('Type',booleanT,'Name','validSwitch');
    dataZero=sumProductNet.addSignal2('Type',outType,'Name','dataZero');
    dataZero.SimulinkRate=dataRate;
    pirelab.getConstComp(sumProductNet,dataZero,0);
    dataSwitch=sumProductNet.addSignal2('Type',outType,'Name','dataSwitch');
    dataCast=sumProductNet.addSignal2('Type',outType,'Name','dataCast');

    validEn=sumProductNet.addSignal2('Type',booleanT,'Name','validEn');
    validEn.SimulinkRate=dataRate;
    pirelab.getConstComp(sumProductNet,validEn,1);

    if isa(outType,'hdlcoder.tp_complex')
        multInPre=sumProductNet.addSignal2('Type',outTypeTC,'Name',['multInpRE',num2str(ii)]);
        pirelab.getRealImag2Complex(sumProductNet,[multInRe(blockInfo.FilterOrder),multInIm(blockInfo.FilterOrder)],multInPre);
        pirelab.getDTCComp(sumProductNet,multInPre,multIn(blockInfo.FilterOrder),blockInfo.RoundingMethod,blockInfo.OverflowAction);
    end

    pirelab.getDTCComp(sumProductNet,multIn(blockInfo.FilterOrder),dataCast,blockInfo.RoundingMethod,blockInfo.OverflowAction);
    pirelab.getSwitchComp(sumProductNet,[dataZero,dataCast],dataSwitch,validSwitch);

    if blockInfo.ResetInputPort
        pirelab.getUnitDelayEnabledResettableComp(sumProductNet,dataSwitch,dataOut,'',syncReset,'dataOutREG',0,'',true','',-1,true);
    else
        pirelab.getUnitDelayComp(sumProductNet,dataSwitch,dataOut);
    end

    if blockInfo.ResetInputPort
        pirelab.getIntDelayEnabledResettableComp(sumProductNet,validIn,validSwitch,'',syncReset,...
        ((blockInfo.FilterOrder-1)*4));
    else
        pirelab.getIntDelayComp(sumProductNet,validIn,validSwitch,((blockInfo.FilterOrder-1)*4));
    end
    if blockInfo.ResetInputPort
        pirelab.getUnitDelayEnabledResettableComp(sumProductNet,validSwitch,validOut,'',syncReset,'validOutREG',0,'',true','',-1,true);
    else
        pirelab.getUnitDelayComp(sumProductNet,validSwitch,validOut);
    end





