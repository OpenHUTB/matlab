




function[status,msg,xilCodeAnalyzer]=checkCompatibility(modelName,varargin)


    narginchk(1,inf);
    options=parseArgs(varargin{:});


    options.IsATS=false;
    options.HarnessInfo=[];
    options.XilCodeAnalyzer=[];


    xilCodeAnalyzer=[];


    if~isempty(options.SubsystemModelH)
        harnessModelToCheck=options.ExtractedModelName;
    else
        harnessModelToCheck=modelName;
    end
    [options.IsATS,options.HarnessInfo]=sldv.code.xil.CodeAnalyzer.isATSHarnessModel(harnessModelToCheck);
    if options.IsATS
        [status,msg,options]=checkCodeForAts(harnessModelToCheck,options);
        if~status
            return
        end
    end


    [status,msg,options]=checkConfig(modelName,options);
    if~status
        return
    end


    if~options.isBDExtractedModel&&~isempty(options.ExtractedModelName)&&...
        ~strcmp(options.ExtractedModelName,modelName)&&isempty(options.SubsystemModelH)
        if options.IsATS
            msg=getString(message('sldv_sfcn:sldv_sfcn:compatGenericAtsUnsupportedReplacementModel',...
            options.HarnessInfo.ownerFullPath));
            status=false;
            return
        end
        modelName=options.ExtractedModelName;
    end


    if options.isBDExtractedModel
        [status,msg]=checkSimulinkFunction(modelName);
        if~status
            return
        end
    end


    if options.IsATS
        xilCleanupObjs=sldv.code.xil.CodeAnalyzer.registerXILSimulationPlugins(harnessModelToCheck,true);%#ok<NASGU>
        modelName=options.HarnessInfo.model;
    end
    [status,msg,options]=checkCodeAndInstrumentation(modelName,options);
    if~status
        return
    end


    [status,msg,options]=checkCodeInterface(modelName,options);
    if~status
        return
    end


    if~isempty(options.StartCovData)
        [status,msg]=sldv.code.xil.CodeAnalyzer.checkCompatibilityForTopOffCoverage(...
        modelName,...
        options.StartCovData,...
        'FilterExistingCov',options.FilterExistingCov);
        if~status
            return
        end
    end


    status=true;
    xilCodeAnalyzer=options.XilCodeAnalyzer;

end


function options=parseArgs(varargin)

    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addOptional(argParser,'SimulationMode','SIL');
        addOptional(argParser,'StartCovData',[]);
        addOptional(argParser,'FilterExistingCov',true);
        addOptional(argParser,'ExtractedModelName','');
        addOptional(argParser,'isBDExtractedModel',false);
        addOptional(argParser,'LogFcn',@(msg)msg);
        addOptional(argParser,'SubsystemModelH',[]);
        addOptional(argParser,'SldvSettings',[]);
    end

    parse(argParser,varargin{:});

    options=argParser.Results;

end


function[status,msg,options]=checkCodeForAts(~,options)


    status=false;
    msg='';


    buildDirStruct=RTW.getBuildDir(options.HarnessInfo.model);
    isTopModel=isfile(fullfile(buildDirStruct.BuildDirectory,'codedescriptor.dmr'));
    mdlRefBuildDir=fullfile(buildDirStruct.CodeGenFolder,buildDirStruct.ModelRefRelativeBuildDir);
    isModelRef=isfile(fullfile(mdlRefBuildDir,'codedescriptor.dmr'));

    if isTopModel&&isModelRef
        msg=getString(message('PIL:pil_subsystem:CannotSelectGeneratedCode',...
        options.HarnessInfo.name,buildDirStruct.BuildDirectory,mdlRefBuildDir));
        return
    elseif(~isTopModel&&~isModelRef)
        msg=getString(message('PIL:pil_subsystem:GeneratedCodeMissingOrIncomplete',...
        options.HarnessInfo.name,buildDirStruct.BuildDirectory,mdlRefBuildDir));
        return
    end



    if(options.SimulationMode~="SIL")&&isTopModel
        msg=getString(message('sldv_sfcn:sldv_sfcn:subsysTopModelCodeTargetMismatch'));
        return
    elseif(options.SimulationMode~="ModelRefSIL")&&isModelRef
        msg=getString(message('sldv_sfcn:sldv_sfcn:subsysModelRefCodeTargetMismatch'));
        return
    end


    status=true;

end


function[status,msg,options]=checkConfig(~,options)


    status=false;
    msg='';


    if~license('test','RTW_Embedded_Coder')
        msg=getString(message('sldv_sfcn:sldv_sfcn:compatNoEmbeddedCoderLicense'));
        return
    end


    if options.IsATS





        [errMsg,warnMsg]=rtw.pil.AtomicSubsystemManager.compatibilityCheck(...
        options.HarnessInfo.model,options.HarnessInfo.ownerFullPath);
        if~isempty(errMsg)
            errMsg=cellfun(@(x)x.message,errMsg,'UniformOutput',false);
            msg=strjoin(errMsg,[newline,newline]);
            return
        end
        if~isempty(warnMsg)

            warnMsg=getString(message('sldv_sfcn:sldv_sfcn:compatGenericAtsWarning',...
            harnessInfo.ownerFullPath,strjoin(warnMsg,[newline,newline])));
            options.LogFcn(newline);
            options.LogFcn(warnMsg);
        end
    end


    status=true;

end


function[status,msg]=checkSimulinkFunction(modelName)


    status=true;
    msg='';

    testComp=Sldv.Token.get.getTestComponent();
    if isempty(testComp)||~isa(testComp,'SlAvt.TestComponent')
        return
    end

    if isfield(testComp.analysisInfo,'stubbedSimulinkFcnInfo')&&...
        ~isempty(testComp.analysisInfo.stubbedSimulinkFcnInfo)
        status=false;
        msg=getString(message('sldv_sfcn:sldv_sfcn:compatModelHasStubbedSimulinkFunction',modelName));
        return
    end

end


function[status,msg,options]=checkCodeAndInstrumentation(modelName,options)


    status=false;



    [isOK,msg]=updateForCodeCoverage(modelName,options);
    if~isempty(msg)
        return
    end


    moduleName=SlCov.coder.EmbeddedCoder.buildModuleName(...
    modelName,char(options.SimulationMode));


    if isOK
        xilCodeAnalyzer=sldv.code.xil.CodeAnalyzer.createFromModel(...
        modelName,'SimulationMode',options.SimulationMode,...
        'IsATS',options.IsATS,'HarnessInfo',options.HarnessInfo);
    end


    trDataFile=SlCov.coder.EmbeddedCoder.getCodeCovDataFiles(moduleName);
    if~isOK||~isfile(trDataFile)
        msg=genCovInfoNotFoundMsg(char(options.SimulationMode));
        return
    end


    try
        codeDesc=xilCodeAnalyzer.getCodeDescriptor();
        if isempty(codeDesc)||isempty(codeDesc.codeInfo)
            msg=genCovInfoNotFoundMsg(char(options.SimulationMode));
            return
        end
    catch Me
        msg=getString(...
        message('sldv_sfcn:sldv_sfcn:compatCodeExtractionUnknowError',...
        Me.message));
        return
    end


    try
        sldv.code.xil.internal.TraceabilityDb(trDataFile);
    catch
        msg=getString(message('sldv_sfcn:sldv_sfcn:compatCovInfoExtractionUnknowError'));
        return
    end



    try
        xilCodeAnalyzer.getXilInfo();
    catch Me
        msg=getString(...
        message('sldv_sfcn:sldv_sfcn:compatCodeExtractionUnknowError',...
        Me.message));
        return
    end


    status=true;
    options.XilCodeAnalyzer=xilCodeAnalyzer;

    function msg=genCovInfoNotFoundMsg(covMode)
        msgId='sldv_sfcn:sldv_sfcn:compatCovInfoNotFound';
        if covMode=="ModelRefSIL"
            msgId=[msgId,'ModelRef'];
        end
        msg=getString(message(msgId));
    end
end


function[status,msg,options]=checkCodeInterface(modelName,options)


    status=false;
    msg='';




    mdls=find_mdlrefs(modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    for ii=1:numel(mdls)


        blks=find_system(mdls{ii},...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'Type','block',...
        'BlockType','ObserverReference'...
        );
        if~isempty(blks)
            msg=getString(message('sldv_sfcn:sldv_sfcn:compatObserverReferenceBlockError',mdls{ii}));
            return
        end
    end


    xilCodeAnalyzer=options.XilCodeAnalyzer;
    covMode=char(options.SimulationMode);
    if covMode=="SIL"
        if~isa(xilCodeAnalyzer,'sldv.code.xil.CodeAnalyzer')||builtin('isempty',xilCodeAnalyzer)
            xilCodeAnalyzer=sldv.code.xil.CodeAnalyzer.createFromModel(...
            modelName,'SimulationMode',options.SimulationMode,...
            'IsATS',options.IsATS,'HarnessInfo',options.HarnessInfo);
        end
        xilCodeAnalyzer.extractCodeConfig();
        cfgObj=xilCodeAnalyzer.CoderConfig;
        if~isempty(cfgObj)
            if cfgObj.getParam('CodeInterfacePackaging')=="Reusable function"
                if cfgObj.getParam('GenerateAllocFcn')=="on"
                    msg=getString(message('sldv_sfcn:sldv_sfcn:compatCodeReusableFunctionAlloc'));
                    return
                end
            end
        end
    end


    status=true;
    options.XilCodeAnalyzer=xilCodeAnalyzer;

end


function[isOK,msg]=updateForCodeCoverage(modelName,options)

    isOK=false;
    msg='';


    if get_param(modelName,'IsERTTarget')~="on"
        msg=getString(message('sldv_sfcn:sldv_sfcn:compatNotErtTargetError',modelName));
        return
    end

    modelH=get_param(modelName,'Handle');


    clrObjs=unlockModel(modelName,true);%#ok<NASGU>


    if options.SimulationMode=="ModelRefSIL"
        testGenMode=Sldv.utils.Options.TestgenTargetGeneratedModelRefCodeStr;
    else
        testGenMode=Sldv.utils.Options.TestgenTargetGeneratedCodeStr;
    end


    if strcmp(get(options.SldvSettings,'IncludeRelationalBoundary'),'on')
        set_param(modelName,'CovMetricSettings','bwe');
    end

    options.LogFcn(newline);
    options.LogFcn(getString(message('sldv_sfcn:sldv_sfcn:compatCovInfoExtractCodeMsgStart')));

    try
        if options.IsATS


            paramStruct=simulationSettingsForCoverageInstrumentation();
            paramStruct.CovSaveSingleToWorkspaceVar='on';
            paramStruct.CovSaveName=genvarname('sldvXILCovData',evalin('base','who'));



            if slfeature('LockMainMdlSubsysOnHarnessOpen')&&Simulink.harness.isHarnessBD(modelH)
                harnessOwnerBD=Simulink.harness.internal.getHarnessOwnerBD(modelH);
                if~utils.isLockedLibrary(harnessOwnerBD)
                    origInfo=get_param(harnessOwnerBD,'InSLDVAnalysis');
                    set_param(harnessOwnerBD,'InSLDVAnalysis',1);
                    infoCleanUp=onCleanup(@()(set_param(harnessOwnerBD,'InSLDVAnalysis',origInfo)));
                end
            elseif slfeature('LockMainMdlSubsysOnHarnessOpen')&&~utils.isLockedLibrary(modelH)
                origInfo=get_param(modelH,'InSLDVAnalysis');
                set_param(modelH,'InSLDVAnalysis',1);
                infoCleanup=onCleanup(@()(set_param(modelH,'InSLDVAnalysis',origInfo)));
            end

            simOuts=sim(options.HarnessInfo.name,paramStruct);
            cvd=evalin('base',paramStruct.CovSaveName);
            evalin('base',['clear ',paramStruct.CovSaveName]);
        else
            paramStruct=simulationSettingsForCoverageInstrumentation();
            if options.isBDExtractedModel
                harnessModelName=options.ExtractedModelName;
            else
                harnessModelName='HARNESS_4_SLDV_SIL_CODEGEN_VALIDATION';
                harnesslist=Simulink.harness.internal.find(modelName);
                if~isempty(harnesslist)
                    for idx=1:numel(harnesslist)
                        if harnesslist(idx).isOpen
                            Simulink.harness.internal.close(modelName,harnesslist(idx).name);
                        end
                    end
                end
                harnesslist=Simulink.harness.internal.find(modelName,'Name',harnessModelName);
                if~isempty(harnesslist)
                    Simulink.harness.internal.delete(modelH,harnessModelName);
                end

                Simulink.harness.internal.create(modelName,...
                false,...
                false,...
                'Name',harnessModelName,'Source','Inport',...
                'DriveFcnCallWithTestSequence',false,...
                'SLDVCompatible',true,'VerificationMode','SIL');
                Simulink.harness.internal.load(modelName,harnessModelName,false);
                if strcmpi(testGenMode,'GenCodeModelRef')
                    blockUT=Simulink.harness.internal.getActiveHarnessCUT(modelName);
                    set_param(blockUT,'CodeInterface','Model reference');
                end
            end





            testObj=cvtest(harnessModelName);
            testObj.modelRefSettings.enable='on';
            testObj.modelRefSettings.excludeTopModel=1;
            [cvd,simOuts]=cvsim(testObj,paramStruct);
        end

        isOK=~isempty(cvd)&&(isa(cvd,'cvdata')||isa(cvd,'cv.cvdatagroup'));
        if~isOK&&~isempty(simOuts)&&...
            isa(simOuts(1),'Simulink.SimulationOutput')&&...
            ~isempty(simOuts(1).ErrorMessage)
            msg=simOuts(1).ErrorMessage;
        end
        options.LogFcn(getString(message('sldv_sfcn:sldv_sfcn:compatCovInfoExtractCodeMsgEnd')));
    catch Me
        msg=getString(message('sldv_sfcn:sldv_sfcn:compatCovInfoExtractCodeError',Me.message));
        errorEx=Me;
        while~isempty(errorEx.cause)
            if isempty(errorEx.cause{1}.cause)
                msg=sprintf('%s\n\n%s',errorEx.cause{1}.message,msg);
                break;
            else
                errorEx=errorEx.cause{1};
            end
        end
    end


    if~options.IsATS&&~options.isBDExtractedModel
        harnesslist=Simulink.harness.internal.find(modelName,'Name',harnessModelName);
        if~isempty(harnesslist)
            if harnesslist.isOpen



                set_param(harnessModelName,'Dirty','off');
                Simulink.harness.internal.close(modelH,harnessModelName);
            end
            Simulink.harness.internal.delete(modelH,harnessModelName);
            set_param(modelName,'Dirty','off');
        end
    end
end


function clrObjs=unlockModel(modelName,forceBuild)







    if nargin<2
        forceBuild=false;
    end

    dirtyFlag=get_param(modelName,'Dirty');
    restoreDirtyFlag=onCleanup(@()set_param(modelName,'Dirty',dirtyFlag));
    fastRestartStatus=get_param(modelName,'FastRestart');
    restoreFastRestartStatus=onCleanup(@()set_param(modelName,'FastRestart',fastRestartStatus));
    restoreLockFlag=cvprivate('unlockModel',modelName);
    clrObjs=[restoreDirtyFlag,restoreFastRestartStatus,restoreLockFlag];





    if forceBuild
        [~,configSet]=sldvprivate('configcomp_get',get_param(modelName,'Handle'));
        if get_param(configSet,'GenCodeOnly')=="on"
            setConfigSetProps(configSet,{'GenCodeOnly','off'});
            restoreConfigSet=onCleanup(@()setConfigSetProps(configSet,{'GenCodeOnly','on'}));
            clrObjs=[restoreConfigSet,clrObjs];
        end
    end
    set_param(modelName,'Dirty','off','FastRestart','off');

    function setConfigSetProps(configSet,props)


        if configSet.isLockedForSim

            configSet.unlock;


            clrConfigSetLock=onCleanup(@()configSet.lock);
        end
        activeCS=configSet;
        if isa(activeCS,'Simulink.ConfigSetRef')
            activeCS=activeCS.getRefConfigSet();
        end
        set_param(activeCS,props{:});
    end
end

function paramStruct=simulationSettingsForCoverageInstrumentation()
    paramStruct=struct;
    paramStruct.StopTime='0';
    paramStruct.RecordCoverage='on';
    paramStruct.CovModelRefEnable='on';
    paramStruct.CovHighlightResults='off';
    paramStruct.CovHtmlReporting='off';
    paramStruct.GenerateReport='off';
    paramStruct.GenerateCodeMetricsReport='off';
    paramStruct.LaunchReport='off';
end







