function result=emlckernel(clientType,varargin)




    import matlab.internal.lang.capability.Capability;

    originalDir=pwd();
    cleanupHandle=onCleanup(@()doCleanup(originalDir));

    CC=[];
    result=struct();
    extraOutputs=result;
    dduxPayload=coder.internal.ddux.CliCodegenData(clientType);
    clientType=normalizeClientType(clientType);
    try
        CC=coder.internal.CompilationContext(clientType);

        [profileCleanup,shouldDoCompile]=preCompileSteps();%#ok<ASGLU>

        dduxPayload=computeDduxConversionAndLang(dduxPayload);
        if CC.isCodegenToProject()
            codegenToProjectSteps();
        elseif shouldDoCompile
            compileSteps();
        end
        dduxPayload=computeDduxPostCompile(dduxPayload,result);
    catch err
        dduxPayload.succeeded=false;
        result=struct('internal',err);
        handleError(err);
        if coder.internal.gui.globalconfig('RethrowInternalErrors')
            err.rethrow();
        end
    end
    coder.internal.ddux.logger.logCoderEventData("cliCodegen",dduxPayload);
    if~isempty(CC)&&~isempty(CC.ExtraCodegenOutputs)
        result.extraOutputs=extraOutputs;
    end


    function[profileCleanup,shouldDoCompile]=preCompileSteps()


        shouldDoCompile=true;


        profileCleanup=coder.internal.CodegenProfilerSentinel();
        profileCleanup.enablePerformanceTracer()

        saveReproSteps(clientType,varargin{:});


        emcPtStart('emlckernel-precompile');
        c=onCleanup(@()emcPtStop('emlckernel-precompile'));

        emcArgParserAndValidator(CC,varargin{:});
        setDebugOutput('compilationContext',CC);


        profileCleanup.enableCodegenProfileSettings(CC);

        if checkPolyMexCompatibility()
            if~CC.Project.FeatureControl.EnablePolymorphicMex
                ccdiagnosticid('Coder:common:MultipleCoderTypes');
            end
            CC.Project.PolyMexType='SingleEntry';
            preparePolyMexEntryPoints();
        end

        if~hasEntryPoint()

            result.summary.passed=true;
            shouldDoCompile=false;
            return
        end
        if~Capability.isSupported(Capability.LocalClient)&&CC.codingHDL()
            error(message('Coder:common:HDLMOError'));
        end
        if CC.isCodeGenClient()||CC.isAudioPluginClient()||CC.isSimscapeClient()||...
            CC.isAlgorithmAnalyzerClient()||CC.isDlAccelClient()||CC.isPSTestClient()
            if~CC.codingMex()&&~CC.codingHDL()&&~CC.codingPLC()&&~CC.codingFixPt()&&~CC.codingDvoRangeAnalysis()
                tflName=CC.ConfigInfo.CodeReplacementLibrary;
            elseif CC.codingDvoRangeAnalysis()
                tflName='DMM';
            else





                if CC.codingMex()&&...
                    CC.isGpuTarget()
                    tflName='SIM_CUDA';
                else
                    tflName='SIM';
                end
            end
        else
            tflName='SIM';
        end

        if CC.Project.IsClassAsEntrypoint
            validateClassMethodName();
        end

        CC.CRLControl=getEmlTflControl(tflName);
    end


    function compileSteps()

        finalizeProject();
        if CC.Options.parseOnly
            postDryRun(true);
            return;
        else
            result=doit();

            if result.summary.passed&&CC.Project.FeatureControl.EnableDockerImageGeneration
                generateDockerImage();
            end

            if~result.summary.passed
                cleanupHardware();
            elseif CC.CommandArgs.runTest
                result=runTestBench(result);
            end
        end
    end


    function codegenToProjectSteps()


        if~isequal(CC.Project.PolyMexType,'None')
            ccdiagnosticid('Coder:common:CliToAppMultiSignatureUnsupported');
        end
        userLogDir=CC.Options.LogDirectory;
        userCodeTemplate=[];
        if isprop(CC.ConfigInfo,'CodeTemplate')
            userCodeTemplate=CC.ConfigInfo.CodeTemplate;
        end
        if hasEntryPoint()
            finalizeProject();
        end
        codergui.internal.cliToApp('codegen2project',CC.Options.generatedProjectFile,...
        'create',CC,'UserLogDir',userLogDir,'UserCodeTemplate',userCodeTemplate);
        postDryRun(false);
    end


    function clientType=normalizeClientType(clientType)
        if strcmpi(clientType,'appCodegen')


            clientType='codegen';
        end
    end


    function dduxPayload=computeDduxConversionAndLang(dduxPayload)
        if CC.codingHDL()
            if isprop(CC.ConfigInfo,'TargetLanguage')
                dduxTargetLang=CC.ConfigInfo.TargetLanguage;
            else
                dduxTargetLang='HDL';
            end
        elseif CC.isCUDATarget()
            dduxTargetLang='CUDA';
        elseif CC.isOpenCLTarget()
            dduxTargetLang='OpenCL';
        elseif CC.codingPLC()
            dduxTargetLang='PLC';
        elseif CC.isTargetLangCPP()
            dduxTargetLang='C++';
        elseif CC.isTargetLangC()
            dduxTargetLang='C';
        else
            dduxTargetLang='Unknown';
        end
        dduxPayload.targetLang=dduxTargetLang;
        if CC.isDoubleToSingle()
            dduxPayload.numericConversion='single';
        elseif CC.isF2fEnabled()
            dduxPayload.numericConversion='fixed-point';
        else
            dduxPayload.numericConversion='none';
        end
    end


    function dduxPayload=computeDduxPostCompile(dduxPayload,result)
        if isfield(result,'summary')
            if isfield(result.summary,'passed')
                dduxPayload.succeeded=result.summary.passed;
            end
            if isfield(result.summary,'buildFailed')
                dduxPayload.buildFailed=result.summary.buildFailed;
            end
        end
        if CC.hasEntryPoint()
            dduxPayload.numEntryPointFcns=numel(CC.Project.EntryPoints);
        end
    end


    function compilerInfo=getCompilerInfo()
        compilerInfo=compilerman(~CC.codingMex(),~CC.isTargetLangCPP(),true);
    end


    function b=verbose()
        cfg=CC.ConfigInfo;
        b=isprop(cfg,'Verbosity')&&ischar(cfg.Verbosity)&&cfg.Verbosity=="Verbose";
    end


    function b=silent()
        if CC.isCodeGenClient()||CC.isPSTestClient()
            cfg=CC.ConfigInfo;
            b=isprop(cfg,'Verbosity')&&ischar(cfg.Verbosity)&&cfg.Verbosity=="Silent";
        else
            b=true;
        end
    end


    function b=hasEntryPoint()
        b=CC.hasEntryPoint();
    end


    function setupCodeTemplate()
        if CC.isERT()
            cfg=CC.ConfigInfo;
            if isprop(cfg,'CodeTemplate')
                if isempty(cfg.CodeTemplate)
                    if CC.isGpuTarget()
                        cfg.CodeTemplate=coder.MATLABCodeTemplate('gpucoder_default_template.cgt');
                    else
                        cfg.CodeTemplate=coder.MATLABCodeTemplate;
                    end
                else

                    if any(strcmp(cfg.CodeTemplate.getCurrentTokens(),'SourceGeneratedOn'))
                        default_cgt=coder.MATLABCodeTemplate;
                        cfg.CodeTemplate.setTokenValue('SourceGeneratedOn',...
                        default_cgt.getTokenValue('SourceGeneratedOn'));
                    end
                end
            end
        end
    end


    function setupTargetHardware()
        if CC.codingRtw()
            cfg=CC.ConfigInfo;
            if isprop(cfg,'Hardware')&&~isempty(cfg.Hardware)
                cfg.Hardware.preBuild(cfg);
            end
        end
    end


    function setupCRL()

        if CC.codingHDL()||CC.codingPLC()||CC.codingFixPt()||CC.codingDvoRangeAnalysis()
            return;
        end

        CC.CRLControl.MatlabCoder=true;


        if~CC.codingMex()
            checkTflConfiguration();
        else



            CC.CRLControl.doPreRTWBuildProcessing()
        end
    end


    function validateDeepLearningConfig()
        cfg=CC.ConfigInfo;

        if isprop(cfg,'DeepLearningConfig')&&~isempty(cfg.DeepLearningConfig)
            cfg.DeepLearningConfig.validate(cfg);
        end
    end


    function report=doit()

        if CC.codingTarget=="rtw:exe"&&CC.ConfigInfo.GenCodeOnly==false&&CC.ConfigInfo.GenerateExampleMain~="GenerateCodeAndCompile"
            if isempty(CC.ConfigInfo.CustomSource)&&isempty(CC.CommandArgs.CustomSource)
                ccwarningid('Coder:FE:ExeTargetWithoutMain');
            end
        end



        coder.report.RegisterCGIRInspectorResults.clearResults();

        checkCancellationRequest(CC.Project);
        doC89AutoFallback();
        enableHalf();
        enableCppRenamer();
        setupExportStyle();
        if CC.Project.FeatureControl.NewStructureCastLowering==2&&~CC.codingHDL
            CC.Project.FeatureControl.NewStructureCastLowering=1;
        end

        if CC.codingPLC
            plcprivate('plc_builder','generate_matlab_plc_code_start',CC.ConfigInfo);
        end

        report=compile();
        postcompile();
        report=adjustscripts(report);
        report=checkBuildLogForWarnings(report);
        report.summary.codingTarget=CC.Project.CodingTarget;
        report.summary.compilerName=CC.CompilerName;
        if~isequal(CC.Project.PolyMexType,'None')&&...
            ~isempty(CC.Project.EntryPoints(1).OriginName)
            report.summary.name=CC.Project.EntryPoints(1).OriginName;
        end
        if isprop(CC.ConfigInfo,'TargetLang')
            report.summary.TargetLang=CC.ConfigInfo.TargetLang;
        end
        if isprop(CC.ConfigInfo,'CppInterfaceClassName')
            report.summary.interface.className=CC.ConfigInfo.CppInterfaceClassName;
        end
        if isprop(CC.ConfigInfo,'CppNamespace')
            report.summary.interface.topNamespace=CC.ConfigInfo.CppNamespace;
        end
        if report.summary.passed&&(CC.codingMex()||CC.codingRtw())
            report.summary.OutputFileName=generateFinalOutputFileName(report.summary,CC.ConfigInfo);
            report.summary.VerificationMEXname=generateVerificationMEXFilename();
        else
            report.summary.OutputFileName='';
            report.summary.VerificationMEXname='';
        end

        if isReportingPotentialDifferences()
            [report,report.summary.potentialDifferences]=processPotentialDifferences(report);
        else
            report.summary.potentialDifferences=[];
        end


        dumpLog=~CC.isJavaPrjBuild()&&(verbose()||report.summary.buildFailed);
        if dumpLog&&isfield(report.summary,'buildResults')
            dumpBuildLog(report.summary.buildResults);
        end

        cfg=CC.ConfigInfo;

        reportContext=[];
        codegenInfo=[];

        if hasReportableMessages(report)||cfg.GenerateReport||hasGPUReportableMessages(report)
            if~CC.isPSTestClient()
                if~CC.Options.preserve
                    createLogDir();
                end
                report.summary.directory=CC.Options.LogDirectory;
                [reportContext,report,codegenInfo]=genReportAndReportInfo(report);
            end
        elseif report.summary.passed&&~silent()
            disp([message('Coder:reportGen:compilationSucceededNoReport').getString,newline]);
        end


        report.summary.directory=CC.Options.LogDirectory;

        if isprop(cfg,'ReportInfoVarName')&&~isempty(cfg.ReportInfoVarName)
            if isempty(codegenInfo)
                if isempty(reportContext)
                    reportContext=getReportContext(report);
                end
                try
                    codegenInfoBuilder=codergui.internal.CodegenInfoBuilder(reportContext,[],[]);
                    codegenInfo=codegenInfoBuilder.build();
                catch
                    ccwarningid('Coder:reportGen:CodegenInfoGenerationFailed');
                end
            end
            assignin('base',cfg.ReportInfoVarName,codegenInfo);
        end

        cleanupHdl();
        cleanupDeepLearning();
        CC.cleanupGpu();
        cleanupPLC();
        if isprop(CC.ConfigInfo,'EnableGitSupport')&&CC.ConfigInfo.EnableGitSupport...
            &&isprop(CC.ConfigInfo,'EnableAutoCommit')&&CC.ConfigInfo.EnableAutoCommit
            emcGitCommit(CC.Project.BldDirectory);
        end


        if CC.isJavaPrjBuild()
            postPrjBuild(report);
        end


        setDebugOutput('reportContext',reportContext);
        inspector=coder.report.RegisterCGIRInspectorResults.getInstance();
        if ismember('designInspector',CC.ExtraCodegenOutputs)
            if~isempty(inspector)
                setDebugOutput('designInspector',inspector.copy());
            else
                setDebugOutput('designInspector',coder.report.RegisterCGIRInspectorResults());
            end
        end
    end


    function[reportContext,report,codegenInfo]=genReportAndReportInfo(report)
        verboseDisp(message('Coder:common:VerboseGenreport').getString);
        emcPtStart('report');
        c=onCleanup(@()emcPtStop('report'));
        reportContext=getReportContext(report);
        [report,codegenInfo]=genreport(report,reportContext);
    end


    function[report,codegenInfo]=genreport(report,reportContext)
        try



            msgTypeName=showMessageSummary(report);

            reportGenArgs={reportContext,'GenCodegenInfo',isprop(CC.ConfigInfo,'ReportInfoVarName')};
            if ismember('reportDebug',CC.ExtraCodegenOutputs)
                [reportResult,debugLog]=codergui.ReportServices.Generator.run(reportGenArgs{:});
                setDebugOutput('reportDebug',debugLog);
            else
                reportResult=codergui.ReportServices.Generator.run(reportGenArgs{:});
            end
            if isfield(reportResult,'codegenInfo')
                codegenInfo=reportResult.codegenInfo;
                setDebugOutput('reportInfo',codegenInfo);
            else
                codegenInfo=[];
            end

            report.summary.mainhtml=reportResult.reportFile;
            if~report.summary.passed
                status='Failed';
            elseif isempty(report.summary.messageList)
                status='Succeeded';
            elseif strcmp(msgTypeName,'Info')
                status='SucceededWithInfos';
            else
                status='SucceededWithWarnings';
            end
            msgid=sprintf('%s%s','compilation',status);

            genReportLinks(msgid,report.summary.mainhtml);

        catch err
            if CC.isCodeGenClient()||CC.isAudioPluginClient()||CC.isSimscapeClient()||...
                CC.isAlgorithmAnalyzerClient()||CC.isDlAccelClient()||CC.isPSTestClient()
                disp('Compilation failed.');
            else
                disp('MEX-generation failed.');
            end
            rethrow(err);
        end
    end


    function reportContext=getReportContext(report)
        emcPtStart('reportinfo');
        c=onCleanup(@()emcPtStop('reportinfo'));

        reportContext=coder.report.ReportContext(report);
        reportContext.useCompilationContext(CC);
        reportContext.useDesignInspectorResults();
        reportContext.IsErt=CC.isERT();
        reportContext.IsEmlc=...
        CC.isCodeGenClient()||...
        CC.isAudioPluginClient()||...
        CC.isSimscapeClient()||...
        CC.isAlgorithmAnalyzerClient();

        if CC.codingHDL()
            reportContext.IsHdl=true;
        else
            reportContext.IsCpp=CC.isTargetLangCPP();
            reportContext.CompilerName=CC.CompilerName;
            reportContext.CodeReplacementLibrary=CC.CRLControl;
        end
    end


    function genReportLinks(msgid,mainhtml)
        if silent()&&msgid~="compilationFailed"
            return
        end
        if~feature('hotlinks')
            msgid=[msgid,'ND'];



            href=strrep(mainhtml,[pwd,filesep],'');
        else
            href=sprintf('matlab: open(''%s'');',...
            coder.report.internal.str2StrVar(mainhtml));
        end
        msgText=message(['Coder:reportGen:',msgid],href).getString;
        if(CC.codingHDL())
            disp(['### ',msgText]);
        else
            disp([msgText,newline]);
        end

        cfg=CC.ConfigInfo;
        if cfg.LaunchReport
            emcOpenReport(mainhtml);
        end
    end


    function msgTypeName=showMessageSummary(report)
        if isempty(report.summary.messageList)
            msgTypeName='';
            return;
        end

        found=false;
        function searchFor(messageList,what)
            for messageId=1:numel(messageList)
                msg=messageList{messageId};
                if strcmpi(msg.MsgTypeName,what)&&~msg.isFcnCallFailed
                    found=true;
                    break;
                end
            end
        end
        searchFor(report.summary.coderMessages,'Error');
        if~found
            searchFor(report.summary.coderMessages,'Warning');
        end
        if~found
            searchFor(report.summary.messageList,'Error');
        end
        if~found
            searchFor(report.summary.messageList,'Warning');
        end
        if~found
            msg=report.summary.messageList{1};
        end
        msgTypeName=msg.MsgTypeName;
        descriptor='???';
        if strcmpi(msgTypeName,'Warning')
            descriptor='Warning:';
        elseif strcmpi(msgTypeName,'Info')
            descriptor='Note:';
        end
        moreinfo=coder.internal.moreinfo(msg.MsgID);
        msgText=sprintf('%s %s\n%s',descriptor,msg.MsgText,moreinfo);
        matlab.internal.display.printWrapped(msgText);
        scriptId=msg.ScriptID;
        if scriptId~=0
            if scriptId>numel(report.scripts)

                scriptId=1;
            end
            script=report.scripts{scriptId};
            if~isempty(script.ScriptName)&&(msg.TextStart>=0)
                [lineNo,colNo]=scriptPositionToLine(script,msg.TextStart);
                scriptPath=coder.report.internal.str2StrVar(script.ScriptPath);
                GenOpenToLine(script.ScriptName,scriptPath,lineNo,colNo,msg.MsgTypeName);
            end
        end
    end


    function report=compile()
        emcPtStart('emlckernel-compile');
        ptCleanup=onCleanup(@()emcPtStop('emlckernel-compile'));
        reportCompilationStarted();
        buildInfo=RTW.BuildInfo;


        buildInfo.addIncludePaths(CC.Project.BldDirectory,'BuildDir');
        buildInfo.addSourcePaths(CC.Project.BldDirectory,'BuildDir');




        buildInfo.addIncludePaths(CC.Project.OutDirectory,'StartDir');
        buildInfo.addSourcePaths(CC.Project.OutDirectory,'StartDir');
        if isprop(CC.ConfigInfo,'DeepLearningConfig')&&~isempty(CC.ConfigInfo.DeepLearningConfig)
            CC.Project.FeatureControl.DLTargetLib=CC.ConfigInfo.DeepLearningConfig.TargetLibrary;
            if isprop(CC.ConfigInfo.DeepLearningConfig,'TargetLibrary')&&...
                any(strcmp(CC.ConfigInfo.DeepLearningConfig.TargetLibrary,{'arm-compute','arm-compute-mali'}))
                if(CC.ConfigInfo.GenCodeOnly)&&strcmp(CC.ConfigInfo.OutputType,'EXE')
                    buildInfo.addKeyValuePair('MakeVar','override PRODUCT',['../',CC.Project.FileName]);
                end
            end
        else


            CC.Project.FeatureControl.DLTargetLib='disabled';
        end

        if isprop(buildInfo.Settings,'DisablePackNGo')&&...
            ~isa(CC.ConfigInfo,'coder.CodeConfig')
            buildInfo.Settings.DisablePackNGo=true;
        end

        if(isa(CC.ConfigInfo,'coder.EmbeddedCodeConfig')||isa(CC.ConfigInfo,'coder.CodeConfig')||isa(CC.ConfigInfo,'coder.MexConfig'))
            CC.Project.FeatureControl.EnableGPU=~isempty(CC.ConfigInfo.GpuConfig)&&CC.ConfigInfo.GpuConfig.Enabled;
            if CC.Project.FeatureControl.EnableGPU
                CC.Project.FeatureControl.GpuComputeCapability=CC.ConfigInfo.GpuConfig.ComputeCapability;
            end
        end



        if~isempty(CC.JavaConfig)&&coderprivate.isFixedPointConversionEnabled(CC.JavaConfig)...
            &&~CC.codingFixPt()&&~CC.codingHDL()
            pathBackup=path;
            c=onCleanup(@()path(pathBackup));
            addpath(CC.FixptData.OutputFilesDirectory);
        end
        delete(ptCleanup);
        if CC.codingFixPt()
            CC.updateFixptCodeGenDir();
            if~isempty(CC.ConfigInfo.getSearchPaths())
                pathBackup=path;
                c=onCleanup(@()path(pathBackup));
                addpath(CC.ConfigInfo.getSearchPaths());
            end


            if strcmp(CC.ClientType,'fiaccel')
                CC.ConfigInfo.ProposeTypesMode=coder.FixPtConfig.MODE_FIXPT;
            end
            fpc=coder.internal.Float2FixedConverter(CC.ConfigInfo);
            fpc.floatGlobalTypes=CC.Project.InitialGlobalValues;
            fixptSuffix=CC.ConfigInfo.FixPtFileNameSuffix;
            pEP=CC.ConfigInfo.DesignFunctionName;
            if iscell(pEP)
                pEP=pEP{1};
            end
            if~coder.internal.Float2FixedConverter.checkFixedPointCodeName(pEP,fixptSuffix)
                throw(MException(message('Coder:FXPCONV:invalidFixPtSuffixCLI',fixptSuffix)));
            end
            if~isempty(CC.FixptState)&&isfield(CC.FixptState,'inputTypes')
                fpc.inputTypes=CC.FixptState.inputTypes;
            end
            if strcmp(CC.ClientType,'fiaccel')
                fpc.UseCoderForCodegen=false;
            end
            report=fpc.doFixPtConversion();
        else
            buildConfig=generateBuildConfig(CC.ConfigInfo,CC.Project.BldDirectory);
            report=coder.internal.compile(CC,buildInfo,buildConfig);
        end
        if CC.isCodeGenClient()||CC.isPSTestClient()||CC.isAudioPluginClient()||CC.isSimscapeClient()||...
            CC.isAlgorithmAnalyzerClient()||CC.isDlAccelClient()||report.summary.buildFailed||CC.Options.preserve
            report.summary.buildInfo=buildInfo;
        else
            report.summary.buildResults={};
        end




        if CC.isAudioPluginClient()&&report.summary.passed&&strcmpi('rtw:dll',CC.codingTarget())
            if ispc
                dllFile=[CC.Options.outputfile,'.dll'];
            elseif ismac
                dllFile=[CC.Options.outputfile,'.dylib'];
            else
                assert(0,'unexpected platform');
            end
            assert(isfield(CC.Options,'AudioPluginDumpDirectory'),'no audioplugin dump directory provided');
            movefile(fullfile(CC.Options.BldDirectory,dllFile),fullfile(CC.Options.AudioPluginDumpDirectory,dllFile));
        end


        if report.summary.passed&&~isempty(CC.Options.packageFile)
            packNGo(buildInfo,{'fileName',CC.Options.packageFile});
        end
    end


    function postcompile()
        if~CC.Options.preserve
            emcDeleteDir(CC.Options.BldDirectory);
        end
    end


    function postDryRun(isInternal)
        postcompile();
        result.summary.passed=true;
        if isInternal
            result.project=CC.Project;
            result.configInfo=CC.ConfigInfo;
            result.compilationContext=CC;
        end
    end


    function postPrjBuild(report)




        import('com.mathworks.toolbox.coder.app.UnifiedTargetFactory');%#ok<JAPIMATHWORKS> 

        if CC.isJavaPrjBuild()&&~isempty(CC.Project.CodeGenWrapper)&&...
            UnifiedTargetFactory.isUnifiedTarget(CC.JavaConfig.getTarget())
            manager=coder.internal.CoderGuiDataManager.getInstance();
            manager.cacheReportPostCodegen(CC.JavaConfig,report);
        end
    end


    function removeOldArtifacts()
        bldDirectory=CC.Options.BldDirectory;
        oldBldInfo=emcLoadPreviousBuildInfo(bldDirectory);
        emcBuildClean(bldDirectory,oldBldInfo,CC.codingMex());

        if CC.codingRtw()
            removeOldExampleArtifacts(oldBldInfo);
        end

        removeOldCXSparseDir();
    end


    function removeOldReport()
        bldDirectory=CC.Options.BldDirectory;
        reportDir=fullfile(bldDirectory,'html');
        codergui.ReportViewer.closeAll(reportDir);
        [~]=rmdir(reportDir,'s');
    end


    function removeOldExampleArtifacts(bldInfo)
        if~isempty(bldInfo)
            exampleMainVerified=CC.Project.verifyExampleMain(bldInfo);
        else
            exampleMainVerified=true;
        end
        CC.Options.ExamplesDirectory=fullfile(CC.Options.BldDirectory,'examples');
        if exampleMainVerified
            createDir(CC.Options.ExamplesDirectory,'w');
        end
        CC.Project.ExamplesDirectory=CC.Options.ExamplesDirectory;
    end


    function setupFixPt()
        if~CC.codingFixPt()
            return;
        end




        if~isfield(CC.FixptState,'coderConstIndices')||isempty(CC.FixptState.coderConstIndices)


            ipTypesList=arrayfun(@(ep)ep.InputTypes,CC.Project.EntryPoints','UniformOutput',false)';
            if~all(cellfun(@isempty,ipTypesList))
                CC.FixptState.inputTypes=ipTypesList;
            end
        end


    end

    function CC=setupWorkDirInHdlState(CC)
        if(CC.ParsedProjectFile)
            prjRoot=CC.Options.ProjectRoot;
            dirInfo=emlhdlcoder.WorkFlow.Manager.instance.getDirInfoFromPrjFile(prjRoot,CC.Options.projectFile);
        else
            dirInfo.workDir=CC.Project.OutDirectory;
            fixPtDone=CC.ConfigInfo.IsFixPtConversionDone;
            if fixPtDone
                DesignFunctionName=CC.FixptData.DesignFunctionName;
            else
                DesignFunctionName=CC.ConfigInfo.DesignFunctionName;
            end
            if CC.Project.IsUserSpecifiedOutputDir

                CC.HDLState.codegenDir=dirInfo.workDir;
                dirInfo.fxpBldDir=fullfile(dirInfo.workDir,DesignFunctionName,'fixpt');
            else
                dirInfo.fxpBldDir=fullfile(dirInfo.workDir,'codegen',DesignFunctionName,'fixpt');
            end
        end

        CC.Options.workDir=dirInfo.workDir;
        CC.HDLState.workDir=dirInfo.workDir;
        if(isfield(dirInfo,'fxpBldDir'))
            CC.HDLState.fxpBldDir=dirInfo.fxpBldDir;
        end
        if(isfield(dirInfo,'codegenFolder'))
            CC.HDLState.codegenDir=dirInfo.codegenFolder;
        end
    end


    function setupHdl()
        if~CC.codingHDL()
            return;
        end

        if~CC.isHDLCoderEnabled()
            ccdiagnosticid('Coder:common:NoHDLCoderTargetEnabled');
        end

        isCLIWorkFlow=~CC.ParsedProjectFile;

        if isCLIWorkFlow
            hdlDrv=slhdlcoder.HDLCoder;
        else
            hdlDrv=hdlcurrentdriver;
        end

        CC.HDLState.oldDriver=hdlcurrentdriver;
        CC.HDLState.oldMode=hdlcodegenmode;

        hdlDrv.AllModels=struct('modelName','MLHDLC');
        hdlDrv.mdlIdx=1;
        hdlcurrentdriver(hdlDrv);
        hdlcodegenmode('slcoder');
        isMatlabMode=true;
        hdlCfg=CC.ConfigInfo;
        hdlismatlabmode(isMatlabMode,hdlCfg);




        [fcnHasInputs,fcnHasOutputs]=coder.internal.Helper.checkForInputAndOutputParams(CC.ConfigInfo.DesignFunctionName);
        if(~fcnHasOutputs)
            error(message('Coder:common:DesignMustHaveOutputs'));
        end

        hasTestBench=~isempty(CC.ConfigInfo.TestBenchScriptName);
        hasInputTypes=~isempty(CC.Project.EntryPoints(end).InputTypes);

        if fcnHasInputs&&~hasInputTypes&&~hasTestBench
            ccdiagnosticid('Coder:configSet:InputTypesNotSpecified');
        end

        fixPtDone=CC.ConfigInfo.IsFixPtConversionDone;
        if fixPtDone
            hdlDrv.cgInfo.fxpCfg=CC.FixptData;
        end

        tbName=CC.ConfigInfo.TestBenchScriptName;
        if~isCLIWorkFlow
            origITyps=CC.HDLState.origInputTypes{end};
        else
            if fixPtDone


                pEpIndex=1;
                origITyps=CC.FixptData.InputArgs{pEpIndex};
            else
                origITyps=CC.Project.EntryPoints(end).InputTypes;
            end
        end



        hdlDrv.cgInfo.origItcs=origITyps;

        if fcnHasInputs&&isempty(origITyps)

            CC.HDLState.inVals=[];



            if~isempty(tbName)
                CC=setupWorkDirInHdlState(CC);
                [inVals,outVals]=emlhdlcoder.WorkFlow.Manager.instance.useTBToInferInputTypes(CC,fixPtDone);
                CC.HDLState.inVals=inVals;
                CC.HDLState.outVals=outVals;
                if~isempty(inVals)
                    CC.parseCoderTypes(inVals);
                end
            end


        else
            if fixPtDone
                if isCLIWorkFlow


                    pEpIndex=1;
                    nITyps=hdlDrv.cgInfo.fxpCfg.ConvertedInputFiTypes{pEpIndex};
                    if~isa(nITyps,'coder.Type')
                        nITyps=cellfun(@(v)coder.typeof(v),nITyps,'UniformOutput',false);
                    end
                else
                    newTypesMap=CC.HDLState.fiTypes;
                    nITyps=convertTypesToFixPt(origITyps,newTypesMap,CC.FixptData.fimath);
                end
                CC.Project.EntryPoints(end).InputTypes=nITyps;
            end
            CC.HDLState.inVals=CC.Project.EntryPoints(end).InputTypes;

            CC=setupWorkDirInHdlState(CC);
        end

        [hdlDrv.cgInfo.coderConstIndices,hdlDrv.cgInfo.coderConstVals]=screenHdlInputs(CC.Project.EntryPoints(end).InputTypes);

        hdlDrv.cgInfo.inVals=CC.HDLState.inVals;
        hdlDrv.cgInfo.inputITCs=CC.Project.EntryPoints(end).InputTypes;
        hdlDrv.cgInfo.HDLConfig=CC.ConfigInfo;


        if(isfield(CC.HDLState,'fxpBldDir'))
            hdlDrv.cgInfo.fxpBldDir=CC.HDLState.fxpBldDir;
        end
        if(isfield(CC.HDLState,'codegenDir'))
            hdlDrv.cgInfo.codegenDir=CC.HDLState.codegenDir;
        end

        if strcmpi(hdlCfg.Workflow,'IP Core Generation')||strcmpi(hdlCfg.Workflow,'FPGA Turnkey')
            if isCLIWorkFlow
                hDI=downstream.DownstreamIntegrationDriver(CC.Project.EntryPoints(end).Name,false,false,'',downstream.queryflowmodesenum.NONE,hdlDrv,true);
                hDI.set('Workflow',hdlCfg.Workflow);
                hDI.set('Board',hdlCfg.TargetPlatform);
                if fixPtDone&&isfield(CC.HDLState,'fxpBldDir')
                    entryPoint=fullfile(hdlDrv.cgInfo.fxpBldDir,[CC.Project.EntryPoints(end).Name,'.m']);
                else
                    entryPoint=fullfile(CC.Project.OutDirectory,[CC.Project.EntryPoints(end).Name,'.m']);
                end
                [status,~,~]=hDI.hTurnkey.hTable.populateInterfaceTable('','',entryPoint);
                if status
                    hdlDrv.DownstreamIntegrationDriver=hDI;
                else
                    hdlDrv.DownstreamIntegrationDriver='';
                end
            end
        end
    end


    function setupPLC()
        if~CC.codingPLC()
            return;
        end
    end


    function[coderConstIndices,constVals]=screenHdlInputs(vals)
        coderConstIndices=[];
        constVals={};
        for ii=1:length(vals)
            val=vals{ii};
            if isa(val,'coder.Constant')
                coderConstIndices=[coderConstIndices,ii];%#ok<AGROW>
                constVals{end+1}=val.Value;%#ok<AGROW>
            end
        end

        assert(length(coderConstIndices)==length(constVals));
    end


    function cleanupHdl()
        if~CC.codingHDL()
            return;
        end
        inst=emlhdlcoder.WorkFlow.Manager.instance();
        uiMode=inst.isInWorkFlowMode();
        if~uiMode

            if~isempty(CC.HDLState)
                hdlcodegenmode(CC.HDLState.oldMode);
                hdlcurrentdriver(CC.HDLState.oldDriver);
            end
            isMatlabMode=false;
            hdlCfg=[];
            hdlismatlabmode(isMatlabMode,hdlCfg);
        end
    end

    function cleanupDeepLearning()

        clear(which('coder.internal.loadCachedDeepLearningObj'));
    end

    function cleanupPLC()
        if~CC.codingPLC()
            return;
        end

        plcprivate('plc_builder','generate_matlab_plc_code_end',CC.ConfigInfo);
    end


    function sortEntryPoints()
        function visitEntryPoint(ep)

            if visitedMap.isKey(ep.Name)
                return;
            end
            if tmpVisited.isKey(ep.Name)

                error(message('Coder:FE:OutputCycleErr',ep.Name));
            end
            tmpVisited(ep.Name)=true;
            for typeIdx=1:numel(ep.InputTypes)
                if~isa(ep.InputTypes{typeIdx},'coder.OutputType')
                    continue;
                end

                if~epMap.isKey(ep.InputTypes{typeIdx}.FunctionName)
                    error(message('Coder:FE:OutputFcnNameInvalid',ep.InputTypes{typeIdx}.FunctionName));
                end
                visitEntryPoint(originalEntryPoints(epMap(ep.InputTypes{typeIdx}.FunctionName)));
            end

            CC.Project.EntryPoints(end+1)=ep;

            tmpVisited.remove(ep.Name);

            visitedMap(ep.Name)=1;
        end

        function checkOutputTypeUse(ep)
            for inputIdx=1:numel(ep.InputTypes)
                if isa(ep.InputTypes{inputIdx},'coder.OutputType')

                    if strcmp(ep.Name,ep.InputTypes{inputIdx}.FunctionName)
                        error(message('Coder:FE:OutputCycleErr',ep.Name));
                    else
                        error(message('Coder:FE:OutputFcnNameInvalid',ep.InputTypes{inputIdx}.FunctionName));
                    end
                end
            end
        end


        if numel(CC.Project.EntryPoints)<=1

            checkOutputTypeUse(CC.Project.EntryPoints(1));
            return;
        else

            originalEntryPoints=CC.Project.EntryPoints;

            epName=cell(1,numel(originalEntryPoints));
            epIdx=1:numel(originalEntryPoints);
            for i=1:numel(originalEntryPoints)
                epName{i}=originalEntryPoints(i).Name;
            end
            epMap=containers.Map(epName,epIdx);


            visitedMap=containers.Map;


            CC.Project.EntryPoints=repmat(CC.Project.EntryPoints,0,0);


            for i=1:numel(originalEntryPoints)
                currentEP=originalEntryPoints(i).Name;

                if visitedMap.isKey(currentEP)
                    continue;
                end


                if originalEntryPoints(i).HasInputTypes==false
                    CC.Project.EntryPoints(end+1)=originalEntryPoints(i);
                    visitedMap(currentEP)=true;
                end


                tmpVisited=containers.Map;

                visitEntryPoint(originalEntryPoints(i));
            end


            assert(numel(CC.Project.EntryPoints)==numel(originalEntryPoints));
        end
    end

    function finalizeProject()
        setupCRL();
        setupCodeTemplate();
        setupTargetHardware();
        setupFixPt();
        setupHdl();
        setupPLC();
        CC.setupGpu();
        createOutputDirectory();

        CC.Project.Name=CC.Project.EntryPoints(1).Name;
        CC.Project.BldDirectory=CC.Options.BldDirectory;
        CC.Project.InterfaceDirectory=CC.Options.InterfaceDirectory;
        CC.Project.TargetDirectory=CC.Options.TargetDirectory;
        if~isempty(CC.Options.outputfile)
            CC.Project.FileName=CC.Options.outputfile;
        else
            CC.Project.FileName=defaultOutputName();
        end
        sortEntryPoints();
        CC.CompilerName='Unknown';
        if CC.codingMex()
            canUseJIT=CC.isNewCodeGenClient()&&~CC.ConfigInfo.GenCodeOnly&&~CC.ConfigInfo.NoDefaultJIT;
            noCompilerDetected=false;
            try
                compilerInfo=getCompilerInfo();
                CC.CompilerName=compilerInfo.compilerName;
            catch ME
                if strcmp(ME.identifier,'Coder:buildProcess:unknownMexCompiler')
                    noCompilerDetected=true;
                else
                    rethrow(ME);
                end
            end

            if ispc&&strcmp(CC.CompilerName,'lcc64')
                noCompilerDetected=true;
            end

            if canUseJIT&&noCompilerDetected
                CC.ConfigInfo.EnableJIT=true;
                CC.ConfigInfo.EnableJITSilentBailOut=true;
            end

            if coderprivate.compiler_supports_eml_openmp(CC.CompilerName)
                CC.Project.CompilerSupportsOpenMP=true;
                if ispc&&strcmp(CC.CompilerName,'mingw64')
                    CC.Project.OpenMPLibrary=compilerInfo.OpenMPLib;
                end
            end

            if CC.Project.FeatureControl.EnableBLAS
                if~coderprivate.compiler_supports_eml_blas(CC.CompilerName)
                    CC.Project.FeatureControl.EnableBLAS=false;
                    CC.Project.FeatureControl.UseLAPACK=false;
                    msgId='Coder:reportGen:noCompilerBlasSupport';
                    ccwarningid(msgId,CC.CompilerName);
                end
            end

            coverageSetting=getenv('TESTCOVERAGE');
            if(ispc||ismac)&&~isempty(coverageSetting)&&strcmp(coverageSetting,'PROFILER')&&isprop(CC.ConfigInfo,'EnableMexProfiling')
                CC.ConfigInfo.EnableMexProfiling=true;
                CC.Project.FeatureControl.MexProfilingLevel='AllFcns';
                CC.Project.FeatureControl.EnableImprovedMexProfileCoverage=true;
            end

            if~noCompilerDetected&&compilerInfo.codingMinGWMakefile&&isprop(CC.ConfigInfo,'TargetLang')&&CC.ConfigInfo.TargetLang=="C++"&&CC.ConfigInfo.EnableMexProfiling
                ccwarningid('Coder:FE:ProfilingMinGWCpp');
                CC.ConfigInfo.EnableMexProfiling=false;
            end

            if(CC.isGpuTarget())
                coder.gpu.getDefaultGpuToolchain(CC.ConfigInfo.TargetLang,CC.codingMex());
            end
        elseif isprop(CC.ConfigInfo,'Toolchain')&&~CC.isSimscapeClient()&&~CC.isAlgorithmAnalyzerClient()
            if CC.isCUDATarget()&&...
                strcmp(CC.ConfigInfo.Toolchain,'Automatically locate an installed toolchain')
                CC.ConfigInfo.Toolchain=coder.gpu.getDefaultGpuToolchain(CC.ConfigInfo.TargetLang,CC.codingMex());
            end

            [lToolchainInfo,lIsToolchainInstalled]=...
            coder.make.internal.getToolchainInfoFromName(CC.ConfigInfo.Toolchain);




            if~lIsToolchainInstalled&&strcmp(computer,'PCWIN64')&&...
                strcmp(CC.ConfigInfo.Toolchain,coder.make.internal.getInfo('default-toolchain'))
                CC.ConfigInfo.Toolchain=coder.make.internal.getToolchainNameFromRegistry('LCC-x');
                lToolchainInfo=coder.make.internal.getToolchainInfoFromName...
                (CC.ConfigInfo.Toolchain);
            end

            CC.CompilerName=getBTICompilerName(lToolchainInfo);
            CC.Project.CompilerSupportsOpenMP=lToolchainInfo.hasCustomBuildConfiguration('OpenMP');


            checkSettingsForXIL();

        else
            CC.Project.CompilerSupportsOpenMP=false;
        end
        validateDeepLearningConfig();
    end


    function name=defaultOutputName()
        if CC.Project.IsClassAsEntrypoint
            name=CC.CommandArgs.ClassName;
            if CC.codingMex()
                name=[name,'_mex'];
            end
            return;
        end

        if~isequal(CC.Project.PolyMexType,'None')&&...
            ~isempty(CC.Project.EntryPoints(1).OriginName)
            if CC.codingMex()
                name=[CC.Project.EntryPoints(1).OriginName,'_mex'];
            else
                name=CC.Project.EntryPoints(1).OriginName;
            end

            return;
        end

        if~CC.isNewCommand()||~CC.codingMex()
            name=CC.Project.Name;
            return;
        end



        names=cell(numel(CC.Project.EntryPoints),1);
        for i=1:numel(CC.Project.EntryPoints)
            names{i}=CC.Project.EntryPoints(i).Name;
        end
        names=unique(names);
        name=[names{1},'_mex'];
    end




    function removeOldCXSparseDir()
        cxsparseDir=fullfile(CC.Options.BldDirectory,'CXSparse');
        if isfolder(cxsparseDir)
            emcDeleteDir(cxsparseDir);
        end
    end

    function createOutputDirectory()

        if CC.Options.preserve
            createLogDir();
            CC.Options.BldDirectory=CC.Options.LogDirectory;
            if~CC.isDryRun()
                emcGenGitIgnore(CC.Options.BldDirectory);
                if isprop(CC.ConfigInfo,'EnableGitSupport')&&CC.ConfigInfo.EnableGitSupport
                    emcSetupGitRepo(CC.Options.BldDirectory,CC.ConfigInfo.RepositoryStyle=="ForceCreate");
                end
            end
        else
            CC.Options.BldDirectory=createDir(tempname,'w');
        end

        if~CC.isDryRun()

            removeOldArtifacts();
            removeOldReport();
        end


        interfaceDir=fullfile(CC.Options.BldDirectory,'interface');
        CC.Options.InterfaceDirectory=createDir(interfaceDir,'w');

        isXILBuild=isSILTestingOn(CC.Project.FeatureControl)||(isprop(CC.ConfigInfo,'VerificationMode')...
        &&~isequal(CC.ConfigInfo.VerificationMode,'None'));
        if(isXILBuild)
            targetDir=fullfile(CC.Options.BldDirectory,'target');
            CC.Options.TargetDirectory=createDir(targetDir,'w');
        else
            CC.Options.TargetDirectory=CC.Options.BldDirectory;
        end
    end


    function logDir=nameLogDir(baseDir)
        logDir=CC.nameLogDir(baseDir);
    end


    function createLogDir()
        logDir=CC.Options.LogDirectory;
        if isempty(logDir)
            logDir=nameLogDir(pwd());
        end
        CC.Options.LogDirectory=createDir(logDir,'a');
    end


    function d=createDir(d,mode)
        function exists=directoryExists(d)
            [exists,m]=fileattrib(d);
            if exists
                exists=m.directory==true;
            end
        end
        checkDirName(d);
        if CC.isDryRun()
            return;
        end
        makeNewDir=true;
        switch mode
        case 'a'
            if directoryExists(d)
                makeNewDir=false;
            end
        case 'w'
            if directoryExists(d)
                emcDeleteDir(d);
            end
        end

        if makeNewDir
            [status,msg,~]=mkdir(d);
            if status==0
                ccdiagnosticid('Coder:configSet:CannotCreateDirectory',d,msg);
            end
        end

        [status,attributes]=fileattrib(d);
        if~status
            ccdiagnosticid('Coder:configSet:CannotAccessDirectory',d);
        end
        d=attributes.Name;
    end


    function checkDirName(d)
        function tf=canConvertUTF16ToLCP(d)
            tf=strcmp(native2unicode(unicode2native(d)),d);
        end

        if~CC.codingMex()
            badchars='[\$#*?]';
        else
            if ispc
                badchars='[<>"|?*]';
            else
                badchars='[\\]';
            end
        end



        badpos=regexp(d,badchars,'once');
        if~isempty(badpos)
            ccdiagnosticid('Coder:configSet:DirectoryNameHasBadChar',...
            d,d(badpos));
        end
        if~canConvertUTF16ToLCP(d)
            ccdiagnosticid('Coder:configSet:FolderBadUTF162LCPCompat',d);
        end
    end


    function checkTflConfiguration()


        TflStr=CC.ConfigInfo.CodeReplacementLibrary;
        hw=CC.ConfigInfo.HardwareImplementation;
        if hw.ProdEqTarget
            HwStr=hw.ProdHWDeviceType;
        else
            HwStr=hw.TargetHWDeviceType;
        end
        CC.CRLControl.validateTflHw(TflStr,HwStr);

        tr=emcGetTargetRegistry();
        lCompilerForModel=CC.ConfigInfo.Toolchain;
        coder.internal.checkCrlToolchainCompatibility(TflStr,tr,lCompilerForModel);
    end


    function report=adjustscripts(report)
        for i=1:length(report.scripts)
            [unicodemap,mnormal]=makeunicodemap(report.scripts{i}.ScriptText);
            report.scripts{i}.unicodemap=unicodemap;
            report.scripts{i}.mnormal=mnormal;
            report.scripts{i}.linemap=makeLineMap(report.scripts{i}.ScriptText,unicodemap);
        end
    end


    function[boolean]=hasReportableMessages(report)
        boolean=~isempty(report.summary.messageList);
    end


    function[boolean]=hasGPUReportableMessages(report)
        boolean=CC.isGpuTarget()&&gpuCodeGenInfoHasActionableMessages(report);
    end


    function report=checkBuildLogForWarnings(report)
        if~CC.isPureMatlabCoder()
            return;
        end
        if~isfield(report,'summary')
            return;
        end
        if~isfield(report.summary,'buildResults')
            return;
        end
        buildResults=report.summary.buildResults;
        if isempty(buildResults)||isempty(buildResults{1})
            return;
        end
        if isempty(buildResults{1}.Log)
            return;
        end
        buildLog=buildResults{1}.Log;
        lines=regexp(buildLog,'\n','split');

        targetLang='C';
        if CC.isTargetLangCPP()
            targetLang='C++';
        end
        for i=1:numel(lines)
            line=lines{i};
            lineClass=emcGetBuildLineClass(line,CC.CompilerName);
            if strcmp(lineClass,'warning')
                msg.ScriptID=1;
                msg.FunctionID=1;
                msg.MsgTypeName='Warning';
                msg.isFcnCallFailed=false;
                msg.TextStart=-1;
                msg.TextLength=-1;
                msg.MsgID='Coder:buildProcess:targetCompilerWarnings';

                msg.MsgText=message(msg.MsgID,targetLang).getString;
                report.summary.coderMessages{end+1}=msg;
                report.summary.messageList{end+1}=msg;
                break;
            end
        end
    end


    function reportCompilationStarted()
        if verbose()
            fcnNames=CC.Project.EntryPoints(1).Name;
            if numel(CC.Project.EntryPoints)>1
                for i=2:numel(CC.Project.EntryPoints)-1
                    fcnNames=sprintf('%s, %s',fcnNames,CC.Project.EntryPoints(i).Name);
                end
                fcnNames=sprintf('%s and %s',fcnNames,CC.Project.EntryPoints(end).Name);
            end
            verboseDisp(message('Coder:common:VerboseCompleFunc',fcnNames).getString);
        end
    end


    function verboseDisp(msg)
        if verbose()
            fprintf(msg);
        end
    end


    function handleError(err)
        if isempty(err.cause)
            s=err.message;
        else

            err=coderprivate.makeCause(err);
            s=err.getReport();
        end

        matlab.internal.display.printWrapped(s);


        if HasDesktop
            href=sprintf('matlab: help(''%s'')',CC.clientName());
            msg=message('Coder:reportGen:UsageLinked',href,CC.clientName());
        else
            msg=message('Coder:reportGen:Usage',CC.clientName());
        end
        disp(msg.getString());
        cleanupHardware();
        cleanupHdl();
        cleanupDeepLearning();
        CC.cleanupGpu();
    end


    function cleanupHardware()
        if CC.codingRtw()
            cfg=CC.ConfigInfo;
            if isprop(cfg,'Hardware')&&~isempty(cfg.Hardware)
                cfg.Hardware.errorHandler(cfg);
            end
        end
    end


    function mexFile=genXILMEXFileName(isSILTesting)



        if isSILTesting
            suffix='sil';
        else
            suffix=lower(CC.ConfigInfo.VerificationMode);
        end
        if numel(CC.Project.EntryPoints)==1
            mexFile=[CC.Project.Name,'_',suffix,'.',mexext];
        else
            mexFile=[CC.Project.FileName,'_',suffix,'.',mexext];
        end
    end


    function result=runTestBench(result)

        if CC.CommandArgs.GenCodeOnly
            error(message('Coder:FE:RunTestMustCompile'));
        end
        if~ischar(CC.CommandArgs.runTestFile)
            error(message('Coder:FE:TestBenchNameIsNotString'));
        end
        testFile=CC.CommandArgs.runTestFile;
        EP=cell(1,numel(CC.Project.EntryPoints));
        for i=1:numel(CC.Project.EntryPoints)
            EP{i}=CC.Project.EntryPoints(i).Name;
        end

        if~isequal(CC.Project.PolyMexType,'None')
            EP=CC.Project.EntryPoints(1).OriginName;
        end
        if CC.codingMex
            mexFile=CC.Project.FileName;
        elseif isprop(CC.ConfigInfo,'VerificationMode')&&...
            (strcmpi(CC.ConfigInfo.VerificationMode,'sil')==1||...
            strcmpi(CC.ConfigInfo.VerificationMode,'pil')==1)
            mexFile=genXILMEXFileName(false);
        else
            error(message('Coder:FE:RunTestOnlySupportMexOrSIL'));
        end

        turnOnProfiling=CC.codingMex&&CC.ConfigInfo.EnableMexProfiling;
        if turnOnProfiling
            msgID='Coder:FE:RunTestBenchWithMexProfileOn';
        else
            msgID='Coder:FE:RunTestBenchWithMex';
        end
        matlab.internal.display.printWrapped(message(msgID,testFile,mexFile).getString());
        result.summary.testBenchName=testFile;
        result.summary.testBenchPath=evalc(['which ',testFile]);

        try
            runTest(testFile,EP,mexFile,turnOnProfiling);
            result.summary.testBenchPassed=true;
        catch ME
            result.summary.testBenchPassed=false;
            newME=coderprivate.makeCause(ME);
            result.summary.testBenchDetails=getReport(newME);
        end

        function runTest(testFile,EP,mexFile,turnOnProfiling)
            if turnOnProfiling
                profile('on');
            end

            coder.runTest(testFile,EP,mexFile);

            c=onCleanup(@()profilerCleanup(turnOnProfiling));
        end

        function profilerCleanup(profileOn)
            if profileOn
                profile('viewer');
            end
        end
    end


    function checkSettingsForXIL()

        if coder.connectivity.MATLABSILPIL.emcIsXILEnabled(CC.ConfigInfo,CC.Project)

            coder.connectivity.MATLABSILPIL.RTWErrorCheckHook(CC.ConfigInfo,CC.Project);
        end
    end


    function ret=isReportingPotentialDifferences()
        cfg=CC.ConfigInfo;
        isReportPotentialDifferences=(isprop(cfg,'ReportPotentialDifferences')&&cfg.ReportPotentialDifferences);
        isGenReport=(cfg.GenerateReport||CC.isJavaPrjBuild());
        isReportInfo=(isprop(cfg,'ReportInfoVarName')&&~isempty(cfg.ReportInfoVarName));
        ret=isReportPotentialDifferences&&(isGenReport||isReportInfo);
    end


    function isCompatible=checkPolyMexCompatibility()
        if(~isPolymexSupportedConfig&&CC.Options.PolyMexOptions.treatedAsPolyMex&&CC.Options.PolyMexOptions.hasMultipleArgs)
            emlcprivate('ccdiagnosticid','Coder:common:MultipleCoderTypes');
        end

        if(CC.isGpuTarget()&&isPolymexSupportedConfig()&&CC.Options.PolyMexOptions.treatedAsPolyMex)
            ccdiagnosticid('Coder:configSet:MultiSignatureMexNotSupportedForGPUCoder');
        end


        isCompatible=isPolymexSupportedConfig()&&CC.Options.PolyMexOptions.treatedAsPolyMex;
    end


    function isSupported=isPolymexSupportedConfig()
        isSupported=false;
        if CC.codingMex()
            isSupported=true;
            return;
        end

        if CC.Project.FeatureControl.EnablePolymorphicLib&&~isempty(CC.ConfigInfo)&&CC.codingRtw()
            isSupported=true;
            return
        end
    end


    function preparePolyMexEntryPoints()
        assert(~isempty(CC.Project.EntryPoints));



        if~isequal(CC.Project.EntryPoints.Name)

            if~CC.Project.FeatureControl.EnableMultiEntryPolyMex
                ccdiagnosticid('Coder:common:MultipleCoderTypes');
            end
            CC.Project.PolyMexType='MultiEntry';

            entrySet=partitionEntryPoints();
            decisionTreeInfo.NumEntryPoints=numel(entrySet);
            decisionTreeInfo.MultiEntryDecisionTree=cell(1,numel(entrySet));
            for i=1:numel(entrySet)
                decisionTree=generateDecisionTree(entrySet{i});
                entryPtInfo.EntryPtName=entrySet{i}(1).OriginName;
                entryPtInfo.decisionTree=decisionTree;
                decisionTreeInfo.MultiEntryDecisionTree{i}=entryPtInfo;
            end
            CC.Project.MultiEntryDecisionTreeInfo=decisionTreeInfo;
            return;
        end

        CC.Project.DecisionTree=generateDecisionTree(CC.Project.EntryPoints);
    end


    function entryPtSet=partitionEntryPoints()
        etryNames={CC.Project.EntryPoints(:).Name};
        [C,~,ic]=unique(etryNames);
        entryPtSet=cell(1,numel(C));
        for idx=1:numel(C)
            entryPtSet{idx}=CC.Project.EntryPoints(ic==idx);
        end
    end


    function decisionTree=generateDecisionTree(EntryPoints)
        numEntryPts=numel(EntryPoints);
        polyEntrySignature=cell(numEntryPts,1);



        nUserInputs=nnz([EntryPoints.HasUserNumOutputs]);

        if(nUserInputs==1)
            userInputEntryIdx=find([EntryPoints.HasUserNumOutputs]==1);
            CC.Options.PolyMexOptions.userNumOutputs=repmat(EntryPoints(userInputEntryIdx(1)).UserNumOutputs,1,numEntryPts);
            nUserInputs=numEntryPts;
        else
            CC.Options.PolyMexOptions.userNumOutputs=[EntryPoints.UserNumOutputs];
        end

        for entryPtIdx=1:numEntryPts
            currentName=EntryPoints(entryPtIdx).Name;
            newName=strcat(currentName,num2str(entryPtIdx));
            EntryPoints(entryPtIdx).Name=newName;
            if(CC.Options.PolyMexOptions.hasUserNumOutputs&&entryPtIdx<=nUserInputs)
                EntryPoints(end).HasUserNumOutputs=true;
                EntryPoints(entryPtIdx).UserNumOutputs=CC.Options.PolyMexOptions.userNumOutputs(entryPtIdx);
            end

            ipTypes=EntryPoints(entryPtIdx).InputTypes;

            inputStruct=struct;
            for typeIdx=1:numel(ipTypes)
                inputStruct.(['fInput',num2str(typeIdx)])=ipTypes{typeIdx};
            end

            polyEntrySignature{entryPtIdx}=struct('idx',entryPtIdx,'val',inputStruct);
        end


        decisionTree=coder.internal.generateDecisionTree(CC,polyEntrySignature);
    end


    function doC89CrlAutoFallback()

        if CC.codingRtw()&&isprop(CC.ConfigInfo,'CodeReplacementLibrary')...
            &&~isempty(CC.ConfigInfo.CodeReplacementLibrary)&&strcmpi(CC.ConfigInfo.TargetLang,'C')

            if rtwprivate('isTargetLangSupportedByTFL',CC.ConfigInfo.CodeReplacementLibrary,getActualTargetLangStandard(CC.ConfigInfo),true)==0
                ccwarningid('Coder:buildProcess:C99IncompatibleTFL');
                CC.ConfigInfo.TargetLangStandard='C89/C90 (ANSI)';
            else

                libNames=coder.internal.getCrlLibraries(CC.ConfigInfo.CodeReplacementLibrary);
                n=length(libNames);
                tr=emcGetTargetRegistry();
                for i=1:n
                    currentCrl=coder.internal.getTfl(tr,libNames{i});
                    tflTableList=coder.internal.getTflTableList(tr,libNames{i});
                    if~isempty(currentCrl)&&~currentCrl.IsLangStdTfl&&~isempty(find(strcmpi(tflTableList,'ansi_tfl_table_tmw.mat'),1))
                        ccwarningid('Coder:buildProcess:C99IncompatibleTFL');
                        CC.ConfigInfo.TargetLangStandard='C89/C90 (ANSI)';
                        break;
                    end
                end
            end
        end
    end


    function name=generateVerificationMEXFilename()
        name='';
        if CC.codingMex()
            return
        end
        isNormalXIL=isprop(CC.ConfigInfo,'VerificationMode')&&...
        (strcmpi(CC.ConfigInfo.VerificationMode,'sil')==1||...
        strcmpi(CC.ConfigInfo.VerificationMode,'pil')==1);
        isSILTesting=isSILTestingOn(CC.Project.FeatureControl);
        if isNormalXIL||isSILTesting
            name=genXILMEXFileName(isSILTesting);
        end
    end


    function doC89AutoFallback
        if CC.codingMex()&&CC.ConfigInfo.ForceANSIC
            return;
        end
        if CC.codingRtw()&&strcmpi(CC.ConfigInfo.TargetLangStandard,'C89/C90 (ANSI)')
            return
        end

        if strcmp(CC.CompilerName,'lcc64')
            if CC.codingMex()
                CC.ConfigInfo.ForceANSIC=true;
            else
                ccwarningid('Coder:buildProcess:C99IncompatibleCompiler');
                CC.ConfigInfo.TargetLangStandard='C89/C90 (ANSI)';
            end
            return;
        end

        doC89CrlAutoFallback();
    end


    function validateClassMethodName()



        entryPts=CC.Project.EntryPoints;
        mc=meta.class.fromName(CC.CommandArgs.ClassName);
        methodNameCell={mc.MethodList.Name};
        for i=1:numel(entryPts)
            currentEntryPt=entryPts(i);
            methodName=currentEntryPt.Name;
            methodIdx=find(strcmp(methodNameCell,methodName),1);
            if isempty(methodIdx)

                if checkCustomSetterGetterMethod(mc,methodName)
                    continue;
                end
                error(message('Coder:builtins:MCOSMethodNotFound',methodName,CC.CommandArgs.ClassName));
            end
        end
    end


    function setupExportStyle
        if CC.codingMex||strcmp(CC.codingTarget,'rtw:dll')
            if strcmp(CC.CompilerName,'lcc64')
                CC.Project.FeatureControl.ExportStyle='File';
                return;
            end
            if CC.Project.FeatureControl.ExportStyle=="Auto"
                if CC.isTargetLangCPP()
                    CC.Project.FeatureControl.ExportStyle='Macro';
                else
                    CC.Project.FeatureControl.ExportStyle='File';
                end
            end
            return;
        end
        CC.Project.FeatureControl.ExportStyle='Auto';
    end


    function enableHalf
        if(CC.isCodeGenClient()||CC.isPSTestClient())&&(CC.codingMex()||CC.codingRtw()||CC.isGpuTarget())
            CC.Project.FeatureControl.HalfSupport=true;
        end
        if CC.isGpuTarget()
            CC.Project.FeatureControl.HalfComplexSupport=false;
        end
    end


    function enableCppRenamer
        if CC.isCodeGenClient()||CC.isDlAccelClient()||CC.isPSTestClient()
            CC.Project.FeatureControl.EnableCppRenamer=true;
        end
    end


    function setDebugOutput(outputName,outputValue)
        if~isempty(CC.ExtraCodegenOutputs)&&ismember(outputName,CC.ExtraCodegenOutputs)
            extraOutputs.(outputName)=outputValue;
        end
    end
end




function doCleanup(origFolder)
    cd(origFolder);

    emcGetMexCompiler();

    coder.report.RegisterCGIRInspectorResults.clearResults();
end


function compilerName=getBTICompilerName(lToolchainInfo)
    compilerName=coder.make.getMexShortNameForHostToolchain(lToolchainInfo);
    if isempty(compilerName)
        compilerName='Unknown';
    end
end


function flag=checkCustomSetterGetterMethod(mc,methodName)

    flag=false;
    if~contains(methodName,'.')
        return;
    end
    for i=1:numel(mc.PropertyList)
        fh=mc.PropertyList(i).SetMethod;
        if~isempty(fh)&&checkSubstring(fh,methodName)
            flag=true;
            return;
        end
        fh=mc.PropertyList(i).GetMethod;
        if~isempty(fh)&&checkSubstring(fh,methodName)
            flag=true;
            return;
        end
    end

    function flag=checkSubstring(fh,mthdname)
        flag=false;
        fhstr=func2str(fh);
        strtoken=split(fhstr,'.');
        methodstrtoken=split(mthdname,'.');
        if isequal(strtoken(end-1:end),methodstrtoken)
            flag=true;
            return;
        end
    end
end


function name=generateFinalOutputFileName(reportSummary,configInfo)
    if strcmpi(reportSummary.codingTarget,'MEX')
        suffix=['.',mexext];
    else

        if isprop(configInfo,'Toolchain')
            tci=coder.make.internal.getToolchainInfoFromName(configInfo.Toolchain);
        else
            name='';
            return;
        end
        if strcmpi(reportSummary.codingTarget,'RTW:DLL')
            suffix=tci.getBuildTool('Linker').getFileExtension('Shared Library');
        elseif strcmpi(reportSummary.codingTarget,'RTW:LIB')
            suffix=tci.getBuildTool('Archiver').getFileExtension('Static Library');
        else
            suffix=tci.getBuildTool('Linker').getFileExtension('Executable');
        end
    end
    name=[reportSummary.fileName,suffix];
end


function dumpBuildLog(buildResults)
    if~iscell(buildResults)
        buildResults={buildResults};
    end
    for i=1:numel(buildResults)
        buildResult=buildResults{i};
        if~isempty(buildResult)
            disp(repmat('-',1,72));
            disp(buildResult);
            disp(repmat('-',1,72));
        end
    end
end


function[booleanResult]=gpuCodeGenInfoHasActionableMessages(report)
    booleanResult=false;
    if~isfield(report,'inference')||isempty(report.inference)
        return;
    end

    allFcns=report.inference.Functions;
    scripts=report.inference.Scripts;

    scriptCount=numel(scripts);
    allFcnScriptIds=[allFcns.ScriptID];

    mask=allFcnScriptIds>0&allFcnScriptIds<=scriptCount;

    if numel(allFcns)>1
        mask(mask)=[scripts(allFcnScriptIds(mask)).IsUserVisible];
        for i=find(~mask)
            fcn=allFcns(i);
            if~isempty(fcn.Messages)
                mask(i)=true;
            elseif fcn.IsExtrinsic||fcn.IsAutoExtrinsic
                mask(i)=true;
            end
        end
    end

    includedFunctionIds=find(mask);


    if isempty(includedFunctionIds)
        return;
    end
    MAT_DIAGNOSTICS_VAR='diagnostics';
    matFile=fullfile(report.summary.buildDirectory,'gpu_codegen_info.mat');
    fileInfo=whos('-file',matFile);

    if isfield(fileInfo,'name')&&ismember(MAT_DIAGNOSTICS_VAR,{fileInfo.name})
        rawData=load(matFile,MAT_DIAGNOSTICS_VAR);
        rawData=rawData.diagnostics;

        results=cellfun(@(f)gpuCodeGenCheckCategory(includedFunctionIds,f,rawData.(f)),...
        fieldnames(rawData),'UniformOutput',false);
        if(any([results{:}]))
            booleanResult=true;
            return
        end
    end
end


function booleanResult=gpuCodeGenCheckCategory(includedFunctionIds,categoryId,subCats)
    booleanResult=false;
    if isempty(subCats)||isempty(vertcat(subCats.locations))
        return;
    end
    assert(ismember(categoryId,{'kernelCreation','memory','pragma','designPattern','other'}),...
    'Unrecognized category ID. Changing category IDs require coordinated changes in several files');

    for i=1:numel(subCats)
        includedLocs=subCats(i).locations(ismember([subCats(i).locations.rid],includedFunctionIds));
        if~isempty(includedLocs)
            booleanResult=true;
            return;
        end
    end
end


function generateDockerImage()
    coder.internal.package.docker(CC.Project.FeatureControl.BaseDockerImage,...
    CC.Project.FeatureControl.DockerImageName,...
    CC.Project.FeatureControl.DockerArtifactsToCopy,...
    CC.Project.FeatureControl.DockerArtifactsDestPath,...
    CC.Options.BldDirectory);
end


function cleanupDeepLearning()

    clear(which('coder.loadMatObj'));
end










