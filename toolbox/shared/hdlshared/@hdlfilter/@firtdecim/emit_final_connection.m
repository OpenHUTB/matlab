function hdl_arch=emit_final_connection(this,entitysigs,cast_result)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end
    cplxity=this.isInputPortComplex||~isreal(this.polyphasecoefficient);
    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    castvtype=outputall.vtype;
    castsltype=outputall.sltype;
    if hdlgetparameter('filter_registered_output')==1
        [outputregname,outputreg]=hdlnewsignal('output_register','filter',-1,cplxity,0,castvtype,castsltype);
        hdlregsignal(outputreg);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(outputreg)];
        [tempbody,tempsignals]=hdlunitdelay(cast_result,outputreg,...
        ['output_register',hdlgetparameter('clock_process_label')],0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        final_result=outputreg;
    else
        final_result=cast_result;
    end


    if~hdlgetparameter('filter_registered_output')&&~hdlgetparameter('filter_registered_input')
        if multiclock&&~hdlgetparameter('filter_generate_ceout')

        else
            sel=hdlgetcurrentclockenable;
            [bpassregvtype,bpassregsltype]=hdlgettypesfromsizes(outputall.size,outputall.bp,outputall.signed);
            [idxname,regout]=hdlnewsignal('regout','filter',-1,cplxity,0,bpassregvtype,bpassregsltype);
            hdlregsignal(regout);
            [idxname,muxout]=hdlnewsignal('muxout','filter',-1,cplxity,0,bpassregvtype,bpassregsltype);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(regout),makehdlsignaldecl(muxout)];

            processName=['DataHoldRegister',hdlgetparameter('clock_process_label')];
            [bpregbody,bpregsignals]=hdlunitdelay(final_result,regout,...
            processName,0);

            muxbody=hdlmux([final_result,regout],muxout,sel,{'='},1,'when-else');
            hdl_arch.signals=[hdl_arch.signals,bpregsignals];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,bpregbody,muxbody];
            final_result=muxout;
        end
    end
    [tempbody,tempsignals]=hdlfinalassignment(final_result,entitysigs.output);
    hdl_arch.signals=[hdl_arch.signals,tempsignals];
    hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];


    if multiclock==0
        saved_ce=hdlsignalfindname(hdlgetparameter('clockenablename'));
        hdlsetcurrentclockenable(saved_ce);
    else

        saved_ce=hdlsignalfindname(hdlgetparameter('clockenablename'));
        saved_clk=hdlsignalfindname(hdlgetparameter('clockname'));
        saved_rst=hdlsignalfindname(hdlgetparameter('resetname'));
        hdlsetcurrentclockenable(saved_ce);
        hdlsetcurrentclock(saved_clk);
        hdlsetcurrentreset(saved_rst);
    end






