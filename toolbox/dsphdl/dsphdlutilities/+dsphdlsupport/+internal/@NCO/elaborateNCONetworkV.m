function elaborateNCONetworkV(this,topNet,blockInfo)







    accWL=blockInfo.AccuWL;
    quantWL=blockInfo.PhaseBits;

    accType=pir_sfixpt_t(accWL,0);
    doutType=pirgetdatatypeinfo(topNet.PirOutputSignals(1).Type);
    dim=doutType.dims;
    outType=pir_sfixpt_t(doutType.wordsize,doutType.binarypoint);
    if doutType.iscomplex
        outType=pir_complex_t(outType);
    end
    lutaddr_type=pir_ufixpt_t(quantWL,0);
    phaseout_type=pir_ufixpt_t(quantWL,0);




    accType_vector=pirelab.createPirArrayType(accType,dim);
    lutaddrIdx_types=pirelab.createPirArrayType(lutaddr_type,dim);
    phaseout_types=pirelab.createPirArrayType(phaseout_type,dim);


    insignals=topNet.PirInputSignals;



    inMode=blockInfo.inMode;
    outMode=blockInfo.outMode;

    pInc=topNet.addSignal(accType,'pInc');
    pInc.SimulinkRate=blockInfo.SimulinkRate;




    pInc_DTC=topNet.addSignal(accType,'pInc_DTC');
    pInc_DTC.SimulinkRate=blockInfo.SimulinkRate;
    pOffset=topNet.addSignal(accType,'pOffset');
    pOffset.SimulinkRate=blockInfo.SimulinkRate;


    pOffset_DTC=topNet.addSignal(accType,'pOffset_DTC');
    pOffset_DTC.SimulinkRate=blockInfo.SimulinkRate;
    dither_DTC=topNet.addSignal(accType_vector,'dither_DTC');
    dither_DTC.SimulinkRate=blockInfo.SimulinkRate;
    dither_vector=topNet.addSignal(accType_vector,'dithervector');
    dither_vector.SimulinkRate=blockInfo.SimulinkRate;
    dither_vector_reg=topNet.addSignal(accType_vector,'dithervector_reg');
    dither_vector_reg.SimulinkRate=blockInfo.SimulinkRate;
    phase_vector=topNet.addSignal(accType_vector,'phasevector');
    phase_vector.SimulinkRate=blockInfo.SimulinkRate;
    dither_phase_vector=topNet.addSignal(accType_vector,'dither_phase_vector');
    dither_phase_vector.SimulinkRate=blockInfo.SimulinkRate;
    phase_output_vector=topNet.addSignal(accType_vector,'phaseoutputvector_reg');
    phase_output_vector.SimulinkRate=blockInfo.SimulinkRate;
    phase_output_vector_reg=topNet.addSignal(accType_vector,'phaseoutputvector_reg');
    phase_output_vector_reg.SimulinkRate=blockInfo.SimulinkRate;
    quant_output_vector=topNet.addSignal(lutaddrIdx_types,'quantoutputvector');
    quant_output_vector.SimulinkRate=blockInfo.SimulinkRate;
    dither_phase_vector_reg=topNet.addSignal(accType_vector,'dither_phase_vector_reg');
    dither_phase_vector_reg.SimulinkRate=blockInfo.SimulinkRate;
    pOffset_delay=topNet.addSignal(accType,'phase_delay');
    pOffset_delay.SimulinkRate=blockInfo.SimulinkRate;
    phase_output_reg=topNet.addSignal(lutaddrIdx_types,'phase_output_reg');
    phase_output_reg.SimulinkRate=blockInfo.SimulinkRate;
    is_frac=false;

    if inMode(1)

        pInc_info=pirgetdatatypeinfo(insignals(1).Type);
        if(pInc_info.binarypoint)
            is_frac=true;
            pirelab.getDTCComp(topNet,insignals(1),pInc_DTC,'floor','wrap');
            pirelab.getWireComp(topNet,pInc_DTC,pInc,'floor','wrap');
        else
            pirelab.getDTCComp(topNet,insignals(1),pInc,'floor','wrap');
        end

    else
        DT=fi(blockInfo.PhaseInc,1,accWL,0,'OverflowAction','wrap');
        pirelab.getConstComp(topNet,pInc,DT);
    end


    if inMode(2)
        offsetIdx=2-(1-inMode(1));
        pOffset_info=pirgetdatatypeinfo(insignals(offsetIdx).Type);
        if(pOffset_info.binarypoint~=0||is_frac)
            is_frac=true;
            pirelab.getDTCComp(topNet,insignals(offsetIdx),pOffset_DTC,'floor','wrap');
            pirelab.getWireComp(topNet,pOffset_DTC,pOffset,'floor','wrap');
        else
            pirelab.getDTCComp(topNet,insignals(offsetIdx),pOffset,'floor','wrap');
        end

    else
        temp2=fi(blockInfo.PhaseOffset,1,accWL,0,'OverflowAction','wrap');
        pirelab.getConstComp(topNet,pOffset,temp2);
    end


    if inMode(3)
        ditherIdx=3-(2-sum(inMode(1:2)));
        dither_info=pirgetdatatypeinfo(insignals(ditherIdx).Type);
        if(dither_info.binarypoint~=0||is_frac)
            is_frac=true;
            pirelab.getDTCComp(topNet,insignals(ditherIdx),dither_DTC,'floor','wrap');
            pirelab.getWireComp(topNet,dither_DTC,dither_vector_reg,'floor','wrap');
        else
            pirelab.getDTCComp(topNet,insignals(ditherIdx),dither_vector_reg,'floor','wrap');
        end
        pirelab.getIntDelayComp(topNet,dither_vector_reg,dither_vector,3,'dither_from_source_reg',0);
    end


    if inMode(4)
        resetIdx=4-(3-sum(inMode(1:3)));
        reset=insignals(resetIdx);
    else
        reset=topNet.addSignal(pir_boolean_t,'reset');
        reset.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getConstComp(topNet,reset,0);
    end




    validIn=insignals(end);
    if validIn.SimulinkRate~=blockInfo.SimulinkRate
        validInbk=topNet.addSignal(validIn.Type,'validInbk');
        pirelab.getWireComp(topNet,validIn,validInbk);
        validInbk.SimulinkRate=blockInfo.SimulinkRate;
    else
        validInbk=validIn;
    end
    validIn_delay=topNet.addSignal(validIn.Type,'valid_delay');
    pirelab.getIntDelayComp(topNet,validIn,validIn_delay,3,'',0);







    outsignals=topNet.PirOutputSignals;


    resetn=topNet.addSignal(pir_boolean_t,'resetn');
    resetn.SimulinkRate=blockInfo.SimulinkRate;
    vldIn=topNet.addSignal(pir_boolean_t,'vldIn');
    vldIn.SimulinkRate=blockInfo.SimulinkRate;
    pirelab.getBitwiseOpComp(topNet,reset,resetn,'NOT');
    pirelab.getBitwiseOpComp(topNet,[resetn,validInbk],vldIn,'AND');
    outsel=topNet.addSignal(outsignals(end).Type,'outsel');
    outsel.SimulinkRate=blockInfo.SimulinkRate;
    pirelab.getIntDelayComp(topNet,vldIn,outsel,blockInfo.delay-1,'outsel_reg',0);
    comp=pirelab.getIntDelayComp(topNet,outsel,outsignals(end),1,'validOut_reg',0);
    comp.addComment('validOut register');
    WaveNet=this.elabNCOWave(topNet,blockInfo,blockInfo.SimulinkRate);
    WaveNet.addComment('Wave form Generation Component');


    wn=this.elabNCOPhaseMulV(topNet,blockInfo,blockInfo.SimulinkRate,pInc,vldIn,reset,phase_vector);
    wn.addComment('Wave form Generation Component');
    pirelab.instantiateNetwork(topNet,wn,[pInc,vldIn,reset],phase_vector,'pinc_mul');


    pirelab.getIntDelayComp(topNet,pOffset,pOffset_delay,2,0);

    pirelab.getAddComp(topNet,[phase_vector,pOffset_delay],phase_output_vector,'Floor','Wrap');
    pirelab.getIntDelayComp(topNet,phase_output_vector,phase_output_vector_reg,1,0);


    if(inMode(3)||blockInfo.InternalDither)
        if(blockInfo.InternalDither)
            DN=this.elabNCODitherV(topNet,blockInfo,blockInfo.SimulinkRate,dim);
            pirelab.instantiateNetwork(topNet,DN,vldIn,dither_vector,'dither');
            pirelab.getAddComp(topNet,[phase_output_vector_reg,dither_vector],dither_phase_vector,'Floor','Wrap',[],[],'++');
        else
            pirelab.getAddComp(topNet,[phase_output_vector_reg,dither_vector],dither_phase_vector,'Floor','Wrap',[],[],'++');
        end
    else
        pirelab.getWireComp(topNet,phase_output_vector_reg,dither_phase_vector);
    end

    if dim==1
        pirelab.getWireComp(topNet,dither_phase_vector,dither_phase_vector_reg);
    else
        pirelab.getUnitDelayComp(topNet,dither_phase_vector,dither_phase_vector_reg,0);
    end





    pirelab.getBitSliceComp(topNet,dither_phase_vector_reg,quant_output_vector,accWL-1,accWL-quantWL);




    pirelab.getWireComp(topNet,quant_output_vector,phase_output_reg);


    if(outMode(1)&&outMode(2))

        for i=1:dim
            dmx_sin(i)=topNet.addSignal(lutaddr_type,['dmx_',num2str(dim)]);
            dmx_sin(i).SimulinkRate=blockInfo.SimulinkRate;
        end
        dout_bus_sin=topNet.addSignal(outsignals(1).Type,'dout_bus');
        dout_bus_sin.SimulinkRate=blockInfo.SimulinkRate;
        out_reg_sin=topNet.addSignal(outsignals(1).Type,'out_reg');
        out_reg_sin.SimulinkRate=blockInfo.SimulinkRate;
        outzero_sin=topNet.addSignal(outsignals(1).Type,'outzero');
        outzero_sin.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getDemuxComp(topNet,phase_output_reg,dmx_sin);
        pirelab.getConstComp(topNet,outzero_sin,0);

        for i=1:dim
            dmx_cos(i)=topNet.addSignal(lutaddr_type,['dmx_',num2str(dim)]);
            dmx_cos(i).SimulinkRate=blockInfo.SimulinkRate;
        end
        pirelab.getDemuxComp(topNet,phase_output_reg,dmx_cos);

        dout_bus_cos=topNet.addSignal(outsignals(2).Type,'dout_bus');
        dout_bus_cos.SimulinkRate=blockInfo.SimulinkRate;
        out_reg_cos=topNet.addSignal(outsignals(2).Type,'out_reg');
        out_reg_cos.SimulinkRate=blockInfo.SimulinkRate;

        outzero_cos=topNet.addSignal(outsignals(2).Type,'outzero');
        outzero_cos.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getConstComp(topNet,outzero_cos,0);

        for i=1:dim
            dout_sin(i)=topNet.addSignal(outType,['dout_',num2str(dim)]);%#ok<*AGROW>
            dout_sin(i).SimulinkRate=blockInfo.SimulinkRate;
            dout_cos(i)=topNet.addSignal(outType,['dout_',num2str(dim)]);
            dout_cos(i).SimulinkRate=blockInfo.SimulinkRate;
            pirelab.instantiateNetwork(topNet,WaveNet,dmx_sin(i),[dout_sin(i),dout_cos(i)],['wavegen_',num2str(dim)]);
        end






        pirelab.getMuxComp(topNet,dout_sin,dout_bus_sin);
        pirelab.getSwitchComp(topNet,[dout_bus_sin,outzero_sin],out_reg_sin,outsel,'valid out switch','==',1);
        pirelab.getUnitDelayComp(topNet,out_reg_sin,outsignals(1),'',0);
        pirelab.getMuxComp(topNet,dout_cos,dout_bus_cos);
        pirelab.getSwitchComp(topNet,[dout_bus_cos,outzero_cos],out_reg_cos,outsel,'valid out switch','==',1);
        pirelab.getUnitDelayComp(topNet,out_reg_cos,outsignals(2),'',0);

    else


































        dout_bus=topNet.addSignal(outsignals(1).Type,'dout_bus');
        dout_bus.SimulinkRate=blockInfo.SimulinkRate;
        out_reg=topNet.addSignal(outsignals(1).Type,'out_reg');
        out_reg.SimulinkRate=blockInfo.SimulinkRate;

        outzero=topNet.addSignal(outsignals(1).Type,'outzero');
        outzero.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getConstComp(topNet,outzero,0);
        for i=1:dim
            dmx(i)=topNet.addSignal(lutaddr_type,['dmx_',num2str(dim)]);
            dmx(i).SimulinkRate=blockInfo.SimulinkRate;
            dout(i)=topNet.addSignal(outType,['dout_',num2str(dim)]);
            dout(i).SimulinkRate=blockInfo.SimulinkRate;
        end
        if(dim==1)
            pirelab.getWireComp(topNet,phase_output_reg,dmx);
        else
            pirelab.getDemuxComp(topNet,phase_output_reg,dmx);
        end
        for i=1:dim
            pirelab.instantiateNetwork(topNet,WaveNet,dmx(i),dout(i),['wavegen_',num2str(dim)]);
        end

        if(dim==1)
            pirelab.getWireComp(topNet,dout,dout_bus);
        else
            pirelab.getMuxComp(topNet,dout,dout_bus);
        end
        pirelab.getSwitchComp(topNet,[dout_bus,outzero],out_reg,outsel,'valid out switch','==',1);
        pirelab.getUnitDelayComp(topNet,out_reg,outsignals(1),'',0);
    end



    if outMode(4)

        quantacc_s=topNet.addSignal(phaseout_types,'quantacc_s');
        quantacc_s.SimulinkRate=blockInfo.SimulinkRate;

        pirelab.getDTCComp(topNet,phase_output_reg,quantacc_s,'Floor','Wrap','SI');

        phaseDly=topNet.addSignal(phaseout_types,'phaseDly');
        phaseDly.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getIntDelayComp(topNet,quantacc_s,phaseDly,4,'OutPhaseRegister',0);

        phasezero=topNet.addSignal(phaseout_types,'phasezero');
        phasezero.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getConstComp(topNet,phasezero,0);

        phaseOut=topNet.addSignal(phaseout_types,'phaseOut');
        phaseOut.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getSwitchComp(topNet,[phaseDly,phasezero],phaseOut,outsel,...
        'select valid output','==',1);

        regcomp=pirelab.getIntDelayComp(topNet,phaseOut,outsignals(end-1),1,'OutPhaseRegister',0);
        regcomp.addComment('Output phase register');
    end









