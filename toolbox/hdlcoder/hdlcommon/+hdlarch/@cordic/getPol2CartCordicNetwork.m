function hCordicNet=getPol2CartCordicNetwork(topNet,hInSignals,hOutSignals,cordicInfo)











    hCordicNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',cordicInfo.networkName,...
    'InportNames',{'magnitude','angle'},...
    'InportTypes',[hInSignals(1).Type,hInSignals(2).Type],...
    'InportRates',[hInSignals(1).SimulinkRate,hInSignals(2).SimulinkRate],...
    'OutportNames',{'sin','cos'},...
    'OutportTypes',[hOutSignals(1).Type,hOutSignals(2).Type]);


    magnitude=hCordicNet.PirInputSignals(1);
    angle=hCordicNet.PirInputSignals(2);
    sin=hCordicNet.PirOutputSignals(1);
    cos=hCordicNet.PirOutputSignals(2);

    pirelab.getAnnotationComp(hCordicNet,'anno','CORDIC implementation for Magnitude-Angle to Complex');

    hdlarch.cordic.getPol2CartCordicComp(hCordicNet,[magnitude,angle],[sin,cos],cordicInfo);


