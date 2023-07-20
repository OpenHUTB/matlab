function taskComponents=getTaskComponents(modelName)




    mustBeTextScalar(modelName);

    taskStereotype="soc_blockset_profile.SoftwareTask";
    fcnModelArch=systemcomposer.openModel(modelName);
    [~,taskComponents]=fcnModelArch.find(...
    systemcomposer.query.HasStereotype(...
    systemcomposer.query.IsStereotypeDerivedFrom(taskStereotype)));
end
