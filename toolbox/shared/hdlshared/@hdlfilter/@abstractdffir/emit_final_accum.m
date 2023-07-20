function[hdl_arch,last_sum]=emit_final_accum(this,hdl_arch,last_sum,final_sum,ce_afinal)






    oldce=hdlgetcurrentclockenable;
    hdlsetcurrentclockenable(ce_afinal);
    [acc_final_bdy,acc_intersig]=hdlunitdelay(last_sum,final_sum,...
    ['Finalsum_reg',hdlgetparameter('clock_process_label')],0);
    hdlsetcurrentclockenable(oldce);
    hdl_arch.body_blocks=[hdl_arch.body_blocks,acc_final_bdy];
    last_sum=final_sum;
