function hNewtonNet=getSqrtNewtonNetwork(topNet,hInSignals,hOutSignals,newtonInfo)





















    hNewtonNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',newtonInfo.networkName,...
    'InportNames',{'din'},...
    'InportTypes',[hInSignals(1).Type],...
    'InportRates',[hInSignals(1).SimulinkRate],...
    'OutportNames',{'dout'},...
    'OutportTypes',[hOutSignals(1).Type]);


    din=hNewtonNet.PirInputSignals(1);
    dout=hNewtonNet.PirOutputSignals(1);


    pirelab.getAnnotationComp(hNewtonNet,'anno','Sqrt Implementation using RecipSqrt Newton Method');


    rsqrtoutType=hdlarch.newton.getNewtonSqrtType(din);


    rsnewtonInfo=newtonInfo;
    rsnewtonInfo.rndMode='Nearest';
    rsnewtonInfo.satMode='Saturate';
    rsqrt_out=hNewtonNet.addSignal(rsqrtoutType,'rsqrt_out');
    hdlarch.newton.getRecipSqrtNewtonComp(hNewtonNet,din,rsqrt_out,rsnewtonInfo);


    rsqrt_outp=hNewtonNet.addSignal(rsqrtoutType,'rsqrt_outp');
    d1Comp=pireml.getUnitDelayComp(hNewtonNet,rsqrt_out,rsqrt_outp,'rsqrt_out_reg');
    d1Comp.addComment('Pipeline register');


    din_p=hNewtonNet.addSignal(din.Type,'din_p');
    d2Comp=pireml.getIntDelayComp(hNewtonNet,din,din_p,newtonInfo.iterNum+3,'din_reg');
    d2Comp.addComment('Pipeline registers');


    rndMode=newtonInfo.rndMode;
    satMode=newtonInfo.satMode;
    tSignalIn=[rsqrt_outp,din_p];
    mulComp=pireml.getMulComp(hNewtonNet,tSignalIn,dout,rndMode,satMode,'mul');
    mulComp.addComment('Multiply RecipSqrt result by input');




