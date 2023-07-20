function configurePILSettings(hObj,val)




    cs=hObj.getConfigSet;

    pilConfig=rtw.pil.ConfigureModelForPILBlock(cs);

    if(val)

        pilConfig.configure;

        setProp(hObj,'CreateSILPILBlock','PIL');
    else

        pilConfig.remove;

        setProp(hObj,'CreateSILPILBlock','None');
    end
