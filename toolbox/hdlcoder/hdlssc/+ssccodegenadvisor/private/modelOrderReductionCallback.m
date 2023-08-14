function[ResultDescription,ResultDetails]=modelOrderReductionCallback(sys)






    ResultDescription={};
    ResultDetails={};

    modelAdvisorObj=Simulink.ModelAdvisor.getModelAdvisor(sys);
    modelAdvisorObj.setCheckErrorSeverity(1);


    sscCodeGenWorkflowObjCheck=modelAdvisorObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;

    try


        sscCodeGenWorkflowObj.resetLinearModel();

        if isfield(sscCodeGenWorkflowObj.listOfSwitches,'Approx')
            sscCodeGenWorkflowObj.linearize=any([sscCodeGenWorkflowObj.listOfSwitches.Approx]);
        else
            sscCodeGenWorkflowObj.linearize=false;
        end


        formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');

        if sscCodeGenWorkflowObj.linearize
            sscCodeGenWorkflowObj.linearizeSwitches();
            setSubResultStatus(formatTemplate,'Pass');
            setSubBar(formatTemplate,0);
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};
            if sscCodeGenWorkflowObj.modelOrderReductionValLogic
                setSubResultStatusText(formatTemplate,ModelAdvisor.Text(message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:LinearizedValidationModelGenerated',...
                ssccodegenutils.getModelHyperlink(sscCodeGenWorkflowObj.linearModelVldn,sys)).getString));
                setSubBar(formatTemplate,0);
            else
                txtObj=ModelAdvisor.Text('Linearization performed.');
                ResultDescription{end+1}=txtObj;
            end

            modelAdvisorObj.setCheckResultStatus(true);
            ResultDetails{end+1}={};
            resultStatus=true;

        else
            numSwitches=sscCodeGenWorkflowObj.checkNumberSwitches();

            if numSwitches>15

                setSubBar(formatTemplate,0);
                ResultDescription{end+1}=formatTemplate;
                ResultDetails{end+1}={};

                resultStatus=false;
                setSubResultStatus(formatTemplate,'Warn');
                setSubResultStatusText(formatTemplate,'Large number of switches detected. Linearization is suggested for FPGA synthesis.');
                modelAdvisorObj.setCheckErrorSeverity(0);


            else
                setSubResultStatus(formatTemplate,'Pass');
                setSubBar(formatTemplate,0);
                ResultDescription{end+1}=formatTemplate;
                ResultDetails{end+1}={};

                txtObj=ModelAdvisor.Text('No model reduction performed.');
                ResultDescription{end+1}=txtObj;
                ResultDetails{end+1}={};
                resultStatus=true;

            end
        end
        modelAdvisorObj.setCheckResultStatus(resultStatus);




    catch me

        if strcmpi(me.identifier,'linearizecallback:NothingToLinearize')
            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatus(formatTemplate,'Warn');
            setSubResultStatusText(formatTemplate,ModelAdvisor.Text(me.message()));
            setSubBar(formatTemplate,0);
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};
            modelAdvisorObj.setCheckResultStatus(false);
            modelAdvisorObj.setCheckErrorSeverity(0);



        else

            formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
            setSubResultStatus(formatTemplate,'Fail');
            setSubResultStatusText(formatTemplate,ModelAdvisor.Text(me.message()));
            setSubBar(formatTemplate,0);
            ResultDescription{end+1}=formatTemplate;
            ResultDetails{end+1}={};
            modelAdvisorObj.setCheckResultStatus(false);
        end



    end


