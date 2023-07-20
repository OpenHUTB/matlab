function baseEmit(this)






    hdlsetparameter('filter_target_language',hdlgetparameter('target_language'));


    entitysigs=createhdlports(this);


    hdl_arch=emit_inithdlarch(this);

    ce=struct('delay',hdlgetcurrentclockenable,'output',[0,0],'ceout',[0,0],...
    'outsig',[0,0],'out_reg',[0,0],'fd',0,'fdinit',0);

    [fdreg_arch,fdregsig]=emit_fd_reg(this,entitysigs);

    hdl_polyfir=this.emit_polyfir(entitysigs,ce,fdregsig);

    hdl_arch=combinehdlcode(this,hdl_arch,fdreg_arch,hdl_polyfir);

    emit_assemblehdlcode(this,hdl_arch);


