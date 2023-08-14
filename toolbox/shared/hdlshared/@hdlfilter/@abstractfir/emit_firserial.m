function[hdl_arch,entitysigs,cast_result,ce]=emit_firserial(this,entitysigs,coeffs_data,ce)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';
    hdl_arch.component_decl='';
    hdl_arch.component_config='';
    hdl_arch.body_component_instances='';

    ssi=hdlgetparameter('filter_serialsegment_inputs');
    coeffs=this.Coefficients;
    dlist_modifier=find(coeffs);


    [hdl_arch,ce,pairs,ctr_out]=emit_timingcontrol(this,hdl_arch,ce,ssi);

    [delayline_arch,delaylist]=emit_delayline(this,entitysigs,ce.delay);


    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');
    if~coeffs_internal
        if~strcmpi(hdlgetparameter('filter_storage_type'),'Registers')

            [procint_arch,coeffs_data]=emit_procint(this,entitysigs,coeffs_data,ce,pairs);
        else
            [procint_arch,coeffs_data]=emit_procint(this,entitysigs,coeffs_data,ce);
        end
    else
        procint_arch.functions='';
        procint_arch.typedefs='';
        procint_arch.constants='';
        procint_arch.signals='';
        procint_arch.body_blocks='';
        procint_arch.body_output_assignments='';
    end


    dlist_serial=delaylist(dlist_modifier);
    if hdlgetparameter('filter_registered_input')==1
        delaylist=dlist_serial;
    end

    [preadd_arch,preaddlist,pairs]=emit_serial_preadd(this,pairs,ctr_out,delaylist);

    [mac_arch,~,~,last_sum,ce]=emit_serial_mac(this,ce,coeffs_data,pairs,preaddlist,ctr_out);

    [typeconv_arch,cast_result]=emit_outputtypeconvert(this,last_sum);

    hdl_arch=combinehdlcode(this,hdl_arch,delayline_arch,procint_arch,preadd_arch,mac_arch,typeconv_arch);




