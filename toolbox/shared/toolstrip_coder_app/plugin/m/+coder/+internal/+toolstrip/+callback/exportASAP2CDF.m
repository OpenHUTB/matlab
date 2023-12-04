function exportASAP2CDF(cbinfo,~)

    model=cbinfo.model.Handle;
    modelName=get_param(model,'name');

    persistent appASAP2GENAppInstanceMap;

    if isempty(appASAP2GENAppInstanceMap)

        appASAP2GENAppInstanceMap=containers.Map;
    end

    if appASAP2GENAppInstanceMap.isKey(modelName)

        instance=appASAP2GENAppInstanceMap(modelName);
        if isvalid(instance)
            figure(instance.Asap2AndCdfGenerator);
            return;
        else
            appASAP2GENAppInstanceMap.remove(modelName);
        end
    end
    instance=Simulink.ExportASAP2CDF.launchAsap2CdfApp(modelName);
    appASAP2GENAppInstanceMap(modelName)=instance;

    mlock;
end
