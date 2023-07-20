












function[analysisOk,analysisArray]=modelAnalysis(modelName,opts,varargin)



    if~bdIsLoaded(modelName)
        load_system(modelName);
        unloadModel=onCleanup(@()bdclose(modelName));
    end

    extraArgs={};
    if nargin>=2
        if isa(opts,'Sldv.Options')
            sldvOptions=opts;
            extraArgs=varargin;
        else
            sldvOptions=sldvoptions(modelName);
            extraArgs=[opts,varargin];
        end
    else
        sldvOptions=sldvoptions(modelName);
    end


    persistent argParser;
    if isempty(argParser)
        argParser=inputParser;
        addOptional(argParser,'forceAnalysis',false);
        addOptional(argParser,'testComponent',[]);
        addOptional(argParser,'simulationMode','SIL');
    end

    parse(argParser,extraArgs{:});
    options=argParser.Results;

    options=sldv.code.internal.getAnalysisOptionsFromSldv(sldvOptions,options);

    analysisMode=sldv.code.CodeAnalyzer.getAnalysisModeFromOptions(sldvOptions);

    testComp=options.testComponent;

    options.exportFcnInfo=sldv.code.xil.internal.SldvExportFcnSchedulerInfo.defaultSchedulingInfo();
    if~isempty(testComp)&&isa(testComp,'SlAvt.TestComponent')
        designModelName=get_param(testComp.analysisInfo.designModelH,'Name');
        showBeginEnd=false;


        if testComp.analysisInfo.blockDiagramExtract&&...
            ~isempty(testComp.analysisInfo.exportFcnGroupsInfo)
            options.exportFcnInfo=sldv.code.xil.internal.extractExportFcnSchedulerInfo(testComp);
        end
    else
        designModelName=modelName;
        showBeginEnd=true;
    end

    startTic=tic;


    codeAnalyzer=sldv.code.xil.internal.getCurrentCodeAnalyzer(testComp);
    if~isempty(codeAnalyzer)&&~isempty(codeAnalyzer.AtsHarnessInfo)&&...
        isstruct(codeAnalyzer.AtsHarnessInfo)

        isATS=true;
        harnessInfo=codeAnalyzer.AtsHarnessInfo;
    else
        [isATS,harnessInfo]=sldv.code.xil.CodeAnalyzer.isATSHarnessModel(modelName);
    end

    if isATS
        slObjKind='subsystem';
        slObjName=strrep(harnessInfo.ownerFullPath,newline,' ');
    else
        slObjKind='model';
        slObjName=modelName;
    end
    if showBeginEnd
        sldv.code.internal.showMessage(testComp,'info','sldv_sfcn:sldv_sfcn:analyzingModelCode',...
        slObjKind,slObjName,SlCov.CovMode.toDescription(options.simulationMode));
    end
    try
        if builtin('isempty',codeAnalyzer)||~isa(codeAnalyzer,'sldv.code.xil.CodeAnalyzer')
            codeAnalyzer=sldv.code.xil.CodeAnalyzer.createFromModel(modelName,'simulationMode',options.simulationMode);
        end
        if~strcmp(designModelName,modelName)
            codeAnalyzer.updateModelName(designModelName);
        end
    catch Me
        sldv.code.internal.showMessage(testComp,'warning','sldv_sfcn:sldv_sfcn:analyzingModelCodeError',slObjKind,Me.message);
        analysisOk=false;
        return
    end

    codeAnalyzer.setAnalysisOptions(options);
    codeAnalyzer.AnalysisMode=analysisMode;

    analysisOk=true;
    errorCount=0;


    codeAnalyzer.removeUnsupported();

    if nargout>=2
        analysisArray=[];
    end

    if~codeAnalyzer.isempty()

        if codeAnalyzer.SimulationMode=="SIL"
            loader=sldv.code.xil.internal.CodeInfoLoader();
        else
            loader=sldv.code.xil.internal.CodeInfoLoaderModelRef();
        end
        instanceDd=loader.openDb(designModelName,sldvOptions);
        instanceDd.clearOtherStaticChecksums(codeAnalyzer);

        allEntries=codeAnalyzer.splitEntries();


        for idx=1:numel(allEntries)
            instances=allEntries(idx).splitInstances();
            analyzedInstances=false(size(instances));

            analysisOk=true;

            for ii=1:numel(instances)
                currentAnalysis=instances(ii);
                upToDate=isUpToDate(codeAnalyzer,currentAnalysis,instanceDd,options);
                if~upToDate
                    instanceDd.clearInstances(currentAnalysis);
                    copyCodeGenInfo(codeAnalyzer,currentAnalysis);
                    currentOk=doAnalysis(currentAnalysis,instanceDd,options,testComp,slObjKind);
                    analyzedInstances(ii)=true;
                    errorCount=errorCount+(currentOk==false);
                    analysisOk=analysisOk&currentOk;
                end
            end

            if~any(analyzedInstances)


            elseif nargout>=2
                instances=instances(analyzedInstances);
                analysisArray=[analysisArray;instances(:)];%#ok<AGROW>
            end
        end

    end
    if showBeginEnd
        elapsedTime=toc(startTic);

        if errorCount==0
            sldv.code.internal.showMessage(testComp,'info','sldv_sfcn:sldv_sfcn:analyzingModelCodeFinished',slObjKind,slObjName);
        else
            sldv.code.internal.showMessage(testComp,'info','sldv_sfcn:sldv_sfcn:analyzingModelCodeFinishedWithErrors',slObjKind,slObjName,errorCount);
        end

        sldv.code.internal.showMessage(testComp,'info','sldv_sfcn:sldv_sfcn:analysisTimeInfo',round(elapsedTime));
    end


    function analysisOk=doAnalysis(codeAnalyzer,instanceDd,options,testComp,slObjKind)
        try
            analysisOk=codeAnalyzer.runSldvAnalysis(options);

            fullLog=codeAnalyzer.getFullIrLog();
            if analysisOk
                instanceDd.addAnalysis(codeAnalyzer);
            else
                errors=fullLog.getErrors();

                if~isempty(errors)
                    errors.fixXilIds();
                    errors.showMessage(testComp);
                else
                    sldv.code.internal.showMessage(testComp,'error','sldv_sfcn:sldv_sfcn:analysisCodeError',slObjKind);
                end

                analysisOk=false;
            end

            warnings=fullLog.getWarnings();
            if~isempty(warnings)
                warnings.showMessage(testComp);
            end
        catch ME
            sldv.code.internal.showString(testComp,'error',ME.message);
            analysisOk=false;
        end


        function upToDate=isUpToDate(codeAnalyzer,currentCodeAnalyzer,instanceDd,options)
            if options.forceAnalysis
                upToDate=false;
                return
            end
            if~strcmp(codeAnalyzer.CodeGenFolder,currentCodeAnalyzer.CodeGenFolder)
                upToDate=false;
                return
            end
            if~isequal(codeAnalyzer.AtsHarnessInfo,currentCodeAnalyzer.AtsHarnessInfo)
                upToDate=false;
                return
            end
            upToDate=instanceDd.hasExistingInfo(currentCodeAnalyzer,true,false);


