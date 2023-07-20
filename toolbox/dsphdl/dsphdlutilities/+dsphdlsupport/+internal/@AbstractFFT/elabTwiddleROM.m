function[twiddleROM1,twiddleROM2]=elabTwiddleROM(this,hN,blockInfo,dataRate,stageNum,address,twiddle_re,twiddle_im)










    twiddle_index=(0:2^(stageNum-1)-1)/(2^stageNum);
    twiddle_index=twiddle_index(twiddle_index<=1/8);
    twiddleTable_tmp=fi(exp(-1i*2*pi*twiddle_index).',1,twiddle_re.Type.WordLength,-twiddle_re.Type.FractionLength,'RoundingMethod','Convergent','OverflowAction','Wrap');
    twiddle_data=twiddleTable_tmp;


    twiddleS_re=hN.addSignal2('Type',pir_sfixpt_t(twiddle_re.Type.WordLength,twiddle_re.Type.FractionLength),'Name','twiddleS_re');
    twiddleS_re.SimulinkRate=dataRate;
    twiddleS_im=hN.addSignal2('Type',pir_sfixpt_t(twiddle_im.Type.WordLength,twiddle_im.Type.FractionLength),'Name','twiddleS_im');
    twiddleS_im.SimulinkRate=dataRate;

    twiddleROM1=pirelab.getDirectLookupComp(hN,address,twiddleS_re,twiddle_data.real,'Twiddle_re');
    twiddleROM1.addComment('Twiddle ROM1');
    twiddleROM2=pirelab.getDirectLookupComp(hN,address,twiddleS_im,twiddle_data.imag,'Twiddle_im');
    twiddleROM2.addComment('Twiddle ROM2');

    pirelab.getUnitDelayComp(hN,twiddleS_re,twiddle_re,'TWIDDLEROM_RE',0,blockInfo.resetnone);
    pirelab.getUnitDelayComp(hN,twiddleS_im,twiddle_im,'TWIDDLEROM_IM',0,blockInfo.resetnone);
