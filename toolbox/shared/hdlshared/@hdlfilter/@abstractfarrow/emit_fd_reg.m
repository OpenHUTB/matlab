function[fdreg_arch,fdregsig]=emit_fd_reg(this,entitysigs)





    fdreg_arch.functions='';
    fdreg_arch.typedefs='';
    fdreg_arch.constants='';
    fdreg_arch.signals='';
    fdreg_arch.body_blocks='';
    fdreg_arch.body_output_assignments='';

    fdall=hdlgetallfromsltype(this.fdSLtype,'inputport');
    fdregvtype=fdall.vtype;
    fdregsltype=fdall.sltype;

    if hdlgetparameter('filter_registered_input')==1
        fduname=hdlsignalname(entitysigs.fd_input);
        [uname,fdregsig]=hdlnewsignal([fduname,'_reg'],'filter',-1,0,...
        0,fdregvtype,fdregsltype);
        hdlregsignal(fdregsig);
        fdreg_arch.signals=[fdreg_arch.signals,makehdlsignaldecl(fdregsig)];
        [fdregbody,fdregsignals]=hdlunitdelay(entitysigs.fd_input,fdregsig,...
        ['FracDelay_Input_Register',hdlgetparameter('clock_process_label')],0);
        fdreg_arch.body_blocks=[fdreg_arch.body_blocks,fdregbody];
    else
        fdregsig=entitysigs.fd_input;
    end


