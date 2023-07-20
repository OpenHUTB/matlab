function addCleanupListenerForAccelSim(toDelete)



    fDeleter=Simulink.ModelReference.ProtectedModel.FileDeleter.Instance();
    fDeleter.addFileToDelete(toDelete);
end

