function[hdl_arch,preaddlist]=emit_par_preadd(this,delaylist)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    num_channel=hdlgetparameter('filter_generate_multichannel');
    preaddlist=delaylist(1:num_channel:end);