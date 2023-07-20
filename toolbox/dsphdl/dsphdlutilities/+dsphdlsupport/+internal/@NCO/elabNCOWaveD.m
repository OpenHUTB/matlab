function waveNet=elabNCOWaveD(this,topNet,blockInfo,dataRate)




    quantWL=blockInfo.PhaseBits;
    accWL=blockInfo.AccuWL;

    if blockInfo.PhaseQuantization&&(quantWL<accWL)
        phaseType=pir_ufixpt_t(quantWL,accWL-quantWL);
    else
        quantWL=accWL;
        phaseType=pir_ufixpt_t(accWL,0);
    end

    outType=pir_sfixpt_t(blockInfo.outWL,-blockInfo.outFL);

    delay=3;

    inportnames={'phaseIdx'};
    inporttypes=phaseType;
    inportrates=dataRate;

    outMode=blockInfo.outMode;
    outcase=outMode(1)+2*outMode(2)+4*outMode(3);

    switch outcase

    case 3
        outportnames={'sine','cosine'};
        outporttypes=[outType,outType];
    case 4
        outportnames={'exp'};
        outCType=pir_complex_t(outType);
        outporttypes=outCType;
    otherwise
        outportnames={'sine','cosine'};
        outporttypes=[outType,outType];
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


    quantacc=waveNet.PirInputSignals(1);
    phaseIdxReg=waveNet.addSignal(phaseType,'phaseIdxReg');
    phaseIdxReg.SimulinkRate=blockInfo.SimulinkRate;
    pirelab.getIntDelayComp(waveNet,quantacc,phaseIdxReg,1,'phaseIdxRegister',0);
    outsignals=waveNet.PirOutputSignals;




    ufix1Type=pir_ufixpt_t(1,0);
    lutaddrType=pir_ufixpt_t(quantWL-2,0);
    lutaddrOType=pir_ufixpt_t(quantWL-3,0);
    addrmaxType=pir_ufixpt_t(quantWL-2+1,0);


    msb3=waveNet.addSignal(ufix1Type,'msb3');
    msb3.SimulinkRate=blockInfo.SimulinkRate;
    msb3Reg=waveNet.addSignal(ufix1Type,'msb3Reg');
    msb3Reg.SimulinkRate=blockInfo.SimulinkRate;
    msb2=waveNet.addSignal(ufix1Type,'msb2');
    msb2.SimulinkRate=blockInfo.SimulinkRate;
    msb1=waveNet.addSignal(ufix1Type,'msb1');
    msb1.SimulinkRate=blockInfo.SimulinkRate;


    lutaddr1=waveNet.addSignal(lutaddrType,'lutaddr1');
    lutaddr1.SimulinkRate=blockInfo.SimulinkRate;
    lutaddr2=waveNet.addSignal(lutaddrType,'lutaddr2');
    lutaddr2.SimulinkRate=blockInfo.SimulinkRate;
    lutaddr=waveNet.addSignal(lutaddrType,'lutaddr');
    lutaddr.SimulinkRate=blockInfo.SimulinkRate;
    lutaddrO=waveNet.addSignal(lutaddrOType,'lutaddrO');
    lutaddrO.SimulinkRate=blockInfo.SimulinkRate;


    signSel=waveNet.addSignal(ufix1Type,'signSel');
    signSel.SimulinkRate=blockInfo.SimulinkRate;
    signSelReg=waveNet.addSignal(ufix1Type,'signSelReg');
    signSelReg.SimulinkRate=blockInfo.SimulinkRate;
    lutSel=waveNet.addSignal(ufix1Type,'lutSel');
    lutSel.SimulinkRate=blockInfo.SimulinkRate;
    lutSelReg=waveNet.addSignal(ufix1Type,'lutSelReg');
    lutSelReg.SimulinkRate=blockInfo.SimulinkRate;
    sineSignSel=waveNet.addSignal(ufix1Type,'sineSignSel');
    sineSignSel.SimulinkRate=blockInfo.SimulinkRate;
    sineSignSelReg=waveNet.addSignal(ufix1Type,'sineSignSelReg');
    sineSignSelReg.SimulinkRate=blockInfo.SimulinkRate;
    sin45Sel=waveNet.addSignal(ufix1Type,'sin45Sel');
    sin45Sel.SimulinkRate=blockInfo.SimulinkRate;
    sin45SelReg=waveNet.addSignal(ufix1Type,'sin45SelReg');
    sin45SelReg.SimulinkRate=blockInfo.SimulinkRate;


    octantVal=waveNet.addSignal(outType,'octantVal');
    octantVal.SimulinkRate=blockInfo.SimulinkRate;
    addrmax=waveNet.addSignal(addrmaxType,'lutaddrmax');
    addrmax.SimulinkRate=blockInfo.SimulinkRate;




    pirelab.getBitSliceComp(waveNet,phaseIdxReg,lutaddr1,quantWL-3,0,'lutaddr1Comp');
    pirelab.getBitSliceComp(waveNet,phaseIdxReg,msb3,quantWL-3,quantWL-3,'msb3Comp');
    pirelab.getBitSliceComp(waveNet,phaseIdxReg,msb2,quantWL-2,quantWL-2,'msb2Comp');
    pirelab.getBitSliceComp(waveNet,phaseIdxReg,msb1,quantWL-1,quantWL-1,'msb1Comp');


    comp=pirelab.getConstComp(waveNet,addrmax,2^(quantWL-2));
    comp.addComment('Map LUT address in correct phase');
    pirelab.getSubComp(waveNet,[addrmax,lutaddr1],lutaddr2,'Floor','Wrap');


    pirelab.getSwitchComp(waveNet,[lutaddr2,lutaddr1],lutaddr,msb3,'lutaddrSwitch','~=',0);
    pirelab.getBitSliceComp(waveNet,lutaddr,lutaddrO,quantWL-4,0,'lutaddrOComp');


    comp=pirelab.getBitwiseOpComp(waveNet,[msb2,msb3],lutSel,'xor','lutSelComp');
    comp.addComment('LUT selection signal');
    comp=pirelab.getBitwiseOpComp(waveNet,[msb1,msb2],signSel,'xor','signSelComp');
    comp.addComment('Cosine sign selection signal');

    comp=pirelab.getWireComp(waveNet,msb1,sineSignSel);
    comp.addComment('Sine sign selection signal');

    pirelab.getIntDelayComp(waveNet,lutSel,lutSelReg,delay,'lutSelRegComp',0);
    pirelab.getIntDelayComp(waveNet,signSel,signSelReg,delay,'signSelRegComp',0);
    pirelab.getIntDelayComp(waveNet,sineSignSel,sineSignSelReg,delay,'sineSignSelRegComp',0);

    comp=pirelab.getCompareToValueComp(waveNet,lutaddr1,sin45Sel,'==',2^(quantWL-3));
    comp.addComment('45 degree address');
    pirelab.getIntDelayComp(waveNet,sin45Sel,sin45SelReg,delay,'sin45SelRegComp',0);


    pirelab.getConstComp(waveNet,octantVal,double(sin(pi/4)),'octantValComp');

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...



    switch outcase

    case 3
        sinout=outsignals(1);
        cosout=outsignals(2);
    case 4
        sinout=waveNet.addSignal(outsignals(1).Type.BaseType,'sinout');
        sinout.SimulinkRate=blockInfo.SimulinkRate;
        cosout=waveNet.addSignal(outsignals(1).Type.BaseType,'cosout');
        cosout.SimulinkRate=blockInfo.SimulinkRate;
    otherwise
        sinout=outsignals(1);
        cosout=outsignals(2);
    end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...




    lutoutsin=waveNet.addSignal(outType,'lutoutsin');
    lutoutsin.SimulinkRate=blockInfo.SimulinkRate;
    lutoutcos=waveNet.addSignal(outType,'lutoutcos');
    lutoutcos.SimulinkRate=blockInfo.SimulinkRate;
    lutselsin=waveNet.addSignal(outType,'lutselsin');
    lutselsin.SimulinkRate=blockInfo.SimulinkRate;
    lutselcos=waveNet.addSignal(outType,'lutselcos');
    lutselcos.SimulinkRate=blockInfo.SimulinkRate;
    fullsinmag=waveNet.addSignal(outType,'fullsinmag');
    fullsinmag.SimulinkRate=blockInfo.SimulinkRate;
    fullcosmag=waveNet.addSignal(outType,'fullcosmag');
    fullcosmag.SimulinkRate=blockInfo.SimulinkRate;
    inverseSin=waveNet.addSignal(outType,'inverseSin');
    inverseSin.SimulinkRate=blockInfo.SimulinkRate;
    inverseCos=waveNet.addSignal(outType,'inverseCos');
    inverseCos.SimulinkRate=blockInfo.SimulinkRate;








    lutNetSin=this.elabNCOLUTOptSin(waveNet,blockInfo,dataRate);
    lutNetSin.addComment('Sin Look Up Table Generation Component');
    pirelab.instantiateNetwork(waveNet,lutNetSin,lutaddrO,lutoutsin,'Sin_Wave_inst');


    lutNetCos=this.elabNCOLUTOptCos(waveNet,blockInfo,dataRate);
    lutNetCos.addComment('Cos Look Up Table Generation Component');
    pirelab.instantiateNetwork(waveNet,lutNetCos,lutaddrO,lutoutcos,'Cos_Wave_inst');






    comp=pirelab.getSwitchComp(waveNet,[lutoutcos,lutoutsin],lutselsin,lutSelReg,'sinlut','~=',0);
    comp.addComment('Select sine output LUT');
    comp=pirelab.getSwitchComp(waveNet,[lutoutsin,lutoutcos],lutselcos,lutSelReg,'coslut','~=',0);
    comp.addComment('Select cosine output LUT');


    comp=pirelab.getSwitchComp(waveNet,[octantVal,lutselsin],fullsinmag,sin45SelReg,'fullsinmagComp','~=',0);
    comp.addComment('Assign sine pi/4 value');
    comp=pirelab.getSwitchComp(waveNet,[octantVal,lutselcos],fullcosmag,sin45SelReg,'fullcosmagComp','~=',0);
    comp.addComment('Assign cosine pi/4 value');


    pirelab.getUnaryMinusComp(waveNet,fullsinmag,inverseSin);
    pirelab.getUnaryMinusComp(waveNet,fullcosmag,inverseCos);
    comp=pirelab.getSwitchComp(waveNet,[inverseSin,fullsinmag],sinout,sineSignSelReg,'sinoutComp','~=',0);
    comp.addComment('Select sign of sine output');
    comp=pirelab.getSwitchComp(waveNet,[inverseCos,fullcosmag],cosout,signSelReg,'cosoutComp','~=',0);
    comp.addComment('Select sign of cosine ouptput');

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...





    if outcase==4

        pirelab.getRealImag2Complex(waveNet,[cosout,sinout],outsignals(1));

    end
end
