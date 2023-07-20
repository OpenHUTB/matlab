function[hdl_arch,delaylist,sumlist]=emit_delayline(this,ce,entitysigs)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    polycoeffs=this.polyphasecoefficients;
    delaylen=size(polycoeffs,2)-1;
    storageall=hdlgetallfromsltype(this.StateSLType);
    storagevtype=storageall.vtype;
    storagesltype=storageall.sltype;

    cplxity=this.isInputPortComplex||~isreal(polycoeffs);

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    if hdlgetparameter('isvhdl')&&delaylen>1
        hdl_arch.typedefs=[hdl_arch.typedefs,...
        '  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF ',...
        storagevtype,'; -- ',storagesltype,'\n'];
        delay_vector_vtype=['delay_pipeline_type(0 TO ',num2str(delaylen-1),')'];
        delayvect=[delaylen,0];
    elseif delaylen<=1
        delay_vector_vtype=storagevtype;
        delayvect=0;
    else
        delay_vector_vtype=storagevtype;
        delayvect=[delaylen,0];
    end

    [~,delay_pipe_out]=hdlnewsignal('delay_pipeline','filter',-1,cplxity,...
    delayvect,delay_vector_vtype,storagesltype);
    hdlregsignal(delay_pipe_out);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(delay_pipe_out)];


    [~,sumvector_out]=hdlnewsignal('sumvector','filter',-1,cplxity,...
    delayvect,delay_vector_vtype,storagesltype);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(sumvector_out)];

    delay_pipe_in=sumvector_out;



    if multiclock==0




        hdlsetcurrentclockenable(ce.out_temp);

    else






        clk1=entitysigs.clk1;
        clken1=entitysigs.clken1;
        reset1=entitysigs.reset1;
        hdlsetcurrentclockenable(clken1);
        hdlsetcurrentclock(clk1);
        hdlsetcurrentreset(reset1);
    end

    [tempbody,tempsignals]=hdlunitdelay(delay_pipe_in,delay_pipe_out,...
    ['Delay_Pipeline',hdlgetparameter('clock_process_label')],0);

    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
    hdl_arch.signals=[hdl_arch.signals,tempsignals];

    delaylist=hdlexpandvectorsignal(delay_pipe_out);
    sumlist=hdlexpandvectorsignal(sumvector_out);



















