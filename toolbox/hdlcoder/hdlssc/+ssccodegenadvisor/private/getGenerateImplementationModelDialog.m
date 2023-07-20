function tbTab=getGenerateImplementationModelDialog(mdladvObj)













    sscCodeGenWorkflowObjCheck=mdladvObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;




    solverMethod_lbl.Type='text';
    solverMethod_lbl.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckSolverName');
    solverMethod_lbl.RowSpan=[1,1];
    solverMethod_lbl.ColSpan=[1,1];

    solverMethod.Type='text';
    solverMethod.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckSolverEntries');
    solverMethod.Tag='com.mathworks.hdlssc.ssccodegenadvisor.solverMethodTag';
    solverMethod.Enabled=true;
    solverMethod.RowSpan=[1,1];
    solverMethod.ColSpan=[2,2];

    numSolverIterations_lbl.Type='text';
    numSolverIterations_lbl.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckIterationsName');
    numSolverIterations_lbl.RowSpan=[1,1];
    numSolverIterations_lbl.ColSpan=[4,4];

    numSolverIterations.Type='edit';
    numSolverIterations.Tag='com.mathworks.hdlssc.ssccodegenadvisor.numSolverIterationsTag';
    [numberOfSolverIterations,editable]=utilUpdateSolverIterations(sscCodeGenWorkflowObj);
    numSolverIterations.Value=numberOfSolverIterations;


    numSolverIterations.Enabled=editable;
    numSolverIterations.RowSpan=[1,1];
    numSolverIterations.ColSpan=[5,5];
    numSolverIterations.DialogRefresh=true;

    numSolverIterations.MatlabMethod='ssccodegenadvisor.dialogParameterCallback';
    numSolverIterations.MatlabArgs={mdladvObj,'%dialog','%value','%tag'};


    hyperlinkWhatIsThis.Type='hyperlink';
    hyperlinkWhatIsThis.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelChangeThis');
    hyperlinkWhatIsThis.Tag='com.mathworks.hdlssc.ssccodegenadvisor.numberOfSolverIteration';
    hyperlinkWhatIsThis.Enabled=true;
    hyperlinkWhatIsThis.RowSpan=[1,1];
    hyperlinkWhatIsThis.ColSpan=[6,6];
    hyperlinkWhatIsThis.MatlabMethod='ssccodegenadvisor.dialogHyperlinkCallback';
    hyperlinkWhatIsThis.MatlabArgs={'%tag'};




    solverSettingsSection.Type='group';
    solverSettingsSection.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelSolverSettings');
    solverSettingsSection.Items=[{solverMethod_lbl},...
    {solverMethod},...
    {numSolverIterations_lbl},...
    {numSolverIterations},...
    {hyperlinkWhatIsThis}];
    solverSettingsSection.LayoutGrid=[1,6];
    solverSettingsSection.ColStretch=[0,1,2,0,0,0];
    solverSettingsSection.RowSpan=[1,1];
    solverSettingsSection.ColSpan=[1,6];
    solverSettingsSection.Enabled=true;



    precision.Type='radiobutton';
    precision.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckHDLDataTypeName');
    precision.Tag='com.mathworks.hdlssc.ssccodegenadvisor.precisionTag';
    precision.Entries={'Single',...
    'Double',...
    'Single coefficient, double computation'};


    precision.Value=sscCodeGenWorkflowObj.precisionVal;
    precision.RowSpan=[2,4];
    precision.ColSpan=[1,1];
    precision.Enabled=true;
    precision.MatlabMethod='ssccodegenadvisor.dialogParameterCallback';
    precision.MatlabArgs={mdladvObj,'%dialog','%value','%tag'};
    precision.DialogRefresh=true;

    useRAM.Type='combobox';
    useRAM.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckRamMapName');
    useRAM.Tag='com.mathworks.hdlssc.ssccodegenadvisor.ramMapTag';
    useRAM.Entries={'Auto','On','Off'};


    switch sscCodeGenWorkflowObj.UseRAM
    case 'Auto'
        useRAM.Value=0;
    case 'On'
        useRAM.Value=1;
    case 'Off'
        useRAM.Value=2;
    end

    useRAM.RowSpan=[2,6];
    useRAM.ColSpan=[4,4];
    useRAM.Enabled=true;

    useRAM.MatlabMethod='ssccodegenadvisor.dialogParameterCallback';

    useRAM.MatlabArgs={mdladvObj,'%dialog','%value','%tag'};

    hyperlinkWhatIsThisRamMap.Type='hyperlink';
    hyperlinkWhatIsThisRamMap.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelRamMapOverview');
    hyperlinkWhatIsThisRamMap.Tag='com.mathworks.hdlssc.ssccodegenadvisor.ramMapOverview';
    hyperlinkWhatIsThisRamMap.Enabled=true;
    hyperlinkWhatIsThisRamMap.RowSpan=[2,6];
    hyperlinkWhatIsThisRamMap.ColSpan=[7,7];
    hyperlinkWhatIsThisRamMap.MatlabMethod='ssccodegenadvisor.dialogHyperlinkCallback';
    hyperlinkWhatIsThisRamMap.MatlabArgs={'%tag'};

    hyperlinkWhatIsThis.Type='hyperlink';
    hyperlinkWhatIsThis.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:whatsThis');
    hyperlinkWhatIsThis.Tag='com.mathworks.hdlssc.ssccodegenadvisor.mixedDoubleSingle';
    hyperlinkWhatIsThis.Enabled=true;
    hyperlinkWhatIsThis.RowSpan=[4,4];
    hyperlinkWhatIsThis.ColSpan=[2,2];
    hyperlinkWhatIsThis.MatlabMethod='ssccodegenadvisor.dialogHyperlinkCallback';
    hyperlinkWhatIsThis.MatlabArgs={'%tag'};

    implementationModelSettingsSection.Type='group';
    implementationModelSettingsSection.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelModelSettings');
    implementationModelSettingsSection.Items=[{precision},{hyperlinkWhatIsThis},{useRAM},{hyperlinkWhatIsThisRamMap}];
    implementationModelSettingsSection.LayoutGrid=[5,3];
    implementationModelSettingsSection.RowStretch=[0,0,0,0,1];
    implementationModelSettingsSection.ColStretch=[0,0,1];
    implementationModelSettingsSection.RowSpan=[2,2];
    implementationModelSettingsSection.ColSpan=[1,6];
    implementationModelSettingsSection.Enabled=true;



    generateValidationLogic.Type='checkbox';
    generateValidationLogic.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckGenerateValidationName');


    generateValidationLogic.Value=sscCodeGenWorkflowObj.GenerateValidation;

    generateValidationLogic.Tag='com.mathworks.hdlssc.ssccodegenadvisor.generateValidationLogicTag';
    generateValidationLogic.RowSpan=[1,1];
    generateValidationLogic.ColSpan=[1,1];

    validationEmptySpace.Type='text';
    validationEmptySpace.Name='   ';
    validationEmptySpace.RowSpan=[1,1];

    validationTolerance_lbl.Type='text';
    validationTolerance_lbl.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckValidationToleranceName');
    validationTolerance_lbl.RowSpan=[1,1];
    validationTolerance_lbl.ColSpan=[5,5];

    validationTolerance.Type='edit';
    validationTolerance.Tag='com.mathworks.hdlssc.ssccodegenadvisor.validationToleranceTag';
    validationTolerance.RowSpan=[1,1];
    validationTolerance.ColSpan=[6,6];

    validationTolerance.Value=sscCodeGenWorkflowObj.ValidationTolerance;

    validationTolerance.Enabled=generateValidationLogic.Value;
    validationTolerance.MatlabMethod='ssccodegenadvisor.dialogParameterCallback';
    validationTolerance.MatlabArgs={mdladvObj,'%dialog','%value','%tag'};





    generateValidationLogic.MatlabMethod='ssccodegenadvisor.dialogParameterCallback';
    generateValidationLogic.MatlabArgs={mdladvObj,'%dialog','%value','%tag',validationTolerance.Tag};

    verificationSettingsSection.Type='group';
    verificationSettingsSection.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelVerificationSettings');
    verificationSettingsSection.Items=[{generateValidationLogic},{validationEmptySpace},{validationTolerance_lbl},{validationTolerance}];
    verificationSettingsSection.LayoutGrid=[1,6];
    verificationSettingsSection.ColStretch=[0,1,1,1,0,0];
    verificationSettingsSection.RowSpan=[3,3];
    verificationSettingsSection.ColSpan=[1,6];
    verificationSettingsSection.Enabled=true;


    tbTab.Items={solverSettingsSection,implementationModelSettingsSection,verificationSettingsSection};
    tbTab.LayoutGrid=[3,6];
    tbTab.RowStretch=[0,0,1];
    tbTab.ColStretch=[0,0,0,0,0,1];

    tbTab.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckTitle');


