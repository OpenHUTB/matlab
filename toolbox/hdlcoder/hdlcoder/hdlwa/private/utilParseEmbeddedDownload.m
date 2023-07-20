function isReset=utilParseEmbeddedDownload(mdladvObj,hDI)




    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
    taskObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.EmbeddedDownload');


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    programOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAProgrammingMethod'));
    isReset=false;

    try
        if~isequal(programOption.Value,hdlcoder.ProgrammingMethod.convertToString(hDI.hIP.getProgrammingMethod))
            hDI.hIP.setProgrammingMethod(hdlcoder.ProgrammingMethod.convertToEnum(programOption.Value));
        end
    catch ME

        taskObj.reset;
        isReset=true;

        errorMsg=sprintf(['Error occurred in Task 4.4 when loading Restore Point.\n',...
        'The error message is:\n%s\n'],...
        ME.message);
        hf=errordlg(errorMsg,'Error','modal');

        set(hf,'tag','load Program Target Device error dialog');
        setappdata(hf,'MException',ME);
    end

end


