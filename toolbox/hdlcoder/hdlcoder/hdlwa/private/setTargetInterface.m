function[ResultDescription,ResultDetails]=setTargetInterface(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    ResultDescription={};
    ResultDetails={};

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;

    try

        utilParseExecutionMode(mdladvObj,hDI);





        hDI.EnableTestpointsSetting=hDI.isTestPointEnabledOnModel;


        validateCell=hDI.validateTargetInterface;


        [ResultDescription,ResultDetails,hasError]=utilDisplayValidation(validateCell,...
        ResultDescription,ResultDetails);


        utilUpdateInterfaceTable(mdladvObj,hDI);

    catch ME

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
        ME.message,ME.cause,{},{},ME.getReport);


        utilUpdateInterfaceTable(mdladvObj,hDI);
        return;
    end

    if hasError
        Result=false;
    else
        Result=true;

        hDI.hTurnkey.hTable.savePortInterfaceToModel;
        if hDI.isIPWorkflow||hDI.isXPCWorkflow
            hDI.saveSyncModeSettingToModel(system,hDI.get('ExecutionMode'));
        end

        statusText=Passed.emitHTML;
        text=ModelAdvisor.Text([statusText,'Set Target Interface Table.']);
        ResultDescription{end+1}=text;
        ResultDetails{end+1}='';
    end


    mdladvObj.setCheckResultStatus(Result);

    if hDI.isIPCoreGen

        utilAdjustGenerateAXISlave(mdladvObj,hDI);

        utilAdjustGenerateIPCore(mdladvObj,hDI);
    end




    if hDI.isIPCoreGen
        hRD=hDI.hTurnkey.hD.hIP.getReferenceDesignPlugin;
        if~isempty(hRD)
            maxFrqlimitRD=hRD.hClockModule.ClockMaxMHz;
            targetFrequency=hDI.getTargetFrequency;
            limit=hDI.adjustDeviceFrequencyLimit;
            if(maxFrqlimitRD~=limit)
                freqLimit=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGWarning1'),{'Warn'});
                statusText=freqLimit.emitHTML;
                text=ModelAdvisor.Text([statusText,DAStudio.message('hdlcommon:workflow:LimitMaxfreqAMandFDCOverEthernet')]);
                ResultDescription{end+1}=text;
                ResultDetails{end+1}='';
            end
            if(targetFrequency>limit)
                targetFrequency=limit;
            end
            hDI.setTargetFrequency(targetFrequency);
            utilAdjustTargetFrequency(mdladvObj,hDI);
        end
    end

end
