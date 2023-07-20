



classdef(Sealed)CompilationContext<handle
    properties
        ClientType(1,:)char
Project
Options
ConfigInfo
ConfigHardware
        CommandArgs(1,1)struct=struct()
        ParsedCommandConfig(1,1)logical
        ParsedProjectFile(1,1)logical
CompilerName
JavaConfig
CRLControl
FixptState
FixptData
FixptSummary
HDLState
GpuState
        ExtraCodegenOutputs string{mustBeMember(ExtraCodegenOutputs,...
        ["reportContext","reportDebug","reportInfo","compilationContext","designInspector"])}
    end

    methods

        function this=CompilationContext(aClientType)
            this.ClientType=aClientType;
            this.Project=this.defaultProject(aClientType);
            this.Options=this.defaultOptions();

            this.CommandArgs.GenCodeOnly=false;
            this.CommandArgs.RowMajor=false;
            this.CommandArgs.PreserveArrayDims=false;
            this.CommandArgs.EliminateSingleDims=false;
            this.CommandArgs.EnableJIT=false;
            this.CommandArgs.EnableDebugging=false;
            this.CommandArgs.EnableMexProfiling=false;
            this.CommandArgs.GenerateReport=false;
            this.CommandArgs.LaunchReport=false;
            this.CommandArgs.ExportCodegenInfo=false;
            this.CommandArgs.GenerateCodeMetricsReport=false;
            this.CommandArgs.GenerateCodeReplacementReport=false;
            this.CommandArgs.HighlightPotentialDataTypeIssues=false;
            this.CommandArgs.Verbose=false;
            this.CommandArgs.Silent=false;
            this.CommandArgs.CustomSource={};
            this.CommandArgs.CustomSourceCode='';
            this.CommandArgs.CustomLibrary={};
            this.CommandArgs.CustomInclude={};
            this.CommandArgs.HwConfig=[];
            this.CommandArgs.EnableOpenMP=[];
            this.CommandArgs.InlineBetweenUserFunctions='';
            this.CommandArgs.InlineBetweenUserAndMathWorksFunctions='';
            this.CommandArgs.InlineBetweenMathWorksFunctions='';
            this.CommandArgs.runTest=false;
            this.CommandArgs.runTestFile='';
            this.CommandArgs.NumCompileJobs=1;
            this.CommandArgs.TargetLang='';
            this.CommandArgs.TargetLangStandard='';
            this.CommandArgs.ClassName='';
            this.CommandArgs.ClassAsEPType=[];
            this.CommandArgs.HasConstructorInfo=false;
            this.CommandArgs.NeedsConstructorInfo=false;
        end


        function b=hasEntryPoint(this)
            b=~isempty(this.Project.EntryPoints(1).Name);
        end


        function b=supportMultipleEntryPoints(this)
            b=~strcmpi(this.ClientType,'FIACCEL')||...
            fifeature('EnableMultipleEntryMexFcnGenerationInFiaccel');
        end


        function t=isNewCodeGenClient(this)
            t=strcmpi(this.ClientType,'codegen');
        end


        function t=isCodeGenClient(this)
            t=strcmpi(this.ClientType,'emlc')||strcmpi(this.ClientType,'codegen');
        end


        function t=isAudioPluginClient(this)
            t=strcmpi(this.ClientType,'audioplugin');
        end


        function t=isDlAccelClient(this)
            t=strcmpi(this.ClientType,'dlaccel');
        end


        function t=isSimscapeClient(this)
            t=strcmpi(this.ClientType,'simscape');
        end


        function t=isAlgorithmAnalyzerClient(this)
            t=strcmpi(this.ClientType,'algorithmanalyzer');
        end


        function t=isFiaccelClient(this)
            t=strcmpi(this.ClientType,'fiaccel');
        end


        function t=isPSTestClient(this)
            t=strcmpi(this.ClientType,'pstest');
        end


        function t=isEmbeddedProduction(this)
            t=strcmp(this.Options.ProjectTarget,'production');
        end


        function t=isEmbeddedPrototype(this)
            t=strcmp(this.Options.ProjectTarget,'prototype');
        end


        function t=isEmbeddedTarget(this)
            t=this.isEmbeddedProduction()||this.isEmbeddedPrototype();
        end


        function t=isNewCommand(this)
            t=strcmpi(this.ClientType,'codegen')||...
            strcmpi(this.ClientType,'mexgen')||...
            strcmpi(this.ClientType,'fiaccel')||...
            strcmpi(this.ClientType,'audioplugin')||...
            strcmpi(this.ClientType,'algorithmanalyzer')||...
            strcmpi(this.ClientType,'simscape')||...
            strcmpi(this.ClientType,'simbio')||...
            strcmpi(this.ClientType,'dlaccel')||...
            strcmpi(this.ClientType,'pstest');
        end


        function t=isPureMatlabCoder(this)
            t=isa(this.ConfigInfo,'coder.CodeConfig')||...
            isa(this.ConfigInfo,'coder.MexCodeConfig');
        end


        function t=isERT(this)
            if isa(this.ConfigInfo,'coder.EmbeddedCodeConfig')
                t=this.ConfigInfo.IsERTTarget;
            else
                t=false;
            end
        end



        function t=clientName(this)
            if strcmpi(this.ClientType,'simbio')
                t='coder.internal.simbiohelper';
            else
                t=lower(this.ClientType);
            end
        end


        function isCliToProj=isCodegenToProject(this)

            isCliToProj=~isempty(this.Options.generatedProjectFile);
        end


        function b=isTargetLangCPP(this)
            b=isTargetLangImpl(this,'C++');
        end


        function b=isTargetLangC(this)
            b=isTargetLangImpl(this,'C');
        end


        function b=isTargetLangImpl(this,lang)
            b=~isempty(this.ConfigInfo)&&...
            isprop(this.ConfigInfo,'TargetLang')&&...
            strcmp(this.ConfigInfo.TargetLang,lang);
        end


        function isprj=isJavaPrjBuild(this)


            isprj=~isempty(this.JavaConfig);
        end


        function dryRun=isDryRun(this)
            dryRun=this.isCodegenToProject()||this.Options.parseOnly;
        end


        function fc=getFeatureControl(this)
            fc=this.Project.FeatureControl;
        end


        function t=codingTarget(this)
            t=lower(this.Project.CodingTarget);
        end


        function b=codingMex(this)
            b=isa(this.ConfigInfo,'coder.MexConfig')||...
            isa(this.ConfigInfo,'coder.MexCodeConfig');
        end


        function b=codingRtw(this)
            b=isa(this.ConfigInfo,'coder.CodeConfig')||...
            isa(this.ConfigInfo,'coder.EmbeddedCodeConfig');
        end


        function b=processedOldConfigObject(~)
            b=false;
        end


        function b=isHDLCoderEnabled(this)
            feature_enabled=this.Project.FeatureControl.EnableHDLCoder;
            checkoutLicense=true;
            b=coderprivate.hasHDLCoderLicense(checkoutLicense,feature_enabled);
        end


        function b=isPLCCoderEnabled(this)%#ok<MANU>

            b=coderprivate.hasPLCCoderLicense();
        end


        function b=codingHDL(this)
            b=isa(this.ConfigInfo,'coder.HdlConfig');
        end


        function b=codingPLC(this)
            b=isa(this.ConfigInfo,'coder.PLCConfig');
        end


        function b=codingFixPt(this)
            b=isa(this.ConfigInfo,'coder.FixPtConfig');
        end


        function b=isF2fEnabled(this)
            b=~isempty(this.ConfigInfo)&&...
            isprop(this.ConfigInfo,'F2FConfig')&&...
            ~isempty(this.ConfigInfo.F2FConfig)&&...
            this.ConfigInfo.F2FConfig.F2FEnabled;
        end


        function b=isDoubleToSingle(this)
            b=this.isF2fEnabled()&&this.ConfigInfo.F2FConfig.DoubleToSingle;
        end


        function b=codingDvoRangeAnalysis(this)
            b=isa(this.ConfigInfo,'coder.DvoRangeAnalysisConfig');
        end


        function b=isGpuTarget(this)
            b=~isempty(this.ConfigInfo)&&...
            isprop(this.ConfigInfo,'GpuConfig')&&...
            ~isempty(this.ConfigInfo.GpuConfig)&&...
            this.ConfigInfo.GpuConfig.Enabled;
        end


        function b=isCUDATarget(this)
            b=this.isGpuTarget&&...
            this.ConfigInfo.GpuConfig.isCUDACodegen();
        end


        function b=isOpenCLTarget(this)
            b=this.isGpuTarget&&...
            this.ConfigInfo.GpuConfig.isOpenCLCodegen();
        end


        function setupGpu(this)
            if this.isGpuTarget()
                this.GpuState.useSharedLib=images.internal.coder.useSharedLibrary();
                images.internal.coder.useSharedLibrary(false);
                if this.ConfigInfo.PreserveArrayDimensions==true
                    throw(MException(message('Coder:configSet:UnsupportedOptionForCurrentConfig','PreserveArrayDimensions')));
                end

                gpuCfg=this.ConfigInfo.GpuConfig;
                if gpuCfg.EnableMemoryManager&&gpuCfg.MinPoolSize>=gpuCfg.MaxPoolSize
                    error(message('gpucoder:common:MinMaxPoolSizeValues'));
                end
            end
        end


        function updateFixptCodeGenDir(this)
            fcnNames=this.ConfigInfo.DesignFunctionName;
            if~iscell(fcnNames)
                fcnNames={fcnNames};
            end
            workDir=pwd;
            primaryEP=fcnNames{1};
            if isempty(this.ConfigInfo.CodegenDirectory)
                bldDir=fullfile(workDir,'codegen',primaryEP,this.ConfigInfo.getRelativeBuildDirectory());
            else
                bldDir=fullfile(this.ConfigInfo.CodegenDirectory,primaryEP,this.ConfigInfo.getRelativeBuildDirectory());
            end
            this.Options.LogDirectory=this.expandProjectMacros(bldDir);
        end


        function cleanupGpu(this)
            if this.isGpuTarget()&&~isempty(this.GpuState)
                images.internal.coder.useSharedLibrary(this.GpuState.useSharedLib);
                this.GpuState.useSharedLib=[];
            end
        end


        function anEp=createEntryPointObject(this,userInputName)
            if~ischar(userInputName)
                if isstring(userInputName)&&isscalar(userInputName)
                    userInputName=char(userInputName);
                else
                    disp(userInputName);
                    error(message('Coder:configSet:InvalidFunctionName'));
                end
            end
            if isempty(userInputName)
                error(message('Coder:configSet:InvalidFunctionName'));
            end

            [dir,fcnName]=fileparts(userInputName);
            if isempty(fcnName)
                error(message('Coder:configSet:MissingFunctionName',dir));
            end


            [validNameStrart,validNameEnd]=regexp(fcnName,'[a-zA-Z]{1}[^\W]*','once');
            if isempty(validNameStrart)||validNameStrart~=1||validNameEnd~=length(fcnName)
                error(message('Coder:configSet:EntryPointNameInvalid',fcnName));
            end

            if~isempty(dir)

                pparts=strsplit(dir,filesep);
                replaceMask='';

                for i=length(pparts):-1:1
                    if(startsWith(pparts{i},'+'))
                        replaceMask=fullfile(pparts{i},replaceMask);
                    else
                        break;
                    end
                end

                dir=strrep(dir,replaceMask,'');



                if isempty(replaceMask)||~startsWith(dir,toolboxdir(''))
                    this.addSearchPathKernel(dir);
                end
            end

            if~isempty(this.CommandArgs.ClassName)

                completeName='';


                setExpression='(set[.]\w*)';
                getExpression='(get[.]\w*)';

                combinedExpr=strcat(setExpression,'|',getExpression);
                matchStr=regexp(userInputName,combinedExpr,'match');
                if~isempty(matchStr)
                    fcnName=userInputName;
                end


            else


                completeName=which(userInputName);




                if isempty(completeName)

                    relCompleteName=fullfile(pwd,userInputName);
                    if isfile(relCompleteName)

                        completeName=relCompleteName;
                    else



                        completeName=userInputName;
                    end
                end






                completeName=this.deferFileNameFromMEX(completeName);








            end




            anEp=coder.internal.EntryPoint(fcnName);
            anEp.OriginName=fcnName;
            anEp.UserInputName=userInputName;
            anEp.CompleteName=completeName;
            anEp.InputIndex=numel(this.Project.EntryPoints);
        end


        function fileName=deferFileNameFromMEX(~,fileName)
            [p,fcnName,e]=fileparts(fileName);
            if(e==("."+mexext))
                newFileNameMLX=fullfile(p,[fcnName,'.mlx']);
                newFileNameP=fullfile(p,[fcnName,'.p']);
                newFileNameM=fullfile(p,[fcnName,'.m']);
                if isfile(newFileNameMLX)
                    fileName=newFileNameMLX;
                elseif isfile(newFileNameP)
                    fileName=newFileNameP;
                elseif isfile(newFileNameM)
                    fileName=newFileNameM;
                end
            end
        end


        function checkEntryPointFcnName(this,userInputName)
            newEp=createEntryPointObject(this,userInputName);

            if this.supportMultipleEntryPoints()
                for i=1:numel(this.Project.EntryPoints)
                    if strcmpi(this.Project.EntryPoints(i).Name,newEp.Name)
                        error(message('Coder:configSet:DuplicateFunctionName',newEp.Name));
                    end
                end
                if isempty(this.Project.EntryPoints(end).Name)
                    this.Project.EntryPoints(end).Name=newEp.Name;
                    this.Project.EntryPoints(end).OriginName=newEp.OriginName;
                    this.Project.EntryPoints(end).CompleteName=newEp.CompleteName;
                    this.Project.EntryPoints(end).UserInputName=newEp.UserInputName;
                else
                    this.Project.EntryPoints(end+1)=newEp;
                end
            else
                if isempty(this.Project.EntryPoints(1).Name)
                    this.Project.EntryPoints(1).Name=newEp.Name;
                    this.Project.EntryPoints(1).OriginName=newEp.OriginName;
                    this.Project.EntryPoints(1).CompleteName=newEp.CompleteName;
                    this.Project.EntryPoints(1).UserInputName=newEp.UserInputName;
                else
                    error(message('Coder:configSet:MultipleFunctionNames',...
                    this.Project.EntryPoints(1).Name,newEp.Name));
                end
            end


            this.Project.EntryPoints(end).ParentClassName=this.CommandArgs.ClassName;

            if this.Options.PolyMexOptions.treatedAsPolyMex
                for i=1:numel(this.Project.EntryPoints)
                    if isempty(this.Project.EntryPoints(i).Name)||strcmp(this.Project.EntryPoints(i).Name,newEp.Name)
                        this.Project.EntryPoints(i).Name=newEp.Name;
                        this.Project.EntryPoints(i).OriginName=newEp.OriginName;
                        this.Project.EntryPoints(i).CompleteName=newEp.CompleteName;
                        this.Project.EntryPoints(i).UserInputName=newEp.UserInputName;
                        this.Project.EntryPoints(i).InputIndex=i;
                    end
                end
            end
        end


        function newProp=createPropertyObject(~,prop,propType)
            newProp=coder.internal.PropertyList(prop.Name);
            newProp.DataType=propType;
            newProp.GetAccess=prop.GetAccess;
            newProp.SetAccess=prop.SetAccess;
            newProp.Dependent=prop.Dependent;
            newProp.Abstract=prop.Abstract;
            newProp.Transient=prop.Transient;
            newProp.Visible=~prop.Hidden;
            newProp.AbortSet=prop.AbortSet;
            newProp.Copyable=~prop.NonCopyable;
            newProp.HasDefault=prop.HasDefault;
        end


        function checkEntryPointClassProperties(this,className,propName,propType)
            info=meta.class.fromName(className);
            for i=1:numel(info.PropertyList)
                if strcmp(info.PropertyList(i).Name,propName)
                    newProp=this.createPropertyObject(info.PropertyList(i),propType);
                    break;
                end
            end

            if isempty(this.Project.PropertyList(end).Name)
                this.Project.PropertyList(end).Name=newProp.Name;
                this.Project.PropertyList(end).DataType=newProp.DataType;
                this.Project.PropertyList(end).GetAccess=newProp.GetAccess;
                this.Project.PropertyList(end).SetAccess=newProp.SetAccess;
                this.Project.PropertyList(end).Dependent=newProp.Dependent;
                this.Project.PropertyList(end).Abstract=newProp.Abstract;
                this.Project.PropertyList(end).Transient=newProp.Transient;
                this.Project.PropertyList(end).Visible=newProp.Visible;
                this.Project.PropertyList(end).AbortSet=newProp.AbortSet;
                this.Project.PropertyList(end).Copyable=newProp.Copyable;
                this.Project.PropertyList(end).HasDefault=newProp.HasDefault;
            else
                this.Project.PropertyList(end+1)=newProp;
            end
        end


        function parseCoderTypes(this,arg)
            if this.Project.EntryPoints(end).HasInputTypes
                this.Options.PolyMexOptions.treatedAsPolyMex=true;
                this.Options.PolyMexOptions.hasMultipleArgs=true;
                this.Project.EntryPoints(end+1)=this.Project.EntryPoints(end).copy();
                this.Project.EntryPoints(end).CompleteName=this.Project.EntryPoints(end-1).CompleteName;
                this.Project.EntryPoints(end).InputTypes=[];
            end
            t={};
            this.Project.EntryPoints(end).HasInputTypes=true;
            if iscell(arg)&&isempty(arg)
                return;
            end
            val=checkArg(arg);
            if~iscell(val)
                val={val};
            end
            for i=1:numel(val)
                name=sprintf('u%d',i);
                ec=sprintf('args{%d}',i);
                v=val{i};
                if isa(v,'coder.Type')
                    t{end+1}=v;%#ok<AGROW>
                else
                    try
                        t{end+1}=coder.typeof(v);%#ok<AGROW>
                    catch me
                        x=coderprivate.msgSafeException('Coder:common:InputArgUntypeable',ec);
                        x=x.addCause(coderprivate.makeCause(me));
                        x.throw();
                    end
                end
                t{end}=this.checkTypeFromExample(t{end},ec);
                t{end}.Name=name;
            end
            this.Project.EntryPoints(end).InputTypes=t;
        end


        function[iTy,isConstructor,isStaticMethod]=getThisTypeForClassMethod(this,className,methodName)
            iTy={};
            isConstructor=false;
            isStaticMethod=false;
            if~isempty(className)
                mc=meta.class.fromName(className);
                idx=find(strcmp({mc.MethodList.Name},methodName),1);
                if~isempty(idx)
                    isStaticMethod=mc.MethodList(idx).Static;
                end
            end

            if~isempty(className)&&~isStaticMethod


                if strcmp(methodName,className)

                    isConstructor=true;
                    iTy={this.CommandArgs.ClassAsEPType};
                    this.CommandArgs.HasConstructorInfo=true;
                else

                    this.CommandArgs.NeedsConstructorInfo=true;
                    iTy={coder.OutputType(className)};
                end
            end
        end


        function iTy=checkTypeFromExample(~,iTy,errPath)

            if isa(iTy,'coder.type.Base')
                iTy=iTy.getCoderType();
            end

            if~isa(iTy,'coder.Type')||~isscalar(iTy)
                emlcprivate('ccdiagnosticid','Coder:common:RequireCoderType',errPath);
            end
            if isa(iTy,'coder.EnumType')
                clName=iTy.ClassName;
                mc=meta.class.fromName(clName);
                if isempty(mc)
                    error(message('Coder:builtins:EnumClassdefNotfound',clName));
                end
            end
        end


        function inputType=processMethodInputArguments(~,methodName,outputType,fcnType,isConstructor,isStatic)
            assert(iscell(outputType));
            if isConstructor||isStatic

                foundThisType=false;
                for i=1:numel(fcnType.InputTypes)
                    if isa(fcnType.InputTypes{i},'coder.ThisType')
                        foundThisType=true;
                        break;
                    end
                end



                if foundThisType
                    error(message('Coder:builtins:CoderThisTypeInConstructorOrStaticMethod',methodName));
                end

                inputType=fcnType.InputTypes(:)';
            else


                if numel(fcnType.InputTypes)<1||~isa(fcnType.InputTypes{1},'coder.ThisType')
                    error(message('Coder:builtins:CoderThisTypeMissing',methodName));
                end






                for i=1:numel(fcnType.InputTypes)
                    if isa(fcnType.InputTypes{i},'coder.ThisType')
                        fcnType.InputTypes{i}=outputType{1};
                    end
                end

                inputType=fcnType.InputTypes;
            end
        end


        function createEntryptsFromClassAsEP(this)
            aClassType=this.CommandArgs.ClassAsEPType;
            if isempty(aClassType.Methods)
                error(message('Coder:builtins:EntrypointMethodInfoMissing',aClassType.ClassName));
            end

            for i=1:numel(aClassType.Methods)
                this.checkEntryPointFcnName(aClassType.Methods(i).Name);
            end

            propList=fieldnames(aClassType.Properties);
            for i=1:numel(propList)
                propType=getfield(aClassType.Properties,propList{i});
                this.checkEntryPointClassProperties(aClassType.ClassName,propList{i},propType);
            end

            for i=1:numel(this.Project.EntryPoints)
                entryPoint=this.Project.EntryPoints(i);
                fcnType=aClassType.Methods(i).Type;
                [thisType,isConstructor,isStatic]=this.getThisTypeForClassMethod(...
                entryPoint.ParentClassName,entryPoint.Name);
                inputTypes=this.processMethodInputArguments(entryPoint.Name,...
                thisType,fcnType,isConstructor,isStatic);
                if isConstructor
                    inputTypes=[thisType(:)',inputTypes(:)'];
                end
                if~isempty(inputTypes)
                    entryPoint.InputTypes=inputTypes;
                    entryPoint.HasInputTypes=true;
                end
                entryPoint.IsStaticMethod=isStatic;
            end

        end

        function[major,minor]=codingTargetDir(this)
            if this.isNewCommand()
                major=lower(this.ClientType);
            else
                major='emcprj';
            end
            switch this.codingTarget()
            case 'mex'
                if this.isNewCommand()
                    minor='mex';
                else
                    minor='mexfcn';
                end
            case{'rtw','rtw:lib'}
                if this.isNewCommand()
                    minor='lib';
                else
                    minor='rtwlib';
                end
            case 'rtw:dll'
                minor='dll';
            case 'rtw:exe'
                if this.isNewCommand()
                    minor='exe';
                else
                    minor='rtwexe';
                end
            case 'hdl'
                minor='hdlsrc';
            case 'plc'
                minor='plcsrc';
            otherwise
                assert(false);
            end
        end


        function logDir=nameLogDir(this,baseDir)
            if this.codingHDL()
                logDir=this.Options.defaultLogDir;
            else
                name=this.Project.EntryPoints(1).Name;
                if numel(this.Project.EntryPoints)>1&&~isempty(this.Options.outputfile)
                    name=this.Options.outputfile;
                end

                if~isequal(this.Project.PolyMexType,'None')&&...
                    ~isempty(this.Project.EntryPoints(1).OriginName)
                    name=this.Project.EntryPoints(1).OriginName;
                    if~isempty(this.Options.outputfile)
                        name=this.Options.outputfile;
                    end
                end
                if this.Project.IsClassAsEntrypoint
                    name=this.CommandArgs.ClassName;
                end
                [major,minor]=this.codingTargetDir();
                logDir=fullfile(char(baseDir),major,minor,name);
            end
        end


        function appendCustomFile(this,file,field)
            this.CommandArgs.(field){end+1}=char(file);
        end


        function addSearchPath(this,filepath)
            addSearchPathKernel(this,filepath);
            if this.isCodeGenClient()||this.isPSTestClient()
                this.appendCustomFile(filepath,'CustomInclude');
            end
        end


        function addSearchPathKernel(this,filepath)
            p=this.Project.SearchPath;
            if numel(p)~=0
                p=[p,pathsep];
            end
            this.Project.SearchPath=[p,char(filepath)];
        end


        function text=expandProjectMacros(this,text)
            text=coder.internal.CompilationContext.expandMacros(text,this.Options.ProjectRoot);
        end
    end

    methods(Access=public,Static)
        function text=expandMacros(text,projectRoot)












            text=strrep(text,'${PROJECT_ROOT}',projectRoot);
            text=strrep(text,'${MATLAB_ROOT}',matlabroot);
            text=strrep(text,'${PREF_DIR}',prefdir);
        end
    end

    methods(Access=private)

        function options=defaultOptions(this)
            options.LogDirectory=[];
            options.outputfile=[];
            options.help=false;
            options.preserve=this.isCodeGenClient()||this.isPSTestClient();
            options.ProjectTarget='mex:code';
            options.ProjectRoot=pwd();
            options.parseOnly=false;
            options.packageFile='';
            options.CodegenInfoVarName='info';
            options.generatedProjectFile='';
            options.PolyMexOptions.treatedAsPolyMex=false;
            options.PolyMexOptions.hasMultipleArgs=false;
            options.PolyMexOptions.hasUserNumOutputs=false;
            options.PolyMexOptions.userNumOutputs=[];
        end
    end

    methods(Access=private,Static)

        function project=defaultProject(aClientType)
            project=coder.internal.Project;
            project.Client=upper(aClientType);
            project.FeatureControl=coder.internal.FeatureControl;
            project.OutDirectory=pwd;
            project.EntryPoints=coder.internal.EntryPoint('');
            project.PropertyList=coder.internal.PropertyList('');
            project.SearchPath='';

        end
    end
end


function val=checkArg(arg)



    if coder.internal.isCharOrScalarString(arg)&&(startsWith(arg,'{')||startsWith(arg,'coder.typeof('))
        try
            nil=evalin('base',arg);%#ok<NASGU>



        catch ME


            x=coderprivate.msgSafeException('Coder:configSet:FailedToEvalArgument',arg);
            if~isempty(ME)
                x=x.addCause(coderprivate.makeCause(ME));
            end
            throw(x);
        end
    end
    val=arg;
end




