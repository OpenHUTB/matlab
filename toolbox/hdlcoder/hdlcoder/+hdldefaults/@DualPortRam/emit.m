
function hdlcode=emit(this,hC)





    reporterrors(this,hC);

    param=this.getBlockParam(hC);

    this.displayCodeGenMsg(hC,param.fullPathName,param.fullFileName);

    this.fixPorts(hC,param.hasClkEn);


    hRam=hdl.dualPortRam('hasClkEnable',param.hasClkEn,...
    'dataIsComplex',param.ramIsComplex,...
    'entityName',hC.Name,...
    'fullFileName',param.fullFileName,...
    'fullPathName',param.fullPathName);

    hdlcode=hRam.emit(hC.PirInputSignals,hC.PirOutputSignals,...
    hdlsignalname(hC.PirInputPorts),hdlsignalname(hC.PirOutputPorts));


