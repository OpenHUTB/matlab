function ycbcr2rgbNet=elabYCBCR2RGB(this,topNet,blockInfo,dataRate)





    inportnames={'Y','Cb','Cr','hStartIn','hEndIn','vStartIn','vEndIn','validIn'};
    outportnames={'R','G','B','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};

    insignals=topNet.PirInputSignals;
    pixelIn=insignals(1);
    dataType=pixelIn.type.basetype;
    ctrlType=pir_boolean_t();

    ycbcr2rgbNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','YCBCR2RGB',...
    'InportNames',inportnames,...
    'InportTypes',[dataType,dataType,dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',outportnames,...
    'OutportTypes',[dataType,dataType,dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType]);


    compoIn=ycbcr2rgbNet.PirInputSignals(1:3);
    hStartIn=ycbcr2rgbNet.PirInputSignals(4);
    hEndIn=ycbcr2rgbNet.PirInputSignals(5);
    vStartIn=ycbcr2rgbNet.PirInputSignals(6);
    vEndIn=ycbcr2rgbNet.PirInputSignals(7);
    validIn=ycbcr2rgbNet.PirInputSignals(8);
    inRate=hStartIn.SimulinkRate;

    R=ycbcr2rgbNet.PirOutputSignals(1);
    G=ycbcr2rgbNet.PirOutputSignals(2);
    B=ycbcr2rgbNet.PirOutputSignals(3);
    hStartOut=ycbcr2rgbNet.PirOutputSignals(4);
    hEndOut=ycbcr2rgbNet.PirOutputSignals(5);
    vStartOut=ycbcr2rgbNet.PirOutputSignals(6);
    vEndOut=ycbcr2rgbNet.PirOutputSignals(7);
    validOut=ycbcr2rgbNet.PirOutputSignals(8);


    range=[blockInfo.MinMaxLuma(1),blockInfo.MinMaxLuma(2);...
    blockInfo.MinMaxChroma(1),blockInfo.MinMaxChroma(2);...
    blockInfo.MinMaxChroma(1),blockInfo.MinMaxChroma(2)];
    range=fi(range,dataType.BaseType.Signed,dataType.BaseType.WordLength,dataType.BaseType.FractionLength);

    for ii=1:3
        muxsel1=ycbcr2rgbNet.addSignal(ctrlType,['Mux',num2str(ii),'Sel1']);
        pirelab.getCompareToValueComp(ycbcr2rgbNet,compoIn(ii),muxsel1,'<',range(ii,1));

        muxsel2=ycbcr2rgbNet.addSignal(ctrlType,['Mux',num2str(ii),'Sel2']);
        pirelab.getCompareToValueComp(ycbcr2rgbNet,compoIn(ii),muxsel2,'>',range(ii,2));

        ConstMin=ycbcr2rgbNet.addSignal(dataType,['ConsMin',num2str(ii)]);
        pirelab.getConstComp(ycbcr2rgbNet,ConstMin,range(ii,1));

        ConstMax=ycbcr2rgbNet.addSignal(dataType,['ConsMax',num2str(ii)]);
        pirelab.getConstComp(ycbcr2rgbNet,ConstMax,range(ii,2));

        switchout1=ycbcr2rgbNet.addSignal(dataType,['SwitchOut1',num2str(ii)]);
        pirelab.getSwitchComp(ycbcr2rgbNet,[compoIn(ii),ConstMin],switchout1,muxsel1);

        switchout(ii)=ycbcr2rgbNet.addSignal(dataType,['SwitchOut2',num2str(ii)]);
        pirelab.getSwitchComp(ycbcr2rgbNet,[switchout1,ConstMax],switchout(ii),muxsel2);
    end

    YSat=ycbcr2rgbNet.addSignal(dataType,'In1Reg');
    CbSat=ycbcr2rgbNet.addSignal(dataType,'In2Reg');
    CrSat=ycbcr2rgbNet.addSignal(dataType,'In3Reg');
    hStartInReg=ycbcr2rgbNet.addSignal(ctrlType,'hStartInReg');
    hEndInReg=ycbcr2rgbNet.addSignal(ctrlType,'hEndInReg');
    vStartInReg=ycbcr2rgbNet.addSignal(ctrlType,'vStartInReg');
    vEndInReg=ycbcr2rgbNet.addSignal(ctrlType,'vEndInReg');
    validInReg=ycbcr2rgbNet.addSignal(ctrlType,'validInReg');

    pirelab.getUnitDelayComp(ycbcr2rgbNet,switchout(1),YSat);
    pirelab.getUnitDelayComp(ycbcr2rgbNet,switchout(2),CbSat);
    pirelab.getUnitDelayComp(ycbcr2rgbNet,switchout(3),CrSat);
    pirelab.getUnitDelayComp(ycbcr2rgbNet,hStartIn,hStartInReg);
    pirelab.getUnitDelayComp(ycbcr2rgbNet,hEndIn,hEndInReg);
    pirelab.getUnitDelayComp(ycbcr2rgbNet,vStartIn,vStartInReg);
    pirelab.getUnitDelayComp(ycbcr2rgbNet,vEndIn,vEndInReg);
    pirelab.getUnitDelayComp(ycbcr2rgbNet,validIn,validInReg);


    rgb2ycbcrNet=this.elabRGB2YCBCR(topNet,blockInfo,inRate);
    rgb2ycbcrNet.addComment('YCbCr to RGB Core');
    pirelab.instantiateNetwork(ycbcr2rgbNet,rgb2ycbcrNet,[YSat,CbSat,CrSat,hStartInReg,hEndInReg,vStartInReg,vEndInReg,validInReg],...
    [R,G,B,hStartOut,hEndOut,vStartOut,vEndOut,validOut],'ycbcr2rgbCore_inst');
