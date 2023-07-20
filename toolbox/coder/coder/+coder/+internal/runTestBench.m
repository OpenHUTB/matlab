function result=runTestBench(tbConfig)



    import com.mathworks.toolbox.coder.plugin.TestBenchConfig;
    import com.mathworks.toolbox.coder.plugin.TestBenchResult;
    import com.mathworks.toolbox.coder.plugin.TestBenchRunMode;

    dataManager=coder.internal.CoderGuiDataManager.getInstance();

    if tbConfig.isUseCachedData()
        resultStruct=dataManager.retrieveFromCache(tbConfig.getBuildType(),dataManager.FIELD_TEST_OUTPUT);
        result=TestBenchResult('');

        if isfield(resultStruct,'message')&&ischar(resultStruct.message)
            result.setMessage(resultStruct.message);
        end

        if isfield(resultStruct,'unhitFunctions')&&iscell(resultStruct.unhitFunctions)
            cellfun(@(fcnName)result.addUnhitFunction(fcnName),resultStruct.unhitFunctions,'UniformOutput',false);
        end

        if isfield(resultStruct,'log')&&ischar(resultStruct.log)
            result.setOutputLog(resultStruct.log);
        end



        return;
    end


    tbm=coder.internal.TestBenchManager.getInstance();
    if tbConfig.getRunMode()==TestBenchRunMode.RUN_ORIGINAL
        testRunMode='original';
    else
        testRunMode='compiled';
    end
    tbm.reset(testRunMode);


    if~tbConfig.isSynthetic()
        clear(char(tbConfig.getTestBenchFile().getAbsolutePath()));
    end


    msgText=[];
    if tbConfig.getRunMode()==TestBenchRunMode.RUN_COMPILED
        msgText=prepareTestBench(tbm,tbConfig);
    end

    isCheckForIssues=tbConfig.getBuildType()==com.mathworks.toolbox.coder.app.CoderBuildType.CHECK_FOR_ISSUES;
    if(isCheckForIssues)
        covrtEnableCoverageLogging(true);
        coverageCleanup=onCleanup(@()covrtEnableCoverageLogging(false));
    end


    if isempty(msgText)
        if tbConfig.isProfilingEnabled()
            viewerOpener=onCleanup(@()profile('viewer'));
        end
        msgText=executeTestBench(tbm,tbConfig);
        if tbConfig.isProfilingEnabled()
            fprintf('\n<a href="matlab:profile(''viewer'');">%s</a>',...
            message('Coder:FE:ProfileViewerHyperlinkText').getString());
        end
    end

    result=TestBenchResult(msgText);
    unhitFcns=getUnhitFunctions(tbm);
    cellfun(@(fcn)result.addUnhitFunction(fcn),unhitFcns,'UniformOutput',false);



    if tbConfig.isSupportsCaching()
        assert(~tbConfig.isUseCachedData());
        resultStruct=struct('message',msgText,'unhitFunctions',{unhitFcns},'log',[]);
        dataManager.setGuiTestOutput(tbConfig.getProjectConfiguration(),...
        tbConfig.getBuildType(),resultStruct);
    end

    tbm.reset();
end


function msgText=prepareTestBench(tbm,tbConfig)
    import com.mathworks.toolbox.coder.plugin.TestBenchRunMode;

    msgText='';

    mexFcnPath=char(tbConfig.getWorkingFolder());
    if isempty(mexFcnPath)
        mexFcnPath=pwd();
    end
    mexFcnName=char(tbConfig.getMexFunctionName());
    [~,mexFcnName,~]=fileparts(mexFcnName);
    mexFcnPath=fullfile(mexFcnPath,[mexFcnName,'.',mexext()]);

    isEntryPtCompiled=tbConfig.getRunMode()==TestBenchRunMode.RUN_COMPILED;
    isMexInEntryPtPath=false;
    tbExecCfg=coder.internal.TestBenchExecConfig(isMexInEntryPtPath,isEntryPtCompiled);
    try
        if~tbConfig.isSynthetic()
            testBenchFolder=fileparts(char(tbConfig.getTestBenchFile().getAbsolutePath()));
            oldpath=cd(testBenchFolder);
            fileType=exist(mexFcnPath,'file');
            cd(oldpath);
            mexFileType=3;
            if fileType~=mexFileType
                error(message('Coder:configSet:MexFunctionNotFound',mexFcnName));
            end
        end

        it=tbConfig.getEntryPointFiles().iterator();
        while it.hasNext()
            entryPoint=it.next();
            entryPointPath=char(entryPoint.getAbsolutePath());
            tbm.interceptForExecution(entryPointPath,mexFcnPath,tbExecCfg);
        end
    catch ME
        if~tbConfig.isSynthetic()
            [~,testBenchFcn]=fileparts(char(tbConfig.getTestBenchFile().getAbsolutePath()));
        else
            testBenchFcn=tbConfig.getSyntheticCode();
        end

        if tbConfig.isSynthetic()
            x=coderprivate.msgSafeException('Coder:FE:TestBenchAdHocPrepError');
        else
            x=coderprivate.msgSafeException('Coder:FE:TestBenchPrepError',testBenchFcn);
        end

        x=x.addCause(coderprivate.makeCause(ME));
        msgText=x.getReport();
    end
end


function msgText=executeTestBench(tbm,tbConfig)
    if~tbConfig.isSynthetic()
        testBenchFile=tbConfig.getTestBenchFile();
        testBenchPath=char(testBenchFile.getAbsolutePath());
        testBenchResource=coder.internal.TestBenchResource(testBenchPath);
    else
        testCode=char(tbConfig.getSyntheticCode());
        testBenchResource=coder.internal.TestBenchResource(testCode);
        testBenchResource.setIsSynthetic(true);
    end

    msgText='';
    profiling=tbConfig.isProfilingEnabled();
    if profiling
        profile off;
        profile clear;
        profileCleanup=onCleanup(@()profile('off'));
        profile on;
    end

    try
        msgStruct=coder.internal.runTestExecute(tbm,testBenchResource);
        if profiling
            profile off;
        end
    catch ME

        if profiling
            profile off;
        end
        msgText=ME.message;
        return;
    end
    if isempty(msgStruct)
        return;
    end
    if~isfield(msgStruct,'stack')
        msgText=msgStruct.message;
        return;
    end

    stackTrace=cell(1,numel(msgStruct.stack));
    stackEntry=findFunctionName(msgStruct.stack(1));
    if false



    else
        msgLink=num2str(stackEntry.line);
    end

    stackTrace{1}=sprintf('Error using %s (line %s)\n%s\n\n',...
    stackEntry.name,msgLink,msgStruct.message);

    for sp=2:numel(msgStruct.stack)
        stackEntry=findFunctionName(msgStruct.stack(sp));
        errorLine=findErrorLine(stackEntry);
        msgLine=sprintf('Error in %s (line %d)\n%s\n',...
        stackEntry.name,stackEntry.line,errorLine);
        stackTrace{sp}=msgLine;
    end
    msgText=[stackTrace{:}];
end


function newsite=findFunctionName(site)
    newsite=site;
    try
        T=mtree(site.file,'-file');
        fundecls=mtfind(T,'Kind','FUNCTION');
        index=find(site.line>=fundecls.lineno,1,'last');
        if~isempty(index)
            names=fundecls.Fname.strings;
            if index<=numel(names)
                newsite.name=names{index};
                [~,name,~]=fileparts(site.file);
                if~strcmp(name,newsite.name)
                    newsite.name=[name,'>',newsite.name];
                end
            end
        end
    catch
    end
end


function line=findErrorLine(site)
    line='';
    [~,~,ext]=fileparts(site.file);
    if~strcmp(ext,'.m')
        return;
    end
    fid=[];
    try
        fid=fopen(site.file,'rt');
        text=fread(fid,[1,inf],'*char');
        fclose(fid);
        fid=[];

        nl=newline;
        startPos=1;
        lineNo=1;
        for i=1:length(text)
            if lineNo==site.line
                for j=i:length(text)
                    if text(j)==nl
                        break;
                    end
                end
                line=text(startPos:j);
                break;
            end
            if text(i)==nl
                startPos=i+1;
                lineNo=lineNo+1;
            end
        end
    catch
        if~isempty(fid)&&fid~=-1
            fclose(fid);
        end
    end
end


function unhitFcns=getUnhitFunctions(tbm)
    allhits=tbm.retrieveAllFunctionHits();
    names=allhits.keys();
    statuses=allhits.values();
    unhitFcns={};

    for i=1:numel(names)
        if~statuses{i}
            unhitFcns{end+1}=names{i};%#ok<AGROW>
        end
    end
end
