function[delayline_arch,delaylist]=emit_delayline(this,entitysigs,ce_delay)






    fl=getfilterlengths(this);
    firlen=fl.firlen;

    delayline_arch.functions='';
    delayline_arch.typedefs='';
    delayline_arch.constants='';
    delayline_arch.signals='';
    delayline_arch.body_blocks='';
    delayline_arch.body_output_assignments='';

    arch=this.implementation;
    inputrounding='round';
    inputsaturation=true;

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputvtype=inputall.portvtype;
    inputsltype=inputall.portsltype;

    delayvtype=inputall.vtype;
    delaysltype=inputall.sltype;
    if~strcmpi(arch,'distributedarithmetic')
        if hdlgetparameter('filter_registered_input')==1
            delaylen=firlen;
        else
            if~strcmpi(arch,'parallel')
                delaylen=firlen;
            else
                delaylen=firlen-1;
            end
        end



        if hdlgetparameter('isvhdl')&&(delaylen>1)

            delayline_arch.typedefs=[delayline_arch.typedefs,...
            '  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
            delayvtype,'; -- ',delaysltype,'\n'];
            delay_vector_vtype=['delay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
        else
            delay_vector_vtype=delayvtype;
        end
        if delaylen>1
            [uname,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,0,...
            [delaylen,0],delay_vector_vtype,delaysltype);
        else
            [uname,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,0,...
            0,delay_vector_vtype,delaysltype);
        end
        hdlregsignal(delay_pipe_out);
        delayline_arch.signals=[delayline_arch.signals,makehdlsignaldecl(delay_pipe_out)];
        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(ce_delay);

        [tapbody,tapsignals]=hdltapdelay(entitysigs.input,delay_pipe_out,...
        ['Delay_Pipeline',hdlgetparameter('clock_process_label')],delaylen,'Newest',0);
        hdlsetcurrentclockenable(oldce);

        delayline_arch.body_blocks=[delayline_arch.body_blocks,tapbody];
        delayline_arch.signals=[delayline_arch.signals,tapsignals];

        if delaylen>1
            delaylist=hdlexpandvectorsignal(delay_pipe_out);
        else
            delaylist=delay_pipe_out;
        end

        if hdlgetparameter('filter_registered_input')==0

            if~strcmpi(delayvtype,inputvtype)||~strcmp(delaysltype,inputsltype)
                etypec_sig=[hdlsignalname(entitysigs.input),'_regtype'];
                [uname,entitysigs.input_type_conv]=hdlnewsignal(etypec_sig,'filter',-1,0,...
                0,delayvtype,delaysltype);
                hdlregsignal(entitysigs.input_type_conv);
                delayline_arch.signals=[delayline_arch.signals,makehdlsignaldecl(entitysigs.input_type_conv)];
                delayline_arch.body_blocks=[delayline_arch.body_blocks,...
                hdldatatypeassignment(entitysigs.input,...
                entitysigs.input_type_conv,...
                inputrounding,inputsaturation)];
            else
                entitysigs.input_type_conv=entitysigs.input;
            end

            delaylist=[entitysigs.input_type_conv,delaylist];
        end

    end




