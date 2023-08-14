function[hdl_arch,cast_result]=emit_outputtypeconvert(this,entitysigs,ce)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    phases=this.interpolationfactor;
    addinputreg=hdlgetparameter('filter_registered_input');
    if~addinputreg
        addinputreg=true;
        hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+phases);
    end
    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    reginputvtype=inputall.vtype;
    reginputsltype=inputall.sltype;

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];


    if hdlgetparameter('clockinputs')==1
        multiclock=0;
        saved_ce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(ce.out_temp);
    else
        multiclock=1;
        saved_ce=hdlgetcurrentclockenable;
        saved_clk=hdlgetcurrentclock;
        saved_rst=hdlgetcurrentreset;
        clk1=hdlsignalfindname([hdlgetparameter('clockname'),'1']);
        clken1=hdlsignalfindname([hdlgetparameter('clockenablename'),'1']);
        reset1=hdlsignalfindname([hdlgetparameter('resetname'),'1']);
        hdlsetcurrentclockenable(clken1);
        hdlsetcurrentclock(clk1);
        hdlsetcurrentreset(reset1);
    end

    if addinputreg==1
        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        indentedcomment,'  ---------------- Input Registers ----------------\n\n'];
        delayvtype=reginputvtype;
        delaysltype=reginputsltype;

        [uname,inputregister]=hdlnewsignal('inputregister','filter',-1,isInputPortComplex(this),...
        0,delayvtype,delaysltype);

        hdlregsignal(inputregister);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(inputregister)];

        [tapbody,tapsignals]=hdlunitdelay(entitysigs.input,inputregister,...
        ['Input_Register',hdlgetparameter('clock_process_label')],0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tapbody];
        hdl_arch.signals=[hdl_arch.signals,tapsignals];
    else
        inputregister=entitysigs.input;
    end


    if multiclock==0
        hdlsetcurrentclockenable(saved_ce);
    else

        hdlsetcurrentclockenable(saved_ce);
        hdlsetcurrentclock(saved_clk);
        hdlsetcurrentreset(saved_rst);
    end

    cast_result=inputregister;


