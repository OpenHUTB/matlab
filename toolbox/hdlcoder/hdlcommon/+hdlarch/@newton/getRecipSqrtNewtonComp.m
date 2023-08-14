function getRecipSqrtNewtonComp(hN,hInSignals,hOutSignals,newtonInfo)




















    newtonInfo=initialize_parameters(newtonInfo);


    rndMode=newtonInfo.rndMode;
    satMode=newtonInfo.satMode;

    din=hInSignals(1);
    dout=hOutSignals(1);

    ufix1Type=pir_ufixpt_t(1,0);
    ufix2Type=pir_ufixpt_t(2,0);


    outputType=dout.Type;
    output_ex=pirelab.getTypeInfoAsFi(outputType,rndMode,satMode);
    newtonInfo.output_ex=output_ex;


    intermType=hdlarch.newton.getNewtonRSqrtIntermType(hInSignals,hOutSignals,newtonInfo.intermDT,newtonInfo.internalRule);
    newtonInfo.intermType=intermType;
    newtonInfo.interm_ex=pirelab.getTypeInfoAsFi(intermType,rndMode,'Wrap');




    [anorm,dynamicshift,normFixedShift]=hdlarch.newton.getNewtonInputComp(hN,hInSignals);
    normType=anorm.Type;
    newtonInfo.normType=normType;


    sel=hN.addSignal(ufix2Type,'sel');
    cntRate=din.SimulinkRate;
    [~,hClkEnb,~]=hN.getClockBundle(din,3,1,0);
    cntComp=pireml.getCounterLimitedComp(hN,sel,2,cntRate,'sel_cnt',0,false,hClkEnb);
    cntComp.addComment('Selector signal counter');



    anorm_p=hN.addSignal(normType,'anorm_p');
    d1Comp=pireml.getUnitDelayComp(hN,anorm,anorm_p,'anorm_reg');
    d1Comp.addComment('Pipeline register');


    xinit=hN.addSignal(intermType,'xinit');
    inzero=hN.addSignal(ufix1Type,'inzero');
    tSignalsIn=[anorm_p,sel];
    tSignalsOut=[xinit,inzero];
    hPIVNet=hdlarch.newton.getNewtonPolynomialIVNetwork(hN,tSignalsIn,tSignalsOut,newtonInfo);
    pirelab.instantiateNetwork(hN,hPIVNet,tSignalsIn,tSignalsOut,'iv_stage_inst');


    anorm_p2=hN.addSignal(normType,'anorm_p2');
    d2Comp=pireml.getUnitDelayComp(hN,anorm_p,anorm_p2,'anorm_reg2');
    d2Comp.addComment('Pipeline registers');



    tSignalsIn=[xinit,anorm_p2,sel];
    hCoreNet=hdlarch.newton.getNewtonRSqrtCoreNetwork(hN,tSignalsIn,newtonInfo);


    iterNum=newtonInfo.iterNum;
    for stageNum=1:iterNum

        xstage=hN.addSignal(intermType,sprintf('xstage%d',stageNum));
        astage=hN.addSignal(normType,sprintf('astage%d',stageNum));
        tSignalsOut=[xstage,astage];











        pirelab.instantiateNetwork(hN,hCoreNet,tSignalsIn,tSignalsOut,sprintf('core_stage%d_inst',stageNum));
        tSignalsIn=[tSignalsOut,sel];
    end






    dynamicshift_p=hN.addSignal(dynamicshift.Type,'dynamicshift_p');
    d3Comp=pireml.getIntDelayComp(hN,dynamicshift,dynamicshift_p,iterNum+2,'ds_reg');
    d3Comp.addComment('Pipeline registers');

    denormout=hN.addSignal(outputType,'denormout');
    tSignalsIn=[tSignalsOut(1),dynamicshift_p];
    hdlarch.newton.getNewtonOutputComp(hN,tSignalsIn,denormout,newtonInfo,normFixedShift);



    inzero_p=hN.addSignal(ufix1Type,'inzero_p');
    d4Comp=pireml.getIntDelayComp(hN,inzero,inzero_p,iterNum+1,'inzero_reg');
    d4Comp.addComment('Pipeline registers');


    isSaturate=(~ischar(satMode)&&satMode)||strcmpi(satMode,'saturate');
    if isSaturate
        infValue=pirelab.getTypeInfoAsFi(outputType,rndMode,satMode,upperbound(output_ex));
    else
        infValue=pirelab.getTypeInfoAsFi(outputType);
    end
    constInf=hN.addSignal(outputType,'constInf');
    pireml.getConstComp(hN,constInf,infValue);


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



