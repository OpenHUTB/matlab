function taskComponents=getAperiodicTaskComponents(modelName)




    mustBeTextScalar(modelName);

    taskStereotype="soc_blockset_profile.AperiodicSoftwareTask";
    fcnModelArch=systemcomposer.openModel(modelName);
    [~,taskComponents]=fcnModelArch.find(...
    systemcomposer.query.HasStereotype(...
    systemcomposer.query.IsStereotypeDerivedFrom(taskStereotype)));
end