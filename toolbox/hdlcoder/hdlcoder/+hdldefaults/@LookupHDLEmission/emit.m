function hdlcode=emit(this,hC)




    reporterrors(this,hC);
    hdlcode=hdlcodeinit;
    bfp=hC.SimulinkHandle;





    tablein=this.hdlslResolve('InputValues',bfp);
    tableout=this.hdlslResolve('OutputValues',bfp);

    [hdlcode.arch_body_blocks,hdlcode.arch_signals,hdlcode.arch_constants]=...
    hdllookuptable(hC.PirInputPorts(1).Signal,...
    hC.PirOutputPorts(1).Signal,...
    tablein,tableout,...
    'Nearest',1);

    hdlcode=hdlcodeconcat([this.emitBlockComments(hC),hdlcode]);
