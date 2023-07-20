function baseEmit(this)






    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));

    hdlentitysignalsinit;
    hdlsetparameter('filter_excess_latency',0);

    ce=struct('delay',0,'muxb1',[0,0],'afinal',[0,0],'muxc',[0,0],...
    'accum',[0,0],'muxa',[0,0],'muxb',[0,0],'output',[0,0],'ceout',[0,0],...
    'outsig',[0,0],'out_reg',[0,0]);

    disp(sprintf('%s',hdlcodegenmsgs(1)));

    [hdl_arch]=emit_inithdlarch(this);

    entitysigs=createhdlports(this);

    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));

    [counter_arch,ce]=emit_timingcontrol(this,entitysigs,ce);

    [typeconv_arch,cast_result]=emit_outputtypeconvert(this,entitysigs,ce);

    finalcon_arch=emit_final_connection(this,entitysigs,cast_result);

    hdl_arch=combinehdlcode(this,hdl_arch,counter_arch,typeconv_arch,finalcon_arch);

    emit_assemblehdlcode(this,hdl_arch);



