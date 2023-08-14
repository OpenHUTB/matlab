function hdlcode=finishEmit(this,hC)





    bfp=hC.SimulinkHandle;


    fp=get(get_param(bfp,'Handle'),'Path');
    slname=get_param(bfp,'Name');
    hdladdtoentitylist([fp,'/',slname],hC.Name,'','');

    hdlcode.entity_name=hC.Name;
    hdlcode.arch_name=hdlgetparameter('vhdl_architecture_name');
    hdlcode.library_name=hdlgetparameter('vhdl_library_name');
    hdlcode.component_name=hC.Name;


