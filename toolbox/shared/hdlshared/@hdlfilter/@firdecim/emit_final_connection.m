function hdl_arch=emit_final_connection(this,entitysigs,cast_result,ce)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    arch=this.implementation;
    complexity=isOutputPortComplex(this);
    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    castvtype=outputall.vtype;
    castsltype=outputall.sltype;

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    clk1=hdlsignalfindname([hdlgetparameter('clockname'),'1']);
    clken1=hdlsignalfindname([hdlgetparameter('clockenablename'),'1']);
    reset1=hdlsignalfindname([hdlgetparameter('resetname'),'1']);

    if hdlgetparameter('filter_registered_output')==1
        [outputregname,outputreg]=hdlnewsignal('output_register','filter',-1,complexity,0,castvtype,castsltype);
        hdlregsignal(outputreg);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(outputreg)];
        if strcmpi(arch,'serial')

            if multiclock
                oldce=hdlgetcurrentclockenable;
                hdlsetcurrentclock(clk1);
                hdlsetcurrentclockenable(clken1);
                hdlsetcurrentreset(reset1);
            else
                oldce=hdlgetcurrentclockenable;
                hdlsetcurrentclockenable(ce.output);
            end
        end
        if strcmpi(arch,'distributedarithmetic')&&multiclock
            hdlsetcurrentclock(clk1);
            hdlsetcurrentclockenable(clken1);
            hdlsetcurrentreset(reset1);
        end

        [tempbody,tempsignals]=hdlunitdelay(cast_result,outputreg,...
        ['output_register',hdlgetparameter('clock_process_label')],0);
        if strcmpi(arch,'serial')
            hdlsetcurrentclockenable(oldce);
        end
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        final_result=outputreg;
    else
        final_result=cast_result;
    end


    if~hdlgetparameter('filter_registered_output')&&~hdlgetparameter('filter_registered_input')&&...
        strcmpi(this.Implementation,'parallel')
        if multiclock&&~hdlgetparameter('filter_generate_ceout')

        else
            sel=hdlgetcurrentclockenable;
            [bpassregvtype,bpassregsltype]=hdlgettypesfromsizes(outputall.size,outputall.bp,outputall.signed);
            [~,regout]=hdlnewsignal('regout','filter',-1,complexity,0,bpassregvtype,bpassregsltype);
            hdlregsignal(regout);
            [~,muxout]=hdlnewsignal('muxout','filter',-1,complexity,0,bpassregvtype,bpassregsltype);
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


