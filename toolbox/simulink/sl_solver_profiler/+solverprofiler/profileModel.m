function varargout=profileModel(mdl,varargin)














































    import solverprofiler.internal.SolverProfilerDataClass;
    import solverprofiler.internal.SolverProfilerSessionDataManager
    import solverprofiler.internal.ModelConfigClass;
    import solverprofiler.internal.SolverProfilerCommandLineOptionsManager;
    import solverprofiler.util.*



    if nargout>1
        id='Simulink:solverProfiler:TooManyOutputArguments';
        msg=utilDAGetString('TooManyOutputArguments');
        throw(MException(id,msg));
    end


    mdl=convertStringsToChars(mdl);
    options=cellfun(@convertStringsToChars,varargin,'UniformOutput',false);


    try
        load_system(mdl);
    catch exception
        id='Simulink:solverProfiler:UnableToLoadModel';
        msg=utilDAGetString('UnableToLoadModel',mdl,exception.message);
        throw(MException(id,msg));
    end



    if(strcmp(get_param(mdl,'EnableSteadyStateSolver'),'on'))
        id='Simulink:solverProfiler:DoesNotSupportSteadyState';
        msg=utilDAGetString('DoesNotSupportSteadyState');
        throw(MException(id,msg));
    end


    try
        optMgr=SolverProfilerCommandLineOptionsManager(mdl);
        optMgr.setOptions(options);
    catch exception
        throw(exception);
    end


    mdlConfig=ModelConfigClass(mdl);

    if optMgr.SaveStatesOn()
        mdlConfig.enableStateLogging();
    else
        mdlConfig.disableStateLogging();
    end

    if optMgr.SaveZCSignalsOn()
        mdlConfig.enableZCLogging();
    else
        mdlConfig.disableZCLogging();
    end

    if optMgr.SaveSimscapeStatesOn()
        mdlConfig.enableSimscapeStateLogging();
    else
        mdlConfig.disableSimscapeStateLogging();
    end

    if optMgr.SaveJacobianOn()
        mdlConfig.enableJacobianLogging();
    else
        mdlConfig.disableJacobianLogging();
    end

    mdlConfig.setFromTime(optMgr.getStartTime());
    mdlConfig.setToTime(optMgr.getStopTime());
    mdlConfig.setPDLength(optMgr.getBufferSize());

    mdlConfig.configForProfiler();

    try
        spidata=sim(mdl,'TimeOut',utilInterpretVal(optMgr.getTimeOut()));
    catch exception
        cleanUp(mdlConfig);
        throw(exception);
    end


    mdlConfig.restoreConfig();

    try
        utilCheckData(spidata,0);
    catch ME
        cleanUp(mdlConfig);
        throw(ME)
    end

    SPData=SolverProfilerDataClass(mdl);
    SPData.initializeSortedPD(spidata);
    SPData.fillZeroCrossingInfo(spidata);
    SPData.fillResetInfo(spidata);
    SPData.setStateRange(spidata);
    if mdlConfig.isXoutLogged()
        if mdlConfig.isXoutStreamedIfLogged()
            SPData.fillStateValue(mdlConfig.getXoutFilePath());
        else
            SPData.fillStateValue(spidata);
        end
    end
    SPData.fillFailureInfo(spidata);
    SPData.analyzeModelJacobian(spidata);
    SPData.getOverview();
    SPData.getModelDiagnosticsAndTableIndex(spidata);


    parseUserDataToWorkSpace(mdlConfig,spidata,1);

    mdlConfig.delete;


    file=optMgr.getDataFullFile();
    [path,name,~]=fileparts(file);
    mgr=SolverProfilerSessionDataManager(SPData);
    mgr.saveSessionData(path,name);
    mgr.delete();


    if nargout==1
        if SPData.isDataReady()
            res.file=optMgr.getDataFullFile();
            res.summary=SPData.getSimplifiedOverview();
            varargout{1}=res;
        else
            varargout{1}=[];
        end
    end


    if optMgr.openSPAfterProfile()
        solverprofiler.exploreResult(optMgr.getDataFullFile())
    end
end

function cleanUp(mdlConfig)
    mdlConfig.restoreConfig();
    mdlConfig.delete;
end
