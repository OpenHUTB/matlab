function status=createRestorePoint(model,forceSave)





    if nargin<2
        forceSave=false;
    end

    status=DataTypeWorkflow.RestorePointStatus;

    if forceSave
        createOutput=restorepoint.internal.create(model,'forcesave',true);
    else
        createOutput=restorepoint.internal.create(model);
    end
    status.Status=createOutput.Status;
    status.MissingFiles=createOutput.MissingFiles;
    status.DirtyFiles=createOutput.DirtyFiles;

end


