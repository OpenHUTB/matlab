function result=getArgTypes(testName,entryPointNames,varargin)






















    p=inputParser();
    p.FunctionName='coder.getArgTypes';
    p.addParameter('Uniform',false);

    p.parse(varargin{:});
    r=p.Results;
    try
        validateattributes(r.Uniform,{'double','logical'},{'scalar'},'coder.getArgTypes','UNIFORM');
        r.Uniform=r.Uniform~=0;
        testBenchResource=parseTestBenchOption(testName);
        if~iscell(entryPointNames)
            entryPointNames={entryPointNames};
        end
        if isempty(entryPointNames)
            error(message('Coder:configSet:EntryPointNotSpecified'));
        end
        entryPointPaths=cell(numel(entryPointNames),1);
        for i=1:numel(entryPointPaths)
            entryPointName=entryPointNames{i};
            if isa(entryPointName,'function_handle')
                entryPointName=func2str(entryPointName);
            elseif isstring(entryPointName)
                entryPointName=char(entryPointName);
            end
            entryPointPath=which(entryPointName);
            if isempty(entryPointPath)||strcmpi(entryPointPath,'variable')
                error(message('Coder:configSet:EntryPointNotFound',...
                entryPointName));
            end
            entryPointPaths{i}=entryPointPath;
        end
        types=processTestBench(testBenchResource,entryPointPaths);
    catch ME
        ME.throwAsCaller();
    end
    if r.Uniform||numel(entryPointPaths)>1
        result=types;
    else
        [~,name,~]=fileparts(entryPointPaths{1});
        if isfield(types,name)
            result=types.(name);
        else
            result={};
        end
    end
end


function testBenchResource=parseTestBenchOption(tbOption)
    if isa(tbOption,'function_handle')
        tbOption=func2str(tbOption);
    elseif isstring(tbOption)
        tbOption=char(tbOption);
    end
    testBenchFile=which(tbOption);
    if isempty(testBenchFile)||strcmpi(testBenchFile,'variable')
        error(message('Coder:configSet:TestBenchNotFound',...
        tbOption));
    end
    testBenchResource=coder.internal.TestBenchResource(tbOption);
end


function types=processTestBench(testBenchResource,entryPointPaths)

    tbm=coder.internal.TestBenchManager.getInstance();
    tbm.reset();
    cleanupFcn=onCleanup(@()tbm.reset());

    try

        prepareTestBench(tbm,testBenchResource,entryPointPaths);


        executeTestBench(tbm,testBenchResource);


        types=extractAllInputTypes(tbm,testBenchResource);


        warnIfEntryPointMissed(tbm);
    catch ME
        msgstruct.identifier=ME.identifier;
        msgstruct.message=sanitizeMessage(tbm,entryPointPaths,ME.message);
        msgstruct.stack=ME.stack;
        try
            rethrow(msgstruct);
        catch me
            for i=1:numel(ME.cause)

                me=me.addCause(ME.cause{i});
            end
            me.throwAsCaller();
        end
    end
end


function msgText=sanitizeMessage(tbm,entryPointPaths,msgText)
    if isempty(msgText)
        return;
    end
    for i=1:numel(entryPointPaths)
        entryPointPath=entryPointPaths{i};
        msgText=tbm.sanitizeMessage(entryPointPath,msgText);
    end
end


function prepareTestBench(tbm,testBenchResource,entryPointPaths)
    try
        for i=1:numel(entryPointPaths)
            entryPointPath=entryPointPaths{i};
            tbm.interceptForInference(entryPointPath);
        end
    catch ME
        testBenchExpr=testBenchResource.getTestBenchFunction();
        x=coderprivate.msgSafeException('Coder:FE:TestBenchPrepError',testBenchExpr);
        x=x.addCause(coderprivate.makeCause(ME));
        x.throwAsCaller();
    end
end


function executeTestBench(tbm,testBenchResource)
    suppressOutput=true;
    msgText=tbm.executeTestBench(testBenchResource,suppressOutput);
    if~isempty(msgText)
        error(message('Coder:FE:Explicit',msgText));
    end
end


function types=extractAllInputTypes(tbm,testBenchResource)
    try
        types=extractAllInputTypesImpl(tbm);
    catch ME
        msgID='Coder:FE:TestBenchTypeError';
        testBenchExpr=testBenchResource.getTestBenchFunction();
        x=coderprivate.msgSafeException(msgID,testBenchExpr);
        x=x.addCause(coderprivate.makeCause(ME));
        x.throwAsCaller();
    end
end


function result=extractAllInputTypesImpl(tbm)
    alltypes=tbm.retrieveAllFunctionTypes();
    result=struct;
    keys=alltypes.keys();
    data=alltypes.values();
    for i=1:numel(data)
        types=data{i};
        entryPointName=keys{i};
        if~isempty(types)
            validateInputTypes(types,tbm,entryPointName);
        end
        result.(entryPointName)=types;
    end
end

function validateInputTypes(types,tbm,entryPointName)
    function reject(t,ME)
        if isequal(ME.identifier,'Coder:common:TestBenchvariadically')
            x=coderprivate.msgSafeException('Coder:common:TestBenchvariadically');
        else
            idpNames=tbm.getInputNames(entryPointName);
            idpName=idpNames{t};
            errPath=[entryPointName,':',idpName];
            x=coderprivate.msgSafeException('Coder:FE:TestBenchTypeCause',errPath);
        end
        x=x.addCause(coderprivate.makeCause(ME));
        x.throwAsCaller();
    end

    for t=1:numel(types)
        type=types{t};
        if isa(type,'MException')
            reject(t,type);
        end
    end
end

function warnIfEntryPointMissed(tbm)
    allhits=tbm.retrieveAllFunctionHits();
    keys=allhits.keys();
    data=allhits.values();
    for i=1:numel(data)
        hit=data{i};
        entryPointName=keys{i};
        if~hit
            btStruct=warning('QUERY','BACKTRACE');
            warning('OFF','BACKTRACE');
            warning(message('Coder:FE:EntryPointNotCalled',entryPointName));
            warning(btStruct);
        end
    end
end

