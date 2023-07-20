function[hdl_arch,delaylist]=emit_delayline(this,entitysigs,ce_delay)










    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    arch=this.implementation;
    coeffs=this.Coefficients;
    firlen=length(coeffs);
    inputrounding='round';
    inputsaturation=true;

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputvtype=inputall.portvtype;
    inputsltype=inputall.portsltype;

    delayvtype=inputall.vtype;
    delaysltype=inputall.sltype;

    cplxity=this.isInputPortComplex;

    num_channel=hdlgetparameter('filter_generate_multichannel');
    if hdlgetparameter('filter_registered_input')==1
        delaylen=firlen;
    else
        if~(strcmpi(arch,'parallel')||strcmpi(arch,'distributedarithmetic'))
            delaylen=(firlen-1)*num_channel+1;
        else
            delaylen=(firlen-1)*num_channel;
        end
    end


    if emitMode

        if delaylen==0&&firlen==1
            delaylist=entitysigs.input;
            return;
        end


        if hdlgetparameter('isvhdl')&&(delaylen>1)

            hdl_arch.typedefs=[hdl_arch.typedefs,...
            '  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
            delayvtype,'; -- ',delaysltype,'\n'];
            delay_vector_vtype=['delay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
        else
            delay_vector_vtype=delayvtype;
        end
        if delaylen>1
            [uname,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,cplxity,...
            [delaylen,0],delay_vector_vtype,delaysltype);
        else
            [uname,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,cplxity,...
            0,delay_vector_vtype,delaysltype);
        end
        hdlregsignal(delay_pipe_out);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_out)];

        if strcmpi(arch,'serial')||strcmpi(arch,'serialcascade')
            oldce=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable(ce_delay);
        end

        [tapbody,tapsignals]=hdltapdelay(entitysigs.input,delay_pipe_out,...
        ['Delay_Pipeline',hdlgetparameter('clock_process_label')],delaylen,'Newest',0);

        if strcmpi(arch,'serial')||strcmpi(arch,'serialcascade')
            hdlsetcurrentclockenable(oldce);
        end
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tapbody];
        hdl_arch.signals=[hdl_arch.signals,tapsignals];

        if delaylen>1
            delaylist=hdlexpandvectorsignal(delay_pipe_out);
        else
            delaylist=delay_pipe_out;
        end

        inuname=hdlsignalname(entitysigs.input);
        if hdlgetparameter('filter_registered_input')==0

            if~strcmpi(delayvtype,inputvtype)||~strcmp(delaysltype,inputsltype)

                [uname,entitysigs.input_type_conv]=hdlnewsignal([inuname,'_regtype'],'filter',-1,cplxity,...
                0,delayvtype,delaysltype);
                hdlregsignal(entitysigs.input_type_conv);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(entitysigs.input_type_conv)];
                hdl_arch.body_blocks=[hdl_arch.body_blocks,...
                hdldatatypeassignment(entitysigs.input,...
                entitysigs.input_type_conv,...
                inputrounding,inputsaturation)];
            else
                entitysigs.input_type_conv=entitysigs.input;
            end

            delaylist=[entitysigs.input_type_conv,delaylist];
        end

    else
        hdl_arch.body_blocks='';
        hdl_arch.signals='';

        numChannels=entitysigs.input.Type.getDimensions;

        if numChannels>1
            vectorSize=numChannels;
        elseif delaylen>1
            vectorSize=delaylen;
        else
            vectorSize=0;
        end

        if delaylen==0&&firlen==1
            delaylist=entitysigs.input;
        else
            [~,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,cplxity,...
            vectorSize,delayvtype,delaysltype,entitysigs.input.SimulinkRate);

            [~,tapsignals]=hdltapdelay(entitysigs.input,delay_pipe_out,...
            'Delay_Pipeline',delaylen,'Newest',0);

            if numChannels>1
                delaylist=tapsignals;
            elseif delaylen>1
                delaylist=hdlexpandvectorsignal(delay_pipe_out);
            else
                delaylist=delay_pipe_out;
            end

            if isrow(delaylist)
                delaylist=[entitysigs.input,delaylist];
            else
                delaylist=[entitysigs.input,delaylist.'];
            end
        end
    end

