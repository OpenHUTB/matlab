function getNewtonPolynomialIVStageComp(hN,hInSignals,hOutSignals,newtonInfo)






    ain=hInSignals(1);
    mulin=hInSignals(2);
    adderin=hInSignals(3);
    xinitinterm=hOutSignals(1);


    intermType=newtonInfo.intermType;

    rndMode=newtonInfo.rndMode;
    satMode='Wrap';










    mulout=hN.addSignal(intermType,'mulout');
    muloutreg=hN.addSignal(intermType,'muloutreg');
    sumout=hN.addSignal(intermType,'sumout');



    tSignalIn=[mulin,ain];
    pirelab.getMulComp(hN,tSignalIn,mulout,rndMode,satMode,'mul');


    pirelab.getUnitDelayComp(hN,mulout,muloutreg,'mul_reg');


    tSignalIn=[muloutreg,adderin];
    pirelab.getAddComp(hN,tSignalIn,sumout,rndMode,satMode);


    pirelab.getUnitDelayComp(hN,sumout,xinitinterm,'xinitinterm_reg');