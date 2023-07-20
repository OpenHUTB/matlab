function refreshHarnessToolstrip(systemModel)


    if(slfeature('MultipleHarnessOpen')>0)
        harnessList=Simulink.harness.internal.getHarnessList(systemModel,'loaded');

    else
        harnessList=Simulink.harness.internal.getHarnessList(systemModel,'active');
    end
    for i=1:length(harnessList)
        harnessName=harnessList(i).name;
        mgr=Simulink.harness.internal.toolstrip.TestHarnessContextManager.getContext(get_param(harnessName,'handle'));
        mgr.refresh;
    end
end