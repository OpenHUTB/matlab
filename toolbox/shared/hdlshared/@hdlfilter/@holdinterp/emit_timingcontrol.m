function[hdl_arch,ce]=emit_timingcontrol(this,entitysigs,ce)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    phases=this.interpolationfactor;
    bdt=hdlgetparameter('base_data_type');
    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    if phases==1
        [countervtype,countersltype]=hdlgettypesfromsizes(1,0,0);
        [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
        hdl_arch.constants=[hdl_arch.constants,...
        makehdlconstantdecl(counter_out,hdlconstantvalue(0,1,0,0))];
    else

        decodeval=phases-1;

        countsize=max(2,ceil(log2(phases)));
        [countervtype,countersltype]=hdlgettypesfromsizes(countsize,0,0);
        [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
        hdlregsignal(counter_out);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out)];
        [tempprocessbody,ce.out_temp]=hdlcounter(counter_out,phases,'ce_output',1,0,decodeval);

        hdladdclockenablesignal(ce.out_temp);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_temp)];
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];
    end

    clken=hdlgetcurrentclockenable;

    if multiclock==0
        if phases==1
            ce.out_reg=clken;
            ce.out_temp=clken;
        else

            ce.out_reg=ce.out_temp;
        end

        [tempbody,tempsignals]=hdlfinalassignment(ce.out_reg,entitysigs.ceoutput);
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];
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
    end




