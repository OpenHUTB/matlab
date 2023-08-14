function hNewtonNet=getRecipSqrtNewtonSingleRateNetwork(topNet,hInSignals,hOutSignals,newtonInfo)




















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


    pirelab.getAnnotationComp(hNewtonNet,'anno','RecipSqrt Implementation using Newton Method');


    hdlarch.newton.getRecipSqrtNewtonSingleRateComp(hNewtonNet,din,dout,newtonInfo);

