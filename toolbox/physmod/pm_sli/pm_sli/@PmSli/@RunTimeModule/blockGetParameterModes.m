function paramModeData=blockGetParameterModes(hBlock)












    configData=RunTimeModule_config;






    if isprop(hBlock,'ReferenceBlock')

        code='{IbhI^*x19kNiE9#_HJY%>ib+,( H^dR*\,,)-/2>>47tbT14''vcT=/[}08Ea';
        determineWhichParams=getEditingModeCallback(hBlock,code);

    else
        pm_error(configData.Error.CannotGetParameterMode_msgid);


    end

    if~isempty(determineWhichParams)
        try
            BlockName=getfullname(hBlock.Handle);%#ok This is defined in case the eval below needs it
            paramModeData=eval(determineWhichParams);
        catch
            pm_error(configData.Error.CannotGetParameterMode_msgid);
        end

    else
        paramModeData=[];
    end


