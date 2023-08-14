function hPIVNet=getNewtonPolynomialIVSingleRateNetwork(topNet,hInSignals,hOutSignals,newtonInfo)




    topain=hInSignals(1);
    topxinit=hOutSignals(1);
    topinzero=hOutSignals(2);
    topaout=hOutSignals(3);


    hPIVNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name',sprintf('%s_iv',newtonInfo.networkName),...
    'InportNames',{'ain'},...
    'InportTypes',[topain.Type],...
    'InportRates',[topain.SimulinkRate],...
    'OutportNames',{'xinit','inzero','aout'},...
    'OutportTypes',[topxinit.Type,topinzero.Type,topaout.Type]);


    ain=hPIVNet.PirInputSignals(1);
    xinit=hPIVNet.PirOutputSignals(1);
    inzero=hPIVNet.PirOutputSignals(2);
    aout=hPIVNet.PirOutputSignals(3);


    pirelab.getAnnotationComp(hPIVNet,'anno',...
    'Polynomial initial value stage of the RecipSqrtSingleRate Implementation using Newton Method');


    intermType=newtonInfo.intermType;
    normType=ain.Type;
    ufix2Type=pir_ufixpt_t(2,0);

    rndMode=newtonInfo.rndMode;
    satMode='Wrap';









    intermWL=intermType.WordLength;
    constAType=pir_sfixpt_t(intermWL,-(intermWL-2));
    constBType=pir_sfixpt_t(intermWL,-(intermWL-3));

    constAval=pirelab.getTypeInfoAsFi(constAType,'Nearest','Wrap',1.59320045511401);
    constBval=pirelab.getTypeInfoAsFi(constBType,'Nearest','Wrap',3.18258902474452);
    constCval=pirelab.getTypeInfoAsFi(constBType,'Nearest','Wrap',2.62566612941744);








    constBcast=pirelab.getTypeInfoAsFi(intermType,rndMode,satMode,constBval);
    constCcast=pirelab.getTypeInfoAsFi(intermType,rndMode,satMode,constCval);


    constBneg=pirelab.getTypeInfoAsFi(intermType,rndMode,satMode,-constBcast);



    multmpType=pir_sfixpt_t(intermWL+2,constAType.FractionLength);


    constAcast=pirelab.getTypeInfoAsFi(multmpType,rndMode,satMode,constAval);


    xinitreg=hPIVNet.addSignal(intermType,'xinitreg');
    xinitregmul=hPIVNet.addSignal(multmpType,'xinitreg');
    constA=hPIVNet.addSignal(multmpType,'constA');
    constA.SimulinkRate=ain.SimulinkRate;
    constB=hPIVNet.addSignal(intermType,'constB');
    constB.SimulinkRate=ain.SimulinkRate;
    constC=hPIVNet.addSignal(intermType,'constC');
    constC.SimulinkRate=ain.SimulinkRate;

    constC_p=hPIVNet.addSignal(intermType,'constC_p');
    constC_p.SimulinkRate=ain.SimulinkRate;


    aind2Comp=pireml.getIntDelayComp(hPIVNet,ain,aout,2,'ain_reg');
    aind2Comp.addComment('Pipeline registers');


    constCcomp=pireml.getIntDelayComp(hPIVNet,constC,constC_p,4,'constC_reg');
    constCcomp.addComment('Pipeline registers');


    inportNames={'ain','mulin','adderin'};
    inportTypes=[ain.Type,multmpType,intermType];
    inportRates=[ain.SimulinkRate,constA.SimulinkRate,constB.SimulinkRate];

    hNewNet=pirelab.createNewNetwork('Network',hPIVNet,...
    'Name','NewtonPolynomialIVStage',...
    'InportNames',inportNames,...
    'InportTypes',inportTypes,...
    'InportRates',inportRates,...
    'InportKinds',[],...
    'OutportNames',{'xinitinterm'},...
    'OutportTypes',[xinit.Type]);

    hdlarch.newton.getNewtonPolynomialIVStageComp(hNewNet,hNewNet.PirInputSignals,hNewNet.PirOutputSignals,newtonInfo);

    tSignalsIn=[ain,constA,constB];
    pirelab.instantiateNetwork(hPIVNet,hNewNet,tSignalsIn,xinitreg,'NewtonPolynomialIVStage1');
    tSignalsIn=[aout,xinitregmul,constC_p];
    pirelab.instantiateNetwork(hPIVNet,hNewNet,tSignalsIn,xinit,'NewtonPolynomialIVStage2');


    pirelab.getDTCComp(hPIVNet,xinitreg,xinitregmul);


    pirelab.getConstComp(hPIVNet,constA,constAcast);
    pirelab.getConstComp(hPIVNet,constB,constBneg);
    pirelab.getConstComp(hPIVNet,constC,constCcast);


    mstwobit=hPIVNet.addSignal(ufix2Type,'mstwobit');
    normWL=normType.WordLength;
    pirelab.getBitSliceComp(hPIVNet,ain,mstwobit,normWL-1,normWL-2);
    pirelab.getCompareToValueComp(hPIVNet,mstwobit,inzero,'==',0);


