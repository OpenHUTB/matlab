function checks=defineSSCCodeGenAdvisorChecks




    checks={};


    workflowObjectCheck=ModelAdvisor.Check('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    checks{end+1}=workflowObjectCheck;




    checkSolverConfigurationCheck=ModelAdvisor.Check('com.mathworks.hdlssc.ssccodegenadvisor.checkSolverConfigurationTask');
    checkSolverConfigurationCheck.Title=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:checkSolverConfigurationCheckTitle');
    checkSolverConfigurationCheck.TitleTips=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:checkSolverConfigurationCheckTitleTips');
    checkSolverConfigurationCheck.CallbackHandle=@checkSolverConfigurationCallback;
    checkSolverConfigurationCheck.CallbackStyle='StyleThree';
    checkSolverConfigurationCheck.CallbackContext='Postcompile';
    checks{end+1}=checkSolverConfigurationCheck;


    checkSwitchedLinearCheck=ModelAdvisor.Check('com.mathworks.hdlssc.ssccodegenadvisor.checkSwitchedLinearTask');
    checkSwitchedLinearCheck.Title=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:checkSwitchedLinearCheckTitle');
    checkSwitchedLinearCheck.TitleTips=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:checkSwitchedLinearCheckTitleTips');
    checkSwitchedLinearCheck.CallbackHandle=@checkSwitchedLinearCallback;
    checkSwitchedLinearCheck.CallbackStyle='StyleThree';
    checkSwitchedLinearCheck.CallbackContext='Postcompile';
    checks{end+1}=checkSwitchedLinearCheck;

    if strcmpi(hdlfeature('SSCHDLModelOrderReduction'),'on')


        modelOrderReductionCheck=ModelAdvisor.Check('com.mathworks.hdlssc.ssccodegenadvisor.modelOrderReductionCheck');
        modelOrderReductionCheck.Title=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:modelOrderReductionCheckTitle');
        modelOrderReductionCheck.TitleTips=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:modelOrderReductionCheckTitleTips');
        modelOrderReductionCheck.CallbackHandle=@modelOrderReductionCallback;
        modelOrderReductionCheck.CallbackStyle='StyleThree';
        checks{end+1}=modelOrderReductionCheck;
    end




    getStateSpaceParametersCheck=ModelAdvisor.Check('com.mathworks.hdlssc.ssccodegenadvisor.getStateSpaceParametersTask');
    getStateSpaceParametersCheck.Title=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:getStateSpaceParametersCheckTitle');
    getStateSpaceParametersCheck.TitleTips=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:getStateSpaceParametersCheckTitleTips');
    getStateSpaceParametersCheck.CallbackHandle=@extractEquationsCallback;
    getStateSpaceParametersCheck.CallbackStyle='StyleThree';checks{end+1}=getStateSpaceParametersCheck;


    discretizeCheck=ModelAdvisor.Check('com.mathworks.hdlssc.ssccodegenadvisor.discretizeTask');
    discretizeCheck.Title=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:discretizeCheckTitle');
    discretizeCheck.TitleTips=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:discretizeCheckTitleTips');

    discretizeCheck.CallbackHandle=@discretizeEquationsCallback;
    discretizeCheck.CallbackContext='Postcompile';

    discretizeCheck.CallbackStyle='StyleThree';checks{end+1}=discretizeCheck;


    generateImplementationModelCheck=ModelAdvisor.Check('com.mathworks.hdlssc.ssccodegenadvisor.generateImplementationModelTask');
    generateImplementationModelCheck.Title=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckTitle');
    generateImplementationModelCheck.TitleTips=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckTitleTips');
    generateImplementationModelCheck.CallbackHandle=@generateHDLModelCallback;
    generateImplementationModelCheck.CallbackContext='Postcompile';
    generateImplementationModelCheck.CallbackStyle='StyleThree';
    checks{end+1}=generateImplementationModelCheck;


