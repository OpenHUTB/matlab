function baseEmit(this)







    arch=this.Implementation;

    ce=struct('delay',0,'muxb1',[0,0],'afinal',[0,0],'muxc',[0,0],...
    'accum',[0,0],'muxa',[0,0],'muxb',[0,0],'output',[0,0],'ceout',[0,0],...
    'outsig',[0,0],'out_reg',[0,0],'ctr_sigs',[0,0],'ctr1_out',[0,0],'ctr_out',[0,0]);

    [hdl_arch]=emit_inithdlarch(this);


    entitysigs=createhdlports(this);


    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));


    [coeffs_arch,coeffs_data]=emit_polycoeffs(this);

    switch arch

    case 'parallel'

        [counter_arch,ce]=emit_timingcontrol(this,ce);

        [ceout_arch,ce]=emit_ceout(this,entitysigs,ce);

        [delayline_arch,entitysigs,delaylist]=emit_delayline(this,entitysigs,ce);

        [mac_arch,prodlist]=emit_parallelmac(this,coeffs_data,delaylist);

        add_phases=1;
        [finaladd_arch,last_sum]=emit_final_adder(this,prodlist,add_phases);

        [typeconv_arch,cast_result]=emit_outputtypeconvert(this,last_sum);

        firinterp_arch=combinehdlcode(this,counter_arch,ceout_arch,delayline_arch,mac_arch,finaladd_arch,typeconv_arch);

    case 'serial'

        [counter_arch,ce,counter_out]=emit_timingcontrol(this,ce);

        [ceout_arch,ce]=emit_ceout(this,entitysigs,ce);

        [delayline_arch,entitysigs,delaylist]=emit_delayline(this,entitysigs,ce);
        if hdlgetparameter('clockinputs')>1
            [mac_arch,final_result]=emit_serialmac_fsmclock(this,coeffs_data,delaylist,ce);
        else
            [mac_arch,~,~,final_result]=emit_serialmac(this,delaylist,counter_out,coeffs_data,ce);
        end

        [typeconv_arch,cast_result]=emit_outputtypeconvert(this,final_result);

        firinterp_arch=combinehdlcode(this,counter_arch,ceout_arch,delayline_arch,mac_arch,typeconv_arch);

    case 'distributedarithmetic'

        [da_arch,entitysigs,controlsigs,ce,inputcastsig]=emit_dist_arith(this,entitysigs,ce);

        [ceout_arch,ce]=emit_ceout(this,entitysigs,ce);

        [delayline_arch,cast_result]=emit_da_delayline(this,ce,inputcastsig,controlsigs);

        firinterp_arch=combinehdlcode(this,da_arch,ceout_arch,delayline_arch);

    end


    finalcon_arch=emit_final_connection(this,entitysigs,cast_result,ce.output);

    hdl_arch=combinehdlcode(this,hdl_arch,coeffs_arch,firinterp_arch,finalcon_arch);
    emit_assemblehdlcode(this,hdl_arch);








