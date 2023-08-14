function configurePILSettings(hObj,val)




    cs=hObj.getConfigSet;

    pilConfig=rtw.pil.ConfigureModelForPILBlock(cs);

    if(val)

        if isempty(strfind(getProp(hObj,'compilerOptionsStr'),'-g'))
            setProp(hObj,'compilerOptionsStr',[getProp(hObj,'compilerOptionsStr'),' -g']);
        end

        pilConfig.configure;
    else

        pilConfig.remove;
    end
