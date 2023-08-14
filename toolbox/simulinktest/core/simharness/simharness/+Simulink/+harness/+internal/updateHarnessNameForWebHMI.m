function updateHarnessNameForWebHMI(modelHandle,newModelName)

    webhmi=Simulink.HMI.WebHMI.getWebHMI(modelHandle);
    if~isempty(webhmi)
        webhmi.renameModel(modelHandle,newModelName);
    end


    insts=get_param(modelHandle,'InstrumentedSignals');
    if~isempty(insts)
        set_param(modelHandle,'InstrumentedSignals',insts);
    end
