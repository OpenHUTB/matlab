function job=buildGenericJob(obj,variant,executionMode)







    obj.ensureLicenseNumberIsSetOrError();


    isBatch=executionMode==parallel.internal.types.ExecutionMode.Batch;
    entitlement=obj.LicenseEntitlement;
    batchPermission=parallel.internal.licensing.Permission.ClusterBatchMode;
    isBatchPermitted=entitlement.HasPermissions(batchPermission);

    isInteractive=executionMode==parallel.internal.types.ExecutionMode.Interactive;
    isInteractivePermitted=true;

    if(isBatch&&isBatchPermitted)||(isInteractive&&isInteractivePermitted)
        try
            job=obj.CloudSupport.buildJob(obj,variant,obj.LicenseEntitlement);
        catch E
            throwAsCaller(distcomp.handleJavaException(obj,E));
        end
    else
        if isBatch
            error(message('parallel:cloud:CreateBatchModeNotPermitted'));
        else
            assert(false,'Interactive jobs should always be permitted');
        end
    end
end
