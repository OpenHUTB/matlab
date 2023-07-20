function isReloaded=utilHandle_HDLAdvisorData(action,system,autoRestore)


    if nargin<3
        autoRestore=false;
    end



    mdlObj=get_param(bdroot(system),'object');
    mdladvObj=mdlObj.getModelAdvisorObj;
    model=bdroot(system);
    isReloaded=false;
    fh=0;
    waitbarVal=0;
    try
        switch action








        case 'load'
            hdriver=hdlmodeldriver(model);
            hDI=hdriver.DownstreamIntegrationDriver;


            hdlwaDriver=hdriver.getWorkflowAdvisorDriver;
            targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.SetTargetDevice');
            isFirstTaskReset=(targetObj.State==ModelAdvisor.CheckStatus.NotRun);


            targetInputParams=mdladvObj.getInputParameters(targetObj.MAC);
            boardManagerBtn=targetInputParams{10};


            if(~isFirstTaskReset)


                if~autoRestore
                    autoRestore=generateAutoRestoreMsg;
                end
                if~autoRestore
                    targetObj.reset;
                    return;
                end
            else
                targetObj.reset;
                return;
            end


            fh=waitbar(0,'Please wait...');
            reportLoadingStatus(mdladvObj,fh,waitbarVal,'Loading');
            waitbarVal=waitbarVal+1;



            isReset=utilParseTargetDevice(mdladvObj,hDI);


            boardManagerBtn.Enable=hDI.isFILWorkflow||hDI.isTurnkeyWorkflow;
            if isReset
                reportLoadingStatus(mdladvObj,fh,waitbarVal,'Failed');
                return;
            end




            isReloaded=true;



            if(hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow||hDI.isIPWorkflow)

                if hDI.isIPCoreGen&&~hDI.isGenericIPPlatform

                    if(targetObj.State==ModelAdvisor.CheckStatus.Passed)
                        try

                            utilParseReferenceDesign(mdladvObj,hDI);


                            isReset=utilParseRDParameterTable(mdladvObj,hDI);
                            if isReset
                                reportLoadingStatus(mdladvObj,fh,waitbarVal,'Failed');
                                isReloaded=false;
                                return;
                            end

                            hdlwa.utilUpdateRDParameterTable(mdladvObj,hDI);


                            hDI.hIP.validateTargetReferenceDesign;


                            targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.SetTargetReferenceDesign');

                        catch ME %#ok<NASGU>

                            targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.SetTargetReferenceDesign');
                            targetObj.reset;
                            reportLoadingStatus(mdladvObj,fh,waitbarVal,'Failed');
                            isReloaded=false;





                            return;
                        end
                    end
                end


                if(targetObj.State==ModelAdvisor.CheckStatus.Passed)
                    try

                        utilParseExecutionMode(mdladvObj,hDI);

                        hDI.hTurnkey.hTable.populateInterfaceTable(system);


                        isReset=utilParseInterfaceTable(mdladvObj,hDI);
                        if isReset
                            reportLoadingStatus(mdladvObj,fh,waitbarVal,'Failed');
                            isReloaded=false;
                            return;
                        end


                        utilUpdateInterfaceTable(mdladvObj,hDI);

                    catch ME %#ok<NASGU>

                        utilUpdateInterfaceTable(mdladvObj,hDI);

                        targetObj.reset;
                        reportLoadingStatus(mdladvObj,fh,waitbarVal,'Failed');
                        isReloaded=false;
                        return;
                    end
                end

                reportLoadingStatus(mdladvObj,fh,waitbarVal,'Loading');
                waitbarVal=waitbarVal+1;


                targetInterfaceTaskID=utilGetTargetInterfaceTask(hDI);
                targetObj=hdlwaDriver.getTaskObj(targetInterfaceTaskID);

                if(targetObj.State==ModelAdvisor.CheckStatus.Passed)

                    hDI.validateTargetInterface;
                end

                reportLoadingStatus(mdladvObj,fh,waitbarVal,'Loading');
                waitbarVal=waitbarVal+1;
            end


            if(hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow||hDI.isIPWorkflow)
                targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.SetTargetFrequency');
                isReset=utilParseTargetFrequency(mdladvObj,hDI);
                if isReset
                    reportLoadingStatus(mdladvObj,fh,waitbarVal,'Failed');
                    isReloaded=false;
                    return;
                elseif(targetObj.State==ModelAdvisor.CheckStatus.Passed)

                    cmdStr='runTargetFrequency(system,false)';
                    evalc(cmdStr);
                end
            end

            reportLoadingStatus(mdladvObj,fh,waitbarVal,'Loading');
            waitbarVal=waitbarVal+1;





            if~hDI.isIPCoreGen



                if hDI.isGenericWorkflow
                    targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.GenerateHDLCodeAndReport');
                    utilParseGenerateHDLCode(mdladvObj,hDI);
                    if(targetObj.State==ModelAdvisor.CheckStatus.Passed)


                        cmdStr='runGenerateRTLCodeAndTestbench(system, false)';
                        evalc(cmdStr);
                    end

                else
                    targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.GenerateRTLCode');
                    if(targetObj.State==ModelAdvisor.CheckStatus.Passed)


                        cmdStr='runGenerateRTLCode(system, false)';

                        evalc(cmdStr);
                    end

                end



                reportLoadingStatus(mdladvObj,fh,waitbarVal,'Loading');
                waitbarVal=waitbarVal+1;


                targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.CreateProject');

                if~hDI.isFILWorkflow
                    utilParseCreateProject(mdladvObj,hDI);
                end

                if(targetObj.State==ModelAdvisor.CheckStatus.Passed)

                    hDI.run('CreateProject');

                    projDir=hDI.getProjectPath;
                    isReset=diffChecksumAndResetDownstream(system,mdladvObj,projDir);
                    if isReset
                        closeWaitbar(fh);
                        isReloaded=false;
                        return;
                    end
                end

                reportLoadingStatus(mdladvObj,fh,waitbarVal,'Loading');



                utilAdjustVerifyCosim(mdladvObj,hDI);

                isReset=utilParseMapping(mdladvObj,hDI);
                if isReset
                    closeWaitbar(fh);
                    isReloaded=false;
                    return;
                end
                isReset=utilParseDetermineBASourceOptions(mdladvObj,hDI);
                if isReset
                    closeWaitbar(fh);
                    isReloaded=false;
                    return;
                end


                if(hDI.isGenericWorkflow)
                    isReset=utilParseAnnotateModel(mdladvObj,hDI);
                    if isReset
                        closeWaitbar(fh);
                        isReloaded=false;
                        return;
                    end
                end

                targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.RunLogicSynthesis');
                if(targetObj.State==ModelAdvisor.CheckStatus.Passed)
                    hDI.setStatus('Synthesis');
                end
                targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.RunMapping');
                if(targetObj.State==ModelAdvisor.CheckStatus.Passed)
                    hDI.setStatus('PostMapTiming');
                end
                targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.RunPandR');
                if(targetObj.State==ModelAdvisor.CheckStatus.Passed)
                    hDI.setStatus('PostPARTiming');
                end
                targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.GenerateBitstream');
                if(targetObj.State==ModelAdvisor.CheckStatus.Passed)
                    hDI.setStatus('ProgrammingFile');
                end

            else



                targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.GenerateIPCore');


                isReset=utilParseGenerateIPCore(mdladvObj,hDI);
                if isReset
                    reportLoadingStatus(mdladvObj,fh,waitbarVal,'Failed');
                    isReloaded=false;
                    return;
                end


                if(targetObj.State==ModelAdvisor.CheckStatus.Passed)
                    cmdStr='generateIPCore(system, false)';
                    evalc(cmdStr);
                end

                reportLoadingStatus(mdladvObj,fh,waitbarVal,'Loading');
                waitbarVal=waitbarVal+1;



                isReset=utilParseEmbeddedProject(mdladvObj,hDI);
                if isReset
                    reportLoadingStatus(mdladvObj,fh,waitbarVal,'Failed');
                    isReloaded=false;
                    return;
                end



                targetObj=hdlwaDriver.getTaskObj('com.mathworks.HDL.EmbeddedProject');
                if(targetObj.State==ModelAdvisor.CheckStatus.Passed)
                    targetObj.reset;
                end

                reportLoadingStatus(mdladvObj,fh,waitbarVal,'Loading');
                waitbarVal=waitbarVal+1;



                isReset=utilParseEmbeddedModelGen(mdladvObj,hDI);
                if isReset
                    reportLoadingStatus(mdladvObj,fh,waitbarVal,'Failed');
                    isReloaded=false;
                    return;
                end

                reportLoadingStatus(mdladvObj,fh,waitbarVal,'Loading');
                waitbarVal=waitbarVal+1;



                isReset=utilParseEmbeddedSystemBuild(mdladvObj,hDI);
                if isReset
                    reportLoadingStatus(mdladvObj,fh,waitbarVal,'Failed');
                    isReloaded=false;
                    return;
                end



                isReset=utilParseEmbeddedDownload(mdladvObj,hDI);
                if isReset
                    reportLoadingStatus(mdladvObj,fh,waitbarVal,'Failed');
                    isReloaded=false;
                    return;
                end

            end

            hdlwa.WorkflowManager.updateWorkflow(mdladvObj);

        end
    catch me
        closeWaitbar(fh);
        rethrow(me);
    end
    closeWaitbar(fh);

    function closeWaitbar(fh)
        if~isempty(fh)
            try
                close(fh);
            catch me

                if(~strcmpi(me.identifier,'MATLAB:close:InvalidFigureHandle'))
                    rethrow(me)
                end
            end
        end


        function reportLoadingStatus(mdladvObj,waitBarHandle,waitbarVal,status)

            if strcmpi(status,'Loading')
                if~isempty(waitBarHandle)
                    waitbar(1-1/(waitbarVal+1),waitBarHandle);
                end
            elseif strcmpi(status,'Failed')
                if~isempty(waitBarHandle)
                    close(waitBarHandle);
                end
            end


            function selection=generateAutoRestoreMsg
                choice=questdlg(DAStudio.message('HDLShared:hdldialog:HDLWADlgAutoRestore'),...
                DAStudio.message('HDLShared:hdldialog:HDLWATitleAutoRestore'),...
                DAStudio.message('HDLShared:hdldialog:hdlccYes'),...
                DAStudio.message('HDLShared:hdldialog:hdlccNo'),...
                DAStudio.message('HDLShared:hdldialog:hdlccYes'));
                switch choice
                case DAStudio.message('HDLShared:hdldialog:hdlccYes')
                    selection=true;
                case DAStudio.message('HDLShared:hdldialog:hdlccNo')
                    selection=false;
                end


