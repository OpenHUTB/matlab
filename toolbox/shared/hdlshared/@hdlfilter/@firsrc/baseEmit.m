function baseEmit(this)






    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));

    hdlentitysignalsinit;

    hdlsetparameter('filter_excess_latency',0);

    ce=struct('delay',hdlgetcurrentclockenable,'output',[0,0],'ceout',[0,0],...
    'outsig',[0,0],'out_reg',[0,0],'out',0);

    hdl_arch=emit_inithdlarch(this);



    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end


    entitysigs=createhdlports(this);


    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));



    [tc_arch,ce,cforder,phase_ceout]=emit_timingcontrol(this,entitysigs,ce);


    [coeffs_arch,coeffs_data]=emit_polycoeffs(this);


    if multiclock==0
        saved_ce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(ce.in_temp);
    else
        saved_ce=hdlgetcurrentclockenable;
        saved_clk=hdlgetcurrentclock;
        saved_rst=hdlgetcurrentreset;
        hdlsetcurrentclockenable(entitysigs.clken1);
        hdlsetcurrentclock(entitysigs.clk1);
        hdlsetcurrentreset(entitysigs.reset1);
    end


    [delayline_arch,entitysigs,delaylist]=emit_delayline(this,entitysigs);


    if multiclock==0
        hdlsetcurrentclockenable(saved_ce);
    else

        hdlsetcurrentclockenable(saved_ce);
        hdlsetcurrentclock(saved_clk);
        hdlsetcurrentreset(saved_rst);
    end

    [mac_arch,last_sum]=emit_mac(this,delaylist,coeffs_data,cforder,phase_ceout);


    [typeconv_arch,cast_result]=emit_outputtypeconvert(this,last_sum);


    ce.output=ce.out_temp;
    finalcon_arch=emit_final_connection(this,entitysigs,cast_result,ce);

    hdl_arch=combinehdlcode(this,hdl_arch,tc_arch,coeffs_arch,delayline_arch,mac_arch,typeconv_arch,finalcon_arch);


    emit_assemblehdlcode(this,hdl_arch);


