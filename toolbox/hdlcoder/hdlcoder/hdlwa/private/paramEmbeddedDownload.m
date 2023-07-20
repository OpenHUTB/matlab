function paramEmbeddedDownload(taskobj)




    mdladvObj=taskobj.MAObj;


    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=hdlmodeldriver(hModel);
    hDI=hDriver.DownstreamIntegrationDriver;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);
    programOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAProgrammingMethod'));
    ipAddrOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAIPAddress'));
    usernameOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWASSHUsername'));
    passwordOption=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWASSHPassword'));


    try
        if~isequal(programOption.Value,hdlcoder.ProgrammingMethod.convertToString(hDI.hIP.getProgrammingMethod))
            updateParameterName='programoption';
            hDI.hIP.setProgrammingMethod(hdlcoder.ProgrammingMethod.convertToEnum(programOption.Value));
        elseif~isequal(ipAddrOption.Value,hDI.hIP.getIPAddress)
            updateParameterName='ipaddroption';
            hDI.hIP.setIPAddress(ipAddrOption.Value);
        elseif~isequal(usernameOption.Value,hDI.hIP.getSSHUsername)
            updateParameterName='usernameoption';
            hDI.hIP.setSSHUsername(usernameOption.Value);
        elseif~isequal(passwordOption.Value,hDI.hIP.getSSHPassword)
            updateParameterName='passwordoption';
            hDI.hIP.setSSHPassword(passwordOption.Value);



            hMAExplorer=mdladvObj.MAExplorer;
            if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
                currentDialog=hMAExplorer.getDialog;
                currentDialog.setWidgetValue('InputParameters_4',...
                hDI.hIP.getSSHPasswordForDisplay);
            end
        end

    catch ME
        hf=errordlg(ME.message,'Error','modal');

        set(hf,'tag','HDL Workflow Advisor error dialog');
        setappdata(hf,'MException',ME);


        uiwait(hf);


        hMAExplorer=mdladvObj.MAExplorer;
        if~isempty(hMAExplorer)&&~isempty(hMAExplorer.getDialog)
            currentDialog=hMAExplorer.getDialog;
            if strcmpi(updateParameterName,'programoption')
                currentDialog.setWidgetValue('InputParameters_1',...
                hdlcoder.ProgrammingMethod.convertToString(hDI.hIP.getProgrammingMethod));
            elseif strcmpi(updateParameterName,'ipaddroption')
                currentDialog.setWidgetValue('InputParameters_2',...
                hDI.hIP.getIPAddress);
            elseif strcmpi(updateParameterName,'usernameoption')
                currentDialog.setWidgetValue('InputParameters_3',...
                hDI.hIP.getSSHUsername);
            elseif strcmpi(updateParameterName,'passwordoption')
                currentDialog.setWidgetValue('InputParameters_4',...
                hDI.hIP.getSSHPasswordForDisplay);
            end
        end
    end


    utilAdjustEmbeddedDownload(mdladvObj,hDI);


