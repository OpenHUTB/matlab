function result=inferTestBench(tbConfig)




    import com.mathworks.toolbox.coder.plugin.TestBenchConfig;
    import com.mathworks.toolbox.coder.plugin.TestBenchResult;

    try

        defFigVisibility=get(0,'DefaultFigureVisible');
        set(0,'DefaultFigureVisible','Off');
        figuresPrior=findall(0,'Type','figure');
        figureCleanup=onCleanup(@()cleanupFiguresAfterRun(defFigVisibility,figuresPrior));
    catch
    end
    coder.internal.ddux.logger.logCoderEventData("appAutodefine");
    tbm=coder.internal.TestBenchManager.getInstance();
    result=TestBenchResult('');

    try

        tbm.reset();
        resetOnCleanup=onCleanup(@tbm.reset);


        msgText=prepareTestBench(tbm,tbConfig);


        if isempty(msgText)
            msgText=executeTestBench(tbm,tbConfig);
        end
    catch
    end



    if~exist('msgText','var')||isempty(msgText)
        msgText=extractAllInputTypes(tbm,tbConfig,result);
    end
    result.setMessage(sanitizeMessage(tbm,tbConfig,msgText));


    function cleanupFiguresAfterRun(defFigVisibility,figuresPrior)
        set(0,'DefaultFigureVisible',defFigVisibility);
        figuresNow=findall(0,'Type','figure');
        figsOpened=setdiff(figuresNow,figuresPrior);
        close(figsOpened);
    end
end


function msgText=sanitizeMessage(tbm,tbConfig,msgText)
    if isempty(msgText)
        return;
    end
    it=tbConfig.getEntryPointFiles().iterator();
    while it.hasNext()
        entryPoint=it.next();
        entryPointPath=char(entryPoint.getAbsolutePath());
        msgText=tbm.sanitizeMessage(entryPointPath,msgText);
    end
end


function msgText=prepareTestBench(tbm,tbConfig)
    msgText='';
    try
        it=tbConfig.getEntryPointFiles().iterator();
        while it.hasNext()
            entryPoint=it.next();
            entryPointPath=char(entryPoint.getAbsolutePath());
            tbm.interceptForInference(entryPointPath);
        end
    catch ME
        msgText=formatError(tbConfig,ME);
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

    msgText=tbm.executeTestBench(testBenchResource);
end

function msgText=extractAllInputTypes(tbm,tbConfig,result)
    msgText='';
    try
        extractAllInputTypesImpl(tbm,tbConfig,result);
    catch ME
        msgText=formatError(tbConfig,ME);
    end
end

function extractAllInputTypesImpl(tbm,tbConfig,result)
    alltypes=tbm.retrieveAllFunctionTypes();
    keys=alltypes.keys();
    data=alltypes.values();
    for i=1:numel(data)
        types=data{i};
        entryPointName=keys{i};

        if~isempty(types)
            extractInputTypes(tbm,tbConfig,result,entryPointName,types);
        else
            result.addUnhitFunction(entryPointName);
        end
    end
end

function extractInputTypes(tbm,tbConfig,result,entryPointName,types)
    function createProperty(name,value)
        propNode=xmlDoc.createTextNode(value);
        propElement=xmlDoc.createElement(name);
        propElement.appendChild(propNode);
        element.appendChild(propElement);
    end

    function reject(ME)
        x=coderprivate.msgSafeException('Coder:FE:TestBenchTypeCause',errPath);
        x=x.addCause(coderprivate.makeCause(ME));
        x.throwAsCaller();
    end

    function type=resize(type)
        sizeLimits=[inf,inf];
        if tbConfig.isAutoBounded
            sizeLimits(1)=tbConfig.getAutoBoundedThreshold();
        end
        if tbConfig.isAutoUnbounded
            sizeLimits(2)=tbConfig.getAutoUnboundedThreshold();
        end
        type=coder.resize(type,...
        'sizeLimits',sizeLimits,'recursive',true,'uniform',true);
    end

    xmlDoc=com.mathworks.xml.XMLUtils.createDocument('Inputs');
    xmlRoot=xmlDoc.getDocumentElement;
    xmlRoot.setAttribute('fileName',[entryPointName,'.m']);
    xmlRoot.setAttribute('functionName',entryPointName);
    itcNames=tbm.getInputNames(entryPointName);
    elementName='Input';
    for t=1:numel(types)
        itcName=itcNames{t};
        errPath=[entryPointName,':',itcName];
        type=types{t};
        if isa(type,'MException')
            reject(type);
        end
        if tbConfig.isAutoBounded()||tbConfig.isAutoUnbounded()
            type=resize(type);
        end
        if strcmp(itcName,'varargin{1}')
            element=xmlDoc.createElement(elementName);
            element.setAttribute('Name','varargin');
            createProperty('Class','cell');
            createProperty('Size',sprintf('1 x %d',numel(types)-t+1));
            xmlRoot.appendChild(element);
            xmlRoot=element;
            elementName='Field';
        end
        rootElement=xmlDoc.createElement(elementName);
        xmlRoot.appendChild(rootElement);
        emlcprivate('type2xml',type,false,itcName,xmlDoc,rootElement);
    end
    xml=xmlwrite(xmlDoc);
    result.setTypes(entryPointName,xml);
end

function errorText=formatError(tbConfig,ME)
    if tbConfig.isSynthetic()
        testBenchFcn=getTrimmedCode(60);
    else
        [~,testBenchFcn]=fileparts(char(tbConfig.getTestBenchFile().getName()));
    end

    x=coderprivate.msgSafeException('Coder:FE:TestBenchPrepError',testBenchFcn);
    x=x.addCause(coderprivate.makeCause(ME));
    errorText=x.getReport();

    function code=getTrimmedCode(maxLen)
        code=char(tbConfig.getSyntheticCode());
        if numel(code)>maxLen
            code=[code(1:maxLen),'...'];
        end
    end
end
