function baseEmit(this)






    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));
    hdlentitysignalsinit;

    polycoeffs=this.polyphasecoefficients;

    ce=struct('delay',0,'muxb1',[0,0],'afinal',[0,0],'muxc',[0,0],...
    'accum',[0,0],'muxa',[0,0],'muxb',[0,0],'output',[0,0],'ceout',[0,0],...
    'outsig',[0,0],'out_reg',[0,0]);

    disp(sprintf('%s',hdlcodegenmsgs(1)));

    [hdl_arch]=emit_inithdlarch(this);



    [entitysigs]=createhdlports(this);

    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));



    hdlsetparameter('filter_excess_latency',0);

    [counter_arch,counter_out,ce]=emit_timingcontrol(this,entitysigs,ce);

    [coeffs_arch,coeffs_data]=emit_coefficients(this);



    [inpipe_arch,entitysigs,reginput]=emit_inputpipeline(this,entitysigs,counter_out);

    [mac_arch,prodlist]=emit_parallel_mac(this,coeffs_data,reginput);

    [delayline_arch,delaylist,sumlist]=emit_delayline(this,ce,entitysigs);


    [finalsum_arch,final_result]=emit_finalsum(this,prodlist,sumlist,delaylist);


    [typeconv_arch,cast_result]=emit_outputtypeconvert(this,final_result);

    finalcon_arch=emit_final_connection(this,entitysigs,cast_result);

    hdl_arch=combinehdlcode(this,hdl_arch,counter_arch,coeffs_arch,inpipe_arch,mac_arch,delayline_arch,finalsum_arch,typeconv_arch,finalcon_arch);

    emit_assemblehdlcode(this,hdl_arch);







