function hdlcode=emit(this,hC)





    param=this.getBlockParam(hC);

    this.dataIsComplex=param.ramIsComplex;
    this.hasClkEn=param.hasClkEn;
    this.readNewData=param.readNewData;

    this.displayCodeGenMsg(hC,param.fullPathName,param.fullFileName);

    this.fixPorts(hC,param.hasClkEn);

    hdlcode=this.emit_ram(hC.PirInputSignals,hC.PirOutputSignals,...
    hdlsignalname(hC.PirInputPorts),...
    hdlsignalname(hC.PirOutputPorts));


