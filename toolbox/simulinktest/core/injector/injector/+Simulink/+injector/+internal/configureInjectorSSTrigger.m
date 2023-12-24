function configureInjectorSSTrigger(injSSHdl,trigOn,trigOff,trigData)

    hierElems=[];
    if strcmp(trigOn.TriggerType,'Signal')
        hierElemOn=struct('Type',trigOn.TriggerParams{1},'BlockNodeStr',trigOn.TriggerParams{2},'Spec',trigOn.TriggerParams{3});
        hierElems=[hierElems;hierElemOn];
        trigOn.TriggerParams=[{num2str(numel(hierElems)-1)};trigOn.TriggerParams(4:end)];
    end
    if strcmp(trigOff.TriggerType,'Signal')
        hierElemOff=struct('Type',trigOff.TriggerParams{1},'BlockNodeStr',trigOff.TriggerParams{2},'Spec',trigOff.TriggerParams{3});
        hierElems=[hierElems;hierElemOff];
        trigOff.TriggerParams=[{num2str(numel(hierElems)-1)};trigOff.TriggerParams(4:end)];
    end

    injTrigObj=struct('HierElements',hierElems,'TriggerOn',trigOn,'TriggerOff',trigOff,'TriggerData',trigData);
    Simulink.injector.internal.configureInjectorSSTriggerInternal(injSSHdl,injTrigObj);

end

