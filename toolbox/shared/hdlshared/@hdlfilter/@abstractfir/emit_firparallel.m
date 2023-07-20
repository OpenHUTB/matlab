function[hdl_arch,entitysigs,cast_result,ce]=emit_firparallel(this,entitysigs,coeffs_data,ce)





    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');

    [multichannel_arch,entitysigs]=emit_multichannel(this,entitysigs,ce.delay);

    [delayline_arch,delaylist]=emit_delayline(this,entitysigs,ce.delay);


    if emitMode&&~coeffs_internal

        [procint_arch,coeffs_data]=emit_procint(this,entitysigs,coeffs_data,ce);
    else
        procint_arch=hdl_arch;
    end

    [preadd_arch,preaddlist]=emit_par_preadd(this,delaylist);

    [mac_arch,prodlist]=emit_parallel_mac(this,coeffs_data,preaddlist);

    [finaladd_arch,last_sum]=emit_final_adder(this,prodlist);

    [typeconv_arch,cast_result]=emit_outputtypeconvert(this,last_sum);

    hdl_arch=combinehdlcode(this,hdl_arch,multichannel_arch,delayline_arch,procint_arch,preadd_arch,mac_arch,finaladd_arch,typeconv_arch);
