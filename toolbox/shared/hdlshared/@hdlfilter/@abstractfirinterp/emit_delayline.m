function[hdl_arch,entitysigs,delaylist]=emit_delayline(this,entitysigs,ce)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    polycoeffs=this.PolyphaseCoefficients;
    [~,delaylen]=size(polycoeffs);
    addinputreg=hdlgetparameter('filter_registered_input');
    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    cplxity=this.isInputPortComplex;

    rmode=this.Roundmode;
    [productrounding]=rmode;

    omode=this.Overflowmode;
    [productsaturation]=omode;




    arch=this.Implementation;

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    reginputvtype=inputall.vtype;
    reginputsltype=inputall.sltype;
    inputvtype=inputall.portvtype;
    inputsltype=inputall.portsltype;



    if multiclock==0
        saved_ce=hdlgetcurrentclockenable;
        if strcmpi(arch,'serial')
            hdlsetcurrentclockenable(ce.delay);
        else
            hdlsetcurrentclockenable(ce.out_temp);
        end
    else
        saved_ce=hdlgetcurrentclockenable;
        saved_clk=hdlgetcurrentclock;
        saved_rst=hdlgetcurrentreset;



        clk1=entitysigs.clk1;
        clken1=entitysigs.clken1;
        reset1=entitysigs.reset1;
        hdlsetcurrentclockenable(clken1);
        hdlsetcurrentclock(clk1);
        hdlsetcurrentreset(reset1);
    end

    hdl_arch.body_blocks=[hdl_arch.body_blocks,...
    indentedcomment,'  ---------------- Delay Registers ----------------\n\n'];
    if addinputreg==1||strcmpi(arch,'serial')
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
        [~,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,cplxity,...
        0,delay_vector_vtype,delaysltype);
        hdlregsignal(delay_pipe_out);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_out)];
        [tapbody,tapsignals]=hdlunitdelay(entitysigs.input,delay_pipe_out,...
        ['Delay_Pipeline',hdlgetparameter('clock_process_label')],0);
    elseif reglen==0

        tapbody='';
        tapsignals='';
    else
        [~,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,cplxity,...
        [reglen,0],delay_vector_vtype,delaysltype);
        hdlregsignal(delay_pipe_out);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_out)];
        [tapbody,tapsignals]=hdltapdelay(entitysigs.input,delay_pipe_out,...
        ['Delay_Pipeline',hdlgetparameter('clock_process_label')],reglen,'Newest',0);
    end

    hdl_arch.body_blocks=[hdl_arch.body_blocks,tapbody];
    hdl_arch.signals=[hdl_arch.signals,tapsignals];

    if reglen==1&&~(strcmpi(arch,'serial'))
        delaylist=delay_pipe_out;
    elseif reglen==0
        delaylist=[];
    else
        delaylist=hdlexpandvectorsignal(delay_pipe_out);
    end

    if addinputreg==0

        if~strcmpi(delayvtype,inputvtype)||~strcmp(delaysltype,inputsltype)
            inuname=hdlgetparameter('filter_input_name');
            [~,entitysigs.input_type_conv]=hdlnewsignal([inuname,'_regtype'],'filter',-1,cplxity,...
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
        if~strcmpi(arch,'serial')
            delaylist=[entitysigs.input_type_conv,delaylist];
        end
    end

    if multiclock==0
        hdlsetcurrentclockenable(saved_ce);
    else
        hdlsetcurrentclockenable(saved_ce);
        hdlsetcurrentclock(saved_clk);
        hdlsetcurrentreset(saved_rst);
    end


