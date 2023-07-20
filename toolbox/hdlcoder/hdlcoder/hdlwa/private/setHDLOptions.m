function[ResultDescription,ResultDetails]=setHDLOptions(system)




    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    ResultDescription={};
    ResultDetails={};

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGFailed'),{'Fail'});



    model=bdroot(system);


    hDriver=hdlmodeldriver(model);


    hDI=hDriver.DownstreamIntegrationDriver;


    cs=getActiveConfigSet(model);

    try





        if slprivate('checkSimPrm',cs)
















            hDI.loadGenerateHDLSettingsFromModel(model,false);




            if~hDI.GenerateRTLCode&&(hDI.isTurnkeyWorkflow||hDI.isXPCWorkflow||hDI.isFILWorkflow)
                linkStr=message('HDLShared:hdldialog:MSGThisSetting').getString;
                paramLink=sprintf('<a href="matlab:configset.highlightParameter(%s, ''GenerateHDLCode'');">%s</a>',...
                cleanBlockNameForQuotedDisp(model),linkStr);

                paramNameStr=message('HDLShared:hdldialog:hdlccCodeGenOutput1').getString;
                error(message('HDLShared:hdldialog:InvalidGenerateCodeSetting',paramNameStr,paramLink));
            end




            if hDI.isIPCoreGen&&~isequal(hDI.EnableTestpointsSetting,hDI.isTestPointEnabledOnModel)
                linkStr=message('HDLShared:hdldialog:MSGThisSetting').getString;
                paramLink=sprintf('<a href="matlab:configset.highlightParameter(%s, ''EnableTestpoints'');">%s</a>',...
                cleanBlockNameForQuotedDisp(model),linkStr);

                paramNameStr=message('HDLShared:hdldialog:hdlglblsettingsEnableTestpoints').getString;
                taskNameStr=message('HDLShared:hdldialog:HDLWASetTargetInterface').getString;

                if hDI.EnableTestpointsSetting
                    settingValStr='on';
                else
                    settingValStr='off';
                end

                error(message('HDLShared:hdldialog:InvalidTestpointSetting',paramNameStr,taskNameStr,paramLink,settingValStr,taskNameStr));
            end


            utilAdjustGenerateHDLCode(mdladvObj,hDI);



            cs.closeDialog;


            Result=true;
            status=Passed;
            msg=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:HDLWASetHDLOptionsPassed'));
        else

            Result=false;
            status=Failed;
            msg=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:HDLWASetHDLOptionsFailed'));
        end

    catch ME

        Result=false;
        status=Failed;
        msg=ModelAdvisor.Text(ME.message);
    end

    text=ModelAdvisor.Text([status.emitHTML,msg.emitHTML]);
    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';


    mdladvObj.setCheckResultStatus(Result);