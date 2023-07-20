function hNewtonNet=getRecipNewtonNetwork(topNet,hInSignals,hOutSignals,newtonInfo)













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



    pirelab.getAnnotationComp(hNewtonNet,'anno','Multi-rate Reciprocal Implementation using Reciprocal Newton Method');


    hdlarch.newton.getRecipNewtonComp(hNewtonNet,din,dout,newtonInfo);
