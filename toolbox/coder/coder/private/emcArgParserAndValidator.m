function emcArgParserAndValidator(CC,varargin)




    argc=1;
    nargs=nargin-1;
    arg='';
    function a=itCurrent()
        if argc>numel(varargin)
            ccdiagnosticid('Coder:configSet:MissingParameterOption',arg);
        end
        a=varargin{argc};
    end

    function b=itHasCurrent()
        b=argc<=nargs;
    end

    function itAdvance()
        argc=argc+1;
    end

    function parseStd(arg)

        if strcmpi('C89/C90',arg)||strcmpi('C89',arg)||...
            strcmpi('C90',arg)||strcmpi('ANSI',arg)
            CC.CommandArgs.TargetLangStandard='C89/C90 (ANSI)';
        elseif strcmpi(arg,'C99')
            CC.CommandArgs.TargetLangStandard='C99 (ISO)';
        elseif strcmpi('C++03',arg)
            CC.CommandArgs.TargetLangStandard='C++03 (ISO)';
        elseif strcmpi('C++11',arg)
            CC.CommandArgs.TargetLangStandard='C++11 (ISO)';
        end
    end

    function setReportOptions()
        CC.CommandArgs.GenerateReport=true;
    end

    hasCudaCustomFile=false;
    while itHasCurrent()
        arg=itCurrent();
        if~ischar(arg)
            if isstring(arg)&&isscalar(arg)
                arg=char(arg);
            else
                disp(arg);
                ccdiagnosticid('Coder:configSet:CannotProcessOptions');
            end
        end
        arg=strtrim(arg);
        if isempty(arg)
            ccdiagnosticid('Coder:configSet:CannotProcessOptions');
        end
        if coder.internal.isOptionPrefix(arg)
            if numel(arg)<2
                unrecognizedOption(arg);
            end
            switch arg(2:end)
            case 'c'
                checkEMLC(CC,arg);
                CC.CommandArgs.GenCodeOnly=true;
            case{'d','outputdir'}
                itAdvance();
                CC.Options.LogDirectory=coder.internal.toCharIfString(itCurrent());
                CC.Project.IsUserSpecifiedOutputDir=true;
            case{'audioplugindumpdir'}
                if CC.isAudioPluginClient()
                    itAdvance();
                    CC.Options.AudioPluginDumpDirectory=coder.internal.toCharIfString(itCurrent());
                else
                    unrecognizedOption(arg);
                end
            case 'eg'
                ccdiagnosticid('Coder:configSet:DeprecatedOption','-eg','-args');
            case 'args'
                itAdvance();
                ty=itCurrent();
                CC.parseCoderTypes(ty);
            case 'nargout'
                itAdvance();
                setUserNumOutputs(CC,itCurrent());
            case{'global','globals'}


                itAdvance();
                gv=itCurrent();
                if~isempty(gv)
                    parseInitGlobalValues(CC,gv);
                end
            case{'g','G','debug'}
                CC.CommandArgs.EnableDebugging=true;
            case{'I','include'}
                itAdvance();
                dir=itCurrent();
                if coder.internal.isCharOrScalarString(dir)
                    if startsWith(dir,'[')
                        dir=eval(dir);
                    end
                    CC.addSearchPath(coder.internal.toCharIfString(dir));
                else
                    ccdiagnosticid('Coder:configSet:CannotProcessOptions');
                end
            case{'o','outputfile'}
                itAdvance();
                CC.Options.outputfile=coder.internal.toCharIfString(itCurrent());
            case{'O','optim'}
                itAdvance();
                parseOptimization(CC,itCurrent());
            case 'launchreport'
                setReportOptions();
                CC.CommandArgs.LaunchReport=true;
            case 'report'
                setReportOptions();
            case 'reportinfo'
                itAdvance();
                value=itCurrent();
                checkForValidMATLABVariableName(CC.clientName(),'-reportinfo',value);
                CC.CommandArgs.ExportCodegenInfo=true;
                CC.Options.CodegenInfoVarName=coder.internal.toCharIfString(value);
            case 'config'
                itAdvance();
                parseConfig(CC,itCurrent());
            case 'float2fixed'
                itAdvance();
                cfg=itCurrent();
                if isa(cfg,'coder.FixPtConfig')
                    parseConfig(CC,cfg);
                else
                    ccdiagnosticid('Coder:common:NotAFixPtConfig');
                end
            case 'fixPtData'
                itAdvance();
                CC.FixptData=itCurrent();
            case 'config:mex'
                parseConfig(CC,coder.config('mex'));
            case 'config:lib'
                parseConfig(CC,defaultConfig('lib'));
            case 'config:dll'
                parseConfig(CC,defaultConfig('dll'));
            case 'config:exe'
                parseConfig(CC,defaultConfig('exe'));
            case 'config:hdl'
                parseConfig(CC,coder.config('hdl'));
            case 'config:plc'
                parseConfig(CC,coder.config('plc'));
            case 'config:single'
                parseConfig(CC,coder.config('single'));
            case 'feature'
                itAdvance();
                parseFeatureControl(CC,itCurrent());
            case 'T'
                ccdiagnosticid('Coder:configSet:DeprecatedOption','-T','-config');
            case 'v'
                checkEMLC(CC,arg);
                CC.CommandArgs.Verbose=true;
                CC.CommandArgs.Silent=false;
            case 'silent'
                checkEMLC(CC,arg);
                CC.CommandArgs.Silent=true;
                CC.CommandArgs.Verbose=false;
            case '?'
                CC.Options.help=true;
            case 'profile'
                CC.CommandArgs.EnableMexProfiling=true;
            case 'rowmajor'
                checkEMLC(CC,arg);
                CC.CommandArgs.RowMajor=true;
            case 'preservearraydims'
                checkEMLC(CC,arg);
                CC.CommandArgs.PreserveArrayDims=true;
            case 'jit'
                checkEMLC(CC,arg);
                CC.CommandArgs.EnableJIT=true;
            case 'test'
                checkEMLC(CC,arg);
                CC.CommandArgs.runTest=true;
                itAdvance();
                CC.CommandArgs.runTestFile=itCurrent();
            case 'j'
                itAdvance();
                numCompileJobs=itCurrent();
                validateattributes(numCompileJobs,{'numeric'},{'scalar','integer','>=',0},CC.clientName(),'-j');
                CC.CommandArgs.NumCompileJobs=numCompileJobs;
            case 'toproject'
                checkEMLC(CC,arg);
                itAdvance();
                projectFilename=itCurrent();
                validateattributes(projectFilename,{'char','string'},{'scalartext','nonempty'},CC.clientName,'-toproject');
                CC.Options.generatedProjectFile=projectFilename;
            case 'package'
                itAdvance();
                packageFilename=itCurrent();
                validateattributes(packageFilename,{'char','string'},{'scalartext','nonempty'},CC.clientName,'-package');
                CC.Options.packageFile=packageFilename;
            case 'class'
                if(CC.hasEntryPoint())
                    ccdiagnosticid('Coder:FE:ClassFlagFirst');
                end
                itAdvance();
                CC.Project.IsClassAsEntrypoint=true;
                parseClassAsEP(CC,itCurrent());

            case '-codeGenWrapper'
                itAdvance();
                CC.Project.CodeGenWrapper=itCurrent();
            case '-javaConfig'
                itAdvance();
                CC.JavaConfig=itCurrent();
            case '-fromFixPtConversion'


                itAdvance();
                CC.FixptSummary=itCurrent();
            case '-parseOnly'
                CC.Options.parseOnly=true;
            case '-preserve'
                CC.Options.preserve=true;
            case '-dumpCgelPrecheck'
                CC.Project.FeatureControl.DumpCgelPrecheck=true;
            case '-dumpCgelPostcheck'
                CC.Project.FeatureControl.DumpCgelPostcheck=true;
            case '-dumpCgelPostcompile'
                CC.Project.FeatureControl.DumpCgelPostcompile=true;
            case '-noCodegen'
                CC.Project.FeatureControl.PerformCodegen=false;
            case '-extraOutputs'


                itAdvance();
                CC.ExtraCodegenOutputs=itCurrent();
            otherwise
                currArgs=strsplit(itCurrent(),{':','='});

                if numel(currArgs)==1
                    unrecognizedOption(arg)
                else
                    switch currArgs{1}
                    case '-lang'
                        CC.CommandArgs.TargetLang=currArgs{2};
                    case '-std'
                        CC.CommandArgs.TargetLangStandard=currArgs{2};
                    otherwise
                        unrecognizedOption(arg);
                    end
                end
            end
        else
            hasCudaCustomFile=parseFilename(CC,arg)||hasCudaCustomFile;
        end
        itAdvance();
    end




    if hasCudaCustomFile&&CC.codingMex()&&~CC.isGpuTarget()
        ccdiagnosticid('Coder:configSet:UnsupportedFileExtensionWithoutGPUCoder');
    end

    if CC.Options.help
        genHelp(CC.clientName());
        if~CC.hasEntryPoint()
            return;
        end
    end

    if CC.ParsedCommandConfig&&CC.ParsedProjectFile
        ccdiagnosticid('Coder:common:ConfigObjectWithProjectFile');
    end

    if isempty(CC.ConfigInfo)
        createDefaultConfigObject(CC);
    end

    if CC.isGpuTarget()&&isprop(CC.ConfigInfo,'CustomBLASCallback')&&...
        ~isempty(CC.ConfigInfo.CustomBLASCallback)
        ccdiagnosticid('Coder:common:CustomBLASCallbackGPU');
    end
    if~isempty(CC.ConfigHardware)
        applyConfigHardware(CC);
    end

    cfg=CC.ConfigInfo;
    if~isempty(CC.CommandArgs.TargetLang)
        if isprop(cfg,'TargetLang')
            applyNonEmptyCommandArg(CC.CommandArgs,'TargetLang',cfg);
        else
            ccdiagnosticid('Coder:configSet:NoLang',class(cfg));
        end
    end
    if~isempty(CC.CommandArgs.TargetLangStandard)
        parseStd(CC.CommandArgs.TargetLangStandard);
        if isprop(cfg,'TargetLangStandard')
            applyNonEmptyCommandArg(CC.CommandArgs,'TargetLangStandard',cfg);
        else
            ccdiagnosticid('Coder:configSet:NoLangStandard',class(cfg));
        end
    end
    applyNonEmptyCommandArg(CC.CommandArgs,'EnableOpenMP',cfg);
    disableParallel=true;
    if~isa(cfg,'coder.internal.FeatureControl')
        cfg.GenerateReport=cfg.GenerateReport||CC.CommandArgs.GenerateReport;
        cfg.LaunchReport=cfg.LaunchReport||CC.CommandArgs.LaunchReport;
        if isprop(cfg,'ReportInfoVarName')
            if CC.CommandArgs.ExportCodegenInfo


                cfg.ReportInfoVarName=CC.Options.CodegenInfoVarName;
            end
            if~isempty(cfg.ReportInfoVarName)
                checkForValidMATLABVariableName(CC.clientName(),'ReportInfoVarName',cfg.ReportInfoVarName);
            end
        elseif CC.CommandArgs.ExportCodegenInfo


            ccdiagnosticid('Coder:configSet:UnrecognizedOption','-reportinfo');
        end
        if isa(cfg,'coder.EmbeddedCodeConfig')
            cfg.GenerateCodeReplacementReport=cfg.GenerateCodeReplacementReport||CC.CommandArgs.GenerateCodeReplacementReport;
        end



        if isprop(cfg,'RowMajor')
            cfg.RowMajor=cfg.RowMajor||CC.CommandArgs.RowMajor;
        elseif CC.CommandArgs.RowMajor
            throw(MException(message('Coder:configSet:UnsupportedOptionForCurrentConfig','-rowmajor')));
        end

        if isprop(cfg,'PreserveArrayDimensions')
            cfg.PreserveArrayDimensions=cfg.PreserveArrayDimensions||CC.CommandArgs.PreserveArrayDims;
        elseif CC.CommandArgs.PreserveArrayDims
            throw(MException(message('Coder:configSet:UnsupportedOptionForCurrentConfig','-preservearraydims')));
        end

        if isprop(cfg,'EliminateSingleDimensions')
            cfg.EliminateSingleDimensions=cfg.EliminateSingleDimensions||CC.CommandArgs.EliminateSingleDims;
        end

        if isa(cfg,'coder.MexConfig')&&~isa(cfg,'coder.MexCodeConfig')
            cfg.EnableDebugging=cfg.EnableDebugging||CC.CommandArgs.EnableDebugging;
        else
            if isa(cfg,'coder.EmbeddedCodeConfig')||isa(cfg,'coder.CodeConfig')
                cfg.GenCodeOnly=cfg.GenCodeOnly||CC.CommandArgs.GenCodeOnly;
                if CC.CommandArgs.EnableDebugging
                    cfg.BuildConfiguration='Debug';
                end
                disableParallel=~cfg.EnableOpenMP;
            elseif isa(cfg,'coder.MexCodeConfig')
                cfg.GenCodeOnly=cfg.GenCodeOnly||CC.CommandArgs.GenCodeOnly;
                cfg.EnableDebugging=cfg.EnableDebugging||CC.CommandArgs.EnableDebugging;
                disableParallel=~cfg.EnableOpenMP||~strcmp(CC.Project.FeatureControl.LocationLogging,'Off');
            elseif isa(cfg,'coder.HdlConfig')
                if isempty(cfg.DesignFunctionName)
                    cfg.DesignFunctionName=CC.Project.EntryPoints(end).Name;
                end
                if~CC.ParsedProjectFile
                    updateHDLCodeGenDir(CC);
                end
            elseif isa(cfg,'coder.FixPtConfig')
                CC.updateFixptCodeGenDir();
                if isempty(cfg.DesignFunctionName)
                    cfg.DesignFunctionName=CC.Project.EntryPoints(end).Name;
                end
                if~isempty(CC.Project.SearchPath)
                    cfg.setSearchPaths(CC.Project.SearchPath);
                end
            end

            if~isa(cfg,'coder.HdlConfig')&&~isa(cfg,'coder.PLCConfig')&&~isa(cfg,'coder.FixPtConfig')&&~isa(cfg,'coder.DvoRangeAnalysisConfig')
                [cfg.CustomSource,warnSource]=processFileNameAndPath(cfg.CustomSource,CC.CommandArgs.CustomSource,pathsep);
                [cfg.CustomInclude,warnInclude]=processFileNameAndPath(cfg.CustomInclude,CC.CommandArgs.CustomInclude,pathsep);
                [cfg.CustomLibrary,warnLibrary]=processFileNameAndPath(cfg.CustomLibrary,CC.CommandArgs.CustomLibrary,pathsep);
                if~isempty(CC.CommandArgs.CustomSourceCode)
                    cfg.CustomSourceCode=[cfg.CustomSourceCode,' ',CC.CommandArgs.CustomSourceCode];
                end



                if(warnSource||warnInclude||warnLibrary)
                    warning(message('Coder:buildProcess:DeprecatedMultiSourceFile'));
                end
            end

            if CC.codingFixPt()&&CC.ParsedProjectFile


                ccdiagnosticid('Coder:common:FixPtConverterUnsupportedCoderBuild');
            end
        end
    end

    if isprop(cfg,'Verbosity')
        if CC.CommandArgs.Verbose
            cfg.Verbosity='Verbose';
        elseif CC.CommandArgs.Silent
            cfg.Verbosity='Silent';
        end
    end

    if isprop(cfg,'NumCompileJobs')
        cfg.NumCompileJobs=CC.CommandArgs.NumCompileJobs;
    end

    if CC.isFiaccelClient()
        if CC.Options.preserve==true&&isprop(cfg,'EnableJIT')
            cfg.EnableJIT=false;
        end
    else

        if isa(cfg,'coder.MexConfig')&&~isa(cfg,'coder.MexCodeConfig')
            cfg.EnableJIT=false;
        end
    end

    if CC.CommandArgs.EnableJIT
        if~isa(cfg,'coder.MexCodeConfig')
            ccwarningid('Coder:FE:JitNotSupported');
        else
            cfg.EnableJIT=CC.CommandArgs.EnableJIT||cfg.EnableJIT;
        end
    end

    if CC.CommandArgs.EnableMexProfiling
        if~isa(cfg,'coder.MexCodeConfig')
            ccwarningid('Coder:FE:ProfilingNotSupported');
        else
            cfg.EnableMexProfiling=CC.CommandArgs.EnableMexProfiling||cfg.EnableMexProfiling;
        end
    end

    if~isempty(CC.CommandArgs.runTestFile)
        if~isa(cfg,'coder.MexCodeConfig')...
            &&~isa(cfg,'coder.EmbeddedCodeConfig')...
            &&~isa(cfg,'coder.CodeConfig')
            error(message('Coder:FE:RunTestOnlySupportMexOrSIL'));
        end

        if CC.CommandArgs.EnableMexProfiling
            p=profile('status');
            if strcmp(p.ProfilerStatus,'on')
                error(message('Coder:FE:ProfilingAlreadyOn'));
            end
        end
    end

    if isa(cfg,'coder.MexCodeConfig')&&cfg.EnableJIT&&cfg.GenCodeOnly
        error(message('Coder:FE:JitIncompWithGenCodeOnly'));
    end

    if isa(cfg,'coder.MexCodeConfig')&&cfg.EnableMexProfiling&&CC.isGpuTarget()
        ccwarningid('Coder:FE:ProfilingGPUNotSupported');
    end

    if(isa(cfg,'coder.CodeConfig')||isa(cfg,'coder.MexCodeConfig'))...
        &&cfg.EnableAutoParallelization...
        &&~(~isempty(cfg.GpuConfig)&&cfg.GpuConfig.Enabled)
        if~cfg.EnableOpenMP
            ccwarningid('Coder:FE:AutoParEnableOpenMP');
        end
        if isa(cfg,'coder.MexCodeConfig')&&cfg.EnableJIT
            ccwarningid('Coder:FE:AutoParDisableJIT');
        end
    end

    if~isempty(CC.CommandArgs.HwConfig)
        cfg.HardwareImplementation=CC.CommandArgs.HwConfig;
    end
    if~isempty(CC.CommandArgs.InlineBetweenUserFunctions)
        cfg.InlineBetweenUserFunctions=CC.CommandArgs.InlineBetweenUserFunctions;
    end
    if~isempty(CC.CommandArgs.InlineBetweenUserAndMathWorksFunctions)
        cfg.InlineBetweenUserAndMathWorksFunctions=CC.CommandArgs.InlineBetweenUserAndMathWorksFunctions;
    end
    if~isempty(CC.CommandArgs.InlineBetweenMathWorksFunctions)
        cfg.InlineBetweenMathWorksFunctions=CC.CommandArgs.InlineBetweenMathWorksFunctions;
    end

    if CC.Project.IsClassAsEntrypoint
        if(CC.hasEntryPoint())
            error(message('Coder:builtins:InvalidClassAsEpSyntax'));
        end

        CC.createEntryptsFromClassAsEP();


        if~CC.CommandArgs.HasConstructorInfo&&CC.CommandArgs.NeedsConstructorInfo
            error(message('Coder:builtins:ClassConstructorMethodMissing',CC.CommandArgs.ClassName));
        end


    end
    if~CC.isCodegenToProject()&&~CC.hasEntryPoint()
        ccdiagnosticid('Coder:configSet:NoFunctionNameSpecified');
    end


    setupDeepLearningConfig(cfg);

    if disableParallel||~cfg.EnableOpenMP
        CC.Project.FeatureControl.EnablePARFOR=false;
        CC.Project.FeatureControl.EnableParallel=false;
    end

    if CC.Project.FeatureControl.ClassAsEntryPoint
        CC.Project.FeatureControl.DisableTransformReferenceParams=1;
        if isprop(cfg,'GenerateExampleMain')

            cfg.GenerateExampleMain="DoNotGenerate";
        end
    end

    checkConfigForGpuArrayInputs(CC);

    if isa(cfg,'coder.EmbeddedCodeConfig')
        if isSILTestingOn(CC.Project.FeatureControl)

            cfg.VerificationMode='SIL';
        end
    end


    if isprop(cfg,'TargetLang')&&cfg.TargetLang=="C"
        if isprop(cfg,'TargetLangStandard')
            if cfg.TargetLangStandard~="Auto"&&cfg.TargetLangStandard~="C89/C90 (ANSI)"&&cfg.TargetLangStandard~="C99 (ISO)"
                error(message('Coder:configSet:InvalidLangStandard',cfg.TargetLangStandard,cfg.TargetLang));
            end
        end


        hasCppOptions=false;
        if isprop(cfg,'CppNamespace')&&~isempty(cfg.CppNamespace)
            hasCppOptions=true;
        end
        if isprop(cfg,'CppInterfaceStyle')&&cfg.CppInterfaceStyle=="Methods"
            hasCppOptions=true;
        end
        if isprop(cfg,'CppInterfaceClassName')&&~isempty(cfg.CppInterfaceClassName)
            hasCppOptions=true;
        end

        if hasCppOptions
            ccwarningid('Coder:FE:HasCppSettingForC');
        end

        if isprop(cfg,'DynamicMemoryAllocationInterface')&&cfg.DynamicMemoryAllocationInterface=="C++"
            ccwarningid('Coder:FE:DynamicMemoryInterfaceIncompatible',cfg.DynamicMemoryAllocationInterface,cfg.TargetLang);
        end
    end


    if isprop(cfg,'CppInterfaceStyle')
        if cfg.CppInterfaceStyle=="Methods"

            if isempty(cfg.CppInterfaceClassName)
                error(message('Coder:FE:emptyClassName'));
            end

            if~isempty(cfg.GpuConfig)&&cfg.GpuConfig.Enabled==true
                error(message('Coder:FE:GPUConfig'));
            end

            [errStr,cfg.CppInterfaceClassName]=coder.internal.validateCppIdentifierName(cfg.CppInterfaceClassName,'');


            if~isempty(errStr)
                error(message('Coder:FE:InvalidClassName'));
            end



            if length(cfg.CppInterfaceClassName)>cfg.MaxIdLength
                ccwarningid('Coder:FE:ClassNameTooLong');
            end


            for epIdx=1:numel(CC.Project.EntryPoints)
                if strcmp(cfg.CppInterfaceClassName,CC.Project.EntryPoints(epIdx).Name)
                    error(message('Coder:FE:ClassNameCollidesWithEntryPoint'));
                end
            end

            if strcmp(cfg.CppInterfaceClassName,cfg.CppNamespaceForMathworksCode)
                error(message('Coder:FE:ClassNameCollidesWithNamespace',cfg.CppInterfaceClassName));
            end
        else
            if~isempty(cfg.CppInterfaceClassName)
                ccwarningid('Coder:FE:NonEmptyClassNameStyleFcn',strtrim(cfg.CppInterfaceClassName));
            end
        end
    end

    CC.Project.IsECoderInstalled=coderprivate.hasEmbeddedCoder;

    validateCppNamespaceNames(cfg);
    validateReqsInCodeLicense(cfg);
    setCodingTarget(CC);
    checkOutputName(CC);
    validateDeprecatedOptions(CC);
end


function validateReqsInCodeLicense(cfg)

    if isprop(cfg,'ReqsInCode')&&cfg.ReqsInCode&&~license('test','Simulink_Requirements')
        ccwarningid('Coder:FE:ReqsInCodeNeedsRequirementsToolbox');
    end
end

function validateCppNamespaceNames(cfg)
    function option=validateOrError(option,cfgName)
        [errStr,option]=coder.internal.validateCppIdentifierName(option,'');
        if~isempty(errStr)
            error(message('Coder:FE:InvalidNamespace',option,cfgName));
        end
    end
    if isprop(cfg,'CppNamespace')&&~isempty(cfg.CppNamespace)
        cfg.CppNamespace=validateOrError(cfg.CppNamespace,'CppNamespace');
    end
    if isprop(cfg,'CppNamespaceForMathworksCode')&&~isempty(cfg.CppNamespaceForMathworksCode)
        cfg.CppNamespaceForMathworksCode=validateOrError(cfg.CppNamespaceForMathworksCode,'CppNamespaceForMathworksCode');
    end
end


function unrecognizedOption(arg)
    ccdiagnosticid('Coder:configSet:UnrecognizedOption',arg);
end


function checkEMLC(CC,arg)
    if~CC.isCodeGenClient()&&~CC.isAudioPluginClient()&&~CC.isSimscapeClient()&&...
        ~CC.isAlgorithmAnalyzerClient()&&~CC.isDlAccelClient()&&~CC.isPSTestClient()
        unrecognizedOption(arg);
    end
end


function setupDeepLearningConfig(cfg)
    if nargin==0
        cfg=getCurrentTargetConfig();
    end

    if isprop(cfg,'DeepLearningConfig')&&~isempty(cfg.DeepLearningConfig)
        GpuEnabledState=~isempty(cfg.GpuConfig)&&cfg.GpuConfig.Enabled;
        oldstate=warning('off','backtrace');
        try
            cfg.DeepLearningConfig.preBuild(cfg);
        catch err
            warning(oldstate.state,'backtrace');
            throw(err);
        end
        warning(oldstate.state,'backtrace');
        if~GpuEnabledState&&(~isempty(cfg.GpuConfig)&&cfg.GpuConfig.Enabled)

            validateGPUCoderSettings(cfg);
        end
    end
end


function checkForValidMATLABVariableName(clientName,setting,value)
    validateattributes(value,{'char','string'},{'scalartext'},clientName,setting);
    if~isvarname(value)
        invalidParamEx=MException(message('Coder:configSet:InvalidParameterOption',setting));
        invalidParamEx=invalidParamEx.addCause(MException(message('Coder:configSet:InvalidVarName',value)));
        throw(invalidParamEx);
    end
end


function[ret,shouldIssueTokenizationWarning]=processFileNameAndPath(cfgInput,CCInput,aSep)
    function[tokens,didSplitOnWhitespace]=spaceTokenize(str,aSep)
        replace=true;
        didSplitOnWhitespace=false;
        for i=1:length(str)
            if str(i)==newline
                str(i)=aSep;
                didSplitOnWhitespace=true;
                replace=true;
            elseif str(i)==' '&&replace==true
                str(i)=aSep;
                didSplitOnWhitespace=true;
            elseif str(i)=='"'
                replace=~replace;
            end
        end
        splitPath=regexp(str,aSep,'split');
        tokens={};
        for i=1:numel(splitPath)
            t=strtrim(splitPath{i});
            if~isempty(t)
                if t(1)=='"'
                    t=t(2:end-1);
                end
                tokens{end+1}=t;%#ok<AGROW>
            end
        end
    end


    ret='';
    originallyContainedPathsep=any(contains(cfgInput,pathsep));
    originallyContainedNewline=any(contains(cfgInput,newline));
    didSplitOnWhitespace=false;
    if~isempty(cfgInput)
        cfgInput=strtrim(cfgInput);


        iscellstring=iscell(cfgInput)||(isstring(cfgInput)&&~isscalar(cfgInput));
        if iscellstring
            cfgInput=strjoin(cfgInput,aSep);
        end





        if~contains(cfgInput,pathsep)&&contains(cfgInput,' ')&&~iscellstring
            if isstring(cfgInput)&&isscalar(cfgInput)
                cfgInput=char(cfgInput);
            end
            [tokens,didSplitOnWhitespace]=spaceTokenize(cfgInput,aSep);
            for CCidx=1:numel(tokens)
                ret=[ret,tokens{CCidx},aSep];%#ok<AGROW>
            end
        else
            if cfgInput(1)=='"'&&cfgInput(end)=='"'
                cfgInput=cfgInput(2:end-1);
            end
            ret=[cfgInput,aSep];
        end
    end
    if~isempty(CCInput)
        for CCidx=1:numel(CCInput)
            ret=[ret,CCInput{CCidx},aSep];%#ok<AGROW>
        end
    end
    if~isempty(ret)&&ret(end)==pathsep
        ret=ret(1:end-1);
    end
    shouldIssueTokenizationWarning=didSplitOnWhitespace||originallyContainedPathsep||originallyContainedNewline;
end


function setCodingTarget(CC)
    switch class(CC.ConfigInfo)
    case 'coder.HdlConfig'
        CC.Project.CodingTarget='HDL';
    case 'coder.FixPtConfig'
        CC.Project.CodingTarget='FIXPT';
    case 'coder.DvoRangeAnalysisConfig'
        CC.Project.CodingTarget='DVORANGEANALYSIS';
    case{'coder.CodeConfig','coder.EmbeddedCodeConfig'}
        CC.Project.CodingTarget=['RTW:',CC.ConfigInfo.OutputType];
    case{'coder.MexConfig','coder.MexCodeConfig'}
        CC.Project.CodingTarget='MEX';
    otherwise
        CC.Project.CodingTarget='MEX';
    end
end


function applyConfigHardware(CC)
    switch class(CC.ConfigInfo)
    case{'coder.CodeConfig','coder.EmbeddedCodeConfig'}
        CC.ConfigInfo.HardwareImplementation=CC.ConfigHardware;
    otherwise
        ccdiagnosticid('Coder:common:MultipleConfigObjs');
    end
end


function createDefaultConfigObject(CC)
    if CC.isCodeGenClient()||CC.isAudioPluginClient()||CC.isSimscapeClient()||...
        CC.isAlgorithmAnalyzerClient()||CC.isDlAccelClient()||CC.isPSTestClient()
        if CC.isPSTestClient()
            CC.ConfigInfo=coder.config('lib','Ecoder',true);
        elseif isempty(CC.ConfigInfo)
            CC.ConfigInfo=coder.config('mex');
        else
            CC.ConfigInfo=coder.config('lib','Ecoder',false);
        end
    else
        CC.ConfigInfo=coder.mexconfig();
    end
end


function genHelp(clientName)
    help(clientName);
end


function parseFeatureControl(CC,fc)
    if~isa(fc,'coder.internal.FeatureControl')
        ccdiagnosticid('Coder:configSet:RequireFeatureControl');
    end
    parseObj(CC,fc);
end


function parseClassAsEP(CC,aClassType)

    if~isa(aClassType,'coder.ClassType')
        error(message('Coder:builtins:InvalidClassAsEpSyntax'));
    end
    CC.CommandArgs.ClassName=aClassType.ClassName;
    CC.CommandArgs.ClassAsEPType=aClassType;

end


function parseConfig(CC,cfg)
    validType(CC,cfg);
    parseObj(CC,cfg);
end


function validType(CC,arg)
    switch class(arg)
    case{'coder.MexCodeConfig',...
        'coder.CodeConfig','coder.EmbeddedCodeConfig',...
        'coder.HdlConfig','coder.FixPtConfig','coder.DvoRangeAnalysisConfig',...
        'coder.SingleConfig','coder.PLCConfig'}
    case 'coder.MexConfig'
        if CC.isCodeGenClient()||CC.isAudioPluginClient()||CC.isSimscapeClient()||CC.isAlgorithmAnalyzerClient()||CC.isDlAccelClient()
            ccdiagnosticid('Coder:configSet:UnrecognizedConfigArg','');
        end
    otherwise
        ccdiagnosticid('Coder:configSet:UnrecognizedConfigArg','');
    end
end


function parseObj(CC,arg)
    cfg=evalArg(arg);
    if~isscalar(cfg)
        ccdiagnosticid('Coder:configSet:NonScalarConfig');
    end
    switch class(cfg)
    case 'coder.HardwareImplementation'
        validateConfig(CC,cfg);
        CC.ConfigHardware=cfg;
    case 'coder.internal.FeatureControl'
        CC.Project.FeatureControl=cfg;
    case{'coder.MexConfig','coder.MexCodeConfig',...
        'coder.CodeConfig','coder.EmbeddedCodeConfig'}
        validType(CC,cfg);
        validateConfig(CC,cfg);
        validateGPUCoderSettings(cfg);
        CC.ConfigInfo=createConfigCopy(cfg);
    case{'coder.HdlConfig'}
        validateConfig(CC,cfg);
        CC.ConfigInfo=createConfigCopy(cfg);
        fcnName=CC.ConfigInfo.DesignFunctionName;
        if~isempty(fcnName)
            CC.checkEntryPointFcnName(fcnName);
        end
    case{'coder.PLCConfig'}
        validateConfig(CC,cfg);
        CC.ConfigInfo=createConfigCopy(cfg);
    case{'coder.FixPtConfig','coder.SingleConfig'}
        validateConfig(CC,cfg);
        CC.ConfigInfo=createConfigCopy(cfg);
    case{'coder.DvoRangeAnalysisConfig'}
        validateConfig(CC,cfg);
        CC.ConfigInfo=createConfigCopy(cfg);
        fcnName=cfg.DesignFunctionName;
        if~isempty(fcnName)
            CC.checkEntryPointFcnName(fcnName);
        end
        workDir=pwd;
        bldDir=fullfile(workDir,'codegen',fcnName,'dvo');
        CC.Options.LogDirectory=CC.expandProjectMacros(bldDir);
    otherwise
        if coder.internal.isCharOrScalarString(arg)
            text=strcat(' "',arg,'"');
        else
            text='';
        end
        ccdiagnosticid('Coder:configSet:UnrecognizedConfigArg',text);
    end


    if~isa(cfg,'coder.internal.FeatureControl')
        CC.ParsedCommandConfig=true;
    end
    checkConfig(CC);
end


function validateConfig(CC,val)




    if CC.ParsedProjectFile&&~(isempty(val))
        ccdiagnosticid('Coder:common:ConfigObjectWithProjectFile');
    end

    isConfigHardware=isa(val,'coder.HardwareImplementation');
    if CC.processedOldConfigObject()||...
        (isConfigHardware&&~isempty(CC.ConfigHardware))||...
        (~isConfigHardware&&~isempty(CC.ConfigInfo))
        ccdiagnosticid('Coder:common:MultipleConfigObjs');
    end
end


function validateDeprecatedOptions(CC)
    cfg=CC.ConfigInfo;
    if isempty(cfg)
        return;
    end
    if(isprop(cfg,"InlineThreshold")&&(cfg.InlineThreshold~=10))
        coder.internal.warning('Coder:buildProcess:DeprecateInlineThreshold');
    end
    if(isprop(cfg,"InlineThresholdMax")&&(cfg.InlineThresholdMax~=200))
        coder.internal.warning('Coder:buildProcess:DeprecateInlineThresholdMax');
    end

    if(isprop(cfg,"InlineStackLimit")&&(cfg.InlineStackLimit~=4000)&&(cfg.InlineStackLimit~=1000000))
        coder.internal.warning('Coder:buildProcess:DeprecateInlineStackLimit');
    end
end


function cfg=defaultConfig(type)
    ecoderLicensed=license('test','RTW_Embedded_Coder');
    ecoderInstalled=coderprivate.hasEmbeddedCoder();
    cfg=coder.config(type,'ecoder',ecoderLicensed&&ecoderInstalled);
end


function updateHDLCodeGenDir(CC)
    fcnName=CC.ConfigInfo.DesignFunctionName;
    if isempty(fcnName)

        return;
    end



    if CC.ConfigInfo.IsFixPtConversionDone&&~isempty(CC.FixptData)
        fxpCfg=CC.FixptData;
        dirName=fxpCfg.DesignFunctionName;
    else
        dirName=fcnName;
    end
    workDir=pwd;
    if isempty(CC.Options.LogDirectory)
        bldDir=fullfile(workDir,'codegen',dirName,'hdlsrc');
    else
        workDir=coder.internal.Helper.getCodegenFolderForCLI(pwd,CC.Options.LogDirectory);
        bldDir=fullfile(workDir,dirName,'hdlsrc');

        CC.Project.OutDirectory=workDir;
        CC.Project.IsUserSpecifiedOutputDir=true;
    end
    CC.Options.LogDirectory=CC.expandProjectMacros(bldDir);
end


function newcfg=createConfigCopy(oldcfg)
    function checkHardwareImplementation(cfg)
        if isprop(cfg,'HardwareImplementation')&&...
            isempty(cfg.HardwareImplementation)
            cfg.HardwareImplementation=coder.HardwareImplementation;
        end
    end
    newcfg=oldcfg.copy;
    checkHardwareImplementation(newcfg);
end


function parseInitGlobalValues(CC,arg)
    function iTy=parseCoderTypeValuePairHelper(name,value,type,ec_type)
        if~isempty(type)
            if~isa(type,'coder.Constant')&&~type.contains(value)
                ccdiagnosticid('Coder:common:GlobalValueTypeMismatch',name,ec_type);
            end
        else
            try



                [~]=coder.newtype('constant',value);
                type=coder.typeof(value);

                if isa(type,'coder.type.Base')
                    type=type.getCoderType();
                end
            catch me
                x=coderprivate.msgSafeException('Coder:common:GlobalInitValueUntypeable',name);
                x=x.addCause(coderprivate.makeCause(me));
                x.throw();
            end
        end
        iTy=type;
        iTy.Name=name;
    end

    function iTy=parseCoderTypeValuePair(name,v,ec,ec_type)
        isConstant=false;
        if~iscell(v)&&isa(v,'coder.type.Base')
            v=v.getCoderType();
        end
        if iscell(v)
            if numel(v)~=2
                ccdiagnosticid('Coder:common:GlobalTypeValuePair',name,ec);
            end
            thisType=v{1};
            thisValue=v{2};
            hasValue=true;
            if isa(thisType,'coder.type.Base')
                thisType=thisType.getCoderType();
            end
            if~isa(thisType,'coder.Type')||~isscalar(thisType)
                ccdiagnosticid('Coder:common:GlobalTypeValuePair',name,ec);
            end
            if isa(thisType,'coder.Constant')
                ccdiagnosticid('Coder:common:GlobalConstantTypeValuePair',name,ec);
            end
        elseif isa(v,'coder.Constant')
            thisType=coder.typeof(v.Value);
            thisValue=v.Value;
            isConstant=true;
            hasValue=true;
        elseif isa(v,'coder.Type')
            thisType=v;
            hasValue=false;
            if~(isempty(whos('global',name)))
                thisValue=getGlobalValueHelper(name);
                hasValue=true;
            end
        else
            thisType=[];
            thisValue=v;
            hasValue=true;
        end
        if~hasValue
            iTy=thisType;
            iTy.Name=name;
        else
            iTy=parseCoderTypeValuePairHelper(name,thisValue,thisType,ec_type);
        end

        if isConstant
            iTy.InitialValue=coder.Constant(thisValue);
        else
            if hasValue
                iTy.InitialValue=thisValue;
            end
        end
    end

    val=evalArg(arg);
    if~iscell(val)
        val={val};
    end

    numberofelements=numel(val);
    globalscount=1;
    for i=1:2:numberofelements
        name=val{i};
        if~ischar(name)
            if isstring(name)&&isscalar(name)
                name=char(name);
            else
                ccdiagnosticid('Coder:configSet:InvalidGlobalDataName');
            end
        end
        if i==numberofelements
            ccdiagnosticid('Coder:configSet:MissingGlobalInitialValue',name);
        end
        ec=sprintf('gl{%d}',i);
        ec_type=sprintf('gl{%d}',i+1);

        v=val{i+1};
        iTy=parseCoderTypeValuePair(name,v,ec,ec_type);
        iTyp{globalscount}=iTy;%#ok
        globalscount=globalscount+1;
    end

    CC.Project.InitialGlobalValues=iTyp;
end


function setUserNumOutputs(CC,in)
    numOutputs=evalArg(in);
    validateattributes(numOutputs,{'numeric'},{'scalar','integer'},CC.clientName(),'-nargout')
    if numOutputs<-1


        ccdiagnosticid('Coder:configSet:InvalidNargoutParam',numOutputs);
    end
    if CC.Project.EntryPoints(end).HasUserNumOutputs
        ccdiagnosticid('Coder:common:MultipleUserNumOutputs');
    end
    CC.Project.EntryPoints(end).HasUserNumOutputs=true;
    CC.Project.EntryPoints(end).UserNumOutputs=numOutputs;
    CC.Options.PolyMexOptions.hasUserNumOutputs=true;
    CC.Options.PolyMexOptions.userNumOutputs(end+1)=numOutputs;
end


function val=evalArg(arg)
    if isempty(arg)
        ccdiagnosticid('Coder:configSet:EmptyCmdLineArgument');
    end
    if coder.internal.isCharOrScalarString(arg)
        try
            val=evalin('base',arg);
        catch ME
            val=[];
        end
        if isempty(val)
            x=coderprivate.msgSafeException('Coder:configSet:FailedToEvalArgument',arg);
            if~isempty(ME)
                x=x.addCause(coderprivate.makeCause(ME));
            end
            throw(x);
        end
    else
        val=arg;
    end
end


function hasCudaCustomFile=parseFilename(CC,arg)
    [pathstr,name,ext]=fileparts(char(arg));
    hasCudaCustomFile=false;
    if isempty(ext)
        CC.checkEntryPointFcnName(arg);
        return;
    end
    filename=[name,ext];
    emptyPath=isempty(pathstr);
    if emptyPath
        filepath=pwd;
    else
        filepath=pathstr;
    end
    if strcmp(ext,'.prj')
        if(CC.isCodeGenClient()||CC.isAudioPluginClient()||CC.isSimscapeClient()||CC.isAlgorithmAnalyzerClient()||CC.isDlAccelClient()||CC.isPSTestClient())&&CC.isNewCommand()
            if coderapp.internal.globalconfig('JavaFreePrjParser')
                prj=coderapp.project.import(fullfile(filepath,filename));
                coderapp.project.copyToCompilationContext(prj,CC);
            else
                loadProjectFile(CC,fullfile(filepath,filename));
            end
            return;
        end
        ccdiagnosticid('Coder:configSet:UnrecognizedFileExtension',ext);
    end
    consumed=false;
    if CC.isCodeGenClient()||CC.isAudioPluginClient()||CC.isSimscapeClient()||...
        CC.isAlgorithmAnalyzerClient()||CC.isDlAccelClient()||CC.isPSTestClient()
        if strcmp(ext,'.cu')||strcmp(ext,'.cuh')
            hasCudaCustomFile=true;
        end
        switch emcValidateFileKind(ext)
        case 1
            CC.appendCustomFile(filename,'CustomSource');
            CC.appendCustomFile(filepath,'CustomInclude');
            consumed=true;
        case 2
            CC.CommandArgs.CustomSourceCode=[CC.CommandArgs.CustomSourceCode,sprintf('#include "%s"\n',filename)];
            CC.appendCustomFile(filepath,'CustomInclude');
            consumed=true;
        case 3
            CC.appendCustomFile(filename,'CustomLibrary');
            CC.appendCustomFile(filepath,'CustomInclude');
            consumed=true;
        case 4
            checkMATLABExtension(ext);
        otherwise
            if emptyPath


                whichArg=which(arg);
                if~isempty(whichArg)&&ismember(exist(whichArg),[2,3,4,6,8])%#ok<EXIST>
                    [~,~,fullExt]=fileparts(whichArg);
                    checkMATLABExtension(fullExt);
                    p=meta.package.fromName(name);

                    fcnName=strrep(ext,'.','');
                    if~isempty(p)&&any(arrayfun(@(x)strcmp(x.Name,fcnName),p.FunctionList))
                        ccdiagnosticid('Coder:configSet:EntryPointInPackageNotSupported',arg);
                    end
                end
            end
            ccdiagnosticid('Coder:configSet:UnrecognizedFileExtension',ext);
        end
    end
    if~consumed
        CC.checkEntryPointFcnName(arg);
    end
end


function checkMATLABExtension(ext)
    switch ext
    case{'.m','.p','.mlx'}

    otherwise
        ccdiagnosticid('Coder:configSet:UnrecognizedFileExtension',ext);
    end
end


function checkConfig(CC)
    if~CC.isCodeGenClient()&&~CC.isAudioPluginClient()&&~CC.isSimscapeClient()&&...
        ~CC.isAlgorithmAnalyzerClient()&&~CC.isDlAccelClient()&&~CC.isPSTestClient()
        objClass=class(CC.ConfigInfo);
        switch objClass
        case{'coder.MexCodeConfig','coder.CodeConfig',...
            'coder.EmbeddedCodeConfig','emlcoder.HardwareImplementation'}
            ccdiagnosticid('Coder:configSet:UnsupportConfigObject',objClass);
        end
    end
end


function checkOutputName(CC)
    if~isempty(CC.Options.outputfile)
        [pathstr,CC.Options.outputfile,ext]=fileparts(CC.Options.outputfile);
    else
        pathstr='';
        ext='';
    end
    if~isempty(ext)&&...
        CC.codingMex()&&...
        ~strcmp(ext,['.',mexext])
        ccdiagnosticid('Coder:configSet:UnsupportedExtension',ext);
    end
    if~isempty(CC.Options.outputfile)
        badpos=regexp(CC.Options.outputfile,'[\$#*? \t]','once');
        if isempty(badpos)
            badpos=find(int32(CC.Options.outputfile)>127);
        end
        if~isempty(badpos)
            ccdiagnosticid('Coder:configSet:OutputFileNameHasBadChar',...
            CC.Options.outputfile,CC.Options.outputfile(badpos));
        end
        if CC.codingMex()&&~isvarname(CC.Options.outputfile)
            ccdiagnosticid('Coder:configSet:OutputFileNameNotMexFcnName',...
            CC.Options.outputfile);
        end
    end
    if~isempty(pathstr)
        [stat,attr]=fileattrib(pathstr);
        if(stat~=1)||~attr.directory
            ccdiagnosticid('Coder:configSet:DirectoryNotFound',pathstr);
        end

        CC.Project.OutDirectory=attr.Name;
        if CC.isCodeGenClient()||CC.isAudioPluginClient()||CC.isSimscapeClient()||...
            CC.isAlgorithmAnalyzerClient()||CC.isDlAccelClient()||CC.isPSTestClient()
            CC.Project.BldDirectory=attr.Name;
        end
    end
end





function parseOptimization(CC,arg)
    function reject(arg)
        if CC.isNewCodeGenClient()||CC.isAudioPluginClient()||CC.isSimscapeClient()||CC.isDlAccelClient()
            msgId='Coder:configSet:InvalidOptimization';
        else
            msgId='Coder:configSet:InvalidOptimizationRestrict';
        end
        ccdiagnosticid(msgId,arg);
    end

    if~(ischar(arg)||isstring(arg))
        reject('');
    end
    tokens=regexp(arg,'(\w*)(:)(\w*)','tokens','once');
    if numel(tokens)~=3
        reject(arg);
    end
    switch lower(tokens{1})
    case 'enable'
        enable=true;
    case 'disable'
        enable=false;
    otherwise
        reject(arg);
    end
    switch lower(tokens{3})
    case 'openmp'
        if CC.isNewCodeGenClient()||CC.isAudioPluginClient()||CC.isSimscapeClient()||CC.isAlgorithmAnalyzerClient()||CC.isDlAccelClient()
            CC.CommandArgs.EnableOpenMP=enable;
        else
            reject(arg);
        end
    case 'inline'
        if enable
            CC.CommandArgs.InlineBetweenUserFunctions='Speed';
            CC.CommandArgs.InlineBetweenUserAndMathWorksFunctions='Speed';
            CC.CommandArgs.InlineBetweenMathWorksFunctions='Speed';
        else
            CC.CommandArgs.InlineBetweenUserFunctions='Never';
            CC.CommandArgs.InlineBetweenUserAndMathWorksFunctions='Never';
            CC.CommandArgs.InlineBetweenMathWorksFunctions='Never';
        end
    otherwise
        reject(arg);
    end
end


function checkConfigForGpuArrayInputs(CC)

    isGpuCfg=CC.isGpuTarget();
    numGpuIOinputs=0;
    entryPoints=CC.Project.EntryPoints;
    for i=1:numel(entryPoints)
        inputTypes=CC.Project.EntryPoints(i).InputTypes;
        for idx=1:length(inputTypes)
            iTy=inputTypes{idx};
            if isa(iTy,'coder.PrimitiveType')&&iTy.Gpu
                numGpuIOinputs=numGpuIOinputs+1;
            end
        end
    end

    if~isGpuCfg
        if numGpuIOinputs>0
            error(message('Coder:common:UnsupportedGpuInputCoder'));
        else
            return;
        end
    end

    if(CC.ConfigInfo.RowMajor||CC.CommandArgs.RowMajor)&&numGpuIOinputs>0
        error(message('Coder:common:UnsupportedGpuArrayConfig','RowMajor'));
    end

    if strcmp(CC.ConfigInfo.GpuConfig.MallocMode,'unified')&&numGpuIOinputs>0
        error(message('Coder:common:UnsupportedGpuArrayConfig','Unified memory'));
    end

    if CC.ConfigInfo.GpuConfig.isOpenCLCodegen()&&numGpuIOinputs>0
        error(message('Coder:common:UnsupportedGpuArrayConfig','OpenCL code generation'));
    end

end


function value=getGlobalValueHelper(name)
    eval(['global ',name]);
    value=eval(name);
end


function applyNonEmptyCommandArg(commandArgs,prop,cfg)
    arg=commandArgs.(prop);
    if~isempty(arg)
        cfg.(prop)=arg;
    end
end





