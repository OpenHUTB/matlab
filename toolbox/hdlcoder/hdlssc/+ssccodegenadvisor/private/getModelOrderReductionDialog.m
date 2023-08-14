function tbTab=getModelOrderReductionDialog(mdladvObj)












    sscCodeGenWorkflowObjCheck=mdladvObj.getCheckObj('com.mathworks.hdlssc.ssccodegenadvisor.workflowObjectCheck');
    sscCodeGenWorkflowObj=sscCodeGenWorkflowObjCheck.ResultData;



    description.Type='text';
    description.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:modelOrderReductionCheckTitleTips');
    description.RowSpan=[1,1];
    descriptionSection.Type='panel';
    descriptionSection.Items={description};
    descriptionSection.LayoutGrid=[1,4];
    descriptionSection.RowSpan=[1,1];
    descriptionSection.ColSpan=[1,4];
    descriptionSection.Enabled=true;



    generateValidationLogic.Type='checkbox';
    generateValidationLogic.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:generateImplementationModelCheckGenerateValidationName');



    generateValidationLogic.Value=sscCodeGenWorkflowObj.modelOrderReductionValLogic;

    generateValidationLogic.Tag='com.mathworks.hdlssc.ssccodegenadvisor.ModelOrderReductionValLogicTag';
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
    validationTolerance.Tag='com.mathworks.hdlssc.ssccodegenadvisor.ModelOrderReductionValTolTag';
    validationTolerance.RowSpan=[1,1];
    validationTolerance.ColSpan=[6,6];


    validationTolerance.Value=sscCodeGenWorkflowObj.modelOrderReductionValTol;

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


    tbTab.Items={descriptionSection,verificationSettingsSection};
    tbTab.LayoutGrid=[3,6];
    tbTab.RowStretch=[0,0,1];
    tbTab.ColStretch=[0,0,0,0,0,1];









    tbTab.Name=DAStudio.message('hdlcoder:hdlssc:ssccodegenadvisor_checks:modelOrderReductionCheckLinearization');


