function dcomp=elaborateNCO(this,hN,blockInfo)







    outs=hN.PirOutputSignals;





    if blockInfo.inMode(1)
        insignals=hN.PirInputSignals;
        [indim,hBT]=pirelab.getVectorTypeInfo(insignals(1));

        dmuxout=[];
        for i=1:indim

            pinc(i)=hN.addSignal(hBT,['phaseinc_inp',num2str(i)]);
            pinc(i).SimulinkRate=blockInfo.SimulinkRate;
            pinc_idx(i)=hN.addSignal(hBT,['phase_increment',num2str(i)]);
            pinc_idx(i).SimulinkRate=blockInfo.SimulinkRate;
            dmuxout=[dmuxout,pinc(i)];
        end

        pirelab.getDemuxComp(hN,insignals(1),dmuxout);
        for i=1:indim
            pirelab.getDTCComp(hN,dmuxout(i),pinc_idx(i),'floor','wrap');
        end

    else

        indim=length(blockInfo.accinc);

        for i=1:indim



            pinc_idx(i)=hN.addSignal(blockInfo.accumDType,['C_NCO_PHASE_INCREMENT',num2str(i)]);
            pinc_idx(i).SimulinkRate=blockInfo.SimulinkRate;
            pirelab.getConstComp(hN,pinc_idx(i),blockInfo.accinc(i));
        end



    end





    for i=1:indim
        accum_reg_idx(i)=hN.addSignal(blockInfo.accumDType,['accumulator_reg',num2str(i)]);
        accum_reg_idx(i).SimulinkRate=blockInfo.SimulinkRate;
        accum_input_idx(i)=hN.addSignal(blockInfo.accumDType,['accumulator_input',num2str(i)]);
        accum_input_idx(i).SimulinkRate=blockInfo.SimulinkRate;
        dcomp=pirelab.getAddComp(hN,[accum_reg_idx(i),pinc_idx(i)],accum_input_idx(i),'Floor','Wrap');
    end





    if blockInfo.inMode(2)
        insignals=hN.PirInputSignals;
        offsetIdx=2-(1-blockInfo.inMode(1));

        [indim,hBT]=pirelab.getVectorTypeInfo(insignals(offsetIdx));

        dmuxout=[];
        for i=1:indim

            phaseoffset(i)=hN.addSignal(hBT,['phaseoffset_inp',num2str(i)]);
            phaseoffset(i).SimulinkRate=blockInfo.SimulinkRate;
            dmuxout=[dmuxout,phaseoffset(i)];
        end

        pirelab.getDemuxComp(hN,insignals(offsetIdx),dmuxout);

        for i=1:indim
            pOffset(i)=hN.addSignal(blockInfo.accumDType,['pOffset',num2str(i)]);
            pOffset(i).SimulinkRate=blockInfo.SimulinkRate;
            pirelab.getDTCComp(hN,dmuxout(i),pOffset(i),'floor','wrap');



            pirelab.getIntDelayComp(hN,accum_input_idx(i),accum_reg_idx(i),1,'NCO_phase_accumulator_temp_process3',0);

            total_phase_idx(i)=hN.addSignal(blockInfo.accumDType,['total_phase_idx',num2str(i)]);%#ok<*NASGU>
            total_phase_idx(i).SimulinkRate=blockInfo.SimulinkRate;

            comp=pirelab.getAddComp(hN,[accum_reg_idx(i),pOffset(i)],total_phase_idx(i),'Floor','Wrap');
            comp.addComment('Add phase offset');
        end
    else

        for i=1:indim

            total_phase_idx(i)=hN.addSignal(blockInfo.accumDType,['total_phase_idx',num2str(i)]);%#ok<*NASGU>
            total_phase_idx(i).SimulinkRate=blockInfo.SimulinkRate;


            pirelab.getIntDelayComp(hN,accum_input_idx(i),accum_reg_idx(i),1,'NCO_phase_accumulator_temp_process3',blockInfo.phaseOffset(i));


        end
        total_phase_idx=accum_reg_idx;
    end





    if blockInfo.Dither

        dithervalue=hN.addSignal(pir_ufixpt_t(blockInfo.DitherBits,0),'dither');
        dithervalue.SimulinkRate=blockInfo.SimulinkRate;

        ditherNet=this.elaborateNCODither(hN,blockInfo,blockInfo.SimulinkRate);
        ditherNet.addComment('Internal Dither Generation Component');
        pirelab.instantiateNetwork(hN,ditherNet,[],dithervalue,'dither_inst');

        casteddither=hN.addSignal(blockInfo.accumDType,'casteddither');
        casteddither.SimulinkRate=blockInfo.SimulinkRate;
        pirelab.getDTCComp(hN,dithervalue,casteddither,'floor','Wrap');


        acc=hN.addSignal(blockInfo.accumDType,'accumulator');
        acc.SimulinkRate=blockInfo.SimulinkRate;
        comp=pirelab.getAddComp(hN,[total_phase_idx,casteddither],acc,'Floor','Wrap');
        comp.addComment('Add dither');

    else
        acc=total_phase_idx;

    end






    quantWL=blockInfo.quantWL;
    accWL=blockInfo.accumDType.WordLength;

    if blockInfo.PhaseQuantization&&(quantWL<accWL)

        phaseType=pir_ufixpt_t(quantWL,accWL-quantWL);

        for i=1:indim
            quantacc(i)=hN.addSignal(phaseType,['accQuantized',num2str(i)]);
            quantacc(i).SimulinkRate=blockInfo.SimulinkRate;
            comp=pirelab.getDTCComp(hN,acc(i),quantacc(i),'floor','wrap');
            comp.addComment(' Phase quantization');
        end
    else
        quantacc=acc;
    end





    WaveNet=this.elaborateNCOWave(hN,blockInfo,blockInfo.SimulinkRate);
    WaveNet.addComment('Wave form Generation Component');


    outMode=blockInfo.outMode;


    if isa(outs(1).Type,'hdlcoder.tp_complex')
        outType=outs(1).Type;
    else

        outType=outs(1).Type.BaseType;
    end


    if outMode(1)&&outMode(2)

        for i=1:indim
            internalOut1(i)=hN.addSignal(outType,['internalOut1',num2str(i)]);
            internalOut1(i).SimulinkRate=blockInfo.SimulinkRate;
            internalOut2(i)=hN.addSignal(outType,['internalOut2',num2str(i)]);
            internalOut2(i).SimulinkRate=blockInfo.SimulinkRate;
            pirelab.instantiateNetwork(hN,WaveNet,quantacc(i),[internalOut1(i),internalOut2(i)],['Wave_inst',num2str(i)]);
        end
        pirelab.getMuxComp(hN,internalOut1,outs(1));
        pirelab.getMuxComp(hN,internalOut2,outs(2));

    else
        for i=1:indim
            vecOut(i)=hN.addSignal(outType,['vecOut',num2str(i)]);
            vecOut(i).SimulinkRate=blockInfo.SimulinkRate;
            pirelab.instantiateNetwork(hN,WaveNet,quantacc(i),vecOut(i),['Wave_inst',num2str(i)]);

        end
        pirelab.getMuxComp(hN,vecOut,outs(1));


    end




    if outMode(4)
        phaseSType=pir_ufixpt_t(accWL-quantWL,0);

        for i=1:indim
            quanterr_idx(i)=hN.addSignal(phaseSType,['unsigned_quantization_err',num2str(i)]);
            quanterr_idx(i).SimulinkRate=blockInfo.SimulinkRate;
            pirelab.getDTCComp(hN,acc(i),quanterr_idx(i),'floor','wrap');

            internal_out(i)=hN.addSignal(outs(end).Type.BaseType,['internal_out',num2str(i)]);
            internal_out(i).SimulinkRate=blockInfo.SimulinkRate;
            pirelab.getDTCComp(hN,quanterr_idx(i),internal_out(i),'floor','wrap');
        end
        pirelab.getMuxComp(hN,internal_out,outs(end));
    end
end


