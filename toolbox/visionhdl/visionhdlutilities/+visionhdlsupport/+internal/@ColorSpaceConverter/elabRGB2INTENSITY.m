function rgb2grayNet=elabRGB2INTENSITY(~,topNet,blockInfo,dataRate)





    inportnames={'R','G','B','hStartIn','hEndIn','vStartIn','vEndIn','validIn'};
    outportnames={'Intensity','hStartOut','hEndOut','vStartOut','vEndOut','validOut'};

    insignals=topNet.PirInputSignals;
    pixelIn=insignals(1);
    dataType=pixelIn.type.basetype;
    ctrlType=pir_boolean_t();

    rgb2grayNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','RGB2INTENSITY',...
    'InportNames',inportnames,...
    'InportTypes',[dataType,dataType,dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',outportnames,...
    'OutportTypes',[dataType,ctrlType,ctrlType,ctrlType,ctrlType,ctrlType]);


    component=rgb2grayNet.PirInputSignals(1:3);
    hStartIn=rgb2grayNet.PirInputSignals(4);
    hEndIn=rgb2grayNet.PirInputSignals(5);
    vStartIn=rgb2grayNet.PirInputSignals(6);
    vEndIn=rgb2grayNet.PirInputSignals(7);
    validIn=rgb2grayNet.PirInputSignals(8);

    intensity=rgb2grayNet.PirOutputSignals(1);
    hStartOut=rgb2grayNet.PirOutputSignals(2);
    hEndOut=rgb2grayNet.PirOutputSignals(3);
    vStartOut=rgb2grayNet.PirOutputSignals(4);
    vEndOut=rgb2grayNet.PirOutputSignals(5);
    validOut=rgb2grayNet.PirOutputSignals(6);


    multi1Type=component(1).Type;
    multi2Type=blockInfo.A(1);
    multWL=multi1Type.BaseType.WordLength+multi2Type.WordLength;
    multFL=multi2Type.FractionLength;
    multiType=rgb2grayNet.getType('FixedPoint',...
    'Signed',false,...
    'WordLength',multWL,...
    'FractionLength',-multFL);
    for ii=1:3
        current_gain=blockInfo.A(ii);


        inDlySig=rgb2grayNet.addSignal(component(ii).Type,['multiInReg',num2str(ii)]);
        pirelab.getIntDelayComp(rgb2grayNet,component(ii),inDlySig,2,['multiInDelay',num2str(ii)]);


        multOutSig=rgb2grayNet.addSignal(multiType,['multiOut',num2str(ii)]);
        pirelab.getGainComp(rgb2grayNet,inDlySig,multOutSig,current_gain,3,blockInfo.OptimM);



        multiOutDlySig(ii)=rgb2grayNet.addSignal(multiType,['multiOutReg',num2str(ii)]);
        pirelab.getIntDelayComp(rgb2grayNet,multOutSig,multiOutDlySig(ii),2,['multiOutDelay',num2str(ii)]);
    end


    add1Type=rgb2grayNet.getType('FixedPoint',...
    'Signed',false,...
    'WordLength',multWL+1,...
    'FractionLength',-multFL);


    add1=rgb2grayNet.addSignal(add1Type,'S1_up');
    pirelab.getAddComp(rgb2grayNet,[multiOutDlySig(1),multiOutDlySig(2)],add1);

    add11=rgb2grayNet.addSignal(add1Type,'S1_up_delay');
    pirelab.getIntDelayComp(rgb2grayNet,add1,add11,1);


    add2=rgb2grayNet.addSignal(add1Type,'S1_down_delay');
    pirelab.getDTCComp(rgb2grayNet,multiOutDlySig(3),add2);
    add22=rgb2grayNet.addSignal(add1Type,'S1_down_delay');
    pirelab.getIntDelayComp(rgb2grayNet,add2,add22,1);



    add3Type=rgb2grayNet.getType('FixedPoint',...
    'Signed',false,...
    'WordLength',multWL+2,...
    'FractionLength',-multFL);

    add3=rgb2grayNet.addSignal(add3Type,'S2');
    pirelab.getAddComp(rgb2grayNet,[add11,add22],add3);

    add33=rgb2grayNet.addSignal(add3Type,'S2_delay');
    pirelab.getIntDelayComp(rgb2grayNet,add3,add33,1);


    castOut=rgb2grayNet.addSignal(component(1).Type,'castout');
    regcomp=pirelab.getDTCComp(rgb2grayNet,add33,castOut,'Nearest','Saturate');
    regcomp.addComment('convert dataOut to the data type of R, G, and B');
    castdelay=rgb2grayNet.addSignal(component(1).Type,'cast_delay');
    pirelab.getIntDelayComp(rgb2grayNet,castOut,castdelay,1);


    regcomp=pirelab.getIntDelayComp(rgb2grayNet,hStartIn,hStartOut,8,'hStart');
    regcomp.addComment('delay hStart');
    regcomp=pirelab.getIntDelayComp(rgb2grayNet,hEndIn,hEndOut,8,'hEnd');
    regcomp.addComment('delay hEnd');
    regcomp=pirelab.getIntDelayComp(rgb2grayNet,vStartIn,vStartOut,8,'vStart');
    regcomp.addComment('delay vStart');
    regcomp=pirelab.getIntDelayComp(rgb2grayNet,vEndIn,vEndOut,8,'vEnd');
    regcomp.addComment('delay vEnd');

    muxsel=rgb2grayNet.addSignal(validIn.Type,'Mux_Sel');
    pirelab.getIntDelayComp(rgb2grayNet,validIn,muxsel,7);
    pirelab.getIntDelayComp(rgb2grayNet,muxsel,validOut,1);

    zeroconst=rgb2grayNet.addSignal(component(1).Type,'const_zero');
    pirelab.getConstComp(rgb2grayNet,zeroconst,0);
    switchout=rgb2grayNet.addSignal(component(1).Type,'SwitchOut');
    pirelab.getSwitchComp(rgb2grayNet,[zeroconst,castdelay],switchout,muxsel);
    pirelab.getIntDelayComp(rgb2grayNet,switchout,intensity,1);


