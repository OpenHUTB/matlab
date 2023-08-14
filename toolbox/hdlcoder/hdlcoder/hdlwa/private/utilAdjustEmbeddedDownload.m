function utilAdjustEmbeddedDownload(mdladvObj,hDI)





    if isempty(hDI.hIP)
        return;
    end

    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
    targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.EmbeddedDownload');


    inputParams=mdladvObj.getInputParameters(targetObj.MAC);
    programOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAProgrammingMethod'));
    ipAddrOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPAddress'));
    usernameOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWASSHUsername'));
    passwordOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWASSHPassword'));


    programList=hdlcoder.ProgrammingMethod.convertToString(hDI.hIP.getProgrammingMethodAll);
    if~iscell(programList)
        programList={programList};
    end


    programOption.Entries=programList;
    programOption.Value=hdlcoder.ProgrammingMethod.convertToString(hDI.hIP.getProgrammingMethod);
    programOption.Enable=hDI.hIP.enableProgrammingMethod;



    enableSSHOptions=(hDI.hIP.getProgrammingMethod==hdlcoder.ProgrammingMethod.Download);

    ipAddrOption.Enable=enableSSHOptions;
    usernameOption.Enable=enableSSHOptions;
    passwordOption.Enable=enableSSHOptions;



    if enableSSHOptions
        ipAddrOption.Value=hDI.hIP.getIPAddress;
        usernameOption.Value=hDI.hIP.getSSHUsername;
        passwordOption.Value=hDI.hIP.getSSHPasswordForDisplay;
    else
        ipAddrOption.Value='';
        usernameOption.Value='';
        passwordOption.Value='';
    end

end

