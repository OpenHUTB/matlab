function[hdl_arch,output]=emit_Outputbypassreg(this,input,sel)




    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    if multiclock&&~hdlgetparameter('filter_generate_ceout')

        hdl_arch.signals='';
        hdl_arch.body_blocks='';
        hdl_arch.body_output_assignments='';
        output=input;
    else
        [hdl_arch,output]=emit_Bypassregister(this,input,sel);
    end

