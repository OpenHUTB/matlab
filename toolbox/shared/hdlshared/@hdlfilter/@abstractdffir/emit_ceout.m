function hdl_arch=emit_ceout(this,ce,entitysigs)




    arch=this.Implementation;
    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    if hdlgetparameter('filter_generate_datavalid_output')
        if strcmpi(arch,'parallel')
            ce.outputvld=hdlgetcurrentclockenable;
        end
        [~,initlat]=this.latency;
        if initlat>0
            [intdbody,intdsignals,intdconst,delayedop]=emit_PhaseShiftRegisterDelay(this,ce.outputvld,...
            ['ceout_delay',hdlgetparameter('clock_process_label')],initlat);
            hdl_arch.signals=[hdl_arch.signals,intdsignals];
            hdl_arch.constants=[hdl_arch.constants,intdconst];
            hdl_arch.body_blocks=[hdl_arch.body_blocks,intdbody];
            ce.outputvld=delayedop;


        end
        ce.out_reg=ce.outputvld;
        [tempbody,tempsignals]=hdlfinalassignment(ce.out_reg,entitysigs.ceoutput_datavld);
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];

    end


