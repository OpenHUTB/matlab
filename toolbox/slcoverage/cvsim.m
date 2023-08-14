function varargout=cvsim(varargin)



















































    [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    if status==0
        error(message(msgId));
    end

    [allTestVars,simArgs]=parse_args(varargin,nargout);

    [modelH,isFastRestart]=check_open_model(allTestVars{1});
    set_param(modelH,'cvsimrefCall','on');

    coveng=[];
    try
        model_name_refresh;
        varargout=cell(1,nargout);

        modelName=get_param(modelH,'Name');
        restoreables=[];
        isParallelComputing=cv('CalledFromTransparentFunction');
        for idx=1:length(allTestVars)
            if~isFastRestart
                testVar=allTestVars{idx};
                [testVar,restoreableVar]=setupTest(testVar,simArgs);

                if idx==1
                    restoreables=restoreableVar;
                end
                evalSetupCmd(testVar);
            end

            if isParallelComputing
                [varargout{2:end}]=sim(modelName,simArgs{:});
            else
                hasArgs=~isempty(simArgs);
                if hasArgs



                    try
                        cmdString=sprintf('sim(''%s'',sIM_cMD_aRGS_fROM_cVSIM{:});',modelName);
                        assignin('caller','sIM_cMD_aRGS_fROM_cVSIM',simArgs);
                    catch assignErr
                        if isequal(assignErr.identifier,'MATLAB:err_static_workspace_violation')
                            assignErr=MException('Slvnv:simcoverage:staticworkspace',...
                            'This calling syntax is not supported from a static workspace such as a nested function.');
                        end
                        throw(assignErr);
                    end
                else
                    cmdString=sprintf('sim(''%s'');',modelName);
                end

                try
                    if length(allTestVars)==1
                        [varargout{2:end}]=evalin('caller',cmdString);
                    else
                        evalin('caller',cmdString);
                    end
                catch err
                    newerr=addCause(MException('Slvnv:simcoverage:SimulationFailed','Simulation failed'),err);
                    varargout{1}=[];%#ok<NASGU>
                    throw(newerr);
                end
            end
            coveng=cvi.TopModelCov.getInstance(modelH);
            covdata=coveng.lastCovData;
            varargout{idx}=covdata;
        end
    catch err
        coveng=cvi.TopModelCov.getInstance(modelH);
        clean_up(modelH,restoreables,coveng);
        rethrow(err);
    end
    clean_up(modelH,restoreables,coveng);

    function res=chekcPathOfUnitUnderTest(harnessModel,unitUnderTest,covPath)
        res='';
        fullPath=cvi.TopModelCov.checkCovPath(harnessModel,covPath);
        if contains(fullPath,unitUnderTest)
            res=fullPath;
        end


        function[newTestVar,restoreables]=setupTest(testVar,simArgs)
            modelH=cv('get',testVar.modelcov,'.handle');


            prevDirty=get_param(modelH,'Dirty');
            restoreDirtyFlag=onCleanup(@()set_param(modelH,'Dirty',prevDirty));


            activeCS=getActiveConfigSet(modelH);
            coveng=cvi.TopModelCov.getInstance(modelH);
            if~isempty(coveng)
                setupHarnessInfo(coveng);
            end
            if~isempty(coveng)&&~isempty(coveng.unitUnderTestName)
                unitUnderTestName=coveng.unitUnderTestName;
                res=chekcPathOfUnitUnderTest(coveng.harnessModel,unitUnderTestName,testVar.rootPath);
                if~isempty(res)
                    unitUnderTestName=res;
                end
                newTestVar=cvtest(unitUnderTestName);
                copySettings(newTestVar,testVar);
            elseif~strcmpi(cv('get',testVar.id,'.dbVersion'),SlCov.CoverageAPI.getDbVersion)

                modelName=get_param(modelH,'name');
                set_param(modelH,'CoverageId',0);

                newTestVar=cvtest(modelName);
                rootPath=cv('GetTestRootPath',testVar.id);
                cv('SetTestRootPath',newTestVar.id,rootPath);
                copySettings(newTestVar,testVar);
            else
                newTestVar=clone(testVar);
            end
            resolveDependentMetrics(newTestVar);


            restoreables=setup_model_from_testvar(activeCS,newTestVar);



            modelRefBlocks=find_system(modelH,'FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','all',...
            'BlockType','ModelReference');
            if isempty(modelRefBlocks)&&SlCov.CoverageAPI.supportObserverCoverage
                modelRefBlocks=find_system(modelH,'FollowLinks','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'LookUnderMasks','all',...
                'BlockType','ObserverReference');
            end
            hasModelRefBlocks=~isempty(modelRefBlocks);
            normalRefs=[];
            if hasModelRefBlocks
                normalRefs=cv.ModelRefData.getMdlReferences(get_param(modelH,'name'),true);
            end


            hasCodeCov=false;
            codeCovSettings=slprivate('getCodeCoverageSettings',modelH);
            if ismember(codeCovSettings.CoverageTool,{'None',SlCov.getCoverageToolName()})
                opts=SlCov.coder.EmbeddedCoder.getOptionsFromTestVar(newTestVar);


                topModelSimMode='';
                for ii=1:numel(simArgs)
                    if isstruct(simArgs{ii})&&isfield(simArgs{ii},'SimulationMode')
                        topModelSimMode=simArgs{ii}.SimulationMode;
                    elseif ischar(simArgs{ii})&&strcmp(simArgs{ii},'SimulationMode')&&...
                        (ii<numel(simArgs))&&ischar(simArgs{ii+1})
                        topModelSimMode=simArgs{ii+1};
                    end
                end
                [refModelNames,refModelHandles,topModelIsSILPIL,hasNormalModeRefModel,modelInfoMap]=...
                SlCov.coder.EmbeddedCoder.getRecordingModels(modelH,opts,true,topModelSimMode);
                hasCodeCov=~isempty(refModelNames);
            end

            if SlCov.CoverageAPI.hasSupportedModelRefs(modelH)
                setup_modelref_tests(modelH,newTestVar,normalRefs);
            else
                if hasModelRefBlocks&&...
                    ~strcmpi(newTestVar.modelRefSettings.enable,'off')&&...
                    newTestVar.modelRefSettings.excludeTopModel&&...
                    ~hasCodeCov



                    newTestVar.modelRefSettings.excludeTopModel=false;
                    newTestVar=setAllMetric(newTestVar,0);
                end
                if~(hasCodeCov&&newTestVar.modelRefSettings.excludeTopModel)
                    restoreables=turnOnCoverage(activeCS,restoreables);
                    if~(hasCodeCov&&topModelIsSILPIL)
                        coveng=cvi.TopModelCov.setup(modelH);%#ok<NASGU>
                        activate(newTestVar,newTestVar.modelcov);
                    end
                end
            end

            if hasCodeCov
                if topModelIsSILPIL||(newTestVar.modelRefSettings.excludeTopModel&&~hasNormalModeRefModel)



                    mrfd=cv.ModelRefData;
                    mrfd.init_from_cvtest(modelH,newTestVar,normalRefs);
                    if topModelIsSILPIL
                        if isempty(topModelSimMode)
                            topModelSimMode=get_param(modelH,'SimulationMode');
                        end


                        if strcmpi(topModelSimMode,SlCov.Utils.SIM_SIL_MODE_STR)
                            simMode=SlCov.CovMode.SIL;
                        else
                            assert(strcmpi(topModelSimMode,SlCov.Utils.SIM_PIL_MODE_STR));
                            simMode=SlCov.CovMode.PIL;
                        end
                    else
                        simMode=[];
                    end
                    cvi.TopModelCov.setupFromTopModel(modelH,mrfd,simMode);
                    coveng=cvi.TopModelCov.getInstance(modelH);


                    coveng.covModelRefData.recordingModels=[];
                    coveng.lastReportingModelH=[];





                    newTestVar2=cvtest(modelH);
                    copySettings(newTestVar2,newTestVar);
                    newTestVar=newTestVar2;
                else
                    coveng=cvi.TopModelCov.getInstance(modelH);
                    if isempty(coveng.covModelRefData)







                        mrfd=cv.ModelRefData;
                        mrfd.init_from_cvtest(modelH,newTestVar,normalRefs);
                        coveng.covModelRefData=mrfd;
                    end
                end

                coveng.covModelRefData.codeCovRecordingModels=struct('modelHandles',{refModelHandles},...
                'modelNames',{refModelNames});

                for ii=1:numel(refModelNames)
                    refModelH=refModelHandles(ii);

                    if isequal(refModelH,modelH)


                        if newTestVar.modelRefSettings.excludeTopModel&&numel(refModelNames)==1
                            newTestVar.modelRefSettings.excludeTopModel=false;
                            newTestVar=setAllMetric(newTestVar,0);
                        end
                        restoreables=turnOnCoverage(activeCS,restoreables);

                        set_param(modelH,'RecordCoverage','on');
                        activate(newTestVar,newTestVar.modelcov);
                    else
                        refModelHasNormal=any(strcmp(refModelNames{ii},coveng.covModelRefData.recordingModels));
                        oldModelcovId=get_param(refModelH,'CoverageId');

                        simModes=modelInfoMap(refModelNames{ii});
                        for jj=1:numel(simModes)
                            cvi.TopModelCov.setup(refModelH,newTestVar.modelcov,simModes(jj));
                            covPath=get_param(refModelH,'CovPath');
                            fullCovPath=cvi.TopModelCov.checkCovPath(refModelNames{ii},covPath);
                            testVar=cvtest(fullCovPath);
                            copySettings(testVar,newTestVar);
                            activate(testVar,testVar.modelcov);
                        end



                        if refModelHasNormal
                            set_param(refModelH,'CoverageId',oldModelcovId);
                        end
                    end
                end
            end

            restoreables.CovForceBlockReductionOff=setCovForceBlockReductionOff(activeCS,newTestVar);


            function restoreables=setup_model_from_testvar(activeCS,testVar)




                restoreables=logCoverageEnableParams(activeCS,[]);
                if testVar.modelRefSettings.excludeTopModel
                    setParamOnConfigSet(activeCS,'RecordCoverage','off');
                else
                    setParamOnConfigSet(activeCS,'RecordCoverage','on');
                end
                if~isempty(testVar.rootPath)
                    restoreables.CovPath=get_param(activeCS,'CovPath');
                    setParamOnConfigSet(activeCS,'CovPath',testVar.rootPath);
                end
                restoreables.CovModelRefExcluded=get_param(activeCS,'CovModelRefExcluded');
                if~strcmpi(testVar.modelRefSettings.enable,'off')
                    if isempty(testVar.modelRefSettings.excludedModels)
                        setParamOnConfigSet(activeCS,'CovModelRefEnable','all');
                    else
                        setParamOnConfigSet(activeCS,'CovModelRefEnable','filtered');
                    end
                else
                    setParamOnConfigSet(activeCS,'CovModelRefEnable','off');
                end
                setParamOnConfigSet(activeCS,'CovModelRefExcluded',testVar.modelRefSettings.excludedModels);


                restoreables.CovSFcnEnable=get_param(activeCS,'CovSFcnEnable');
                if testVar.sfcnSettings.enableSfcn
                    setParamOnConfigSet(activeCS,'CovSFcnEnable','on');
                else
                    setParamOnConfigSet(activeCS,'CovSFcnEnable','off');
                end

                function setParamOnConfigSet(activeCS,paramName,paramValue)
                    configset.internal.setParam(activeCS,paramName,paramValue,'Apply','off');


                    function[allTestVars,simArgs]=parse_args(inputArgs,numOfExpectedOuts)
                        if isempty(inputArgs)
                            error(message('Slvnv:simcoverage:cvsim:AtLeastOneArgument'))
                        end

                        [inputArgs{:}]=convertStringsToChars(inputArgs{:});

                        simArgs={};
                        allTestVars={getCvtests(inputArgs{1})};
                        if length(inputArgs)>1
                            if isa(inputArgs{2},'cvtest')
                                allTestVars=[allTestVars,inputArgs(2:end)];

                            else

                                simArgs=inputArgs(2:end);
                            end
                        end

                        if(length(allTestVars)>1)
                            if~isempty(simArgs)
                                error(message('Slvnv:simcoverage:cvsim:MutipleObjects'));
                            end
                            if(length(allTestVars)~=numOfExpectedOuts)
                                error(message('Slvnv:simcoverage:cvsim:SameNumberInputOutput'));
                            end
                        end

                        function cvt=getCvtests(input)
                            if isa(input,'cvtest')
                                cvt=input;
                            else


                                if ischar(input)&&contains(input,'.')

                                    [~,input]=fileparts(input);
                                end
                                try

                                    modelName=bdroot(input);
                                catch Mex
                                    error(message('Slvnv:simcoverage:cvsim:OpenModel',input));
                                end



                                if isequal(modelName,input)
                                    covPath=get_param(input,'CovPath');
                                    input=cvi.TopModelCov.checkCovPath(input,covPath);
                                end
                                cvt=cvtest(input);
                            end


                            function[modelH,isFastRestart]=check_open_model(testVar)


                                if~cv('ishandle',testVar.id)
                                    error(message('Slvnv:simcoverage:cvsim:InvalidCvtestObject'));
                                end
                                modelcovId=testVar.modelcov;
                                modelName=SlCov.CoverageAPI.getModelcovName(modelcovId);

                                if~bdIsLoaded(modelName)
                                    error(message('Slvnv:simcoverage:cvsim:OpenModel',modelName));
                                else
                                    modelH=get_param(modelName,'handle');
                                end
                                isFastRestart=strcmpi(get_param(modelName,'SimulationStatus'),'compiled');
                                if~isFastRestart
                                    cvi.TopModelCov.updateModelHandles(modelcovId,modelName);
                                end


                                function clean_up(modelH,restoreables,coveng)
                                    if~isempty(modelH)

                                        if~strcmpi(get_param(modelH,'SimulationStatus'),'compiled')
                                            if~isempty(restoreables)
                                                prevDirty=get_param(modelH,'Dirty');
                                                cs=getActiveConfigSet(modelH);
                                                params=fieldnames(restoreables);
                                                for i=1:length(params)
                                                    setParamOnConfigSet(cs,params{i},restoreables.(params{i}));
                                                end
                                                set_param(modelH,'Dirty',prevDirty);
                                            end

                                            if~isempty(coveng)
                                                cvi.TopModelCov.termFromTopModel(modelH);
                                            end
                                        else


                                            if~isempty(restoreables)
                                                coveng.restorableParams=restoreables;
                                            end
                                        end
                                        set_param(modelH,'cvsimrefCall','off');
                                    end

                                    if evalin('base','exist(''sIM_cMD_aRGS_fROM_cVSIM'')==1')
                                        evalin('base','clear(''sIM_cMD_aRGS_fROM_cVSIM'');');
                                    end


                                    function restoreables=turnOnCoverage(activeCS,restoreables)
                                        if nargin<2
                                            restoreables=[];
                                        end

                                        if~isfield(restoreables,'CovEnable')
                                            restoreables=logCoverageEnableParams(activeCS,restoreables);
                                        end
                                        setParamOnConfigSet(activeCS,'RecordCoverage','on');


                                        function restoreables=logCoverageEnableParams(activeCS,restoreables)
                                            restoreables.CovEnable=get_param(activeCS,'CovEnable');
                                            restoreables.CovIncludeTopModel=get_param(activeCS,'CovIncludeTopModel');
                                            restoreables.CovIncludeRefModels=get_param(activeCS,'CovIncludeRefModels');


                                            function param_value=setCovForceBlockReductionOff(activeCS,testVar)



                                                param_value=get_param(activeCS,'CovForceBlockReductionOff');
                                                if(testVar.options.forceBlockReduction)
                                                    setParamOnConfigSet(activeCS,'CovForceBlockReductionOff','on');
                                                else
                                                    setParamOnConfigSet(activeCS,'CovForceBlockReductionOff','off');
                                                end



                                                function evalSetupCmd(testVar)
                                                    try
                                                        setupCmd=cv('get',testVar.id,'.mlSetupCmd');
                                                        if~isempty(setupCmd)
                                                            evalin('base',setupCmd);
                                                        end
                                                    catch Mex
                                                        warning(message('Slvnv:simcoverage:cvsim:InvalidSetupCmd',Mex.message));
                                                    end



                                                    function setup_modelref_tests(modelH,topTestVar,refs)

                                                        mrfd=cv.ModelRefData;
                                                        mrfd.init_from_cvtest(modelH,topTestVar,refs);
                                                        cvi.TopModelCov.setupFromTopModel(modelH,mrfd)
                                                        if strcmp(get_param(modelH,'RecordCoverage'),'on')
                                                            activate(topTestVar,topTestVar.modelcov);
                                                        end
                                                        for idx=1:length(refs)
                                                            cs=refs{idx};
                                                            if strcmp(get_param(cs,'RecordCoverage'),'on')
                                                                modelName=get_param(cs,'name');
                                                                covPath=get_param(cs,'CovPath');
                                                                fullCovPath=cvi.TopModelCov.checkCovPath(modelName,covPath);
                                                                testVar=cvtest(fullCovPath);
                                                                copySettings(testVar,topTestVar);
                                                                activate(testVar,testVar.modelcov);
                                                            end
                                                        end


                                                        function resolveDependentMetrics(cvt)
                                                            if cvt.settings.mcdc
                                                                cvt.settings.condition=true;
                                                            end

                                                            if cvt.settings.condition
                                                                cvt.settings.decision=true;
                                                            end
