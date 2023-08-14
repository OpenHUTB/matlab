function baseEmit(this)






    ssi=hdlgetparameter('filter_serialsegment_inputs');

    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));
    hdlentitysignalsinit;

    ce=struct('delay',0,'muxb1',[0,0],'afinal',[0,0],'muxc',[0,0],...
    'accum',[0,0],'muxa',[0,0],'muxb',[0,0],'output',[0,0],'ceout',[0,0],...
    'outsig',[0,0],'out_reg',[0,0]);


    phases=this.decimationfactor;

    if phases==1
        error(message('HDLShared:hdlfilter:decimby1notsupported'));
    end

    polycoeffs=this.polyphasecoefficients;

    [hdl_arch]=emit_inithdlarch(this);

    [entitysigs]=createhdlports(this);

    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));

    switch this.implementation
    case 'parallel'

        hdlsetparameter('filter_excess_latency',0);
        [counter_arch,ce,phasece]=emit_timingcontrol(this,ce);

        [coeffs_arch,coeffs_data]=emit_coefficients(this);

        [delayline_arch,delaylist]=emit_delayline(this,entitysigs,phasece);

        for n=1:phases
            sym=checksymmetry(polycoeffs(n,:));
            if((strcmp(sym,'symmetric')&&any(polycoeffs(n,:)))||...
                (strcmp(sym,'antisymmetric')&&any(polycoeffs(n,:))))&&...
                ~hdlgetparameter('bit_true_to_filter')


                coeffs=polycoeffs(n,:);
                delayline=delaylist{n};

                [preadd_arch]=emit_par_preadd(this,delayline,coeffs,sym);
                delayline_arch=combinehdlcode(this,delayline_arch,preadd_arch);
            end
        end

        [mac_arch,prodlist]=emit_parallel_mac(this,coeffs_data,delaylist,phasece,entitysigs);

        [finaladd_arch,final_result]=emit_final_adder(this,prodlist,phases);

        hdl_arch=combinehdlcode(this,hdl_arch,counter_arch,coeffs_arch,delayline_arch,mac_arch,finaladd_arch);

    case 'serial'

        hdlsetparameter('filter_excess_latency',0);

        [counter_arch,ce,phasece,counter_out,accumAndCeout]=emit_timingcontrol(this,ce);

        [coeffs_arch,coeffs_data]=emit_coefficients(this);

        [delayline_arch,delaylist]=emit_delayline(this,entitysigs,phasece);

        [mac_arch,~,~,final_result]=emit_serial_mac(this,delaylist,counter_out,coeffs_data,ce,accumAndCeout);

        hdl_arch=combinehdlcode(this,hdl_arch,counter_arch,coeffs_arch,delayline_arch,mac_arch);

    case 'distributedarithmetic'

        hdlsetparameter('filter_excess_latency',0);

        [dist_arch,entitysigs,prodlist,ce]=emit_dist_arith(this,entitysigs,ce);

        [coeffs_arch]=emit_coefficients(this);

        [finaladd_arch,final_result]=emit_final_adder(this,prodlist,phases);

        hdl_arch=combinehdlcode(this,hdl_arch,dist_arch,coeffs_arch,finaladd_arch);
    end

    [typeconv_arch,cast_result]=emit_outputtypeconvert(this,final_result);

    if hdlgetparameter('filter_generate_ceout')
        cedelay_arch=emit_cedelayline(this,entitysigs,ce.out_reg);
    else
        cedelay_arch='';
    end


    finalcon_arch=emit_final_connection(this,entitysigs,cast_result,ce);

    hdl_arch=combinehdlcode(this,hdl_arch,typeconv_arch,cedelay_arch,finalcon_arch);

    emit_assemblehdlcode(this,hdl_arch);


