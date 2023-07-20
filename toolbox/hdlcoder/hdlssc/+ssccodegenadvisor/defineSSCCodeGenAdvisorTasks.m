function defineSSCCodeGenAdvisorTasks





    modelAdvisorRoot=ModelAdvisor.Root;


    sscCodeGenAdvisorProcedure=ModelAdvisor.Procedure('com.mathworks.hdlssc.ssccodegenadvisor.sscCodeGenAdvisorProcedure');
    sscCodeGenAdvisorProcedure.DisplayName=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_procedures:sscCodeGenAdvisorProcedureDisplayName');
    sscCodeGenAdvisorProcedure.Description=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_procedures:sscCodeGenAdvisorProcedureDescription');
    sscCodeGenAdvisorProcedure.CSHParameters.MapKey='ssccga';
    sscCodeGenAdvisorProcedure.CSHParameters.TopicID='ssccga_help_button';



    codeGenerationCompatibilityProcedure=ModelAdvisor.Procedure('com.mathworks.hdlssc.ssccodegenadvisor.codeGenerationCompatibilityProcedure');
    codeGenerationCompatibilityProcedure.DisplayName=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_procedures:codeGenerationCompatibilityProcedureDisplayName');
    codeGenerationCompatibilityProcedure.Description=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_procedures:codeGenerationCompatibilityProcedureDescription');
    codeGenerationCompatibilityProcedure.CSHParameters.MapKey='ssccga';
    codeGenerationCompatibilityProcedure.CSHParameters.TopicID=codeGenerationCompatibilityProcedure.ID;


    checkSolverConfigurationTask=ModelAdvisor.Task('com.mathworks.hdlssc.ssccodegenadvisor.checkSolverConfigurationTask');
    checkSolverConfigurationTask.setCheck('com.mathworks.hdlssc.ssccodegenadvisor.checkSolverConfigurationCheck');
    checkSolverConfigurationTask.setCheck('com.mathworks.hdlssc.ssccodegenadvisor.checkSolverConfigurationCheck');
    checkSolverConfigurationTask.CSHParameters.MapKey='ssccga';
    checkSolverConfigurationTask.CSHParameters.TopicID=checkSolverConfigurationTask.ID;
    checkSolverConfigurationTask.MAC='com.mathworks.hdlssc.ssccodegenadvisor.checkSolverConfigurationTask';
    checkSolverConfigurationTask.CustomDialogSchema=@schemaCheckSolverConfiguration;
    checkSolverConfigurationTask.EnableReset=true;
    modelAdvisorRoot.register(checkSolverConfigurationTask);

    checkSwitchedLinearTask=ModelAdvisor.Task('com.mathworks.hdlssc.ssccodegenadvisor.checkSwitchedLinearTask');
    checkSwitchedLinearTask.setCheck('com.mathworks.hdlssc.ssccodegenadvisor.checkSwitchedLinearCheck');
    checkSwitchedLinearTask.CSHParameters.MapKey='ssccga';
    checkSwitchedLinearTask.CSHParameters.TopicID=checkSwitchedLinearTask.ID;
    checkSwitchedLinearTask.MAC='com.mathworks.hdlssc.ssccodegenadvisor.checkSwitchedLinearTask';
    checkSwitchedLinearTask.CustomDialogSchema=@schemaCheckSwitchedLinear;
    checkSwitchedLinearTask.EnableReset=true;
    modelAdvisorRoot.register(checkSwitchedLinearTask);


    codeGenerationCompatibilityProcedure.addTask(checkSolverConfigurationTask);
    codeGenerationCompatibilityProcedure.addTask(checkSwitchedLinearTask);

    modelAdvisorRoot.register(codeGenerationCompatibilityProcedure);


    sscCodeGenAdvisorProcedure.addProcedure(codeGenerationCompatibilityProcedure);
    if strcmpi(hdlfeature('SSCHDLModelOrderReduction'),'on')



        modelOrderReductionProcedure=ModelAdvisor.Procedure('com.mathworks.hdlssc.ssccodegenadvisor.modelOrderReductionProcedure');
        modelOrderReductionProcedure.DisplayName=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_procedures:modelOrderReductionProcedureDisplayName');
        modelOrderReductionProcedure.Description=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_procedures:modelOrderReductionProcedureDescription');
        modelOrderReductionProcedure.CSHParameters.MapKey='ssccga';
        modelOrderReductionProcedure.CSHParameters.TopicID=modelOrderReductionProcedure.ID;


        modelOrderReductionTask=ModelAdvisor.Task('com.mathworks.hdlssc.ssccodegenadvisor.modelOrderReductionTask');
        modelOrderReductionTask.setCheck('com.mathworks.hdlssc.ssccodegenadvisor.modelOrderReductionCheck');
        modelOrderReductionTask.CSHParameters.MapKey='ssccga';
        modelOrderReductionTask.CSHParameters.TopicID=modelOrderReductionTask.ID;
        modelOrderReductionTask.CustomDialogSchema=@schemaModelOrderReduction;
        modelOrderReductionTask.EnableReset=true;
        modelAdvisorRoot.register(modelOrderReductionTask);


        modelOrderReductionProcedure.addTask(modelOrderReductionTask);
        modelAdvisorRoot.register(modelOrderReductionProcedure);


        sscCodeGenAdvisorProcedure.addProcedure(modelOrderReductionProcedure);
    end




    stateSpaceConversionProcedure=ModelAdvisor.Procedure('com.mathworks.hdlssc.ssccodegenadvisor.stateSpaceConversionProcedure');
    stateSpaceConversionProcedure.DisplayName=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_procedures:stateSpaceConversionProcedureDisplayName');
    stateSpaceConversionProcedure.Description=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_procedures:stateSpaceConversionProcedureDescription');
    stateSpaceConversionProcedure.CSHParameters.MapKey='ssccga';
    stateSpaceConversionProcedure.CSHParameters.TopicID=stateSpaceConversionProcedure.ID;


    getStateSpaceParametersTask=ModelAdvisor.Task('com.mathworks.hdlssc.ssccodegenadvisor.getStateSpaceParametersTask');
    getStateSpaceParametersTask.setCheck('com.mathworks.hdlssc.ssccodegenadvisor.getStateSpaceParametersCheck');
    getStateSpaceParametersTask.CSHParameters.MapKey='ssccga';
    getStateSpaceParametersTask.CSHParameters.TopicID=getStateSpaceParametersTask.ID;
    getStateSpaceParametersTask.MAC='com.mathworks.hdlssc.ssccodegenadvisor.getStateSpaceParametersTask';
    getStateSpaceParametersTask.CustomDialogSchema=@schemaExtractEquations;
    getStateSpaceParametersTask.EnableReset=true;
    modelAdvisorRoot.register(getStateSpaceParametersTask);

    discretizeTask=ModelAdvisor.Task('com.mathworks.hdlssc.ssccodegenadvisor.discretizeTask');
    discretizeTask.setCheck('com.mathworks.hdlssc.ssccodegenadvisor.discretizeCheck');
    discretizeTask.CSHParameters.MapKey='ssccga';
    discretizeTask.CSHParameters.TopicID=discretizeTask.ID;
    discretizeTask.EnableReset=true;
    discretizeTask.MAC='com.mathworks.hdlssc.ssccodegenadvisor.discretizeTask';
    discretizeTask.CustomDialogSchema=@schemaDiscretizeEquations;
    modelAdvisorRoot.register(discretizeTask);


    stateSpaceConversionProcedure.addTask(getStateSpaceParametersTask);
    stateSpaceConversionProcedure.addTask(discretizeTask);
    modelAdvisorRoot.register(stateSpaceConversionProcedure);


    sscCodeGenAdvisorProcedure.addProcedure(stateSpaceConversionProcedure);


    implementationModelGenerationProcedure=ModelAdvisor.Procedure('com.mathworks.hdlssc.ssccodegenadvisor.implementationModelGenerationProcedure');
    implementationModelGenerationProcedure.DisplayName=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_procedures:implementationModelGenerationProcedureDisplayName');
    implementationModelGenerationProcedure.Description=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_procedures:implementationModelGenerationProcedureDescription');
    implementationModelGenerationProcedure.CSHParameters.MapKey='ssccga';
    implementationModelGenerationProcedure.CSHParameters.TopicID=implementationModelGenerationProcedure.ID;


    generateImplementationModelTask=ModelAdvisor.Task('com.mathworks.hdlssc.ssccodegenadvisor.generateImplementationModelTask');
    generateImplementationModelTask.setCheck('com.mathworks.hdlssc.ssccodegenadvisor.generateImplementationModelCheck');
    generateImplementationModelTask.CSHParameters.MapKey='ssccga';
    generateImplementationModelTask.MAC='com.mathworks.hdlssc.ssccodegenadvisor.generateImplementationModelTask';
    generateImplementationModelTask.CSHParameters.TopicID=generateImplementationModelTask.ID;
    generateImplementationModelTask.CustomDialogSchema=@schemaGenerateImplementationModel;
    generateImplementationModelTask.EnableReset=true;
    modelAdvisorRoot.register(generateImplementationModelTask);


    implementationModelGenerationProcedure.addTask(generateImplementationModelTask);
    modelAdvisorRoot.register(implementationModelGenerationProcedure);


    sscCodeGenAdvisorProcedure.addProcedure(implementationModelGenerationProcedure);



    modelAdvisorRoot.register(sscCodeGenAdvisorProcedure);


