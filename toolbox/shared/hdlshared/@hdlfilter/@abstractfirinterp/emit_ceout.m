function[hdl_arch,ce]=emit_ceout(this,entitysigs,ce)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';
    bdt=hdlgetparameter('base_data_type');

    if hdlgetparameter('filter_generate_ceout')

        if hdlgetparameter('clockinputs')==1
            multiclock=0;
        else
            multiclock=1;
        end

        arch=this.Implementation;
        phases=this.interpolationfactor;
        clken=hdlgetcurrentclockenable;
        if multiclock==0

            if phases==1
                ce.out_reg=clken;
                ce.out_temp=clken;
            else


                if~(strcmpi(arch,'serial')&&hdlgetparameter('filter_registered_output')~=1)

                    if strcmpi(arch,'serial')
                        ce.out_temp=ce.ceout;
                    end
                    ce.out_reg=ce.out_temp;
                else
                    ce.out_reg=ce.ceout;
                end
            end

            [tempbody,tempsignals]=hdlfinalassignment(ce.out_reg,entitysigs.ceoutput);
            hdl_arch.signals=[hdl_arch.signals,tempsignals];
            hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];

            if hdlgetparameter('filter_generate_datavalid_output')
                if strcmpi(arch,'serial')
                    if hdlgetparameter('filter_registered_output')
                        [~,ce.out_reg]=hdlnewsignal('ce_out_reg','filter',-1,0,0,bdt,'boolean');
                        hdlregsignal(ce.out_reg);
                        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_reg)];
                        [intdelaybody,intdelaysignals]=hdlunitdelay(ce.outputvld,ce.out_reg,['ce_out_register',hdlgetparameter('clock_process_label')],0);
                        hdl_arch.body_blocks=[hdl_arch.body_blocks,intdelaybody];
                        hdl_arch.signals=[hdl_arch.signals,intdelaysignals];
                    else
                        ce.out_reg=ce.outputvld;
                    end
                else
                    if strcmpi(arch,'parallel')
                        ce.outputvld=hdlgetcurrentclockenable;
                    end
                    [~,initlat]=this.latency;


                    if initlat>0
                        [intdbody,intdsignals,intdconst,ce.outputvld]=emit_PhaseShiftRegisterDelay(this,ce.outputvld,...
                        ['ceout_delay',hdlgetparameter('clock_process_label')],initlat);
                    else
                        intdbody='';
                        intdsignals='';
                        intdconst='';
                    end
                    hdl_arch.signals=[hdl_arch.signals,intdsignals];
                    hdl_arch.constants=[hdl_arch.constants,intdconst];
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,intdbody];


                    ce.out_reg=ce.outputvld;
                end
                [tempbody,tempsignals]=hdlfinalassignment(ce.out_reg,entitysigs.ceoutput_datavld);
                hdl_arch.signals=[hdl_arch.signals,tempsignals];
                hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];
            end
        end

    end



