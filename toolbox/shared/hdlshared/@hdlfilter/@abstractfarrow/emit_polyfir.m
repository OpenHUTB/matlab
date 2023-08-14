function hdl_polyfir=emit_polyfir(this,entitysigs,ce,fdregsig)






    disp(sprintf('%s',hdlcodegenmsgs(2)));
    disp(sprintf('%s',hdlcodegenmsgs(3)));
    disp(sprintf('%s',hdlcodegenmsgs(4)));


    [coeffs_arch,coeffs_data]=emit_coefficients(this);

    [delayline_arch,delaylist]=emit_delayline(this,entitysigs,ce.delay);

    preaddlist=delaylist;

    [mac_arch,lastproductedsum]=emit_mac(this,preaddlist,fdregsig,coeffs_data);

    [typeconv_arch,cast_result]=emit_outputtypeconvert(this,lastproductedsum);


    finalcon_arch=emit_final_connection(this,entitysigs,cast_result,ce);

    hdl_polyfir=combinehdlcode(this,coeffs_arch,delayline_arch,mac_arch,typeconv_arch,finalcon_arch);




