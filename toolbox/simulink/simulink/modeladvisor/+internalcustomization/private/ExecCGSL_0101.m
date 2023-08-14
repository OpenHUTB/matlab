





function[ResultDescription]=ExecCGSL_0101(system)

    ResultDescription={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);








    mpsB=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','MultiPortSwitch');




    assB=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Assignment');
    selB=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Selector');
    iteB=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ForIterator');
    indB=[assB;selB;iteB];


    indexTypeOne=get_param(mpsB,'DataPortOrder');
    indexTypeTwo=get_param(indB,'IndexMode');



    allIndex=[indexTypeOne;indexTypeTwo];
    allBlocks=[mpsB;indB];


    failedBlocks=allBlocks(strncmp(allIndex,'Zero-based',10)==0);

    ft1=ModelAdvisor.FormatTemplate('ListTemplate');


    failedBlocks=mdladvObj.filterResultWithExclusion(failedBlocks);

    ft1.setInformation(DAStudio.message('ModelAdvisor:engine:cgsl_0101_Info'));
    if(isempty(failedBlocks))

        ft1.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:cgsl_0101_Pass'));
        ft1.setSubResultStatus('pass');
        allPass=1;
    else

        ft1.setListObj(failedBlocks);
        ft1.setSubResultStatus('warn');
        ft1.setRecAction(DAStudio.message('ModelAdvisor:engine:cgsl_0101_RecAct_1'))
        ft1.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:cgsl_0101_Fail'));
        allPass=0;
    end
    ResultDescription{end+1}=ft1;


















































    if allPass
        mdladvObj.setCheckResultStatus(true);
    end
