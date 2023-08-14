function hdlcode=emit(this)















    hdlcode=hdlcodeinit;

    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
    hdlformatcomment('---- Bypass Register ----')];
    in=this.dataIn;
    sel=this.selectIn;
    out=this.dataOut;

    sltype=hdlsignalsltype(in);
    vtype=hdlsignalvtype(in);
    vectortype=hdlsignalvector(in);
    complextype=hdlsignaliscomplex(in);





    [~,regout]=hdlnewsignal('regout','block',-1,complextype,vectortype,vtype,sltype);


    processName=['DataHoldRegister_',hdluniqueprocessname];
    scalarIC=0;


    if(strcmpi(sltype,'single'))
        scalarIC=single(0);
    end

    obj=hdl.unitdelay('clock',hdlgetcurrentclock,...
    'clockenable',hdlgetcurrentclockenable,...
    'reset',hdlgetcurrentreset,...
    'inputs',in,...
    'outputs',regout,...
    'processName',processName,...
    'resetvalues',scalarIC);

    hdlcode=hdlcodeconcat([hdlcode,obj.emit]);
    hdlcode.arch_signals=makehdlsignaldecl(regout);


    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,...
    hdlmux([in,regout],out,sel,{'='},1,'when-else')];

    hdlcode.arch_body_blocks=[hdlcode.arch_body_blocks,'\n\n'];


