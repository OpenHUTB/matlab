function[hdl_arch,output]=emit_Bypassregister(this,input,sel)



    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    bpassregvtype=hdlsignalvtype(input);
    bpassregsltype=hdlsignalsltype(input);
    complexity=hdlsignaliscomplex(input);


    [~,regout]=hdlnewsignal('regout','filter',-1,complexity,0,bpassregvtype,bpassregsltype);
    hdlregsignal(regout);

    [~,muxout]=hdlnewsignal('muxout','filter',-1,complexity,0,bpassregvtype,bpassregsltype);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(regout),makehdlsignaldecl(muxout)];


    processName=['DataHoldRegister',hdlgetparameter('clock_process_label')];
    [bpregbody,bpregsignals]=hdlunitdelay(input,regout,...
    processName,0);

    muxbody=hdlmux([input,regout],muxout,sel,{'='},1,'when-else');
    hdl_arch.signals=[hdl_arch.signals,bpregsignals];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,bpregbody,muxbody];
    output=muxout;


