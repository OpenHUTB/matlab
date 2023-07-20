function[hdl_arch,delaylist,sumlist]=emit_delayline(this)





    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    coeffs=this.Coefficients;
    firlen=length(coeffs);


    num_channel=hdlgetparameter('filter_generate_multichannel');
    delaylen=(firlen-1)*num_channel;


    if delaylen==0
        delaylist=[];
        sumlist=[];
        return;
    end

    if emitMode

        rmode=this.Roundmode;
        [outputrounding,productrounding,sumrounding]=deal(rmode);

        omode=this.Overflowmode;
        [outputsaturation,productsaturation,sumsaturation]=deal(omode);
        sumall=hdlgetallfromsltype(this.AccumSLtype);
        sumvtype=sumall.vtype;
        sumsltype=sumall.sltype;

        storageall=hdlgetallfromsltype(this.StateSLtype);
        storagevtype=storageall.vtype;
        storagesltype=storageall.sltype;

        cplxity=this.isOutputPortComplex;

        if hdlgetparameter('isvhdl')&&(delaylen>1)
            hdl_arch.typedefs=[hdl_arch.typedefs,...
            '  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
            storagevtype,'; -- ',storagesltype,'\n'];
            delay_vector_vtype=['delay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
        else
            delay_vector_vtype=storagevtype;
        end

        if delaylen>1
            [uname,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,...
            cplxity,[delaylen,0],delay_vector_vtype,storagesltype,0);
        else
            [uname,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,...
            cplxity,0,delay_vector_vtype,storagesltype,0);
        end

        hdlregsignal(delay_pipe_out);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_out)];

        if strcmpi(storagesltype,sumsltype)
            if delaylen>1
                [uname,sumvector_out]=hdlnewsignal('sumvector','filter',-1,...
                cplxity,[delaylen,0],delay_vector_vtype,storagesltype,0);
            else
                [uname,sumvector_out]=hdlnewsignal('sumvector','filter',-1,...
                cplxity,0,delay_vector_vtype,storagesltype,0);
            end

            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumvector_out)];

            delay_pipe_in=sumvector_out;

        else
            if hdlgetparameter('isvhdl')&&(delaylen>1)
                hdl_arch.typedefs=[hdl_arch.typedefs,...
                '  TYPE sum_vector_type IS ARRAY (NATURAL range <>) OF ',...
                sumvtype,'; -- ',sumsltype,'\n'];
                sum_vector_vtype=['sum_vector_type(0 TO ',num2str(delaylen-1),')'];
            else
                sum_vector_vtype=sumvtype;
            end

            if delaylen>1
                [uname,sumvector_out]=hdlnewsignal('sumvector','filter',-1,cplxity,[delaylen,0],...
                sum_vector_vtype,sumsltype,0);
                [uname,delay_pipe_in]=hdlnewsignal('delay_pipeline_in','filter',-1,cplxity,[delaylen,0],...
                delay_vector_vtype,storagesltype,0);
            else
                [uname,sumvector_out]=hdlnewsignal('sumvector','filter',-1,cplxity,0,...
                sum_vector_vtype,sumsltype,0);
                [uname,delay_pipe_in]=hdlnewsignal('delay_pipeline_in','filter',-1,cplxity,0,...
                delay_vector_vtype,storagesltype,0);
            end


            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumvector_out)];
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_in)];

            tempbody=hdldatatypeassignment(sumvector_out,delay_pipe_in,...
            sumrounding,sumsaturation);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        end

        [tempbody,tempsignals]=hdlunitdelay(delay_pipe_in,delay_pipe_out,...
        ['Delay_Pipeline',hdlgetparameter('clock_process_label')],0);

        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];

        delaylist=hdlexpandvectorsignal(delay_pipe_out);

        sumlist=hdlexpandvectorsignal(sumvector_out);

    else
        numInputChannels=hdlgetparameter('filter_generate_multichannel');
        signalRate=hN.PirInputSignals(1).SimulinkRate/numInputChannels;

        if numInputChannels==1
            vectorSize=pirelab.getVectorTypeInfo(hN.PirInputSignals(1),1);
        else
            vectorSize=1;
        end

        delayT=getpirsignaltype(this.StateSLtype,this.isOutputPortComplex,...
        vectorSize);

        for i_delay=1:delaylen
            tdl_sig_in=hN.addSignal(delayT,['sum_',num2str(i_delay)]);
            tdl_sig_out=hN.addSignal(delayT,['del_',num2str(i_delay)]);
            tdl_sig_in.SimulinkRate=signalRate;
            tdl_sig_out.SimulinkRate=signalRate;
            pirelab.getIntDelayComp(hN,tdl_sig_in,tdl_sig_out,1);
            sumlist(i_delay)=tdl_sig_in;
            delaylist(i_delay)=tdl_sig_out;
        end

    end
