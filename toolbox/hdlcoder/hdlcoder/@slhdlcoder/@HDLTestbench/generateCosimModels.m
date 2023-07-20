function generateCosimModels(this,cosimTarget,cosimSetup)%#ok<*INUSD,*INUSL>








    hdlDriver=hdlcurrentdriver;
    hPir=hdlDriver.PirInstance;

    cosimSetup='CosimBlockAndDut';

    if strcmpi(cosimTarget,'ModelSim')
        gc=cosimtb.gencosimmq(cosimSetup,hdlDriver,hPir);
    elseif strcmpi(cosimTarget,'Incisive')
        gc=cosimtb.gencosimin(cosimSetup,hdlDriver,hPir);
    elseif strcmpi(cosimTarget,'Vivado Simulator')
        gc=cosimtb.gencosimvs(cosimSetup,hdlDriver,hPir);
    else
        errMsg=message('hdlcoder:engine:invalidcosimmodeloption');
        this.addCheckToDriver(hdlDriver.ModelName,'error',errMsg);
        error(errMsg);
    end


    gc.doIt;
    hdlDriver.CosimModelName=gc.getCosimModelName;

end