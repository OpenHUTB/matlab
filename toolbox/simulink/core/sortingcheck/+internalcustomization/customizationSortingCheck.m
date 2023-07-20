function customizationSortingCheck()



    if(slsvTestingHook('TaskBasedSorting_AdvisorCheck'))
        cm=DAStudio.CustomizationManager;
        cm.addModelAdvisorCheckFcn(@defineModelAdvisorChecks);
    end




end

function defineModelAdvisorChecks

    mdladvRoot=ModelAdvisor.Root;


    rec=defineDataStoreCheck();
    mdladvRoot.register(rec,'Simulink');

end
