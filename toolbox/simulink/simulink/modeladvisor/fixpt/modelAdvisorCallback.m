function recordCellArray=modelAdvisorCallback()



    recordCellArray={};


    currentRecord=ModelAdvisor.Check('mathworks.codegen.QuestionableFxptOperations');
    currentRecord.Title=DAStudio.message('Simulink:tools:MATitleIdentQuestFixptOper');
    currentRecord.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentQuestFixptOper');
    currentRecord.setCallbackFcn(@execCheckQuestionableFixedPoint,'None','StyleOne');
    currentRecord.CallbackContext='CGIR';
    currentRecord.setInputParametersLayoutGrid([1,1]);
    currentRecord.LicenseName={'RTW_Embedded_Coder','Fixed_Point_Toolbox'};
    currentRecord.Value=false;
    currentRecord.CSHParameters.MapKey='ma.ecoder';
    currentRecord.CSHParameters.TopicID='MATitleIdentQuestFixptOper';
    currentRecord.SupportExclusion=true;

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(currentRecord,'Embedded Coder');


    currentRecord=ModelAdvisor.Check('mathworks.codegen.BlockSpecificQuestionableFxptOperations');
    currentRecord.Title=DAStudio.message('Simulink:tools:MATitleIdentBlocksQuestFixptOper');
    currentRecord.TitleTips=DAStudio.message('Simulink:tools:MATitleTipIdentBlocksQuestFixptOper');
    currentRecord.setCallbackFcn(@execCheckBlockSpecificQuestionableFixedPoint,'None','StyleOne');
    currentRecord.CallbackContext='PostCompile';
    currentRecord.setInputParametersLayoutGrid([1,1]);
    currentRecord.LicenseName={'RTW_Embedded_Coder','Fixed_Point_Toolbox'};
    currentRecord.Value=false;
    currentRecord.CSHParameters.MapKey='ma.ecoder';
    currentRecord.CSHParameters.TopicID='MATitleIdentBlkQuestFixptOperSaturation';
    currentRecord.SupportExclusion=true;

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(currentRecord,'Embedded Coder');



    currentRecord=ModelAdvisor.Check('mathworks.codegen.ExpensiveSaturationRoundingCode');
    currentRecord.Title=DAStudio.message('Simulink:tools:MATitleIdentExpensiveBlocks');
    currentRecord.TitleTips=DAStudio.message('Simulink:tools:MATitletipIdentExpensiveBlocks');
    currentRecord.setCallbackFcn(@execCheckExpensiveBlock,'None','StyleOne');
    currentRecord.CallbackContext='CGIR';
    currentRecord.setInputParametersLayoutGrid([1,1]);
    currentRecord.LicenseName={'RTW_Embedded_Coder','Fixed_Point_Toolbox'};
    currentRecord.Value=false;
    currentRecord.CSHParameters.MapKey='ma.ecoder';
    currentRecord.CSHParameters.TopicID='MATitleIdentExpensiveBlocks';
    currentRecord.SupportExclusion=true;

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(currentRecord,'Embedded Coder');


    currentRecord=ModelAdvisor.Check('mathworks.design.StowawayDoubles');
    currentRecord.Title=DAStudio.message('ModelAdvisor:engine:MATitleStowawayDoubles');
    currentRecord.TitleTips=DAStudio.message('ModelAdvisor:engine:CheckStowawayDoubleTips');
    currentRecord.setCallbackFcn(@execCheckStowawayDoubles,'None','StyleOne');
    currentRecord.CallbackContext='CGIR';
    currentRecord.CSHParameters.MapKey='ma.simulink';
    currentRecord.CSHParameters.TopicID='MATitleStowawayDoubles';
    currentRecord.setInputParametersLayoutGrid([1,1]);
    currentRecord.LicenseName={};
    currentRecord.Visible=true;
    currentRecord.Enable=true;
    currentRecord.Value=false;
    currentRecord.SupportExclusion=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(currentRecord,'Simulink');




end

