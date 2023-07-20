function[hdl_arch,entitysigs,delaylist]=emit_delayline(this,entitysigs)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';


    polycoeffs=this.PolyphaseCoefficients;
    [alsophases,delaylen]=size(polycoeffs);
    addinputreg=hdlgetparameter('filter_registered_input');
    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    cplxity=this.isInputPortComplex;

    rmode=this.Roundmode;
    [productrounding]=rmode;

    omode=this.Overflowmode;
    [productsaturation]=omode;

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    reginputvtype=inputall.vtype;
    reginputsltype=inputall.sltype;
    inputvtype=inputall.portvtype;
    inputsltype=inputall.portsltype;

    hdl_arch.body_blocks=[hdl_arch.body_blocks,...
    indentedcomment,'  ---------------- Delay Registers ----------------\n\n'];
    if addinputreg==1
        reglen=delaylen;
    else
        reglen=delaylen-1;
    end

    delayvtype=reginputvtype;
    delaysltype=reginputsltype;

    if hdlgetparameter('isvhdl')&&reglen>1
        hdl_arch.typedefs=[hdl_arch.typedefs,...
        '  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
        reginputvtype,'; -- ',reginputsltype,'\n'];
        delay_vector_vtype=['delay_pipeline_type(0 TO ',num2str(reglen-1),')'];
    else
        delay_vector_vtype=reginputvtype;
    end

    if reglen==1
        [uname,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,cplxity,...
        0,delay_vector_vtype,delaysltype);
        hdlregsignal(delay_pipe_out);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_out)];
        [tapbody,tapsignals]=hdlunitdelay(entitysigs.input,delay_pipe_out,...
        ['Delay_Pipeline',hdlgetparameter('clock_process_label')],0);
    else
        [uname,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,cplxity,...
        [reglen,0],delay_vector_vtype,delaysltype);
        hdlregsignal(delay_pipe_out);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_out)];
        [tapbody,tapsignals]=hdltapdelay(entitysigs.input,delay_pipe_out,...
        ['Delay_Pipeline',hdlgetparameter('clock_process_label')],reglen,'Newest',0);
    end

    hdl_arch.body_blocks=[hdl_arch.body_blocks,tapbody];
    hdl_arch.signals=[hdl_arch.signals,tapsignals];

    if reglen==1
        delaylist=delay_pipe_out;
    else
        delaylist=hdlexpandvectorsignal(delay_pipe_out);
    end

    if addinputreg==0

        if~strcmpi(delayvtype,inputvtype)||~strcmp(delaysltype,inputsltype)
            inuname=hdlsignalname(entitysigs.input);
            [uname,entitysigs.input_type_conv]=hdlnewsignal([inuname,'_regtype'],'filter',-1,cplxity,...
            0,delayvtype,delaysltype);
            hdlregsignal(entitysigs.input_type_conv);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(entitysigs.input_type_conv)];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,...
            hdldatatypeassignment(entitysigs.input,...
            entitysigs.input_type_conv,...
            productrounding,productsaturation)];
        else
            entitysigs.input_type_conv=entitysigs.input;
        end
        delaylist=[entitysigs.input_type_conv,delaylist];

    end



