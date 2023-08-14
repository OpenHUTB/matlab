function[ResultDescription,ResultDetails]=runFILBuild(system)


    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckErrorSeverity(1);

    ResultDescription={};
    ResultDetails={};

    [hdriver,params]=hdlcoderargs(system);
    hdriver.updateCmdLineHDLSubsystem(hdriver.OrigStartNodeName);

    state=hdriver.initMakehdl(hdriver.ModelName());
    oldDriver=state.oldDriver;
    oldMode=state.oldMode;
    oldAutosaveState=state.oldAutosaveState;



    if(hdriver.isIndustryStandardMode())
        hdriver.updateIndustryStandardParams(hdriver.ModelName());
    end

    try
        hDI=hdriver.DownstreamIntegrationDriver;
        hDI.hFilBuildInfo.setOutputFolder(hDI.getFullFILDir);


        newFilBuildInfo=eda.internal.workflow.FILBuildInfo;
        newFilBuildInfo.Board=hDI.hFilBuildInfo.Board;
        newFilBuildInfo.BoardObj=hDI.hFilBuildInfo.BoardObj;
        newFilBuildInfo.IPAddress=hDI.hFilBuildInfo.IPAddress;
        newFilBuildInfo.MACAddress=hDI.hFilBuildInfo.MACAddress;
        newFilBuildInfo.FPGASystemClockFrequency=hDI.hFilBuildInfo.FPGASystemClockFrequency;
        newFilBuildInfo.EnableHWBuffer=hDI.hFilBuildInfo.EnableHWBuffer;

        for ii=1:numel(hDI.hFilBuildInfo.SourceFiles.FilePath)
            newFilBuildInfo.addSourceFile(...
            hDI.hFilBuildInfo.SourceFiles.FilePath{ii},...
            hDI.hFilBuildInfo.SourceFiles.FileType{ii});
        end
        newFilBuildInfo.setOutputFolder(hDI.hFilBuildInfo.OutputFolder);

        if~hdriver.isCodeGenSuccessful
            hdriver.makehdl(params);
        end

        hdriver.connectToModel;
        hdriver.closeConnection;

        hPir=hdriver.PirInstance;
        cosimSetup='CosimBlockAndDut';
        gc=cosimtb.genfiltb(cosimSetup,hdriver,hPir,newFilBuildInfo);%#ok<NASGU>

        if isempty(hDI.hFilWizardDlg.buildOptions)
            logTxt=evalc('gc.doIt');
        else
            logTxt=evalc('gc.doIt(hDI.hFilWizardDlg.buildOptions{:})');
        end

        hdriver.baseCleanup(oldDriver,oldMode,oldAutosaveState);

    catch ME
        hdriver.baseCleanup(oldDriver,oldMode,oldAutosaveState);
        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message);
        return;
    end


    [ResultDescription,ResultDetails]=utilDisplayResult(logTxt,...
    ResultDescription,ResultDetails);


    mdladvObj.setCheckResultStatus(true);
end


