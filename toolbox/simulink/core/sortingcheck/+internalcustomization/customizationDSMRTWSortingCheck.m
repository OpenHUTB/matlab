function customizationDSMRTWSortingCheck()



    if(slsvTestingHook('TaskBasedSorting_AdvisorCheck'))
        cm=DAStudio.CustomizationManager;
        cm.addModelAdvisorCheckFcn(@defineModelAdvisorChecks);
    end




end

function defineModelAdvisorChecks

    mdladvRoot=ModelAdvisor.Root;


    rec=defineDataStoreSimRtwCmp();
    mdladvRoot.publish(rec,'Simulink Coder');

end
