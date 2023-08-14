function waveNet=elaborateNCOWave(this,topNet,blockInfo,dataRate)



    quantWL=blockInfo.quantWL;
    accWL=blockInfo.accumDType.WordLength;

    if blockInfo.PhaseQuantization&&(quantWL<accWL)
        phaseType=pir_ufixpt_t(quantWL,accWL-quantWL);
    else
        quantWL=accWL;
        phaseType=pir_ufixpt_t(accWL,0);
    end

    outType=pir_sfixpt_t(blockInfo.outWL,-blockInfo.outFL);

    inportnames={'phaseIdx'};
    inporttypes=phaseType;
    inportrates=dataRate;

    outMode=blockInfo.outMode;
    outcase=outMode(1)+2*outMode(2)+4*outMode(3);

    switch outcase
    case 1

        outportnames={'sine'};
        outporttypes=outType;
    case 2

        outportnames={'cosine'};
        outporttypes=outType;
    case 3

        outportnames={'sine','cosine'};
        outporttypes=[outType,outType];
    case 4

        outportnames={'exp'};
        outCType=pir_complex_t(outType);
        outporttypes=outCType;
    end



    waveNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','WaveformGen',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',outportnames,...
    'OutportTypes',outporttypes...
    );


    phaseidx=waveNet.PirInputSignals(1);
    outsignals=waveNet.PirOutputSignals;

    ufix1Type=pir_ufixpt_t(1,0);

    lutaddrType=pir_ufixpt_t(quantWL-2,0);

    sel_sign=waveNet.addSignal(ufix1Type,'selsign');
    sel_sign.SimulinkRate=blockInfo.SimulinkRate;
    sel_addr=waveNet.addSignal(ufix1Type,'seladdr');
    sel_addr.SimulinkRate=blockInfo.SimulinkRate;
    lutaddr1=waveNet.addSignal(lutaddrType,'lutaddr1');
    lutaddr1.SimulinkRate=blockInfo.SimulinkRate;
    lutaddr2=waveNet.addSignal(lutaddrType,'lutaddr2');
    lutaddr2.SimulinkRate=blockInfo.SimulinkRate;

    comp=pirelab.getBitSliceComp(waveNet,phaseidx,sel_sign,quantWL-1,quantWL-1);
    comp.addComment(' Sine sign selection signal');
    pirelab.getBitSliceComp(waveNet,phaseidx,sel_addr,quantWL-2,quantWL-2);
    pirelab.getBitSliceComp(waveNet,phaseidx,lutaddr1,quantWL-3,0);


    addrmaxType=pir_ufixpt_t(quantWL-2+1,0);
    addrmax=waveNet.addSignal(addrmaxType,'lutaddrmax');
    addrmax.SimulinkRate=blockInfo.SimulinkRate;
    comp=pirelab.getConstComp(waveNet,addrmax,2^(quantWL-2));
    comp.addComment('Map LUT address in correct phase');


    pirelab.getSubComp(waveNet,[addrmax,lutaddr1],lutaddr2,'Floor','Wrap');



    switch outcase
    case 1
        sinout=outsignals(1);
    case 2
        cosout=outsignals(1);
    case 3
        sinout=outsignals(1);
        cosout=outsignals(2);
    case 4
        sinout=waveNet.addSignal(outsignals(1).Type.BaseType,'sinout');
        sinout.SimulinkRate=blockInfo.SimulinkRate;
        cosout=waveNet.addSignal(outsignals(1).Type.BaseType,'cosout');
        cosout.SimulinkRate=blockInfo.SimulinkRate;
    end


    lutaddrexd=waveNet.addSignal(addrmaxType,'lutaddrexd');
    lutaddrexd.SimulinkRate=blockInfo.SimulinkRate;
    comp=pirelab.getBitSliceComp(waveNet,phaseidx,lutaddrexd,quantWL-2,0);
    comp.addComment('Get extended LUT address for overflow handling');
    constone=waveNet.addSignal(outType,'ampOne');
    constone.SimulinkRate=blockInfo.SimulinkRate;
    constValue=pirelab.getValueWithType(1,outType);
    pirelab.getConstComp(waveNet,constone,constValue);


    lutNet=this.elaborateNCOLUT(waveNet,blockInfo,dataRate);
    lutNet.addComment('Look Up Table Generation Component');

    if outcase~=2
        lutaddrsin=waveNet.addSignal(lutaddrType,'lutaddrsin');
        lutaddrsin.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getSwitchComp(waveNet,[lutaddr1,lutaddr2],lutaddrsin,sel_addr,...
        'select address','==',0);
        lutoutsin=waveNet.addSignal(outType,'lutoutsin');
        lutoutsin.SimulinkRate=blockInfo.SimulinkRate;

        pirelab.instantiateNetwork(waveNet,lutNet,lutaddrsin,lutoutsin,'SineWave_inst');


        addroverflowsin=waveNet.addSignal(ufix1Type,'addrOverFsin');
        addroverflowsin.SimulinkRate=blockInfo.SimulinkRate;
        addroverflowsinreg=waveNet.addSignal(ufix1Type,'addrOverFsinreg');
        addroverflowsinreg.SimulinkRate=blockInfo.SimulinkRate;
        comp=pirelab.getCompareToValueComp(waveNet,lutaddrexd,addroverflowsin,'==',2^(quantWL-2));
        comp.addComment('Detect sine overflow');

        pirelab.getIntDelayComp(waveNet,addroverflowsin,addroverflowsinreg,0,'AddrOverFsinRegister',0);

        lutoutsin_ampOne=waveNet.addSignal(outType,'lutoutsin_ampOne');
        lutoutsin_ampOne.SimulinkRate=blockInfo.SimulinkRate;
        comp=pirelab.getSwitchComp(waveNet,[lutoutsin,constone],lutoutsin_ampOne,addroverflowsinreg,...
        'Assign Sine Amplitude One','==',0);
        comp.addComment('Assign sine amplitude One');


        invlutoutsin=addSignal(waveNet,outType,'lutoutsin_ampOne_inv');
        invlutoutsin.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getUnaryMinusComp(waveNet,lutoutsin_ampOne,invlutoutsin);
        comp=pirelab.getSwitchComp(waveNet,[lutoutsin_ampOne,invlutoutsin],sinout,sel_sign,...
        'select outputs','==',0);
        comp.addComment('Select sign of Sine output');
    end

    if outcase>1
        sel_signcos=waveNet.addSignal(ufix1Type,'selsign_cos');
        sel_signcos.SimulinkRate=blockInfo.SimulinkRate;


        comp=pirelab.getLogicComp(waveNet,[sel_sign,sel_addr],sel_signcos,'xor');
        comp.addComment(' Cosine sign selection signal');


        lutaddrcos=waveNet.addSignal(lutaddrType,'lutaddrcos');
        lutaddrcos.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getSwitchComp(waveNet,[lutaddr2,lutaddr1],lutaddrcos,sel_addr,...
        'select address','==',0);

        lutoutcos=waveNet.addSignal(outType,'lutoutcos');
        lutoutcos.SimulinkRate=blockInfo.SimulinkRate;

        pirelab.instantiateNetwork(waveNet,lutNet,lutaddrcos,lutoutcos,'CosineWave_inst');


        addreqzero=waveNet.addSignal(ufix1Type,'addreqzero');
        addreqzero.SimulinkRate=blockInfo.SimulinkRate;
        addroverflowcos=waveNet.addSignal(ufix1Type,'addrOverFcos');
        addroverflowcos.SimulinkRate=blockInfo.SimulinkRate;

        comp=pirelab.getCompareToValueComp(waveNet,lutaddrexd,addreqzero,'==',0);
        comp.addComment('Detect cosine overflow');
        addroverflowcos=addreqzero;


        lutoutcos_ampOne=waveNet.addSignal(outType,'lutoutcos_ampOne');
        lutoutcos_ampOne.SimulinkRate=blockInfo.SimulinkRate;
        comp=pirelab.getSwitchComp(waveNet,[lutoutcos,constone],lutoutcos_ampOne,addroverflowcos,...
        'Assign Cosine Amplitude One','==',0);
        comp.addComment('Assign cosine amplitude One');


        invlutoutcos=addSignal(waveNet,outType,'lutoutcos_ampOne_inv');
        invlutoutcos.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getUnaryMinusComp(waveNet,lutoutcos_ampOne,invlutoutcos);
        comp=pirelab.getSwitchComp(waveNet,[lutoutcos_ampOne,invlutoutcos],cosout,sel_signcos,...
        'select outputs','==',0);
        comp.addComment('Select sign of cosine output');
    end

    if outcase==4

        pirelab.getRealImag2Complex(waveNet,[cosout,sinout],outsignals(1));
    end


end