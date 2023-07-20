function success=ResaveSoftwareArchitecture(model)




    save_system(model,'','SaveDirtyReferencedModels',true);
    success=getString(...
    message('SoftwareArchitecture:Engine:ResaveSoftwareArchitectureSuccess',model));
end
