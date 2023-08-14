function isReset=utilParseEmbeddedModelGen(mdladvObj,hDI)




    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;

    if(hDI.isShowCustomSWModelGenerationTask)
        taskObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.EmbeddedCustomModelGen');
    else
        taskObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.EmbeddedModelGen');
    end


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    swModelOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWASWInterfaceModel'));

    if(~hDI.isShowCustomSWModelGenerationTask)
        osOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWAOS'));
        swScriptOption=utilGetInputParameter(inputParams,DAStudio.message('hdlcommon:workflow:HDLWASWInterfaceScript'));
    end
    isReset=false;

    try
        if~isequal(swModelOption.Value,hDI.hIP.GenerateSoftwareInterfaceModel)
            hDI.hIP.GenerateSoftwareInterfaceModel=swModelOption.Value;
        end
        if(~hDI.isShowCustomSWModelGenerationTask)
            if~isequal(osOption.Value,hDI.hIP.getOperatingSystem)
                hDI.hIP.setOperatingSystem(osOption.Value);
            end
            if~isequal(swScriptOption.Value,hDI.hIP.GenerateHostInterfaceScript)
                hDI.hIP.GenerateHostInterfaceScript=swScriptOption.Value;
            end
        end

    catch ME

        taskObj.reset;
        isReset=true;

        errorMsg=sprintf(['Error occurred in Task 4.2 when loading Restore Point.\n',...
        'The error message is:\n%s\n'],...
        ME.message);
        hf=errordlg(errorMsg,'Error','modal');

        set(hf,'tag','load Embedded System Build error dialog');
        setappdata(hf,'MException',ME);
    end

end


