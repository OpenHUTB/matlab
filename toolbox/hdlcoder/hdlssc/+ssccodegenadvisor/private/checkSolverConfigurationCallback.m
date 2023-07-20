function[ResultDescription,ResultDetails]=checkSolverConfigurationCallback(sys)





    ResultDescription={};
    ResultDetails={};


    modelAdvisorObj=Simulink.ModelAdvisor.getModelAdvisor(sys);
    modelAdvisorObj.setCheckErrorSeverity(1);


    sscCodeGenWorkflowObjCheck=modelAdvisorObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;

    try

        sscCodeGenWorkflowObj.checkSolverConfiguration();


        formatTemplate=ModelAdvisor.FormatTemplate('ListTemplate');
        setSubResultStatus(formatTemplate,'Pass');
        setSubBar(formatTemplate,0);
        ResultDescription{end+1}=formatTemplate;
        ResultDetails{end+1}={};

        solverBlks=sscCodeGenWorkflowObj.SolverConfiguration;

        listTitleText='The following checks were performed:';
        listTitleObj=ModelAdvisor.Text(listTitleText);
        ResultDescription{end+1}=listTitleObj;
        ResultDetails{end+1}={};

        listObj=ModelAdvisor.List();
        listObj.setType('bulleted');
        listObj.addItem(ModelAdvisor.Text('Use local solver option is checked for every solver block.'));
        listObj.addItem(ModelAdvisor.Text('Backward Euler or Partitioning solver option is selected for every solver block.'));
        listObj.addItem(ModelAdvisor.Text('Local solver sample time is uniform between all solver blocks.'));
        listObj.addItem(ModelAdvisor.Text('"Use fixed-cost runtime consistency iterations" option is consistent between all solver blocks'));
        listObj.addItem(ModelAdvisor.Text('Max non linear iterations are uniform between all solver blocks.'));
        ResultDescription{end+1}=listObj;
        ResultDetails{end+1}={};

        if~isempty(solverBlks)&&strcmpi(get_param(solverBlks{1},'DoFixedCost'),'on')


            sscCodeGenWorkflowObj.NumberOfSolverIterations=slResolve(get_param(solverBlks{1},'MaxNonlinIter'),solverBlks{1});
        end
        modelAdvisorObj.setCheckResultStatus(true);
        resetSubsequentTasks(modelAdvisorObj)
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
