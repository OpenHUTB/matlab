function s=applyFilterImplParams(this,hF,hC)











    s.pcache={};
    s.hdlvalmsgs=hdlvalidatestruct;


    if hF.InputComplex
        hF.setHDLParameter('InputComplex','on');
    end

    hF.setHDLParameter('nummultipliers',1);
    hF.updateHdlfilterINI;
    applyFullPrecisionSettings(hF);


    hF.setHDLParameter('AddOutputRegister','on');
    hF.setHDLParameter('AddInputRegister','on');
    hF.updateHdlfilterINI;


