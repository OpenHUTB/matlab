function QuadrantBFnet=elabQuadrantMapper(this,topNet,sigInfo,blockInfo,dataRate)







    hTm=sigInfo.absdatatype;
    outMode=blockInfo.outMode;

    inportnames={'xin','yin'};

    if outMode(1)
        outportnames={'xout','yout'};
        outporttypes=[hTm,hTm];
    else
        outportnames={'xout','yout','QA_Control'};
        concatT=sigInfo.concatT;
        outporttypes=[hTm,hTm,concatT];

    end

    QuadrantBFnet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Quadrant_Mapper',...
    'InportNames',inportnames,...
    'InportTypes',[hTm,hTm],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',outportnames,...
    'OutportTypes',outporttypes...
    );


    QuadrantBFInput=QuadrantBFnet.PirInputSignals;
    QuadrantBFOutput=QuadrantBFnet.PirOutputSignals;
    QuadrantBFInput(1).SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;
    QuadrantBFInput(2).SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;
    QuadrantBFOutput(1).SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;
    QuadrantBFOutput(2).SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;

    xAbs=QuadrantBFnet.addSignal2('Type',hTm,'Name','xAbs');
    yAbs=QuadrantBFnet.addSignal2('Type',hTm,'Name','yAbs');
    xAbs.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;
    yAbs.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;

    xAbsReg=QuadrantBFnet.addSignal2('Type',hTm,'Name','xAbsReg');
    yAbsReg=QuadrantBFnet.addSignal2('Type',hTm,'Name','yAbsReg');
    xAbsReg.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;
    yAbsReg.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;

    zeros=QuadrantBFnet.addSignal2('Type',hTm,'Name','zeros');
    zeros.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;

    zeroConst=pirelab.getConstComp(QuadrantBFnet,zeros,0);

    hTcAbs1=pirelab.getAbsComp(QuadrantBFnet,QuadrantBFInput(1),xAbs);
    hTcAbs2=pirelab.getAbsComp(QuadrantBFnet,QuadrantBFInput(2),yAbs);

    pirelab.getUnitDelayComp(QuadrantBFnet,xAbs,xAbsReg,'DelayxAbs',0);
    pirelab.getUnitDelayComp(QuadrantBFnet,yAbs,yAbsReg,'DelayyAbs',0);

    booleanT=QuadrantBFnet.getType('FixedPoint','Signed',0,'WordLength',1,'FractionLength',0);

    AbsRel=QuadrantBFnet.addSignal2('Type',booleanT,'Name','XGreaterThanY');
    xNegative=QuadrantBFnet.addSignal2('Type',booleanT,'Name','xNegative');
    yNegative=QuadrantBFnet.addSignal2('Type',booleanT,'Name','yNegative');

    CompSig1=[xAbsReg,yAbsReg];
    hTcRel1=pirelab.getRelOpComp(QuadrantBFnet,CompSig1,AbsRel,'>',1);

    Mux1in=[yAbsReg,xAbsReg];
    Mux2in=[xAbsReg,yAbsReg];

    xmuxO=QuadrantBFnet.addSignal2('Type',hTm,'Name','xout');
    ymuxO=QuadrantBFnet.addSignal2('Type',hTm,'Name','yout');

    hTcMux1=pirelab.getSwitchComp(QuadrantBFnet,Mux1in,xmuxO,AbsRel);
    hTcMux2=pirelab.getSwitchComp(QuadrantBFnet,Mux2in,ymuxO,AbsRel);

    hTWO1=pirelab.getDTCComp(QuadrantBFnet,xmuxO,QuadrantBFOutput(1));
    hTWO2=pirelab.getDTCComp(QuadrantBFnet,ymuxO,QuadrantBFOutput(2));




    if((outMode(2))||(outMode(3)))

        concatT=QuadrantBFnet.getType('FixedPoint','Signed',0,'WordLength',3,'FractionLength',0);
        concatV=QuadrantBFnet.addSignal2('Type',concatT,'Name','qcControl');

        in1reg=QuadrantBFnet.addSignal2('Type',hTm,'Name','in1reg');
        in2reg=QuadrantBFnet.addSignal2('Type',hTm,'Name','in2reg');
        in1reg.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;
        in2reg.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;

        pirelab.getUnitDelayComp(QuadrantBFnet,QuadrantBFInput(1),in1reg,'Delayin1',0);
        pirelab.getUnitDelayComp(QuadrantBFnet,QuadrantBFInput(2),in2reg,'Delayin2',0);

        CompSig2=[in1reg,zeros];
        CompSig3=[in2reg,zeros];

        hTcRel2=pirelab.getRelOpComp(QuadrantBFnet,CompSig2,xNegative,'<',1);
        hTcRel3=pirelab.getRelOpComp(QuadrantBFnet,CompSig3,yNegative,'<',1);
        bitConcatVector=[AbsRel,xNegative,yNegative];
        hTcBitC=pirelab.getBitConcatComp(QuadrantBFnet,bitConcatVector,concatV,'concatQCControl');

        hTWO3=pirelab.getWireComp(QuadrantBFnet,concatV,QuadrantBFOutput(3));

    end
