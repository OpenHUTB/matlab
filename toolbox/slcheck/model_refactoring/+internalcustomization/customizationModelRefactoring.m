function customizationModelRefactoring()











    cm=DAStudio.CustomizationManager;

    h1=DAServiceManager.OnDemandService;
    h1.Start('sl_m2m_edittime');

    cm.addModelAdvisorCheckFcn(@defineModelRefactoringChecks);
    if slfeature('LibraryPatternDetectionEditTimeCheck')==1
        h1.Start('sl_cloneDetection_edittime');
        cm.addModelAdvisorCheckFcn(@registerLibEdittimeCheck);
    end
    cm.addModelAdvisorTaskFcn(@defineModelRefactoringTasks);
end


