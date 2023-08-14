function closeCallback(this)


    if this.CleanupAfterShow&&~slsvTestingHook('ProtectedModelCleanupTest')
        try
            dirToClean=Simulink.ModelReference.ProtectedModel.getReportRootDirectoryFromBuildDir(this.BuildDir);
            rmdir(dirToClean,'s');
        catch
        end
    end

end