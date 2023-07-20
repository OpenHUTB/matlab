function[ResultDescription,ResultDetails]=setTargetDevice(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    ResultDescription={};
    ResultDetails={};

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;




    nameLengthLimit=52;


    getParam=hdlget_param(gcs,'all');



    if any(strcmp(getParam,'GeneratedModelNamePrefix'))
        gm_prefix=hdlget_param(gcs,'GeneratedModelNamePrefix');
    else
        gm_prefix='';
    end


    totalLengthOfModel=length(gm_prefix)+length(hModel);


    if totalLengthOfModel>=nameLengthLimit
        warnObj=message('hdlcoder:workflow:NameLengthExceeded',hModel,totalLengthOfModel,nameLengthLimit);
        warning(warnObj);
        warnGUIobj=ModelAdvisor.Text(DAStudio.message('hdlcoder:workflow:NameLengthExceeded',hModel,totalLengthOfModel,nameLengthLimit));
        warningObj=ModelAdvisor.Text('Warning ',{'Warn'});
        warnGUI=ModelAdvisor.Text([warningObj.emitHTML,warnGUIobj.emitHTML]);
        ResultDescription{end+1}=warnGUI;
        ResultDetails{end+1}='';
    end

    if hdlwa.hdlwaDriver.isFILFeatureOn
        if~hDI.isBoardEmpty||~hDI.isToolEmpty
            msg=sprintf(['The following settings are required for FPGA-in-the-Loop:\n'...
            ,'Target platform: Generic ASIC/FPGA Target\n'...
            ,'Synthesis Tool: No Synthesis Tool Specified\n']);

            [ResultDescription,ResultDetails]=utilDisplayResult(msg,...
            ResultDescription,ResultDetails);

            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
            'FPGA-in-the-Loop validation',[],ResultDescription,ResultDetails);


            mdladvObj.setCheckResultStatus(false);
            return;
        end
    end



    try

        if hDI.isBoardEmpty
            error(message('hdlcoder:workflow:TargetPlatformNotSelected'));
        end


        hDI.createProjectFolder(hDI.getProjectFolder());



        rtlDir=hDI.getFullHdlsrcDir;
        filDir=hDI.getFullFILDir;
        fpgaDir=hDI.getFullFPGADir;
        if isfolder(rtlDir)||isfolder(filDir)||isfolder(fpgaDir)
            answer=generateDirectoryOverwriteMsg(hDI);
            if answer==false
                error(message('hdlcoder:workflow:DirectoryOverwriteAborted'));
            end
        end


        validateCell=hDI.validateProjectFolder;


        [ResultDescription,ResultDetails]=utilDisplayValidation(validateCell,...
        ResultDescription,ResultDetails);


        if hDI.isIPWorkflow
            hDI.hIP.validateIPCoreWorkflow;
        end


        if hDI.isTurnkeyWorkflow||...
            (hDI.isXPCWorkflow&&~hDI.isIPCoreGen)||...
            (hDI.isIPWorkflow&&hDI.isGenericIPPlatform)
            try


                if hDI.isGenericIPPlatform
                    msg=hDI.hTurnkey.updateInterfaceListWithModel;
                    if~isempty(msg)
                        Warning=ModelAdvisor.Text('Warning ',{'Warn'});
                        ResultDescription{end+1}=ModelAdvisor.Text([Warning.emitHTML,msg.getReport]);
                        ResultDetails{end+1}='';
                    end
                end


                utilParseExecutionMode(mdladvObj,hDI);


                utilAdjustTestPoints(mdladvObj,hDI);


                utilAdjustGenerateAXISlave(mdladvObj,hDI);


                taskID='com.mathworks.HDL.SetTargetDevice';
                msg=utilLoadInterfaceTable(mdladvObj,hDI,taskID);
                if~isempty(msg)
                    for ii=1:length(msg)
                        Warning=ModelAdvisor.Text('Warning ',{'Warn'});
                        ResultDescription{end+1}=ModelAdvisor.Text([Warning.emitHTML,msg{ii}.message]);%#ok<AGROW>
                        ResultDetails{end+1}='';%#ok<AGROW>
                    end
                end
            catch ME

                utilUpdateInterfaceTable(mdladvObj,hDI);
                rethrow(ME);
            end
        end



        targetDeviceInputParams=mdladvObj.getInputParameters;
        tool=targetDeviceInputParams{3}.Value;
        if(strcmpi(tool,'No synthesis tool specified')||strcmpi(tool,'No synthesis tool available on system path'))
            tool='';
        end
        workflowValue=targetDeviceInputParams{1}.Value;
        boardValue=targetDeviceInputParams{2}.Value;
        family=targetDeviceInputParams{4}.Value;
        device=targetDeviceInputParams{5}.Value;
        package=targetDeviceInputParams{6}.Value;
        speed=targetDeviceInputParams{7}.Value;

        hDI.savetargetDeviceSettingToModel(hModel,workflowValue,boardValue,tool,family,device,package,speed);


        toolOption=targetDeviceInputParams{3};
        toolVersionOption=targetDeviceInputParams{12};
        if~hDI.hAvailableToolList.isToolVersionSupported(toolOption.Value)
            if~hDI.getAllowUnsupportedToolVersion()
                error(DAStudio.message('HDLShared:hdldialog:HDLWAUnsupportedToolVersionAllow',toolOption.Value,toolVersionOption.Value));
            else
                warnGUIobj=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:HDLWAUnsupportedToolVersionAttempt',toolOption.Value,toolVersionOption.Value));
                warningObj=ModelAdvisor.Text('Warning ',{'Warn'});
                warnGUI=ModelAdvisor.Text([warningObj.emitHTML,warnGUIobj.emitHTML]);
                ResultDescription{end+1}=warnGUI;
                ResultDetails{end+1}='';
            end
        end

    catch ME

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
        ME.message,ME.cause,{},{},ME.getReport);
        return;
    end


    [ResultDescription,ResultDetails]=checkSoCSupportPackageInstallation(hDI,...
    ResultDescription,ResultDetails);



    if~isempty(validateCell)
        if strcmpi(validateCell{end}.Status,'Error')
            Result=false;
        else
            Result=true;
            statusText=Passed.emitHTML;
            text=ModelAdvisor.Text([statusText,'Set Target Device and Synthesis Tool.']);
            ResultDescription{end+1}=text;
        end
    else
        Result=true;
        statusText=Passed.emitHTML;
        text=ModelAdvisor.Text([statusText,'Set Target Device and Synthesis Tool.']);
        ResultDescription{end+1}=text;
    end
    ResultDetails{end+1}='';


    mdladvObj.setCheckResultStatus(Result);

end


function[ResultDescription,ResultDetails]=checkSoCSupportPackageInstallation(hDI,...
    ResultDescription,ResultDetails)





    if hDI.isProcessingSystemAvailable
        [isInstalled,spName]=hDI.isHDLCoderSoCSPInstalled;
        if~isInstalled
            taskName1=message('hdlcommon:workflow:HDLWASWInterfaceScript').getString;
            taskName2=message('HDLShared:hdldialog:HDLWATitleProgramTargetFPGADevice').getString;
            taskName=strjoin({taskName1,taskName2},'; ');
            msgObj=message('hdlcommon:workflow:SupportPackageUnavailable',spName,taskName);
            warnMsg=msgObj.getString;

            Warning=ModelAdvisor.Text('Warning ',{'Warn'});
            ResultDescription{end+1}=ModelAdvisor.Text([Warning.emitHTML,warnMsg]);
            ResultDetails{end+1}='';
        end

        [isInstalled,spName]=hDI.isEmbeddedCoderSPInstalled;
        if~isInstalled&&~hDI.isLiberoSoc
            taskName=message('hdlcommon:workflow:HDLWASWInterfaceModel').getString;
            msgObj=message('hdlcommon:workflow:SupportPackageUnavailable',spName,taskName);
            warnMsg=msgObj.getString;

            Warning=ModelAdvisor.Text('Warning ',{'Warn'});
            ResultDescription{end+1}=ModelAdvisor.Text([Warning.emitHTML,warnMsg]);
            ResultDetails{end+1}='';
        end

    end

end


function selection=generateDirectoryOverwriteMsg(hDI)
    choice=questdlg(DAStudio.message('HDLShared:hdldialog:HDLWADlgDirectoryOverwrite',hDI.getProjectFolder,DAStudio.message('HDLShared:hdldialog:hdlccYes'),DAStudio.message('HDLShared:hdldialog:hdlccNo')),...
    DAStudio.message('HDLShared:hdldialog:HDLWATitleDirectoryOverwrite'),...
    DAStudio.message('HDLShared:hdldialog:hdlccYes'),...
    DAStudio.message('HDLShared:hdldialog:hdlccNo'),...
    DAStudio.message('HDLShared:hdldialog:hdlccYes'));
    switch choice
    case DAStudio.message('HDLShared:hdldialog:hdlccYes')
        selection=true;
    case DAStudio.message('HDLShared:hdldialog:hdlccNo')
        selection=false;
    end
end


