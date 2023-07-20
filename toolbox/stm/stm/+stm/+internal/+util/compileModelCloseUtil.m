
function[modelCloseUtil,modelCompile]=compileModelCloseUtil(model,harness)
    modelCloseUtil=Simulink.SimulationData.ModelCloseUtil;
    modelToUse=stm.internal.util.resolveHarness(model,harness);
    modelCompile=onCleanup(@()termModel(modelToUse));
    feval(modelToUse,[],[],[],'compile');
end

function modelCompile=termModel(modelToUse)
    try
        modelCompile=feval(modelToUse,[],[],[],'term');
    catch
    end
end
