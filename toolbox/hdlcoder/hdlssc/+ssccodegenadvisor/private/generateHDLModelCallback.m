function[ResultDescription,ResultDetails]=generateHDLModelCallback(sys)





    ResultDescription={};
    ResultDetails={};


    modelAdvisorObj=Simulink.ModelAdvisor.getModelAdvisor(sys);
    modelAdvisorObj.setCheckErrorSeverity(1);


    sscCodeGenWorkflowObjCheck=modelAdvisorObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;

    try

        sscCodeGenWorkflowObj.generateHDLModel();


        formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
        setSubResultStatus(formatTemplate,'Pass');

        mlCmd=strcat("edit ",sscCodeGenWorkflowObj.HDLModelSettingsFile);
        hLink=ssccodegenutils.createHyperlink(mlCmd,'HDL settings');
        modelAdvMsg=ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ImplementationModelGenerated',...
        ssccodegenutils.getModelHyperlink(sscCodeGenWorkflowObj.HDLModel,sys),...
        hLink).getString);
        setSubResultStatusText(formatTemplate,modelAdvMsg);
        setSubBar(formatTemplate,0);
        ResultDescription{end+1}=formatTemplate;
        ResultDetails{end+1}={};


        if sscCodeGenWorkflowObj.GenerateValidation
            ResultDescription{end+1}=ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ValidationModelGenerated',...
            ssccodegenutils.getModelHyperlink(sscCodeGenWorkflowObj.HDLVnlModel,sys)).getString);
            ResultDetails{end+1}={};

        end


        if~isempty(sscCodeGenWorkflowObj.FailedReplacementID)
            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatus(formatTemplate,'Warn');
            setSubResultStatusText(formatTemplate,ModelAdvisor.Text(...
            message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:ImplementationModelFailedReplace',...
            sscCodeGenWorkflowObj.FailedReplacementMessage).getString));
            setSubBar(formatTemplate,0);

            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};
        end

        modelAdvisorObj.setCheckResultStatus(true);
        resetSubsequentTasks(modelAdvisorObj);


    catch me

        formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
        setSubResultStatus(formatTemplate,'Fail');
        setSubResultStatusText(formatTemplate,ModelAdvisor.Text(me.message()));
        setSubBar(formatTemplate,0);
        ResultDescription{end+1}=formatTemplate;
        ResultDetails{end+1}={};
        modelAdvisorObj.setCheckResultStatus(false);
    end

end
