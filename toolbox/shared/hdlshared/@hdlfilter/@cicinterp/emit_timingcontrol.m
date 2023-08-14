function[hdl_arch,ce]=emit_timingcontrol(this,ce,entitysigs)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    clken=hdlsignalfindname([hdlgetparameter('clockenablename')]);
    numfactor=this.interpolationfactor;


    if numfactor==1
        ce.out_reg=clken;
        ce.out_temp=clken;
    else
        if hdlgetparameter('RateChangePort')
            load_val=1;
            maxrate=this.phases;
            ratesize=max(2,ceil(log2(maxrate+1)));
            [countervtype,countersltype]=hdlgettypesfromsizes(ratesize,0,0);

            [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,1,countervtype,countersltype);
            hdlregsignal(counter_out);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out)];

            [tempprocessbody,ce.out_temp]=hdlcounter(counter_out,{ce.ratereg},...
            'ce_output',1,0,0,0,entitysigs.loadenb,load_val);
            ce.out_temp=ce.out_temp(1);
        else

            hdl_arch.body_blocks=[hdl_arch.body_blocks,...
            indentedcomment,...
            '  ------------------ CE Output Generation ------------------\n\n'];
            decodeval=0;

            countsize=max(2,ceil(log2(numfactor)));
            [countervtype,countersltype]=hdlgettypesfromsizes(countsize,0,0);
            [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
            hdlregsignal(counter_out);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out)];

            tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
            [tempprocessbody,ce.out_temp]=hdlcounter(counter_out,numfactor,...
            'ce_output',1,0,decodeval);

            tcinfo.enbsOut=ce.out_temp;
            tcinfo.maxCount=numfactor;
            tcinfo.phases=decodeval;
            tcinfo.initValue=0;
            setLocalTimingInfo(this,tcinfo);
        end
        hdladdclockenablesignal(ce.out_temp);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_temp)];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];

        ce.out_reg=ce.out_temp;
    end
    if hdlgetparameter('filter_generate_ceout')&&~multiclock
        [tempbody,tempsignals]=hdlfinalassignment(ce.out_reg,entitysigs.ceoutput);
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];
    end



    clken1=entitysigs.clken1;
    clk1=entitysigs.clk1;
    reset1=entitysigs.reset1;
    if multiclock==0
        if hdlgetparameter('filter_generate_datavalid_output')

            ce.outputvld=hdlgetcurrentclockenable;

            [~,initlat]=this.latency;

            if initlat>0
                [intdbody,intdsignals,intdconst,ce.outputvld]=emit_PhaseShiftRegisterDelay(this,ce.outputvld,...
                ['cevalid_delay',hdlgetparameter('clock_process_label')],initlat);
            else
                intdbody='';
                intdsignals='';
                intdconst='';
            end
            hdl_arch.signals=[hdl_arch.signals,intdsignals];
            hdl_arch.constants=[hdl_arch.constants,intdconst];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,intdbody];

            [tempbody,tempsignals]=hdlfinalassignment(ce.outputvld,entitysigs.ceoutput_datavld);
            hdl_arch.signals=[hdl_arch.signals,tempsignals];
            hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];
        end
        hdlsetcurrentclockenable(ce.out_temp);

    else
        hdlsetcurrentclockenable(clken1);
        hdlsetcurrentclock(clk1);
        hdlsetcurrentreset(reset1);
    end






