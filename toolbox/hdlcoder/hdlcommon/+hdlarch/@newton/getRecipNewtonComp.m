function getRecipNewtonComp(hN,hInSignals,hOutSignals,newtonInfo)












    newtonInfo=initialize_parameters(newtonInfo);


    rndMode=newtonInfo.rndMode;
    satMode=newtonInfo.satMode;

    iterNum=newtonInfo.iterNum;

    din=hInSignals(1);
    dout=hOutSignals(1);


    inputType=din.Type;

    outputType=dout.Type;

    inputWL=inputType.Wordlength;
    output_ex=pirelab.getTypeInfoAsFi(outputType,'Floor',satMode);
    output_ex.ProductMode='SpecifyPrecision';
    output_ex.ProductWordLength=inputWL;
    output_ex.ProductFractionLength=inputWL-2;
    output_ex.SumMode='SpecifyPrecision';
    output_ex.SumWordLength=inputWL;
    output_ex.SumFractionLength=inputWL-2;
    newtonInfo.output_ex=output_ex;


    ufix1Type=pir_ufixpt_t(1,0);


    inSigned=inputType.Signed;
    inputWL=inputType.WordLength;






    intermWL=inputWL;
    intermFL=-inputType.FractionLength;
    if intermFL>intermWL
        intermWL=intermFL;
    end
    newtonInfo.intermType=pir_ufixpt_t(intermWL,-(intermWL-2));
    intermType=newtonInfo.intermType;




    sel=hN.addSignal(ufix1Type,'sel');
    cntRate=din.SimulinkRate;
    [~,hClkEnb,~]=hN.getClockBundle(din,2,1,0);
    cntComp=pireml.getCounterLimitedComp(hN,sel,1,cntRate,'sel_cnt',0,false,hClkEnb);
    cntComp.addComment('Selector signal counter');


    [anorm,dynamicshift,normFixedShift,onemoreshift,changesign]=hdlarch.newton.getRecipNewtonInputComp(hN,hInSignals);
    normType=anorm.Type;
    newtonInfo.normType=normType;
    xinit=hN.addSignal(intermType,'x0');
    xinit.SimulinkRate=din.SimulinkRate;



    anorm_p=hN.addSignal(anorm.Type,'anorm_p');
    pireml.getConstComp(hN,xinit,1);
    pireml.getUnitDelayComp(hN,anorm,anorm_p,'anorm_reg');

    onemoreshift_p=hN.addSignal(ufix1Type,'onemoreshift_p');
    pireml.getIntDelayComp(hN,onemoreshift,onemoreshift_p,(1+iterNum),'onemoreshift_reg');



    inzero=hN.addSignal(ufix1Type,'inzero');
    mstwobit=hN.addSignal(ufix1Type,'mstwobit');
    normWL=normType.WordLength;
    pireml.getBitSliceComp(hN,anorm_p,mstwobit,normWL-1,normWL-1);
    pireml.getCompareToValueComp(hN,mstwobit,inzero,'==',0);



    tSignalsIn=[xinit,anorm_p,sel];
    hCoreNet=hdlarch.newton.getNewtonRecipCoreNetwork(hN,tSignalsIn,newtonInfo);



    for stageNum=1:iterNum

        xstage=hN.addSignal(intermType,sprintf('xstage%d',stageNum));
        astage=hN.addSignal(normType,sprintf('astage%d',stageNum));
        tSignalsOut=[xstage,astage];











        pirelab.instantiateNetwork(hN,hCoreNet,tSignalsIn,tSignalsOut,sprintf('core_stage%d_inst',stageNum));
        tSignalsIn=[tSignalsOut,sel];
    end


    dynamicshift_p=hN.addSignal(dynamicshift.Type,'dynamicshift_p');
    dsregComp=pireml.getIntDelayComp(hN,dynamicshift,dynamicshift_p,(1+iterNum),'ds_reg');
    dsregComp.addComment('Pipeline registers');



    inzero_p=hN.addSignal(ufix1Type,'inzero_p');
    d4Comp=pireml.getIntDelayComp(hN,inzero,inzero_p,iterNum,'inzero_reg');
    d4Comp.addComment('Pipeline registers');


    isSaturate=(~ischar(satMode)&&satMode)||strcmpi(satMode,'saturate');
    if isSaturate
        infValue=pirelab.getTypeInfoAsFi(outputType,rndMode,satMode,upperbound(output_ex));
    else
        infValue=pirelab.getTypeInfoAsFi(outputType);
    end
    constInf=hN.addSignal(outputType,'constInf');
    constInf.SimulinkRate=din.SimulinkRate;
    pireml.getConstComp(hN,constInf,infValue);

    denormout=hN.addSignal(outputType,'denormout');
    tSignalsIn=[tSignalsOut(1),dynamicshift_p,onemoreshift_p];


    if inSigned
        changesign_p=hN.addSignal(ufix1Type,'changesign_p');
        pireml.getIntDelayComp(hN,changesign,changesign_p,(1+iterNum),'changesign_reg');

        absdenormout=hN.addSignal(outputType,'absdenormout');
        hdlarch.newton.getRecipNewtonOutputComp(hN,tSignalsIn,absdenormout,newtonInfo,normFixedShift);
        negdenormout=hN.addSignal(outputType,'negdenormout');
        pireml.getUnaryMinusComp(hN,absdenormout,negdenormout);

        tSignalIn=[negdenormout,absdenormout];
        signSwComp=pireml.getSwitchComp(hN,[changesign_p,tSignalIn],denormout);

        signSwComp.addComment('Change output sign');
    else
        hdlarch.newton.getRecipNewtonOutputComp(hN,tSignalsIn,denormout,newtonInfo,normFixedShift);
    end


    tSignalIn=[constInf,denormout];
    swComp=pireml.getSwitchComp(hN,[inzero_p,tSignalIn],dout);
    swComp.addComment('Zero input logic');
end

function newtonInfo=initialize_parameters(newtonInfo)

    if~isfield(newtonInfo,'iterNum')
        newtonInfo.iterNum=3;
    end

    if~isfield(newtonInfo,'intermDT')
        newtonInfo.intermDT='Input';
    end

    if~isfield(newtonInfo,'internalRule')
        newtonInfo.internalRule='';
    end

    if~isfield(newtonInfo,'rndMode')
        newtonInfo.rndMode='Floor';
    end

    if~isfield(newtonInfo,'satMode')
        newtonInfo.satMode='Saturate';
    end

    if~isfield(newtonInfo,'networkName')
        newtonInfo.networkName='rsqrt_newton';
    end

end


