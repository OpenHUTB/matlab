function hNewC=elaborate(this,hN,hC)





    hTopNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC...
    );

    e=dsphdlshared.Elaborator('CurrentNetwork',hTopNet,...
    'PIROriginalComponent',hC,...
    'AutoCopyComments',false);

    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        prm=this.buildSysObjParams(hC,hN,sysObjHandle);
    else
        prm=this.buildBlockParams(hC,hN);
    end

    prm.hN=hTopNet;
    prm.hC=[];
    prm.InputSignals=hTopNet.PirInputSignals;
    prm.OutputSignals=hTopNet.PirOutputSignals;





    [oneSumWL,oneSumFL,oneSumSign]=dsphdlshared.hdlgetwordsizefromdata(prm.oneSumType);


    sumdt=prm.hN.getType('FixedPoint',...
    'Signed',oneSumSign,...
    'WordLength',oneSumWL,...
    'FractionLength',-1*oneSumFL);

    castd2dt=prm.hN.getType('FixedPoint',...
    'Signed',0,...
    'WordLength',log2(sqrt(prm.M)),...
    'FractionLength',0);

    reidxdt=prm.hN.getType('FixedPoint',...
    'Signed',0,...
    'WordLength',2*castd2dt.WordLength,...
    'FractionLength',0);
    imidxdt=reidxdt;

    idxdt=prm.hN.getType('FixedPoint',...
    'Signed',0,...
    'WordLength',log2((prm.M)),...
    'FractionLength',0);

    booldt=prm.hN.getType('Boolean');


    reQuad1=prm.hN.addSignal2('Name','reQuadrant1','Type',sumdt);
    imQuad1=prm.hN.addSignal2('Name','imQuadrant1','Type',sumdt);
    reQuad1_p1=prm.hN.addSignal2('Name','reQuadrant1_plus1','Type',sumdt);
    imQuad1_p1=prm.hN.addSignal2('Name','imQuadrant1_plus1','Type',sumdt);

    reint_div2=prm.hN.addSignal2('Name','reCast_divby2','Type',castd2dt);
    imint_div2=prm.hN.addSignal2('Name','imCast_divby2','Type',castd2dt);

    reidx=prm.hN.addSignal2('Name','reIdx','Type',reidxdt);
    imidx=prm.hN.addSignal2('Name','imIdx','Type',imidxdt);


    reZeroClipped=prm.hN.addSignal2('Name','reZeroClipped','Type',castd2dt);
    imZeroClipped=prm.hN.addSignal2('Name','imZeroClipped','Type',castd2dt);


    reSaturated=prm.hN.addSignal2('Name','reSaturated','Type',castd2dt);
    imSaturated=prm.hN.addSignal2('Name','imSaturated','Type',castd2dt);

    LUTidx=prm.hN.addSignal2('Name','LUTidx','Type',idxdt);


    reZeroClipSel=prm.hN.addSignal2('Name','reZeroClip','Type',booldt);
    imZeroClipSel=prm.hN.addSignal2('Name','imZeroClip','Type',booldt);
    reSatSel=prm.hN.addSignal2('Name','reSatSel','Type',booldt);
    imSatSel=prm.hN.addSignal2('Name','imSatSel','Type',booldt);




    sqrtMminus1=prm.hN.addSignal2('Name','sqrtMminus1','Type',sumdt);
    oneSumType=prm.hN.addSignal2('Name','oneSumType','Type',sumdt);
    twoSqrtMminus1=prm.hN.addSignal2('Name','twoSqrtMminus1','Type',sumdt);
    sqrtMminus1Int=prm.hN.addSignal2('Name','sqrtMminus1Int','Type',castd2dt);
    zeroConst=prm.hN.addSignal2('Name','reIdxZeros','Type',castd2dt);

    pirelab.getConstComp(prm.hN,sqrtMminus1,prm.sqrtMminus1);
    pirelab.getConstComp(prm.hN,twoSqrtMminus1,prm.twoSqrtMminus1);
    pirelab.getConstComp(prm.hN,oneSumType,prm.oneSumType);
    pirelab.getConstComp(prm.hN,sqrtMminus1Int,sqrt(prm.M)-1);
    pirelab.getConstComp(prm.hN,zeroConst,0);



    addRoundSat={'RoundingMethod','Nearest','OverflowAction','Saturate'};
    intRoundSat={'RoundingMethod','Floor','OverflowAction','Wrap'};





    [re,im]=trivialDerotate(this,prm,e);


    e.Adder('Inputs',[re,sqrtMminus1],'Outputs',reQuad1,addRoundSat{:});
    e.Adder('Inputs',[im,sqrtMminus1],'Outputs',imQuad1,addRoundSat{:});


    e.Adder('Inputs',[reQuad1,oneSumType],'Outputs',reQuad1_p1,addRoundSat{:});
    e.Adder('Inputs',[imQuad1,oneSumType],'Outputs',imQuad1_p1,addRoundSat{:});


    lsb=oneSumFL;
    e.Slicer('Inputs',reQuad1_p1','Outputs',reint_div2,'MSB',log2(sqrt(prm.M))+lsb,'LSB',lsb+1);
    e.Slicer('Inputs',imQuad1_p1','Outputs',imint_div2,'MSB',log2(sqrt(prm.M))+lsb,'LSB',lsb+1);






    e.CompareToValue(...
    'Inputs',reQuad1,...
    'Outputs',reSatSel,...
    'Operator','>=',...
    'Value',prm.twoSqrtMminus1);

    e.CompareToValue(...
    'Inputs',reQuad1,...
    'Outputs',reZeroClipSel,...
    'Operator','>',...
    'Value',0);


    e.Mux(...
    'Inputs',[reint_div2,sqrtMminus1Int],...
    'Outputs',reSaturated,...
    'Select',reSatSel);


    e.Mux(...
    'Inputs',[zeroConst,reSaturated],...
    'Outputs',reZeroClipped,...
    'Select',reZeroClipSel);


    e.CompareToValue(...
    'Inputs',imQuad1,...
    'Outputs',imSatSel,...
    'Operator','>=',...
    'Value',prm.twoSqrtMminus1);

    e.CompareToValue(...
    'Inputs',imQuad1,...
    'Outputs',imZeroClipSel,...
    'Operator','>',...
    'Value',0);


    e.Mux(...
    'Inputs',[imint_div2,sqrtMminus1Int],...
    'Outputs',imSaturated,...
    'Select',imSatSel);


    e.Mux(...
    'Inputs',[zeroConst,imSaturated],...
    'Outputs',imZeroClipped,...
    'Select',imZeroClipSel);




    e.BitConcat('Inputs',[reZeroClipped,zeroConst],'Outputs',reidx);


    e.Subtractor('Inputs',[sqrtMminus1Int,imZeroClipped],'Outputs',imidx,intRoundSat{:});


    e.Adder('Inputs',[reidx,imidx],'Outputs',LUTidx,intRoundSat{:});

    makeOutput(this,prm,e,LUTidx);


    hNewC=pirelab.instantiateNetwork(hN,hTopNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end
