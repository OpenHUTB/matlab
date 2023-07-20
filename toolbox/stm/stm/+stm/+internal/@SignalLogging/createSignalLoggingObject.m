function createSignalLoggingObject(modelName,harnessName,ownerName,signalSetId)



    openModel(modelName,harnessName,ownerName);
    obj=stm.internal.SignalLogging(modelName,harnessName,signalSetId);
    obj.activate();
end

function openModel(modelName,harness,ownerName)

    open_system(modelName);


    if~isempty(harness)
        sltest.harness.open(ownerName,harness);
    end
end

