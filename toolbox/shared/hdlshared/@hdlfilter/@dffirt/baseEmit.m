function baseEmit(this)






    emitMode=isempty(pirNetworkForFilterComp);

    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));

    coeffs=this.Coefficients;
    firlen=length(coeffs);
    szfirlen=size(firlen);

    structure=this.FilterStructure;
    if szfirlen(1)~=1||szfirlen(2)~=1
        error(message('HDLShared:hdlfilter:multisectionfir',upper(structure)));
    end

    disp(sprintf('%s',hdlcodegenmsgs(1)));
    [entitysigs]=createhdlports(this);

    if emitMode
        hdl_arch=emit_inithdlarch(this);

        disp(sprintf('%s',hdlcodegenmsgs(2)));
        disp(sprintf('%s',hdlcodegenmsgs(3)));
        disp(sprintf('%s',hdlcodegenmsgs(4)));
    else
        hdl_arch=[];
    end



    hdlsetparameter('filter_excess_latency',0);

    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');
    coeffs_port=hdlgetparameter('filter_generate_coeff_port');
    coeffs_data=struct('idx',0,'values',this.Coefficients);

    if coeffs_port
        [coeffs_arch,coeffs_data]=emit_coefficients_port(this,entitysigs,coeffs_data);
    elseif coeffs_internal
        [coeffs_arch,coeffs_data]=emit_coefficients(this);
    else
        coeffs_arch='';
    end

    ce_delay=0;
    [multichannel_arch,entitysigs]=emit_multichannel(this,entitysigs,ce_delay);



    [inreg_arch,reginput]=emit_inputreg_process(this,entitysigs);

    [delayline_arch,delaylist,sumlist]=emit_delayline(this);


    [mac_arch,prodlist]=emit_parallel_mac(this,coeffs_data,reginput);


    [finaladd_arch,final_result]=emit_final_adder(this,prodlist,delaylist,sumlist);

    [typeconv_arch,cast_result]=emit_outputtypeconvert(this,final_result);


    finalcon_arch=emit_final_connection(this,entitysigs,cast_result,ce_delay);

    hdl_arch=combinehdlcode(this,hdl_arch,coeffs_arch,multichannel_arch,inreg_arch,delayline_arch,mac_arch,finaladd_arch,typeconv_arch,finalcon_arch);

    emit_assemblehdlcode(this,hdl_arch);


