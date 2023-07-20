function runTest(tbExecCfg,testName,entryPointNames,compiledName)











































    narginchk(3,4);
    nargoutchk(0,0);
    try
        testBenchResource=parseTestBenchOption(char(testName));
        if nargin==4
            mexFcnName=char(compiledName);
        else
            mexFcnName='';
        end
        if nargin==3
            [entryPointNames,mexFcnName]=getEntryPointNamesFromMEX(entryPointNames,mexFcnName);
        end
        if~iscell(entryPointNames)
            entryPointNames={char(entryPointNames)};
        end
        entryPointPaths=cell(numel(entryPointNames),1);
        for i=1:numel(entryPointPaths)
            entryPointName=entryPointNames{i};
            entryPointPath=which(entryPointNames{i});
            if isempty(entryPointPath)||strcmpi(entryPointPath,'variable')
                error(message('Coder:configSet:EntryPointNotFound',...
                entryPointName));
            end
            entryPointPaths{i}=entryPointPath;
        end
        mexFcnPath=getCompiledPath(entryPointPaths,mexFcnName);
        msgstruct=processTestBench(testBenchResource,entryPointPaths,mexFcnPath,tbExecCfg);
    catch ME
        ME.throwAsCaller();
    end
    if~isempty(msgstruct)
        runTestStack=struct('file','','name','coder.runTest','line',0);
        if isfield(msgstruct,'stack')
            msgstruct.stack(end+1,1)=runTestStack;
        else
            msgstruct.stack=runTestStack;
        end
        error(msgstruct)
    end
end


function[entryPointNames,mexFcnName]=getEntryPointNamesFromMEX(entryPointNames,mexFcnName)
    if~coder.internal.isCharOrScalarString(entryPointNames)
        return;
    end
    [succ,message]=fileattrib(char(entryPointNames));
    if~succ
        return;
    end
    mayBeMexFcnName=message.Name;
    [~,~,ext]=fileparts(mayBeMexFcnName);
    if~strcmp(ext,['.',mexext()])
        return;
    end
    project=coder.internal.Project;
    state=project.getMexFcnProperties(mayBeMexFcnName);
    if isempty(state)
        return;
    end



    mexFcnName=mayBeMexFcnName;
    entryPointNames=cell(1,numel(state.EntryPoints));
    for i=1:numel(state.EntryPoints)
        entryPointNames{i}=state.EntryPoints(i).Name;
    end
end


function testBenchResource=parseTestBenchOption(tbOption)
    testBenchFile=which(tbOption);
    if isempty(testBenchFile)||strcmpi(testBenchFile,'variable')
        error(message('Coder:configSet:TestBenchNotFound',...
        tbOption));
    end
    testBenchResource=coder.internal.TestBenchResource(tbOption);
end


function mexFcnPath=getCompiledPath(entryPointPaths,mexFcnName)
    if isempty(mexFcnName)
        sortedPointPaths=sort(entryPointPaths);
        [~,mexFcnName,~]=fileparts(sortedPointPaths{1});
        mexFcnName=[mexFcnName,'_mex'];
    end
    mexFcnPath=which(mexFcnName);
    [~,~,mexFcnExt]=fileparts(mexFcnPath);
    if isempty(mexFcnPath)||~strcmp(mexFcnExt,['.',mexext()])
        error(message('Coder:configSet:MexFunctionNotFound',mexFcnName));
    end
end


function msgstruct=processTestBench(testBenchResource,entryPointPaths,mexFcnPath,tbExecCfg)

    tbm=coder.internal.TestBenchManager.getInstance();
    tbm.reset('compiled');

    try

        prepareTestBench(tbm,testBenchResource,entryPointPaths,mexFcnPath,tbExecCfg);


        msgstruct=coder.internal.runTestExecute(tbm,testBenchResource);

    catch ME
        tbm.reset();
        ME.throwAsCaller();
    end
    tbm.reset();
end


function prepareTestBench(tbm,testBenchResource,entryPointPaths,mexFcnPath,tbExecCfg)
    tbExecCfg.setEntryPointCompiled(true);
    try
        for it=1:numel(entryPointPaths)
            entryPointPath=entryPointPaths{it};
            tbm.interceptForExecution(entryPointPath,mexFcnPath,tbExecCfg);
        end
    catch ME
        testBenchExpr=testBenchResource.getTestBenchFunction();
        x=coderprivate.msgSafeException('Coder:FE:TestBenchPrepError',testBenchExpr);
        x=x.addCause(coderprivate.makeCause(ME));
        x.throwAsCaller();
    end
end
