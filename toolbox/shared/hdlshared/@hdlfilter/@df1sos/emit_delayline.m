function[hdl_arch,delaylist]=emit_delayline(this,entitysigs,ce_delay)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';


    arch=this.implementation;
    coeffs=this.Coefficients;
    numlen=2*this.numSections;
    denumlen=2*this.numSections;

    inputrounding='round';
    inputsaturation=true;

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputvtype=inputall.portvtype;
    inputsltype=inputall.portsltype;

    delayvtype=inputall.vtype;
    delaysltype=inputall.sltype;

    cplxity=this.isInputPortComplex;

    if hdlgetparameter('filter_registered_input')==1
        delaylen=numlen;
    else
        if~(strcmpi(arch,'parallel')||strcmpi(arch,'distributedarithmetic'))
            delaylen=numlen;
        else
            delaylen=numlen;
        end
    end





    if hdlgetparameter('isvhdl')&&(delaylen>1)

        hdl_arch.typedefs=[hdl_arch.typedefs,...
        '  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
        delayvtype,'; -- ',delaysltype,'\n'];
        num_delay_vector_vtype=['numdelay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
        denum_delay_vector_vtype=['denumdelay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
    else
        numdelay_vector_vtype=delayvtype;
        denumdelay_vector_vtype=delayvtype;
    end


    if delaylen>1
        [uname,numdelay_pipe_out]=hdlnewsignal('numdelay_pipeline','filter',-1,cplxity,...
        [delaylen,0],num_delay_vector_vtype,delaysltype);
        [uname,denumdelay_pipe_out]=hdlnewsignal('denumdelay_pipeline','filter',-1,cplxity,...
        [delaylen,0],denum_delay_vector_vtype,delaysltype);
    else
        [uname,numdelay_pipe_out]=hdlnewsignal('numdelay_pipeline','filter',-1,cplxity,...
        0,numdelay_vector_vtype,delaysltype);
        [uname,denumdelay_pipe_out]=hdlnewsignal('denumdelay_pipeline','filter',-1,cplxity,...
        0,denumdelay_vector_vtype,delaysltype);
    end

    hdlregsignal(numdelay_pipe_out);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(numdelay_pipe_out)];
    hdlregsignal(denumdelay_pipe_out);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(denumdelay_pipe_out)];

    if strcmpi(arch,'serial')||strcmpi(arch,'serialcascade')
        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(ce_delay);
    end

    [numtapbody,numtapsignals]=hdltapdelay(entitysigs.input,numdelay_pipe_out,...
    ['NumDelay_Pipeline',hdlgetparameter('clock_process_label')],delaylen,'Newest',0);
    [denumtapbody,denumtapsignals]=hdltapdelay(entitysigs.input,denumdelay_pipe_out,...
    ['DenumDelay_Pipeline',hdlgetparameter('clock_process_label')],delaylen,'Newest',0);

    if strcmpi(arch,'serial')||strcmpi(arch,'serialcascade')
        hdlsetcurrentclockenable(oldce);
    end
    hdl_arch.body_blocks=[hdl_arch.body_blocks,numtapbody];
    hdl_arch.signals=[hdl_arch.signals,numtapsignals];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,denumtapbody];
    hdl_arch.signals=[hdl_arch.signals,denumtapsignals];

    if delaylen>1
        delaylist=hdlexpandvectorsignal(numdelay_pipe_out);
    else
        delaylist=numdelay_pipe_out;
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





