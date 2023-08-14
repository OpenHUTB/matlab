function tr=reset





    coder.targetreg.internal.TargetRegistry.resetTargetRegistryOnly;




    tr=targetrepository.create();
    tr.restore(targetframework.internal.repository.datasource.Definitions.TargetRepositoryLegacy);
