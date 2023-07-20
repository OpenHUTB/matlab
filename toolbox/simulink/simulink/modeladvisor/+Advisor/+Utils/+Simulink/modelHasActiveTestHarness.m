





function[hasActiveTestHarness,activeTestHarness]=modelHasActiveTestHarness(modelName)

    hasActiveTestHarness=false;
    activeTestHarness=[];


    if~Simulink.harness.isHarnessBD(modelName)&&...
        Simulink.harness.internal.hasActiveHarness(modelName)&&...
        strcmpi(get_param(modelName,'Lock'),'on')
        activeTestHarness=Simulink.harness.internal.getHarnessList(modelName,'active');
        hasActiveTestHarness=true;
    end
end