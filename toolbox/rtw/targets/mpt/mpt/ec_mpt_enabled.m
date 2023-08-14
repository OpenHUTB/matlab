function status=ec_mpt_enabled(modelName)

























    isERTTarget=strcmp(get_param(modelName,'IsERTTarget'),'on');

    isModelRefSim=strcmp(get_param(modelName,'ModelReferenceTargetType'),'SIM');
    isDirectEmit=(slfeature('DirectEmitSubsystemFiles')>0);
    status=isERTTarget&&~isModelRefSim&&~isDirectEmit;

end

