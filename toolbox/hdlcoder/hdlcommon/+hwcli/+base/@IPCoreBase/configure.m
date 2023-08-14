function configure(obj,hDI)





    configure@hwcli.base.WorkflowBase(obj,hDI);


    if~isempty(obj.ReferenceDesignToolVersion)
        hDI.hIP.setRDToolVersion(obj.ReferenceDesignToolVersion);
    end
    hDI.hIP.setIgnoreRDToolVersionMismatch(obj.IgnoreToolVersionMismatch);


    if(obj.RunTaskGenerateRTLCodeAndIPCore)
        hDI.hIP.setIPCoreReportStatus(obj.GenerateIPCoreReport);
        hDI.hIP.setIPRepository(obj.IPCoreRepository);
        hDI.hIP.setIPTestbench(obj.GenerateIPCoreTestbench);
        hDI.hIP.setIPTopCustomFile(obj.CustomIPTopHDLFile);
    end

    if(obj.RunTaskCreateProject)
        hDI.hIP.setUseIPCache(obj.EnableIPCaching);
    end

    if(obj.RunTaskBuildFPGABitstream)
        hDI.hIP.setEmbeddedExternalBuild(obj.RunExternalBuild);
        hDI.setMaxNumOfCores(obj.MaxNumOfCoresForBuild);
        hDI.hIP.setReportTimingFailure(obj.ReportTimingFailure);
        hDI.hIP.setReportTimingFailureTolerance(obj.ReportTimingFailureTolerance);

        if(obj.TclFileForSynthesisBuild==hdlcoder.BuildOption.Custom)
            hDI.setTclFileForSynthesisBuild('Custom');
            hDI.setCustomBuildTclFile(obj.CustomBuildTclFile);
        else
            hDI.setTclFileForSynthesisBuild('Default');
        end

        if(islogical(obj.EnableDesignCheckpoint)&&(obj.EnableDesignCheckpoint)&&strcmp(obj.DefaultCheckpointFile,'Custom'))
            hDI.setEnableDesignCheckpoint(obj.EnableDesignCheckpoint);
            hDI.setDefaultCheckpointFile('Custom');
            hDI.setRoutedDesignCheckpointFilePath(obj.RoutedDesignCheckpointFilePath);
        else
            hDI.setEnableDesignCheckpoint(obj.EnableDesignCheckpoint);
            hDI.setRoutedDesignCheckpointFilePath(obj.RoutedDesignCheckpointFilePath);
            hDI.setDefaultCheckpointFile('Default');
        end
    end


end