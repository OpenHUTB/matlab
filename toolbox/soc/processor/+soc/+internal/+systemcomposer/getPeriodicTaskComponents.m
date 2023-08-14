function taskComponents=getPeriodicTaskComponents(modelName)




    mustBeTextScalar(modelName);

    taskStereotype="soc_blockset_profile.PeriodicSoftwareTask";
    fcnModelArch=systemcomposer.openModel(modelName);
    [~,taskComponents]=fcnModelArch.find(...
    systemcomposer.query.HasStereotype(...
    systemcomposer.query.IsStereotypeDerivedFrom(taskStereotype)));
end
