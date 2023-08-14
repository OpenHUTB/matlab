function deactivateAndloadHarness(owner,harnessName,systemModel)








    try
        stm.internal.util.loadHarness(owner,harnessName);
    catch me
        if isequal(me.identifier,'Simulink:Harness:AnotherHarnessAlreadyActivated')||...
            isequal(me.identifier,'Simulink:Harness:CannotUpdateWhenATestingHarnessIsActive')
            activeHarness=Simulink.harness.internal.getActiveHarness(systemModel);
            if~isempty(activeHarness)

                if strcmp(get_param(activeHarness.name,'FastRestart'),'on')&&string(activeHarness.name)~=string(harnessName)
                    set_param(activeHarness.name,'FastRestart','off');
                end
                close_system(activeHarness.name,0);
                stm.internal.util.loadHarness(owner,harnessName);
            end
        else
            rethrow(me);
        end
    end
end
