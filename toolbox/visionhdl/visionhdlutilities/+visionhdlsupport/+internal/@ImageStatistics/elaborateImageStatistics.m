function elaborateImageStatistics(this,topNet,blockInfo,insignals,outsignals)












    dataIn=insignals(1);
    hStart=insignals(2);
    hEnd=insignals(3);
    vStart=insignals(4);
    vEnd=insignals(5);
    validIn=insignals(6);


    dataRate=dataIn.SimulinkRate;




    num=1;
    if blockInfo.mean
        mean=outsignals(num);
        num=num+1;
    end
    if blockInfo.variance
        variance=outsignals(num);
        num=num+1;
    end
    if blockInfo.stdDev
        stdDev=outsignals(num);
        num=num+1;
    end
    validOut=outsignals(num);



    inpWL=dataIn.Type.WordLength;
    inpFL=dataIn.Type.FractionLength;
    dataInVT=pir_ufixpt_t((inpWL*2),-inpFL);
    lvlOneAccT=pir_ufixpt_t(inpWL+6,-inpFL);
    lvlTwoAccT=pir_ufixpt_t(inpWL+12,-6-inpFL);
    lvlThreeAccT=pir_ufixpt_t(inpWL+18,-12-inpFL);
    lvlFourAccT=pir_ufixpt_t(inpWL+24,-18-inpFL);
    lvlOneAccVT=pir_ufixpt_t((inpWL*2)+6,-inpFL);
    lvlTwoAccVT=pir_ufixpt_t((inpWL*2)+12,-6-inpFL);
    lvlThreeAccVT=pir_ufixpt_t((inpWL*2)+18,-12-inpFL);
    lvlFourAccVT=pir_ufixpt_t((inpWL*2)+24,-18-inpFL);
    accCountT=pir_ufixpt_t(6,0);
    pipeCountT=pir_ufixpt_t(2,0);
    normalizeT=pir_ufixpt_t((inpWL+24),-24-inpFL);
    normalizeVT=pir_ufixpt_t(((inpWL*2)+24),-24-inpFL);
    outT=pir_ufixpt_t(inpWL,-inpFL);
    outVT=pir_ufixpt_t(inpWL*2,-inpFL);
    recipT=pir_sfixpt_t(18,-17-inpFL);
    selT=pir_ufixpt_t(2,0);
    booleanT=pir_boolean_t();


    sigInfo.inType=pir_ufixpt_t(inpWL,0);
    sigInfo.lvlOneAccT=lvlOneAccT;
    sigInfo.lvlTwoAccT=lvlTwoAccT;
    sigInfo.lvlThreeAccT=lvlThreeAccT;
    sigInfo.lvlFourAccT=lvlFourAccT;
    sigInfo.accCountT=accCountT;
    sigInfo.pipeCountT=pipeCountT;
    sigInfo.normalizeT=normalizeT;
    sigInfo.normalizeVT=normalizeVT;
    sigInfo.outT=outT;
    sigInfo.selT=selT;
    sigInfo.booleanT=booleanT;
    sigInfo.recipT=recipT;
    sigInfo.dataInVT=dataInVT;
    sigInfo.lvlOneAccVT=lvlOneAccVT;
    sigInfo.lvlTwoAccVT=lvlTwoAccVT;
    sigInfo.lvlThreeAccVT=lvlThreeAccVT;
    sigInfo.lvlFourAccVT=lvlFourAccVT;


    meanNet=this.elaborateMeanCalc(topNet,blockInfo,sigInfo,dataRate);

    meanNetIn=[dataIn,hStart,hEnd,vStart,vEnd,validIn];

    validOutS=topNet.addSignal2('Type',booleanT,'Name','ValidOut');
    validOutPre=topNet.addSignal2('Type',booleanT,'Name','ValidOut');

    num=1;
    meanS=topNet.addSignal2('Type',normalizeT,'Name','Mean');
    meanNetOut(num)=meanS;
    num=num+1;

    if blockInfo.variance||blockInfo.stdDev
        meanSq=topNet.addSignal2('Type',normalizeVT,'Name','MeanInputSquared');
        meanSqPost=topNet.addSignal2('Type',normalizeVT,'Name','MeanInputSquared');
        meanSquared=topNet.addSignal2('Type',normalizeVT,'Name','MeanInputSquared');
        varTemp=topNet.addSignal2('Type',normalizeVT,'Name','Variance');
        varianceS=topNet.addSignal2('Type',outVT,'Name','Variance');
        meanNetOut(num)=meanSq;
        num=num+1;
    end
    meanNetOut(num)=validOutS;


    Mn=pirelab.instantiateNetwork(topNet,meanNet,meanNetIn,meanNetOut,'meanCalc');
    Mn.addComment('Mean Calculation');










    meanSig=topNet.addSignal2('Type',outT,'Name','Mean');
    pirelab.getDTCComp(topNet,meanS,meanSig,'Nearest','Wrap');
    if blockInfo.mean&&(~blockInfo.variance)&&(~blockInfo.stdDev)

        pirelab.getWireComp(topNet,meanSig,mean);
        pirelab.getWireComp(topNet,validOutS,validOut);
    elseif blockInfo.mean&&(blockInfo.variance)&&(~blockInfo.stdDev)

        pirelab.getIntDelayComp(topNet,meanSig,mean,4);
        pirelab.getIntDelayComp(topNet,validOutS,validOut,4);
    elseif blockInfo.mean&&blockInfo.stdDev


        pirelab.getIntDelayComp(topNet,validOutS,validOutPre,inpWL+4);
        pirelab.getUnitDelayComp(topNet,validOutPre,validOut);
        meanPre=topNet.addSignal2('Type',outT,'Name','Mean');
        pirelab.getIntDelayComp(topNet,meanSig,meanPre,inpWL+4);
        pirelab.getUnitDelayEnabledComp(topNet,meanPre,mean,validOutPre);

    elseif blockInfo.variance&&~blockInfo.stdDev
        pirelab.getIntDelayComp(topNet,validOutS,validOut,4);
    elseif blockInfo.stdDev
        pirelab.getIntDelayComp(topNet,validOutS,validOutPre,inpWL+4);
        pirelab.getUnitDelayComp(topNet,validOutPre,validOut);
    end




    if blockInfo.variance||blockInfo.stdDev




        meanSigPre1=topNet.addSignal2('Type',outT,'Name','preStagePipeline');
        meanSigPre2=topNet.addSignal2('Type',outT,'Name','preStagePipeline');
        meanSigPost1=topNet.addSignal2('Type',normalizeVT,'Name','postStagePipeline');
        meanSigPost2=topNet.addSignal2('Type',normalizeVT,'Name','postStagePipeline');
        pirelab.getUnitDelayComp(topNet,meanSig,meanSigPre1);
        pirelab.getUnitDelayComp(topNet,meanSigPre1,meanSigPre2);
        mm=pirelab.getMulComp(topNet,[meanSigPre2,meanSigPre2],meanSquared);
        pirelab.getUnitDelayComp(topNet,meanSquared,meanSigPost1);
        pirelab.getUnitDelayComp(topNet,meanSigPost1,meanSigPost2);
        mm.addComment('Square the Mean');
        pirelab.getIntDelayComp(topNet,meanSq,meanSqPost,4);
        mms=pirelab.getSubComp(topNet,[meanSqPost,meanSigPost2],varTemp);
        mms.addComment('Subtract mean squared from the mean of input squared');
        pirelab.getDTCComp(topNet,varTemp,varianceS,'Nearest','Wrap');

        if blockInfo.variance
            if blockInfo.stdDev
                variancePre=topNet.addSignal2('Type',outVT,'Name','Variance');
                pirelab.getIntDelayComp(topNet,varianceS,variancePre,inpWL);
                pirelab.getUnitDelayEnabledComp(topNet,variancePre,variance,validOutPre);
            else
                pirelab.getWireComp(topNet,varianceS,variance);
            end
        end

    end



    if blockInfo.stdDev

        devTemp=topNet.addSignal2('Type',outT,'Name','devTemp');
        devPre=topNet.addSignal2('Type',outT,'Name','devPre');
        sqrtInfo.algorithm='UseShift';
        sqrtInfo.pipeline='on';
        sqrtInfo.rndMode='Nearest';
        sqrtInfo.satMode='Wrap';
        sqrtInfo.networkName='SQRTBitSet';
        sqrtInfo.latencyStrategy='MAX';
        sqrtInfo.customLatency=0;
        sqrtInfo.vt=true;
        SQRNet=pirelab.getSqrtBitsetNetwork(topNet,varianceS,devTemp,sqrtInfo);
        SQR=pirelab.instantiateNetwork(topNet,SQRNet,varianceS,devTemp,'SQRT');
        SQR.addComment('Bit-Set Square Root Computation');
        pirelab.getDTCComp(topNet,devTemp,devPre,'Nearest','Wrap');
        pirelab.getUnitDelayEnabledComp(topNet,devPre,stdDev,validOutPre);
    end


