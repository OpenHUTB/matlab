function[fdreg_arch,fdregsig]=emit_fd_reg(this,entitysigs)






    fdreg_arch.functions='';
    fdreg_arch.typedefs='';
    fdreg_arch.constants='';
    fdreg_arch.signals='';
    fdreg_arch.body_blocks='';
    fdreg_arch.body_output_assignments='';

    fdregsig=hdlsignalfindname('frac_delay');



