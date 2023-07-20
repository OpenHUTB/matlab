function[ResultDescription,ResultDetails]=setTargetReferenceDesign(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    ResultDescription={};
    ResultDetails={};

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;

    try

        validateCell=hDI.hIP.validateTargetReferenceDesign;


        [ResultDescription,ResultDetails,hasError]=utilDisplayValidation(validateCell,...
        ResultDescription,ResultDetails);

        if~hasError

            utilAdjustTestPoints(mdladvObj,hDI);

            utilAdjustGenerateAXISlave(mdladvObj,hDI);


            taskID='com.mathworks.HDL.SetTargetReferenceDesign';
            msg=utilLoadInterfaceTable(mdladvObj,hDI,taskID);
            if~isempty(msg)
                for i=1:length(msg)
                    Warning=ModelAdvisor.Text('Warning ',{'Warn'});
                    ResultDescription{end+1}=ModelAdvisor.Text([Warning.emitHTML,msg{i}.message]);%#ok<AGROW>
                    ResultDetails{end+1}='';%#ok<AGROW>
                end
            end
        end
        utilAdjustEmbeddedModelGen(mdladvObj,hDI);

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

        hDI.saveRDSettingToModel(hModel,hDI.hIP.getReferenceDesign);

        statusText=Passed.emitHTML;
        text=ModelAdvisor.Text([statusText,'Set Target Reference Design.']);
        ResultDescription{end+1}=text;
        ResultDetails{end+1}='';
    end


    mdladvObj.setCheckResultStatus(Result);


    utilAdjustGenerateIPCore(mdladvObj,hDI);

end
