


























classdef Analyzer<handle
    properties(Access=private,Hidden=true)
SfcnBuildInfoMap
Sfunctions
SfunctionBlockMap
SfunctionBlockModelMap
SfunctionsDir
Opts
CheckCategories
ChecksResultMap
ChecksCategoryMap
CheckQueue
Model
ReportPath
IsLibrary
RootDir
IsLoaded
WaitBarHandle
EnableMEXReplace
MexPaths
ExemptedBlocks
MexCompiler
SystemUnderAnalysis
    end
    properties(SetAccess=private,Hidden=true)
CheckResult
Report
    end

    properties(SetAccess=private,Hidden=true)
InternalResult
    end

    methods
        function obj=Analyzer(Input,varargin)
            Input=convertStringsToChars(Input);
            obj.Sfunctions={};
            obj.SfunctionsDir={};
            cfg=Simulink.fileGenControl('getconfig');
            obj.RootDir=fullfile(cfg.CacheFolder,'slprj','_sfcncheck');

            [status,msg,msgID]=mkdir(obj.RootDir);
            if(status~=1)
                me=MException('Simulink:SFunctions:AnalyzerInitError',DAStudio.message('Simulink:SFunctions:AnalyzerInitError'));
                me=addCause(me,MException(msgID,msg));
                throw(me);
            end
            obj.EnableMEXReplace=false;
            obj.MexPaths={};
            obj.CheckResult={};
            obj.ExemptedBlocks={};
            obj.MexPaths={};


            p=inputParser;

            checkInput=@(x)validateattributes(x,{'char','string'},{'nonempty'});
            defaultSfcnBuildInfo={};
            checkSfcnBuildInfo=@(x)validateattributes(x,{'cell'},{'2d'});
            defaultOptions=Simulink.sfunction.analyzer.Options();
            checkOptions=@(x)validateattributes(x,{'Simulink.sfunction.analyzer.Options'},{'nonempty'});

            addRequired(p,'Input',checkInput);
            addParameter(p,'BuildInfo',defaultSfcnBuildInfo,checkSfcnBuildInfo);
            addParameter(p,'Options',defaultOptions,checkOptions);
            parse(p,Input,varargin{:});


            obj.Opts=p.Results.Options;
            obj.ReportPath=obj.Opts.ReportPath;



            cc=strsplit(p.Results.Input,'/');
            obj.Model=cc{1};
            obj.SystemUnderAnalysis=p.Results.Input;

            try
                obj.IsLoaded=bdIsLoaded(obj.Model);
            catch ex
                me=MException('Simulink:SFunctions:ComplianceCheckInvalidInput',DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidInput'));
                me=addCause(me,ex);
                throw(me);
            end
            if~obj.IsLoaded
                try
                    load_system(obj.Model);
                catch ex
                    me=MException('Simulink:SFunctions:ComplianceCheckInvalidInput',DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidInput'));
                    me=addCause(me,ex);
                    throw(me);
                end
            end

            finishup=onCleanup(@()obj.modelCleanup(obj.IsLoaded,obj.Model));

            if isequal(get_param(obj.Model,'BlockDiagramType'),'library')
                obj.IsLibrary=true;
                [obj.Sfunctions,obj.SfunctionBlockMap,obj.ExemptedBlocks,obj.SfunctionBlockModelMap]=Simulink.sfunction.analyzer.findSfunctions(obj.SystemUnderAnalysis);
            elseif isequal(get_param(obj.Model,'BlockDiagramType'),'model')
                obj.IsLibrary=false;
                [obj.Sfunctions,obj.SfunctionBlockMap,obj.ExemptedBlocks,obj.SfunctionBlockModelMap]=Simulink.sfunction.analyzer.findSfunctions(obj.SystemUnderAnalysis);
            end


            sfcnBuildInfoArray=p.Results.BuildInfo;
            obj.SfcnBuildInfoMap=containers.Map();
            if~isempty(sfcnBuildInfoArray)
                for i=1:numel(sfcnBuildInfoArray)
                    validateattributes(sfcnBuildInfoArray{i},{'Simulink.sfunction.analyzer.BuildInfo'},{'nonempty'});
                    obj.SfcnBuildInfoMap(sfcnBuildInfoArray{i}.SfcnName)=sfcnBuildInfoArray{i};
                end
                obj.EnableMEXReplace=true;
            else
                for i=1:numel(obj.Sfunctions)
                    sfcnFile=obj.sfunFindSource(obj.Sfunctions{i});
                    if~isempty(sfcnFile)



                        extraFileList={};
                        srcPaths={};
                        includePaths={};
                        [srcPath,~,~]=fileparts(sfcnFile);
                        srcPaths=[{srcPath},srcPaths];
                        includePaths=[{srcPath},includePaths];
                        sfcnFileWrapper=obj.sfunFindSource([obj.Sfunctions{i},'_wrapper']);
                        if~isempty(sfcnFileWrapper)
                            [~,extraFile,ext]=fileparts(sfcnFileWrapper);
                            extraFileList=[extraFileList,{[extraFile,ext]}];
                        end
                        modules=get_param(obj.SfunctionBlockMap(obj.Sfunctions{i}),'SFunctionModules');
                        modules=split(extractBetween(modules,"'","'"));
                        for k=1:numel(modules)
                            temp=obj.sfunFindSource(modules{k});
                            if~isempty(temp)
                                [~,extraFile,ext]=fileparts(temp);
                                extraFileList=[extraFileList,{[extraFile,ext]}];
                            end
                        end

                        makeInfo=obj.getMakeInfoFromMakeCfg(obj.Sfunctions{i},srcPath);
                        if~isempty(makeInfo)
                            if isfield(makeInfo,'includePath')&&iscell(makeInfo.includePath)
                                includePaths=[makeInfo.includePath,includePaths];
                            end
                            if isfield(makeInfo,'sourcePath')&&iscell(makeInfo.sourcePath)
                                srcPaths=[makeInfo.SourcePath,srcPaths];
                            end
                            if isfield(makeInfo,'sources')&&iscell(makeInfo.sources)
                                extraFileList=[makeInfo.sources,extraFileList];
                            end
                        end
                        sfcnBuildInfo=Simulink.sfunction.analyzer.BuildInfo(sfcnFile,'IncPaths',includePaths,'srcPaths',srcPaths,...
                        'ExtraSrcFileList',extraFileList);

                        obj.SfcnBuildInfoMap(sfcnBuildInfo.SfcnName)=sfcnBuildInfo;
                        obj.EnableMEXReplace=true;
                    end
                end
            end
            for i=1:numel(obj.Sfunctions)

                if~isempty(obj.SfcnBuildInfoMap)&&isKey(obj.SfcnBuildInfoMap,obj.Sfunctions{i})
                    temp=obj.SfcnBuildInfoMap(obj.Sfunctions{i});
                    temp.targetDir=fullfile(obj.RootDir,obj.Sfunctions{i});
                    obj.SfcnBuildInfoMap(obj.Sfunctions{i})=temp;
                end

                if obj.EnableMEXReplace
                    mexPath=which(obj.Sfunctions{i});
                    obj.MexPaths=[obj.MexPaths,{mexPath}];
                end
                [status,msg]=mkdir(obj.RootDir,obj.Sfunctions{i});
                obj.SfunctionsDir=[obj.SfunctionsDir,{fullfile(obj.RootDir,obj.Sfunctions{i})}];

            end


            checkCategories={
            Simulink.sfunction.analyzer.internal.ComplianceCheck.ENVIRONMENT_CHECK,...
            Simulink.sfunction.analyzer.internal.ComplianceCheck.SOURCE_CODE_CHECK,...
            Simulink.sfunction.analyzer.internal.ComplianceCheck.MEX_FILE_CHECK,...
            Simulink.sfunction.analyzer.internal.ComplianceCheck.ROBUSTNESS_CHECK
            };

            obj.CheckCategories=checkCategories;
            valueSet=cell(1,numel(checkCategories));
            obj.ChecksCategoryMap=containers.Map(checkCategories,valueSet);





            obj.CheckQueue={};
            obj.ChecksResultMap=containers.Map();

            cpCheck1=Simulink.sfunction.analyzer.internal.MEXSetupCheck('MEX Setup Check',Simulink.sfunction.analyzer.internal.ComplianceCheck.ENVIRONMENT_CHECK);
            obj.addComplianceCheck(cpCheck1,cpCheck1.Category);
            cpCheck2=Simulink.sfunction.analyzer.internal.MEXCompilationCheck('MEX Compile Check',Simulink.sfunction.analyzer.internal.ComplianceCheck.SOURCE_CODE_CHECK,obj.Opts.EnableUsePublishedOnly);
            obj.addComplianceCheck(cpCheck2,cpCheck2.Category);
            if obj.Opts.EnablePolyspace
                cpCheck3=Simulink.sfunction.analyzer.internal.PolySpaceCodeProverCheck...
                ('Polyspace Code Prover Check',Simulink.sfunction.analyzer.internal.ComplianceCheck.SOURCE_CODE_CHECK);
                obj.addComplianceCheck(cpCheck3,cpCheck3.Category);
            end

            cpCheck4=Simulink.sfunction.analyzer.internal.SemanticsComplianceCheck('All Semantics Checks',Simulink.sfunction.analyzer.internal.ComplianceCheck.MEX_FILE_CHECK);
            obj.addComplianceCheck(cpCheck4,cpCheck4.Category);
            if obj.Opts.EnableRobustness
                cpCheck5=Simulink.sfunction.analyzer.internal.InputParamRobustCheck('Input Parameter Robustness Check',Simulink.sfunction.analyzer.internal.ComplianceCheck.ROBUSTNESS_CHECK);
                obj.addComplianceCheck(cpCheck5,cpCheck5.Category);
            end
        end
        function plainResult=run(obj)

            if~obj.IsLoaded
                try
                    load_system(obj.Model);
                catch me
                    error(me.message);
                end
            end
            modelCleanup=onCleanup(@()obj.modelCleanup(obj.IsLoaded,obj.Model));


            models=values(obj.SfunctionBlockModelMap);
            modelCleanups={};
            for i=1:numel(models)
                loaded=bdIsLoaded(models{i});
                if~loaded
                    try
                        load_system(models{i});
                    catch ex
                        me=MException('Simulink:SFunctions:ComplianceCheckInvalidInput',DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidInput'));
                        me=addCause(me,ex);
                        throw(me);
                    end
                end
                modelCleanups{i}=onCleanup(@()obj.modelCleanup(loaded,models{i}));
            end

            preVal=slfeature('SFcnComplianceCheck',1);
            featureCleanup=onCleanup(@()obj.featureCleanup(preVal));

            for i=1:numel(obj.Sfunctions)
                addpath(fullfile(obj.RootDir,obj.Sfunctions{i}));
            end
            pathCleanup=onCleanup(@()obj.pathCleanup());


            obj.WaitBarHandle=waitbar(0,DAStudio.message('Simulink:SFunctions:ComplianceCheckWaitBar'),...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
            waitBarCleanup=onCleanup(@()obj.waitBarCleanup());

            if~isempty(obj.Sfunctions)&&~isempty(obj.CheckQueue)
                total=numel(obj.CheckQueue);
                setappdata(obj.WaitBarHandle,'canceling',0);

                for i=1:total
                    check=obj.CheckQueue{i};
                    set(obj.WaitBarHandle,'Name',check.Description);
                    if~getappdata(obj.WaitBarHandle,'canceling')
                        waitbar((i-1)/total,obj.WaitBarHandle);
                        resultMap=containers.Map();
                        if isa(check,'Simulink.sfunction.analyzer.internal.SemanticsComplianceCheck')

                            if(obj.EnableMEXReplace)
                                newNamePaths=cell(1,numel(obj.MexPaths));
                                for tt=1:numel(obj.MexPaths)
                                    generatedMex=fullfile(obj.RootDir,obj.Sfunctions{tt},[obj.Sfunctions{tt},'.',mexext]);
                                    [mexpath,~,~]=fileparts(obj.MexPaths{tt});
                                    if(~isempty(obj.MexPaths{tt})&&exist(generatedMex,'file')==3&&isequal(mexpath,pwd))
                                        [~,tempstr,~]=fileparts(tempname);
                                        newNamePaths{tt}=[obj.MexPaths{tt},tempstr];
                                        status=movefile(obj.MexPaths{tt},newNamePaths{tt});
                                        if status~=1
                                            break;
                                        end
                                        clear(obj.Sfunctions{tt});
                                        [status,msg,msgID]=copyfile(generatedMex,obj.MexPaths{tt});
                                        if status~=1
                                            warning(msgID,msg);
                                            break;
                                        end
                                    end
                                end
                                mexCleanup=onCleanup(@()obj.mexReplaceCleanup(newNamePaths));
                            end


                            inputStruct.model=obj.Model;
                            inputStruct.rootDir=obj.RootDir;
                            inputStruct.TimeOut=obj.Opts.ModelSimTimeOut;
                            waitbar((i-1)/total,obj.WaitBarHandle,...
                            DAStudio.message('Simulink:SFunctions:ComplianceCheckWaitbarRunning','All S-functions'));
                            re=check.run(inputStruct);

                            combinedOutput=re.description;
                            resultMap=combinedOutput;
                            clear featureCleanup;
                            clear mexCleanup;
                        elseif isa(check,'Simulink.sfunction.analyzer.internal.MEXCompilationCheck')...
                            ||isa(check,'Simulink.sfunction.analyzer.internal.PolySpaceCodeProverCheck')
                            re.description=check.Description;
                            re.result=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                            re.details={Simulink.sfunction.analyzer.internal.geti18nMessage(Simulink.sfunction.analyzer.internal.ComplianceCheck.NO_SOURCE_OR_COMPILER)};
                            for j=1:numel(obj.Sfunctions)
                                target=obj.Sfunctions{j};
                                if getappdata(obj.WaitBarHandle,'canceling')
                                    waitbar((i-1)/total+(1/total)*((j-1)/numel(obj.Sfunctions)),obj.WaitBarHandle,...
                                    DAStudio.message('Simulink:SFunctions:ComplianceCheckWaitbarExiting',check.Description));
                                    te.description=check.Description;
                                    te.result=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                                    te.details={};
                                    for tt=j:numel(obj.Sfunctions)
                                        resultMap(obj.Sfunctions{tt})=te;
                                    end
                                    break;
                                else
                                    tempMap=obj.ChecksResultMap('MEX Setup Check');
                                    tempre=tempMap(target);

                                    waitbar((i-1)/total+(1/total)*((j-1)/numel(obj.Sfunctions)),obj.WaitBarHandle,...
                                    DAStudio.message('Simulink:SFunctions:ComplianceCheckWaitbarRunning',strrep(target,'_','\_')));
                                    if isKey(obj.SfcnBuildInfoMap,target)&&isequal(tempre.result,Simulink.sfunction.analyzer.internal.ComplianceCheck.PASS)
                                        resultMap(target)=...
                                        check.run(obj.SfcnBuildInfoMap(target));
                                    else
                                        resultMap(target)=re;
                                    end
                                    waitbar((i-1)/total+(1/total)*(j/numel(obj.Sfunctions)),obj.WaitBarHandle);
                                end
                            end
                        elseif isa(check,'Simulink.sfunction.analyzer.internal.MEXSetupCheck')
                            re.description=check.Description;
                            re.result=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                            re.details={};
                            for j=1:numel(obj.Sfunctions)

                                target=obj.Sfunctions{j};
                                wizardData=get_param(obj.SfunctionBlockMap(target),'WizardData');
                                if~isempty(wizardData)&&...
                                    (~isfield(wizardData,'BlockSetSDK')&&~isequal(wizardData,'IsBlockSDKSfBuilder')...
                                    ||isfield(wizardData,'BlockSetSDK')&&~wizardData.BlockSetSDK)
                                    libText=wizardData.LibraryFilesText;
                                    blockhandle=getSimulinkBlockHandle(obj.SfunctionBlockMap(target));
                                    [libFileList,srcFileList,objFileList,...
                                    addIncPaths,addLibPaths,addSrcPaths,...
                                    preProcList,~]=slprivate('parseLibCodePaneText',libText,blockhandle);
                                    ext=lower(get_param(obj.Model,'TargetLang'));
                                    if isequal(ext,'c++')
                                        ext='cpp';
                                    end
                                    sfcnFile=[target,'.',ext];
                                    if exist(sfcnFile,'file')~=2
                                        try
                                            set_param(obj.Model,'SimulationCommand','update');
                                        catch
                                        end
                                    end
                                    sfcnWrapperFile=[target,'_wrapper.',ext];
                                    srcFileList=[srcFileList,sfcnWrapperFile];
                                    try
                                        bdInfo=Simulink.sfunction.analyzer.BuildInfo(sfcnFile,'ExtraSrcFileList',srcFileList,...
                                        'libFileList',libFileList,'objFileList',objFileList,'IncPaths',addIncPaths,...
                                        'LibPaths',addLibPaths,'SrcPaths',addSrcPaths,'PreProcDefList',preProcList);
                                    catch ex
                                        me=MException('Simulink:SFunctions:ComplianceCheckInvalidInput',DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidInput'));
                                        me=addCause(me,ex);
                                        throw(me);
                                    end
                                    obj.SfcnBuildInfoMap(target)=bdInfo;
                                end

                                if isKey(obj.SfcnBuildInfoMap,obj.Sfunctions{j})
                                    resultMap(obj.Sfunctions{j})=...
                                    check.run(obj.SfcnBuildInfoMap(obj.Sfunctions{j}));
                                else
                                    resultMap(obj.Sfunctions{j})=re;
                                end
                            end
                        elseif isa(check,'Simulink.sfunction.analyzer.internal.InputParamRobustCheck')
                            re.description=check.Description;
                            re.result=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                            re.details={};
                            for j=1:numel(obj.Sfunctions)
                                if getappdata(obj.WaitBarHandle,'canceling')
                                    waitbar((i-1)/total+(1/total)*((j-1)/numel(obj.Sfunctions)),obj.WaitBarHandle,...
                                    DAStudio.message('Simulink:SFunctions:ComplianceCheckWaitbarExiting',check.Description));
                                    for tt=j:numel(obj.Sfunctions)
                                        resultMap(obj.Sfunctions{tt})=re;
                                    end
                                    break;
                                else
                                    waitbar((i-1)/total+(1/total)*((j-1)/numel(obj.Sfunctions)),obj.WaitBarHandle,...
                                    DAStudio.message('Simulink:SFunctions:ComplianceCheckWaitbarRunning',strrep(obj.Sfunctions{j},'_','\_')));
                                    input.sfcnName=obj.Sfunctions{j};
                                    input.sfcnBlock=obj.SfunctionBlockMap(obj.Sfunctions{j});
                                    input.model=obj.Model;
                                    input.rootDir=obj.RootDir;
                                    resultMap(obj.Sfunctions{j})=...
                                    check.run(input);
                                    waitbar((i-1)/total+(1/total)*(j/numel(obj.Sfunctions)),obj.WaitBarHandle);
                                end
                            end
                        end

                        obj.ChecksResultMap(check.Description)=resultMap;
                        waitbar(i/total,obj.WaitBarHandle);
                    else

                        resultMap2=containers.Map();
                        temp.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                        temp.summaryNum=0;
                        temp.content={};
                        temp.category=Simulink.sfunction.analyzer.internal.ComplianceCheck.MEX_FILE_CHECK;
                        for ll=1:numel(obj.Sfunctions)
                            temp.target=obj.Sfunctions{ll};
                            resultMap2(obj.Sfunctions{ll})=temp;
                        end

                        for kk=i:total
                            check=obj.CheckQueue{kk};
                            if~isa(check,'Simulink.sfunction.analyzer.internal.SemanticsComplianceCheck')
                                resultMap=containers.Map();
                                te.description=check.Description;
                                te.result=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                                te.details={};
                                for tt=1:numel(obj.Sfunctions)
                                    resultMap(obj.Sfunctions{tt})=te;
                                end
                                obj.ChecksResultMap(check.Description)=resultMap;
                            else
                                obj.ChecksResultMap(check.Description)=resultMap2;
                            end
                        end
                        break;
                    end

                end

            end




            [obj.CheckResult,plainResult]=obj.constructCheckResult();
        end
        function generateReport(obj,varargin)

            if nargin<2
                isVisible=true;
            else
                isVisible=varargin{1};
            end

            rpt=Simulink.sfunction.analyzer.internal.ComplianceCheckReport(obj.SystemUnderAnalysis,obj.Sfunctions,...
            obj.CheckCategories,obj.CheckResult,obj.ReportPath,obj.SfunctionBlockMap,obj.IsLibrary);
            rpt.RetainChildren=true;
            if isVisible
                obj.Report=rpt;
                rptgen.rptview(rpt);

            else
                obj.Report=rpt;
            end
            close(rpt);
        end
    end

    methods(Access=private,Hidden=true)
        function waitBarCleanup(obj)
            delete(obj.WaitBarHandle);
        end
        function modelCleanup(obj,isLoaded,model)
            if~isLoaded
                close_system(model,0);
            end
        end

        function featureCleanup(obj,preVal)
            slfeature('SFcnComplianceCheck',preVal);
        end

        function pathCleanup(obj)
            if iscell(obj.SfunctionsDir)
                for i=1:numel(obj.SfunctionsDir)
                    if exist(obj.SfunctionsDir{i},'dir')==7
                        rmpath(obj.SfunctionsDir{i});
                    end
                end
            else
                if exist(obj.SfunctionsDir,'dir')==7
                    rmpath(obj.SfunctionsDir);
                end
            end
        end

        function mexReplaceCleanup(obj,cachePaths)
            if obj.EnableMEXReplace
                for i=1:numel(obj.MexPaths)
                    if(~isempty(obj.MexPaths{i})&&exist(cachePaths{i},'file')==2)
                        clear(obj.Sfunctions{i});
                        delete(obj.MexPaths{i});
                        [status,msg,~]=movefile(cachePaths{i},obj.MexPaths{i});
                        if status~=1
                            warning('Simulink:SFunctions:UnableToRestore',...
                            DAStudio.message('Simulink:SFunctions:UnableToRestore',cachePaths{i},obj.MexPaths{i},msg));
                        end
                    end
                end
            end
        end


        function addComplianceCheck(obj,check,category)
            if isempty(find(cell2mat(obj.CheckCategories)==category))
                error(DAStudio.message('Simulink:SFunctions:ComplianceCheckInvalidCategory',...
                strjoin(Simulink.sfunction.analyzer.internal.ComplianceCheck.checkCategories(cell2mat(obj.checkCategories)),', ')));
            else
                obj.ChecksCategoryMap(category)=[obj.ChecksCategoryMap(category),{check}];
                obj.CheckQueue=[obj.CheckQueue,{check}];
            end
        end


        function srcFile=sfunFindSource(obj,sfun)
            extensions={'.c','.cpp'};
            loc=[matlabroot,filesep,'simulink',filesep,'src',filesep];
            for i=1:length(extensions)
                srcCandidate=[sfun,extensions{i}];

                srcFile=which(srcCandidate);
                if exist(srcFile,'file')==2
                    return;
                end

                srcFile=[loc,srcCandidate];
                if exist(srcFile,'file')==2
                    return;
                end

            end



            makeInfo=getMakeInfoFromMakeCfg(obj,sfun,pwd);
            if~isempty(makeInfo)&&isfield(makeInfo,'sourcePath')
                extensions={'.c','.cpp'};
                for m=1:length(makeInfo.sourcePath)
                    loc=makeInfo.sourcePath{m};
                    if isempty(strfind(loc,['toolbox',filesep,'rtw']))
                        for n=1:length(extensions)
                            srcCandidate=[sfun,extensions{n}];
                            srcFile=[loc,filesep,srcCandidate];
                            if exist(srcFile,'file')==2
                                return;
                            end
                        end
                    end
                end
            end
            srcFile='';
        end

        function[checkResults,plainResult]=constructCheckResult(obj)

            checkResults.TimeGenerated=datestr(datetime('now'));
            checkResults.Platform=computer('arch');
            tt=ver('simulink');
            checkResults.Release=tt.Release;
            checkResults.SimulinkVersion=tt.Version;
            checkResults.ExemptedBlocks=obj.ExemptedBlocks;


            checkResults.MexConfiguration=mex.getCompilerConfigurations('C','Selected');
            plainResult=checkResults;

            obj.InternalResult=cell(numel(obj.Sfunctions),numel(obj.CheckCategories));
            for i=1:numel(obj.Sfunctions)
                for j=1:numel(obj.CheckCategories)
                    checks=obj.ChecksCategoryMap(obj.CheckCategories{j});
                    if(isempty(checks))

                        for t=1:numel(obj.Sfunctions)
                            temp.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                            temp.summaryNum=0;
                            temp.content='';
                            temp.target=obj.Sfunctions{i};
                            temp.category=obj.CheckCategories{j};
                            obj.InternalResult{i,j}=temp;
                        end
                    else

                        if isequal(obj.CheckCategories{j},Simulink.sfunction.analyzer.internal.ComplianceCheck.MEX_FILE_CHECK)
                            resultMap=obj.ChecksResultMap(checks{1}.Description);



                            obj.InternalResult{i,j}=resultMap(obj.Sfunctions{i});
                        else
                            temp.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.PASS;
                            temp.summaryNum=numel(checks);
                            temp.content=cell(1,numel(checks));
                            temp.target=obj.Sfunctions{i};
                            temp.category=obj.CheckCategories{j};
                            if(isempty(obj.SfcnBuildInfoMap))
                                temp.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                                temp.summaryNum=0;
                                temp.content={};
                            else
                                td=0;
                                te=0;
                                tf=0;
                                for k=1:numel(checks)
                                    resultMap=obj.ChecksResultMap(checks{k}.Description);
                                    temp.content{k}=resultMap(obj.Sfunctions{i});
                                    if(isequal(temp.content{k}.result,Simulink.sfunction.analyzer.internal.ComplianceCheck.FAIL))
                                        td=td+1;
                                    end
                                    if(isequal(temp.content{k}.result,Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN))
                                        te=te+1;
                                    end
                                    if(isequal(temp.content{k}.result,Simulink.sfunction.analyzer.internal.ComplianceCheck.WARNING))
                                        tf=tf+1;
                                    end
                                end





                                if(te~=0)



                                    temp.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                                    temp.summaryNum=te;
                                end
                                if(tf~=0)
                                    temp.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.WARNING;
                                    temp.summaryNum=tf;
                                end
                                if(td~=0)
                                    temp.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.FAIL;
                                    temp.summaryNum=td;
                                end
                            end
                            obj.InternalResult{i,j}=temp;
                        end
                    end
                end
            end
            [checkResults.Data,plainResult.Data]=obj.convertToReadable(obj.InternalResult);

        end

        function[readableResult,plainResultData]=convertToReadable(obj,internalResult)
            [x,y]=size(internalResult);
            myEmptyCell=num2cell(zeros(1,y));
            readableResult=repmat(struct('Sfunction',myEmptyCell,...
            'CheckCategory',myEmptyCell,...
            'SummaryResult',myEmptyCell,...
            'SummaryNumber',myEmptyCell,...
            'Check',myEmptyCell),x,1);
            plainResultData=repmat(struct('Sfunction',myEmptyCell,...
            'CheckCategory',myEmptyCell,...
            'Check',myEmptyCell),x,1);
            for i=1:x
                for j=1:y
                    temp=internalResult{i,j};
                    readableResult(i,j).Sfunction=temp.target;
                    readableResult(i,j).CheckCategory=Simulink.sfunction.analyzer.internal.geti18nMessage(temp.category);
                    readableResult(i,j).SummaryResult=Simulink.sfunction.analyzer.internal.geti18nMessage(temp.summaryResult);
                    readableResult(i,j).SummaryNumber=temp.summaryNum;
                    contents=temp.content;
                    z=numel(contents);
                    myEmptyCell=num2cell(zeros(1,z));
                    checks=struct('Description',myEmptyCell,...
                    'Result',myEmptyCell,...
                    'Detail',myEmptyCell);
                    for k=1:z
                        checks(k).Description=contents{k}.description;
                        checks(k).Result=Simulink.sfunction.analyzer.internal.geti18nMessage(contents{k}.result);
                        checks(k).Detail=contents{k}.details;
                    end

                    readableResult(i,j).Check=checks;

                    plainResultData(i,j).Sfunction=readableResult(i,j).Sfunction;
                    plainResultData(i,j).CheckCategory=readableResult(i,j).CheckCategory;
                    plainResultData(i,j).Check=readableResult(i,j).Check;
                end
            end
        end

        function makeInfo=getMakeInfoFromMakeCfg(obj,sfun,loc)

            makeInfo='';
            pwd_init=pwd;
            if exist(fullfile(loc,[sfun,'_makecfg.m']),'file')==2
                cd(loc);
                [~,makeInfo]=evalc([sfun,'_makecfg']);
                cd(pwd_init);
                return;
            end
            if exist(fullfile(loc,'rtwmakecfg.m'),'file')==2
                cd(loc);
                [~,makeInfo]=evalc('rtwmakecfg');
                cd(pwd_init);
            end

        end
    end

end
