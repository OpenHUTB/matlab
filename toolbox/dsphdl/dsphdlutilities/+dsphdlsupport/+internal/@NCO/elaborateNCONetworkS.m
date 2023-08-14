function elaborateNCONetworkS(this,topNet,blockInfo)







    accWL=blockInfo.AccuWL;
    accType=pir_sfixpt_t(accWL,0);



    insignals=topNet.PirInputSignals;




    inMode=blockInfo.inMode;

    pInc=topNet.addSignal(accType,'pInc');
    pInc.SimulinkRate=blockInfo.SimulinkRate;
    pOffset=topNet.addSignal(accType,'pOffset');
    pOffset.SimulinkRate=blockInfo.SimulinkRate;


    if inMode(1)

        pirelab.getDTCComp(topNet,insignals(1),pInc,'floor','wrap');

    else
        pirelab.getConstComp(topNet,pInc,fi(blockInfo.PhaseInc,1,accWL,0,'OverflowAction','Wrap'));
    end

    if inMode(2)
        offsetIdx=2-(1-inMode(1));
        pirelab.getDTCComp(topNet,insignals(offsetIdx),pOffset,'floor','wrap');
    else
        pirelab.getConstComp(topNet,pOffset,fi(blockInfo.PhaseOffset,1,accWL,0,'OverflowAction','Wrap'));
    end

    if inMode(3)

        casteddither=topNet.addSignal(accType,'casteddither');
        casteddither.SimulinkRate=blockInfo.SimulinkRate;
        ditherIdx=3-(2-sum(inMode(1:2)));
        pirelab.getDTCComp(topNet,insignals(ditherIdx),casteddither,'floor','wrap');

    end

    if inMode(4)
        resetIdx=4-(3-sum(inMode(1:3)));
        reset=insignals(resetIdx);
    end

    if inMode(5)

        validIn=insignals(end);
        if validIn.SimulinkRate~=blockInfo.SimulinkRate
            validInbk=topNet.addSignal(validIn.Type,'validInbk');
            pirelab.getWireComp(topNet,validIn,validInbk);
            validInbk.SimulinkRate=blockInfo.SimulinkRate;
        else
            validInbk=validIn;
        end

    else
        validInbk=topNet.addSignal(pir_boolean_t,'validInbk');
        pirelab.getConstComp(topNet,validInbk,true);
        validInbk.SimulinkRate=blockInfo.SimulinkRate;
    end



    outsignals=topNet.PirOutputSignals;


    outsel=topNet.addSignal(outsignals(end).Type,'outsel');
    outsel.SimulinkRate=blockInfo.SimulinkRate;
    pirelab.getIntDelayComp(topNet,validInbk,outsel,blockInfo.delay-1,'outsel_reg',0);

    comp=pirelab.getIntDelayComp(topNet,outsel,outsignals(end),1,'validOut_reg',0);
    comp.addComment('validOut register');



    const0=topNet.addSignal(accType,'const0');
    const0.SimulinkRate=blockInfo.SimulinkRate;
    comp=pirelab.getConstComp(topNet,const0,0);
    comp.addComment(' Constant Zero');

    validpInc=topNet.addSignal(accType,'validPInc');
    validpInc.SimulinkRate=blockInfo.SimulinkRate;
    addpInc=topNet.addSignal(accType,'addpInc');
    addpInc.SimulinkRate=blockInfo.SimulinkRate;
    accphase=topNet.addSignal(accType,'accphase_reg');
    accphase.SimulinkRate=blockInfo.SimulinkRate;

    pirelab.getSwitchComp(topNet,[pInc,const0],validpInc,validInbk,...
    'select PhaseInc','==',1);

    comp=pirelab.getAddComp(topNet,[accphase,validpInc],addpInc,'Floor','Wrap');
    comp.addComment('Add phase increment');

    if inMode(4)
        addpInc_rst=topNet.addSignal(accType,'addPInc_rst');
        addpInc_rst.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getSwitchComp(topNet,[const0,addpInc],addpInc_rst,reset,...
        'reset Phase accumulator','==',1);
    else
        addpInc_rst=addpInc;

    end

    regcomp=pirelab.getUnitDelayComp(topNet,addpInc_rst,accphase,'AccPhaseRegister',0);
    regcomp.addComment('Phase increment accumulator register');


    accoffset=topNet.addSignal(accType,'accoffset');
    accoffset.SimulinkRate=blockInfo.SimulinkRate;
    daccoffset=topNet.addSignal(accType,'accoffsete_reg');
    daccoffset.SimulinkRate=blockInfo.SimulinkRate;

    comp=pirelab.getAddComp(topNet,[accphase,pOffset],accoffset,'Floor','Wrap');
    comp.addComment('Add phase offset');

    regcomp=pirelab.getUnitDelayComp(topNet,accoffset,daccoffset,'AccOffsetRegister',0);
    regcomp.addComment('Phase offset accumulator register');


    if inMode(3)||blockInfo.InternalDither

        if blockInfo.InternalDither

            dithervalue=topNet.addSignal(pir_ufixpt_t(blockInfo.DitherBits,0),'dither');
            dithervalue.SimulinkRate=blockInfo.SimulinkRate;
            ditherNet=this.elabNCODither(topNet,blockInfo,blockInfo.SimulinkRate);
            ditherNet.addComment('Internal Dither Generation Component');
            pirelab.instantiateNetwork(topNet,ditherNet,validInbk,dithervalue,'dither_inst');

            casteddither=topNet.addSignal(accType,'casteddither');
            casteddither.SimulinkRate=blockInfo.SimulinkRate;
            pirelab.getDTCComp(topNet,dithervalue,casteddither,'floor','Wrap');
        end



        ddither=topNet.addSignal(accType,'dither_reg');
        ddither.SimulinkRate=blockInfo.SimulinkRate;
        regcomp=pirelab.getUnitDelayComp(topNet,casteddither,ddither,'DitherRegister',0);
        regcomp.addComment('Dither input register');


        acc=topNet.addSignal(accType,'accumulator');
        acc.SimulinkRate=blockInfo.SimulinkRate;
        comp=pirelab.getAddComp(topNet,[daccoffset,ddither],acc,'Floor','Wrap');
        comp.addComment('Add dither');

    else
        acc=daccoffset;
    end



    quantWL=blockInfo.PhaseBits;
    if blockInfo.PhaseQuantization&&(quantWL<accWL)

        phaseType=pir_ufixpt_t(quantWL,accWL-quantWL);
        quantacc=topNet.addSignal(phaseType,'accQuantized');
        quantacc.SimulinkRate=blockInfo.SimulinkRate;
        comp=pirelab.getDTCComp(topNet,acc,quantacc,'floor','wrap');
        comp.addComment(' Phase quantization');
    else
        quantacc=acc;
    end



    WaveNet=this.elabNCOWave(topNet,blockInfo,blockInfo.SimulinkRate);
    WaveNet.addComment('Wave form Generation Component');


    outMode=blockInfo.outMode;

    outType=outsignals(1).Type;

    outzero=topNet.addSignal(outType,'outzero');
    outzero.SimulinkRate=blockInfo.SimulinkRate;
    pirelab.getConstComp(topNet,outzero,0);

    if outMode(1)&&outMode(2)
        outsine=topNet.addSignal(outType,'outsine');
        outsine.SimulinkRate=blockInfo.SimulinkRate;
        outcos=topNet.addSignal(outType,'outcos');
        outcos.SimulinkRate=blockInfo.SimulinkRate;
        validsine=topNet.addSignal(outType,'validsine');
        validsine.SimulinkRate=blockInfo.SimulinkRate;
        validcos=topNet.addSignal(outType,'validcos');
        validcos.SimulinkRate=blockInfo.SimulinkRate;

        outs=[outsine,outcos];
        pirelab.instantiateNetwork(topNet,WaveNet,quantacc,outs,'Wave_inst');


        pirelab.getSwitchComp(topNet,[outsine,outzero],validsine,outsel,...
        'select valid output','==',1);

        pirelab.getSwitchComp(topNet,[outcos,outzero],validcos,outsel,...
        'select valid output','==',1);

        regcomp=pirelab.getUnitDelayComp(topNet,validsine,outsignals(1),'OutSineRegister',0);
        regcomp.addComment('Output sine register');
        regcomp=pirelab.getUnitDelayComp(topNet,validcos,outsignals(2),'OutCosineRegister',0);
        regcomp.addComment('Output cosine register');


    else
        outs=topNet.addSignal(outType,'outs');
        outs.SimulinkRate=blockInfo.SimulinkRate;
        validouts=topNet.addSignal(outType,'validouts');
        validouts.SimulinkRate=blockInfo.SimulinkRate;

        pirelab.instantiateNetwork(topNet,WaveNet,quantacc,outs,'Wave_inst');


        pirelab.getSwitchComp(topNet,[outs,outzero],validouts,outsel,...
        'select valid output','==',1);

        regcomp=pirelab.getUnitDelayComp(topNet,validouts,outsignals(1),'OutputRegister',0);
        regcomp.addComment('Output register');
    end



    if outMode(4)

        phaseSType=pir_ufixpt_t(quantWL,0);
        quantacc_s=topNet.addSignal(phaseSType,'quantacc_s');
        quantacc_s.SimulinkRate=blockInfo.SimulinkRate;

        pirelab.getDTCComp(topNet,quantacc,quantacc_s,'floor','wrap','SI');

        phaseDly=topNet.addSignal(phaseSType,'phaseDly');
        phaseDly.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getIntDelayComp(topNet,quantacc_s,phaseDly,4,'OutPhaseRegister',0);

        phasezero=topNet.addSignal(phaseSType,'phasezero');
        phasezero.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getConstComp(topNet,phasezero,0);

        phaseOut=topNet.addSignal(phaseSType,'phaseOut');
        phaseOut.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getSwitchComp(topNet,[phaseDly,phasezero],phaseOut,outsel,...
        'select valid output','==',1);
        regcomp=pirelab.getIntDelayComp(topNet,phaseOut,outsignals(end-1),1,'OutPhaseRegister',0);
        regcomp.addComment('Output phase register');
    end



