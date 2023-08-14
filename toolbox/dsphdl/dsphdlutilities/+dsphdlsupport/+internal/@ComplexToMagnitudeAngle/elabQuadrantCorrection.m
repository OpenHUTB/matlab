function QuadrantCorrectNet=elabQuadrantCorrection(this,topNet,siginfo,dataRate,blockInfo)




    hTa=siginfo.angdatatype;
    zType=siginfo.zType;
    booleanT=siginfo.booleanT;
    booleanTwo=siginfo.booleanTwo;
    concatT=siginfo.concatT;


    inportnames={'zin','QA_Control'};
    outportnames={'zout'};


    QuadrantCorrectNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Quadrant_Correction',...
    'InportNames',inportnames,...
    'InportTypes',[zType,concatT],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',outportnames,...
    'OutportTypes',hTa...
    );

    QuadrantAFInput=QuadrantCorrectNet.PirInputSignals;
    QuadrantAFOutput=QuadrantCorrectNet.PirOutputSignals;



    constantoneS=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','constantone');
    constantone=pirelab.getConstComp(QuadrantCorrectNet,constantoneS,1,'constantone');
    mux3out=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','mux1out');
    mux4one=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','mux1out_negate');
    mux4onesC=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','mux1out_negate');
    mux4two=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','pi_subtraction');
    mux4two.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;
    mux4three=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','negpi_addition');
    mux4out=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','mux2out');
    pidivtwosubout=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','pivdivtwosubout');
    pidivtwosubout.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;
    quadrantout=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','zout');
    AbsRelD=QuadrantCorrectNet.addSignal2('Type',booleanT,'Name','AbsRel');
    xyNegativeD=QuadrantCorrectNet.addSignal2('Type',booleanTwo,'Name','xyNegative');
    zCast=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','zCast');

    pidivtwo=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','pidivtwo');
    pidivtwo.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;
    pionepos=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','pionepos');
    pionepos.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;
    pioneneg=QuadrantCorrectNet.addSignal2('Type',hTa,'Name','pioneneg');
    pioneneg.SimulinkRate=topNet.PirInputSignals(1).SimulinkRate;


    if strcmpi(blockInfo.AngleFormat,'Radians')
        pidivval=fi(pi/2,1,(hTa.WordLength),(-(hTa.FractionLength)),'RoundingMethod','Floor','OverflowAction','Wrap');
        pidivtwoconst=pirelab.getConstComp(QuadrantCorrectNet,pidivtwo,pidivval,'pidivtwoconstant');
        pi_posval=fi(pi,1,(hTa.WordLength),(-(hTa.FractionLength)),'RoundingMethod','Floor','OverflowAction','Wrap');
        pioneposC=pirelab.getConstComp(QuadrantCorrectNet,pionepos,pi_posval,'pidivtwoconstant');
        pi_negval=fi(-pi,1,(hTa.WordLength),(-(hTa.FractionLength)),'RoundingMethod','Floor','OverflowAction','Wrap');
        pionenegC=pirelab.getConstComp(QuadrantCorrectNet,pioneneg,pi_negval,'pidivtwoconstant');
        zCastOp=pirelab.getDTCComp(QuadrantCorrectNet,QuadrantAFInput(1),zCast,'Floor','Wrap');

    elseif strcmpi(blockInfo.AngleFormat,'Normalized');
        pidivtwoconst=pirelab.getConstComp(QuadrantCorrectNet,pidivtwo,0.5,'pidivtwoconstant');
        pioneposC=pirelab.getConstComp(QuadrantCorrectNet,pionepos,(1-eps),'pidivtwoconstant');
        pionenegC=pirelab.getConstComp(QuadrantCorrectNet,pioneneg,-1,'pidivtwoconstant');
        zCastOp=pirelab.getDTCComp(QuadrantCorrectNet,QuadrantAFInput(1),zCast,'Floor','Wrap');


    else
        pidivtwoconst=pirelab.getConstComp(QuadrantCorrectNet,pidivtwo,(pi/2),'pidivtwoconstant');
        pioneposC=pirelab.getConstComp(QuadrantCorrectNet,pionepos,pi,'pidivtwoconstant');
        pionenegC=pirelab.getConstComp(QuadrantCorrectNet,pioneneg,-pi,'pidivtwoconstant');

    end




    hTcBitex3=pirelab.getBitExtractComp(QuadrantCorrectNet,QuadrantAFInput(2),AbsRelD,2,2,1);
    hTcBitex4=pirelab.getBitExtractComp(QuadrantCorrectNet,QuadrantAFInput(2),xyNegativeD,1,0,1);

    subbfmux3=[pidivtwo,zCast];



    pidivtwos=pirelab.getAddComp(QuadrantCorrectNet,subbfmux3,pidivtwosubout,'Floor','Wrap','pidivtwosub',hTa,'+-');

    Mux3in=[pidivtwosubout,zCast];
    hTcMux3=pirelab.getSwitchComp(QuadrantCorrectNet,Mux3in,mux3out,AbsRelD);









    negGain=pirelab.getGainComp(QuadrantCorrectNet,mux3out,mux4one,fi(-1,1,2,0),1,1,'Floor','Wrap','Negation');

    subbfmuxin=[pionepos,mux3out];



    subbfmux=pirelab.getAddComp(QuadrantCorrectNet,subbfmuxin,mux4two,'Floor','Wrap','subfmux',hTa,'+-');

    addbfmuxin=[pioneneg,mux3out];

    addbfmux=pirelab.getAddComp(QuadrantCorrectNet,addbfmuxin,mux4three,...
    'Floor','Wrap');

    Mux4in=[mux3out,mux4one,mux4two,mux4three];
    hTcMux4=pirelab.getSwitchComp(QuadrantCorrectNet,Mux4in,mux4out,xyNegativeD);


    hcw1=pirelab.getWireComp(QuadrantCorrectNet,mux4out,QuadrantAFOutput(1));


end

