function baseEmit(this)









    emitMode=isempty(pirNetworkForFilterComp);



    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');

    coeffs_port=hdlgetparameter('filter_generate_coeff_port');

    ce=struct('delay',0,'muxb1',[0,0],'afinal',[0,0],'muxc',[0,0],...
    'accum',[0,0],'muxa',[0,0],'muxb',[0,0]);


    coeffs_data=struct('idx',0,'values',this.Coefficients);

    entitysigs=createhdlports(this);

    if emitMode
        hdl_arch=emit_inithdlarch(this);

        disp(sprintf('%s',hdlcodegenmsgs(2)));
        disp(sprintf('%s',hdlcodegenmsgs(3)));
        disp(sprintf('%s',hdlcodegenmsgs(4)));
    else
        hdl_arch=[];
    end

    if coeffs_port
        [coeffs_arch,coeffs_data]=emit_coefficients_port(this,entitysigs,coeffs_data);
    elseif coeffs_internal
        [coeffs_arch,coeffs_data]=emit_coefficients(this);
    else
        coeffs_arch='';
    end

    switch this.implementation
    case 'parallel'
        [fircompute_arch,entitysigs,cast_result,ce]=emit_firparallel(this,entitysigs,coeffs_data,ce);
    case{'serial','serialcascade'}
        [fircompute_arch,entitysigs,cast_result,ce]=emit_firserial(this,entitysigs,coeffs_data,ce);
    case 'distributedarithmetic'
        [fircompute_arch,entitysigs,cast_result,ce]=emit_firDA(this,entitysigs,ce);
    end


    finalcon_arch=emit_final_connection(this,entitysigs,cast_result,ce.delay);

    ce_out_hdl=emit_ceout(this,ce,entitysigs);

    hdl_arch=combinehdlcode(this,hdl_arch,coeffs_arch,fircompute_arch,finalcon_arch,ce_out_hdl);

    emit_assemblehdlcode(this,hdl_arch);
