function[hdl_arch,entitysigs]=emit_multichannel(this,entitysigs,ce_delay)



    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    num_channel=hdlgetparameter('filter_generate_multichannel');
    if num_channel==1
        return;
    end





    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    arch=this.implementation;
    cplxity_in=this.isInputPortComplex;
    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputvtype=inputall.vtype;
    inputsltype=inputall.sltype;
    cplxity_out=this.isOutputPortComplex;
    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    outputvtype=outputall.vtype;
    outputsltype=outputall.sltype;

    count_to=num_channel;


    this.HDLParameters.INI.setProp('filter_generate_multichannel',1);
    [~,~,slLatency]=this.latency;
    if emitMode
        ctr_sigs_phase=mod(slLatency-1,count_to);
    else
        ctr_sigs_phase=mod(slLatency,count_to);
    end
    this.HDLParameters.INI.setProp('filter_generate_multichannel',num_channel);


    if~emitMode
        [~,serial_in]=hdlnewsignal([hdlgetparameter('filter_input_name'),'_serial'],...
        'filter',-1,cplxity_in,0,inputvtype,inputsltype,hN.PirInputSignals(1).SimulinkRate/num_channel);
        pirelab.getSerializerComp(hN,entitysigs.input,serial_in);

        [~,serial_out]=hdlnewsignal([hdlgetparameter('filter_output_name'),'_serial'],...
        'filter',-1,cplxity_out,0,outputvtype,outputsltype,hN.PirOutputSignals.SimulinkRate/num_channel);

        [~,tap_out_fast]=hdlnewsignal([hdlgetparameter('filter_output_name'),'_serial_tapDelay'],...
        'filter',-1,cplxity_out,num_channel-1,outputvtype,outputsltype,hN.PirOutputSignals.SimulinkRate/num_channel);

        [~,slow_signal_vect]=hdlnewsignal([hdlgetparameter('filter_output_name'),'_serial_tapDelay'],...
        'filter',-1,cplxity_out,num_channel,outputvtype,outputsltype,hN.PirOutputSignals.SimulinkRate);

        pirelab.getTapDelayComp(hN,serial_out,tap_out_fast,num_channel-1);

        fast_signal_array=[hdlexpandvectorsignal(tap_out_fast);serial_out];




        if(hdlgetparameter('clockinputs'))>1&&(ctr_sigs_phase~=0)&&(ctr_sigs_phase~=num_channel-1)
            [~,serial_out_reg]=hdlnewsignal([hdlgetparameter('filter_output_name'),'_serial'],...
            'filter',-1,cplxity_out,0,outputvtype,outputsltype,hN.PirOutputSignals.SimulinkRate/num_channel);
            pireml.getUnitDelayComp(hN,serial_out_reg,serial_out);
            serial_out=serial_out_reg;
        end

        for i_delay=1:num_channel
            slow_signal=hN.addSignal(serial_out.Type,[serial_out.Name,num2str(i_delay)]);
            slow_signal.SimulinkRate=hN.PirOutputSignals.SimulinkRate;
            slow_signal_array(i_delay)=slow_signal;
            delayComp=pireml.getUnitDelayComp(hN,fast_signal_array(i_delay),slow_signal_array(i_delay));
            if hdlgetparameter('clockinputs')>1


                if ctr_sigs_phase==0
                    delayComp.getClockBundle(hN.PirOutputSignals,1,1,1);
                else
                    delayComp.getClockBundle(hN.PirOutputSignals,num_channel,1,0);
                end
            else
                delayComp.getClockBundle(hN.PirOutputSignals,num_channel,num_channel,ctr_sigs_phase);
            end
        end

        pirelab.getMuxComp(hN,slow_signal_array,slow_signal_vect);

        pirelab.getWireComp(hN,slow_signal_vect,entitysigs.output);

    else

        count_bits=max(2,ceil(log2(count_to)));
        [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
        if emitMode
            [~,ctr_out]=hdlnewsignal('cur_count','filter',-1,0,0,countvtype,countsltype);
            hdlregsignal(ctr_out);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_out)];
        else
            hT=pir_ufixpt_t(count_bits,0);
            ctr_out=hN.addSignal(hT,'cur_count');
        end


        [ctr_body,ctr_sigs]=hdlcounter(ctr_out,count_to,['Multichannel_Counter',hdlgetparameter('clock_process_label')],...
        1,0,ctr_sigs_phase);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_sigs)];
        hdladdclockenablesignal(ctr_sigs);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body];



        [~,serial_in]=hdlnewsignal([hdlgetparameter('filter_input_name'),'_serial'],...
        'filter',-1,cplxity_in,0,inputvtype,inputsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(serial_in)];

        [~,serial_out]=hdlnewsignal([hdlgetparameter('filter_output_name'),'_serial'],...
        'filter',-1,cplxity_in,0,outputvtype,outputsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(serial_out)];



        mux_body=hdlmux([entitysigs.input],serial_in,...
        ctr_out,{'='},[0:num_channel],'when-else');
        hdl_arch.body_blocks=[hdl_arch.body_blocks,mux_body];



        buffer_type=[hdlgetparameter('vector_prefix'),outputsltype];
        if hdlgetparameter('isvhdl')
            hdl_arch.typedefs=[hdl_arch.typedefs,...
            '  TYPE ',buffer_type,' IS ARRAY (NATURAL range <>) OF ',...
            outputvtype,'; -- ',outputsltype,'\n'];
            if num_channel>2
                output_delayline_vector_vtype=[buffer_type,'(0 TO ',num2str(num_channel-2),')'];
            else
                output_delayline_vector_vtype=outputvtype;
            end
            output_buffer_vector_vtype=[buffer_type,'(0 TO ',num2str(num_channel-1),')'];
        else
            output_delayline_vector_vtype=outputvtype;
            output_buffer_vector_vtype=outputvtype;
        end

        [~,delay_line_regs]=hdlnewsignal('output_delay_line','filter',-1,cplxity_in,...
        [num_channel-1,0],output_delayline_vector_vtype,outputsltype);
        hdlregsignal(delay_line_regs);

        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_line_regs)];
        delay_line_reglist=hdlexpandvectorsignal(delay_line_regs);


        if strcmpi(arch,'serial')||strcmpi(arch,'serialcascade')
            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(ce_delay);
        end

        [tapbody,tapsignals]=hdltapdelay(serial_out,delay_line_regs,...
        ['Output_Delay_Line',hdlgetparameter('clock_process_label')],num_channel-1,'Newest',0);


        hdl_arch.body_blocks=[hdl_arch.body_blocks,tapbody];
        hdl_arch.signals=[hdl_arch.signals,tapsignals];

        if strcmpi(arch,'serial')||strcmpi(arch,'serialcascade')
            hdlsetcurrentclockenable(oldce);
        end


        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(ctr_sigs);

        [~,output_buffer_regs]=hdlnewsignal('output_buffer','filter',-1,cplxity_in,...
        [num_channel,0],output_buffer_vector_vtype,outputsltype);
        hdlregsignal(output_buffer_regs);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(output_buffer_regs)];
        output_buffer_reglist=hdlexpandvectorsignal(output_buffer_regs);

        [buffbody,buffsignals]=hdlunitdelay([delay_line_reglist(end:-1:1),serial_out],output_buffer_reglist,...
        ['Output_Buffer',hdlgetparameter('clock_process_label')],zeros(1,num_channel));

        hdl_arch.body_blocks=[hdl_arch.body_blocks,buffbody];
        hdl_arch.signals=[hdl_arch.signals,buffsignals];

        hdlsetcurrentclockenable(oldce);

        for n=1:num_channel
            hdlbody=hdlfinalassignment(output_buffer_reglist(n),entitysigs.output(n));
            hdl_arch.body_blocks=[hdl_arch.body_blocks,hdlbody];
        end

    end


    entitysigs.input=serial_in;
    entitysigs.output=serial_out;
