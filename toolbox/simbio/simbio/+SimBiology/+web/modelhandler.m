function out=modelhandler(action,varargin)











    out={action};

    switch(action)
    case 'getModelInfo'
        out=getModelInfo(action,varargin{1});
    case 'getModelParameters'
        out=getModelParameters(varargin{:});
    case 'getModelSpecies'
        out=getModelSpecies(varargin{:});
    case 'getModelInfoFromModel'
        out=getModelInfoFromModel(varargin{1});
    case 'createSBMLModel'
        out=createSBMLModel(action,varargin{1});
    case 'getModelsInWorkspace'
        out=getModelsInWorkspace(action);
    case 'getModelsInWorkspaceInfo'
        out=getModelsInWorkspaceInfo(action,varargin{1});
    case 'createModel'
        out=createModel(action,varargin{1});
    case 'createPKLibraryModel'
        out=createPKLibraryModel(action,varargin{1});
    case 'getModelNamesInProject'
        out=getModelNamesInProject(action,varargin{1});
    case 'getModelObjectsInProject'
        out=getModelObjectsInProject(action,varargin{1});
    case 'duplicateModel'
        out=duplicateModel(varargin{:});
    case 'renameModel'
        renameModel(varargin{1});
    case 'getComponentInfo'
        out=getComponentInfo(varargin{1});
    case 'getModelSessionID'
        out=getModelSessionID(varargin{1});
    case 'initDiagramEditor'
        out=initDiagramEditor(varargin{1});
    case 'getStatesToLog'
        out=getStatesToLog(action,varargin{1});
    case 'saveModelToSBML'
        out=saveModelToSBML(action,varargin{1});
    case 'exportModelToWorkspace'
        out=exportModelToWorkspace(action,varargin{1});
    case 'getRepeatAssignmentLHS'
        out=getRepeatAssignmentLHS(varargin{:});
    case 'getInitialAssignmentLHS'
        out=getInitialAssignmentLHS(varargin{:});
    case 'getEventLHS'
        out=getEventLHS(varargin{:});
    case 'getVariantInfo'
        out=getVariantInfo(varargin{:});
    case 'configureObjectProperty'
        out=configureObjectProperty(varargin{:});
    case 'configureDoseSchedule'
        configureDoseSchedule(varargin{:});
    case 'configureModelProperty'
        out=configureModelProperty(varargin{:});
    case 'configureContentProperty'
        configureContentProperty(varargin{:});
    case 'isValidUnit'
        out=isValidUnit(varargin{:});
    case 'createObject'
        out=createObject(varargin{:});
    case 'createObjectInternal'
        out=createObjectInternal(varargin{:});
    case 'createObjects'
        createObjects(varargin);
    case 'deleteObject'
        out=deleteObject(varargin{:});
    case 'deleteAllObjects'
        deleteAllObjects(varargin{:});
    case 'deleteUnusedQuantities'
        deleteUnusedQuantities(varargin{:});
    case 'verifyModel'
        verifyModel(varargin{:})
    case 'removeModel'
        removeModel(varargin{:});
    case 'turnOnEvents'
        turnOnEvents(varargin{:});
    case 'turnOffEvents'
        turnOffEvents(varargin{:});
    case 'forceEvents'
        forceEvents(varargin{:});
    case 'cleanupOnProjectClose'
        cleanupOnProjectClose(varargin{:});
    case 'resolveTokens'
        [sessionIDs,unresolved]=resolvetokens(varargin{:});
        out=struct('action',action,'sessionIDs',sessionIDs,'unresolved',unresolved);
    case 'resolveObservables'
        out=resolveObservables(varargin{:});
    case 'configureKineticLaw'
        configureKineticLaw(varargin{:});
    case 'getModelEquations'
        out=getModelEquations(action,varargin{:});
    case 'exportModelToHTML'
        out=exportModelToHTML(varargin{:});
    case 'exportDiagram'
        out=exportDiagram(varargin{:});
    case 'getScreenSizeInInches'
        out=getScreenSizeInInches(varargin{:});
    case 'exportExpressionsToHTML'
        out=exportExpressionsToHTML(varargin{:});
    case 'configureRuleUsingQuantity'
        configureRuleUsingQuantity(varargin{:})
    case 'addQuantityToEvent'
        addQuantityToEvent(varargin{:});
    case 'replaceEventLHS'
        replaceEventLHS(varargin{:});
    case 'replaceQuantityInReaction'
        replaceQuantityInReaction(varargin{:});
    case 'addReactantOrProductToReaction'
        addReactantOrProductToReaction(varargin{:});
    case 'removeQuantityFromReaction'
        removeQuantityFromReaction(varargin{:});
    case 'removeQuantityFromRule'
        removeQuantityFromRule(varargin{:});
    case 'addSpeciesToCompartment'
        out=addSpeciesToCompartment(varargin{:});
    case 'getModelFromSessionID'
        out=getModelFromSessionID(varargin{:});
    case 'getUndoState'
        out=getUndoState(varargin{:});
    case 'refreshReaction'
        refreshReaction(varargin{:});
    case 'commitVariant'
        commitVariant(varargin{:});
    case 'saveCode'
        saveCode(varargin{:});
    end

end

function commitVariant(input)

    model=getModelFromSessionID(input.modelSessionID);

    for i=1:numel(input.sessionIDs)
        try
            v=sbioselect(model,'Type','variant','SessionID',input.sessionIDs(i));
            commit(v,model);
        catch
        end
    end

end

function refreshReaction(input)

    model=getModelFromSessionID(input.modelSessionID);
    objs={};
    status={};

    for i=1:numel(input.sessionID)
        objs{end+1}=sbioselect(model,'Type','reaction','SessionID',input.sessionID(i));%#ok<AGROW>
        status{end+1}={};%#ok<AGROW>
    end

    SimBiology.web.eventhandler('expressionStatus',objs,status,false,'');

end

function out=exportModelToWorkspace(action,input)

    model=getModelFromSessionID(input.sessionID);
    expr=['exist(','''',input.varName,'''',')'];
    varAlreadyExist=evalin('base',expr);
    msg='';

    if(~varAlreadyExist||input.overwrite)


        warningID='MATLAB:namelengthmaxexceeded';
        originalWarning=warning('query',warningID);
        warning('off',warningID);


        assignin('base',input.varName,model)


        warning(originalWarning.state,warningID);

    else
        msg=sprintf('Variable ''%s'' exists in the MATLAB workspace.',input.varName);
    end

    info.message=msg;

    out={action,info};

end

function out=saveModelToSBML(action,input)

    model=getModelFromSessionID(input.sessionID);

    sbmlexport(model,input.filename);

    out={action};

end

function out=duplicateModel(input)


    tempDesktopDir=SimBiology.web.internal.desktopTempdir;
    modelFilename=fullfile(tempDesktopDir,'model.mat');




    model=getModelFromSessionID(input.sessionID);
    save(modelFilename,'model');
    fileCleanup1=onCleanup(@()deleteFile(modelFilename));
    newModel=load(modelFilename);
    newModel=newModel.model;


    name=newModel.Name;
    allNames=input.names;
    name=findUniqueName(allNames,name);
    set(newModel,'Name',name);


    results.type='modelAdded';
    results.error=false;
    results.name=newModel.Name;
    results.id=getModelID(newModel);
    results.mInfo=getModelInfoFromModel(newModel);


    if model.hasDiagramSyntax
        diagramJSON=model.getDiagramSyntax.saveToJSON();
        filename='diagram.json';
        tempDiagramFileName=fullfile(tempDesktopDir,filename);
        fileCleanup2=onCleanup(@()deleteFile(tempDiagramFileName));


        fid=fopen(tempDiagramFileName,'w');
        fprintf(fid,'%s',diagramJSON);
        fclose(fid);

        args=struct('model',newModel,'viewFile',tempDiagramFileName,'projectVersion','');
        SimBiology.web.diagramhandler('initDiagramSyntax',args);
    else
        args=struct('model',newModel,'viewFile','','projectVersion','');
        SimBiology.web.diagramhandler('initDiagramSyntax',args);
    end


    turnOnEvents(newModel);


    postToOtherAppForModelAdd(input,results);

    out=results;

end

function out=createSBMLModel(action,input)

    lastwarn('');

    try
        m=sbmlimport(input.filename);


        name=m.Name;
        allNames=input.names;
        name=findUniqueName(allNames,name);
        set(m,'Name',name);


        results.type='modelAdded';
        results.error=false;
        results.name=m.Name;
        results.id=getModelID(m);
        results.mInfo=getModelInfoFromModel(m);
        results.filename=input.filename;
        results.warningMessage=lastwarn;




        if doesDiagramSyntaxNeedToBeInitialized(input)
            args=struct('model',m,'viewFile','','projectVersion','');
            SimBiology.web.diagramhandler('initDiagramSyntax',args);
        end


        turnOnEvents(m);


        postToOtherAppForModelAdd(input,results);
    catch ex
        if strcmp(ex.identifier,'SimBiology:sbmlimport:FileNotFound')
            results.filename=input.filename;
            results.error=true;
            results.name='';
        else
            results.name='';
            results.id='';
            results.errorMessage=SimBiology.web.internal.errortranslator(ex);
        end
    end

    out={action,results};

end

function out=getModelsInWorkspace(action)

    s=sbioroot;
    models=s.Models;


    if isempty(models)
        results.names={};
        results.varnames={};
        results.ids={};
        out={action,results};
        return;
    end


    names=get(models,{'Name'})';
    ids=get(models,{'SessionID'})';


    varnames=cell(1,length(names));
    allvars=evalin('base','whos');
    classnames={allvars.class};
    index=find(strcmp(classnames,'SimBiology.Model'));



    for i=1:length(index)
        nextVarName=allvars(index(i)).name;
        nextObj=evalin('base',nextVarName);


        [tfMember,loc]=ismember(nextObj,models);
        loc=unique(loc(tfMember),'stable');


        for j=1:length(loc)
            varnames{loc(j)}(end+1)={nextVarName};
        end
    end

    results.names=names;
    results.varnames=varnames;
    results.ids=ids;

    out={action,results};

end

function out=getModelsInWorkspaceInfo(action,inputs)

    sessionIDs=inputs.sessionIDs;
    allNames=inputs.names;
    modelNames=cell(numel(sessionIDs),1);
    modelIDs=cell(numel(sessionIDs),1);
    modelInfo=cell(numel(sessionIDs),1);
    initDiagramSyntax=doesDiagramSyntaxNeedToBeInitialized(inputs);

    for i=1:length(sessionIDs)
        m=getModelFromSessionID(sessionIDs(i));
        name=findUniqueName(allNames,m.Name);
        set(m,'Name',name);
        allNames{i}=name;

        modelNames{i}=m.Name;
        modelIDs{i}=get(m,'SessionID');
        modelInfo{i}=getModelInfoFromModel(m);




        if initDiagramSyntax
            args=struct('model',m,'viewFile','','projectVersion','');
            SimBiology.web.diagramhandler('initDiagramSyntax',args);
        end


        turnOnEvents(m);
    end


    results.type='modelAdded';
    results.names=modelNames;
    results.ID=modelIDs;
    results.mInfo=modelInfo;
    out={action,results};

    postToOtherAppForModelAdd(inputs,results);

end

function out=createModel(action,input)

    name=input.name;
    allNames=input.names;


    name=findUniqueName(allNames,name);

    m=sbiomodel(name);
    addcompartment(m,'unnamed');

    results.type='modelAdded';
    results.name=m.Name;
    results.id=getModelID(m);
    results.mInfo=getModelInfoFromModel(m);



    if doesDiagramSyntaxNeedToBeInitialized(input)
        args=struct('model',m,'viewFile','','projectVersion','');
        SimBiology.web.diagramhandler('initDiagramSyntax',args);
    end


    turnOnEvents(m);


    postToOtherAppForModelAdd(input,results);

    out={action,results};

end

function out=createPKLibraryModel(action,input)

    pkm=PKModelDesign;
    notes=sprintf('Model constructed with PKModelDesign with compartments:\n');
    name=input.name;
    allNames=input.names;


    name=findUniqueName(allNames,name);

    compartments=input.compartments;
    for i=1:length(compartments)
        modelInfo=compartments(i);

        pkm.addCompartment(modelInfo.name,...
        'DosingType',modelInfo.dosing,...
        'EliminationType',modelInfo.elimination,...
        'HasResponseVariable',modelInfo.hasResponse,...
        'HasLag',modelInfo.hasLag);

        notes=[notes,sprintf('    %s: Administration = ''%s'', Elimination = ''%s'', HasResponse = %d, HasLag = %d\n',...
        modelInfo.name,modelInfo.dosing,modelInfo.elimination,double(modelInfo.hasResponse),double(modelInfo.hasLag))];%#ok<AGROW>
    end


    warnState=warning('query','MATLAB:structOnObject');
    warning('off','MATLAB:structOnObject');

    [m,pkinfo]=pkm.construct;
    pkinfo=struct(pkinfo);
    set(m,'Notes',notes);
    set(m,'Name',name);


    warning(warnState.state,'MATLAB:structOnObject')

    results.type='modelAdded';
    results.name=m.Name;
    results.id=getModelID(m);
    results.pkInfo=pkinfo;
    results.mInfo=getModelInfoFromModel(m);



    if doesDiagramSyntaxNeedToBeInitialized(input)
        args=struct('model',m,'viewFile','','projectVersion','','isPK',true);
        SimBiology.web.diagramhandler('initDiagramSyntax',args);
    end


    turnOnEvents(m);


    postToOtherAppForModelAdd(input,results);

    out={action,results};

end

function out=getModelNamesInProject(action,inputs)


    if~exist(inputs.projectName,'file')
        results.error=true;
        results.filename=inputs.projectName;

        out={action,results};
        return;
    end


    varinfo=sbioloadproject(inputs.projectName);
    modelNames={};
    allnames=fieldnames(varinfo);

    for i=1:length(allnames)
        modelObj=varinfo.(allnames{i});
        if isa(modelObj,'SimBiology.Model')
            modelNames{end+1}=get(modelObj,'Name');%#ok<AGROW>
            delete(modelObj);
        end
    end


    results.error=false;
    results.names=modelNames;
    out={action,results};

end

function out=getModelObjectsInProject(action,inputs)



    allNames=inputs.allNames;


    modelsToLoad=inputs.names;
    initDiagramSyntax=doesDiagramSyntaxNeedToBeInitialized(inputs);
    models=SimBiology.web.projecthandler('getModelFromProject',inputs.projectName,modelsToLoad,initDiagramSyntax);


    modelNames=cell(1,numel(models));
    modelIDs=cell(1,numel(models));
    modelInfo=cell(1,numel(models));

    for i=1:length(models)
        modelObj=models(i);
        modelName=get(modelObj,'Name');


        name=findUniqueName(allNames,modelName);
        set(modelObj,'Name',name);
        allNames{end+1}=name;%#ok<AGROW>

        modelNames{i}=modelObj.Name;
        modelIDs{i}=get(modelObj,'SessionID');
        modelInfo{i}=getModelInfoFromModel(modelObj);


        turnOnEvents(modelObj);
    end


    results.type='modelAdded';
    results.names=modelNames;
    results.ID=modelIDs;
    results.mInfo=modelInfo;
    results.projectName=inputs.projectName;
    out={action,results};


    postToOtherAppForModelAdd(inputs,results);

end

function postToOtherAppForModelAdd(inputs,results)


    if strcmp(inputs.appType,'ModelingApp')
        SimBiology.web.desktophandler('postEventToModelAnalyzer',results);
    else
        SimBiology.web.desktophandler('postEventToModelBuilder',results);
    end

end

function out=doesDiagramSyntaxNeedToBeInitialized(input)

    out=SimBiology.web.diagram.inithandler('doesDiagramSyntaxNeedToBeInitialized',input);

end

function out=initDiagramEditor(inputs)

    m=getModelFromSessionID(inputs.modelSessionID);
    args=struct('model',m);

    out=SimBiology.web.diagramhandler('initDiagramEditor',args);

end

function renameModel(input)


    modelObj=getModelFromSessionID(input.sessionID);
    transaction=SimBiology.Transaction.create(modelObj);
    set(modelObj,'Name',input.name);
    transaction.commit;

    SimBiology.web.codecapturehandler('postModelPropertyChangedEvent',modelObj,'Name',input.name,false);

end

function out=getModelInfoFromModel(model)

    input.sessionID=model.SessionID;
    input.usedComponents=[];

    out=getModelInfo('',input);
    out=out{2};

end

function out=getModelInfo(action,input)

    m=getModelFromSessionID(input.sessionID);

    s=getModelSpecies(m);
    p=getModelParameters(m);
    c=m.Compartment;


    templateStruct=struct('SessionID','','UUID','','name','','scope','',...
    'ScopeSessionID','','ScopeUUID','','pqn','','type','','value',0,...
    'boundarycondition',false,'units','','constant',true,'notes','',...
    'use',true,'usedInModel',true,'validunits',true,'hasDuplicateName',false);

    info=repmat(templateStruct,length(s)+length(p)+length(c),1);
    count=1;
    for i=1:length(c)
        compartmentInfo=getCompartmentInfo(c(i));
        if~isempty(input.usedComponents)
            compartmentInfo.use=ismember(c(i).PartiallyQualifiedNameReally,input.usedComponents);
        end

        info(count)=compartmentInfo;
        count=count+1;
    end

    for i=1:length(s)
        speciesInfo=getSpeciesInfo(s(i));
        if~isempty(input.usedComponents)
            speciesInfo.use=ismember(s(i).PartiallyQualifiedNameReally,input.usedComponents);
        end

        info(count)=speciesInfo;
        count=count+1;
    end

    for i=1:length(p)
        parameterInfo=getParameterInfo(p(i));
        if~isempty(input.usedComponents)
            parameterInfo.use=ismember(p(i).PartiallyQualifiedNameReally,input.usedComponents);
        end

        info(count)=parameterInfo;
        count=count+1;
    end


    v=getvariant(m);
    d=getdose(m);


    templateStruct=struct('SessionID','','UUID','','name','','active','','type','','notes','','use',true,'properties',[],'hasDuplicateName',false);
    minfo=repmat(templateStruct,length(v)+length(d),1);
    count=1;

    for i=1:length(v)
        variantInfo=getVariantInfo(v(i));
        if~isempty(input.usedComponents)
            variantInfo.use=ismember(v(i).Name,input.usedComponents);
        end

        minfo(count)=variantInfo;
        count=count+1;
    end

    for i=1:length(d)
        doseInfo=getDoseInfo(d(i));
        if~isempty(input.usedComponents)
            doseInfo.use=ismember(d(i).Name,input.usedComponents);
        end

        minfo(count)=doseInfo;
        count=count+1;
    end


    cs=getconfigset(m,'default');
    cinfo.StopTime=cs.StopTime;
    cinfo.TimeUnits=cs.TimeUnits;
    cinfo.SolverType=cs.SolverType;
    cinfo.LogDecimation=1;
    cinfo.StatesToLog=get(cs.RuntimeOptions.StatesToLog,{'SessionID'});
    cinfo.StatesToLogAll=~get(cs.RuntimeOptions,'StatesToLogSet');
    cinfo.DimensionalAnalysis=cs.CompileOptions.DimensionalAnalysis;
    cinfo.UnitConversion=cs.CompileOptions.UnitConversion;
    cinfo.OutputTimes=[];

    cinfo.MaximumNumberOfLogs=num2str(cs.MaximumNumberOfLogs);
    cinfo.MaximumWallClock=num2str(cs.MaximumWallClock);

    if any(strcmp(cinfo.SolverType,{'ssa','expltau','impltau'}))
        cinfo.LogDecimation=cs.SolverOptions.LogDecimation;
    else
        cinfo.OutputTimes=cs.SolverOptions.OutputTimes;
    end


    r=sbioselect(m,'Type','reaction');
    templateStruct=struct('SessionID','','UUID','','type','','name','','reaction','',...
    'reactionrate','','kineticlaw','','active',0,'reversible','','notes','',...
    'use',true,'sessionIDs',[],'unresolved',{},'reactionSessionIDs',[],'hasDuplicateName',false);

    rinfo=repmat(templateStruct,length(r),1);
    for i=1:length(r)
        rinfo(i)=getReactionInfo(r(i));
    end


    r=sbioselect(m,'Type','rule');
    templateStruct=struct('SessionID','','type','','name','','rule','','ruletype','',...
    'active',0,'notes','','use',true,'sessionIDs',[],'hasDuplicateName',false,'unresolved',{},'lhsSessionID',[]);

    ruleInfo=repmat(templateStruct,length(r),1);
    for i=1:length(r)
        ruleInfo(i)=getRuleInfo(r(i));
    end


    evt=sbioselect(m,'Type','event');
    templateStruct=struct('SessionID','','type','','name','','trigger','','eventfcns','',...
    'active',0,'notes','','use',true,'sessionIDs',[],'hasDuplicateName',false,'unresolved',{},'lhsSessionID',[]);

    eInfo=repmat(templateStruct,length(evt),1);
    for i=1:length(evt)
        eInfo(i)=getEventInfo(evt(i));
    end


    obsInfo=resolveObservables(m);

    x.quantity=info;
    x.modifiers=minfo;
    x.reactions=rinfo;
    x.rules=ruleInfo;
    x.events=eInfo;
    x.observables=obsInfo;
    x.csProperties=cinfo;
    x.lhsIDs=getRepeatAssignmentLHS(m);
    x.initialLhsIDs=getInitialAssignmentLHS(m);
    x.eventLhsIDs=getEventLHS(m);
    x.notes=get(m,'Notes');
    x.hasDuplicateName=m.HasDuplicateName;

    out={action,x};

end

function obsInfo=resolveObservables(m)
    obs=m.Observables;
    templateStruct=struct('SessionID','','UUID','','name','','type','','expression','',...
    'active',0,'units','','validunits','','hasDuplicateName',false,'notes','','sessionIDs',[],'unresolved',{});

    obsInfo=repmat(templateStruct,length(obs),1);
    for i=1:length(obs)
        obsInfo(i)=getObservableInfo(obs(i));
    end

end

function info=getComponentInfo(c)

    if isa(c,'SimBiology.Species')
        info=getSpeciesInfo(c);
    elseif isa(c,'SimBiology.Parameter')
        info=getParameterInfo(c);
    elseif isa(c,'SimBiology.Compartment')
        info=getCompartmentInfo(c);
    elseif isa(c,'SimBiology.Variant')
        info=getVariantInfo(c);
    elseif isa(c,'SimBiology.RepeatDose')||isa(c,'SimBiology.ScheduleDose')
        info=getDoseInfo(c);
    elseif isa(c,'SimBiology.Reaction')
        info=getReactionInfo(c);
    elseif isa(c,'SimBiology.Rule')
        info=getRuleInfo(c);
    elseif isa(c,'SimBiology.Event')
        info=getEventInfo(c);
    elseif isa(c,'SimBiology.Observable')
        info=getObservableInfo(c);
    else
        info=[];
    end

end

function info=getSpeciesInfo(s)

    name=s.Name;
    info.SessionID=s.SessionID;
    info.UUID=s.UUID;
    info.name=name;
    info.scope=s.Scope;
    info.value=s.Value;
    info.units=s.Units;
    info.constant=s.Constant;
    info.boundarycondition=s.BoundaryCondition;
    info.type=s.Type;
    info.pqn=s.PartiallyQualifiedNameReally;
    info.notes=s.Notes;
    info.use=true;
    info.usedInModel=(s.InUseCount>=1);
    info.ScopeSessionID=s.Parent.SessionID;
    info.ScopeUUID=s.Parent.UUID;
    info.validunits=s.isValidUnits(s.Units);
    info.hasDuplicateName=s.HasDuplicateName;

end

function info=getCompartmentInfo(c)

    name=c.Name;
    pqn=c.PartiallyQualifiedNameReally;
    info.SessionID=c.SessionID;
    info.UUID=c.UUID;
    info.name=name;
    info.pqn=pqn;
    info.value=c.Value;
    info.units=c.Units;
    info.constant=c.Constant;
    info.boundarycondition=false;
    info.type=c.Type;
    info.scope=c.Scope;
    info.notes=c.Notes;
    info.use=true;
    info.usedInModel=true;
    if~isempty(c.Owner)
        info.ScopeSessionID=c.Owner.SessionID;
        info.ScopeUUID=c.Owner.UUID;
    else
        info.ScopeSessionID=-1;
        info.ScopeUUID=-1;
    end

    info.validunits=c.isValidUnits(c.Units);
    info.hasDuplicateName=c.HasDuplicateName;

end

function info=getParameterInfo(p)

    name=p.Name;
    pqn=p.PartiallyQualifiedNameReally;
    info.SessionID=p.SessionID;
    info.UUID=p.UUID;
    info.name=name;
    info.pqn=pqn;
    info.value=p.Value;
    info.units=p.Units;
    info.constant=p.Constant;
    info.boundarycondition=false;
    info.type=p.Type;
    info.scope=p.Scope;
    info.notes=p.Notes;
    info.use=true;
    info.usedInModel=(p.InUseCount>=1);
    info.validunits=p.isValidUnits(p.Units);
    info.hasDuplicateName=p.HasDuplicateName;


    if isnan(info.value)
        info.value='NaN';
    elseif isinf(info.value)
        info.value=num2str(info.value);
    end

    parent=p.Parent;
    if isa(parent,'SimBiology.Model')
        info.ScopeSessionID=parent.SessionID;
        info.ScopeUUID=parent.UUID;
    elseif isa(parent,'SimBiology.KineticLaw')
        info.ScopeSessionID=parent.Parent.SessionID;
        info.ScopeUUID=parent.Parent.UUID;
    end

end

function params=getModelParameters(model)



    if isa(model,'SimBiology.KineticLaw')
        model=model.Parent.Parent;
    end

    params=model.Parameters;
    reactions=model.Reactions;
    for i=1:length(reactions)
        if~isempty(reactions(i).KineticLaw)
            params=vertcat(params,reactions(i).KineticLaw.Parameters);%#ok<AGROW>
        end
    end

end

function species=getModelSpecies(model)

    comps=model.Compartments;
    if isempty(comps)
        species=[];
        return;
    end

    species=comps(1).Species;
    for i=2:numel(comps)
        species=vertcat(species,comps(i).Species);%#ok<AGROW>
    end

end

function info=getReactionInfo(r)

    info.SessionID=r.SessionID;
    info.UUID=r.UUID;
    info.type=r.Type;
    info.name=r.Name;
    info.reaction=r.Reaction;
    info.reactionrate=r.ReactionRate;
    info.kineticlaw='';
    info.active=r.Active;
    info.reversible=r.Reversible;
    info.notes=r.Notes;
    info.use=true;
    info.sessionIDs=[];
    info.reactionSessionIDs=[];
    info.hasDuplicateName=r.HasDuplicateName;


    klaw=r.KineticLaw;
    if~isempty(klaw)
        paramTokens=klaw.ParameterVariables;
        speciesTokens=klaw.SpeciesVariables;
        params=klaw.ParameterVariableNames;
        species=klaw.SpeciesVariableNames;

        kinfo.type=get(klaw,'KineticLawName');
        kinfo.parameters=[];
        for i=1:length(params)
            kinfo.parameters(i).name=paramTokens{i};
            kinfo.parameters(i).value=params{i};
        end

        kinfo.species=[];
        for i=1:length(species)
            if i>length(speciesTokens)
                kinfo.species(i).name=speciesTokens{1};
            else
                kinfo.species(i).name=speciesTokens{i};
            end

            kinfo.species(i).value=species{i};
        end
    else
        kinfo.type='None';
        kinfo.parameters=[];
        kinfo.species=[];
    end

    info.kineticlaw=kinfo;


    sessionIDs=[];
    unresolved={};
    sessionIDs=getSessionIDs(r.Reactants,sessionIDs);
    sessionIDs=getSessionIDs(r.Products,sessionIDs);
    reactionSessionIDs=sessionIDs;
    [sessionIDs,unresolved]=resolvetokens(r,parserate(r),sessionIDs,unresolved);



    if isempty(r.ReactionRate)&&~isempty(klaw)
        sessionIDs=getSessionIDs(getparameters(klaw),sessionIDs);
        sessionIDs=getSessionIDs(getspecies(klaw),sessionIDs);
    end

    if~isempty(klaw)
        sessionIDs=getSessionIDs(klaw.Parameters,sessionIDs);
    end

    info.sessionIDs=unique(sessionIDs);
    info.unresolved=unique(unresolved);
    info.reactionSessionIDs=reactionSessionIDs;

end

function info=getRuleInfo(r)

    info.SessionID=r.SessionID;
    info.type=r.Type;
    info.name=r.Name;
    info.rule=r.Rule;
    info.ruletype=r.RuleType;
    info.active=r.Active;
    info.notes=r.Notes;
    info.use=true;
    info.sessionIDs=[];
    info.hasDuplicateName=r.HasDuplicateName;


    sessionIDs=[];
    unresolved={};
    [lhs,rhs]=parserule(r);
    [sessionIDs,unresolved]=resolvetokens(r,lhs,sessionIDs,unresolved);
    lhsSessionID=sessionIDs;
    [sessionIDs,unresolved]=resolvetokens(r,rhs,sessionIDs,unresolved);
    info.sessionIDs=unique(sessionIDs);
    info.unresolved=unique(unresolved);

    if isempty(lhsSessionID)
        lhsSessionID=-1;
    end
    info.lhsSessionID=lhsSessionID;

end

function info=getEventInfo(evt)

    info.SessionID=evt.SessionID;
    info.type=evt.Type;
    info.name=evt.Name;
    info.trigger=evt.Trigger;
    info.eventfcns=evt.EventFcns;
    info.active=evt.Active;
    info.notes=evt.Notes;
    info.use=true;
    info.sessionIDs=[];
    info.hasDuplicateName=evt.HasDuplicateName;


    sessionIDs=[];
    unresolved={};
    lhsSessionID=-1*ones(1,length(info.eventfcns));
    tokens=parsetrigger(evt);
    [lhs,rhs]=parseeventfcns(evt);
    [sessionIDs,unresolved]=resolvetokens(evt,tokens,sessionIDs,unresolved);

    for i=1:length(lhs)
        lhsToken=lhs{i};
        if~isempty(lhsToken)
            lhsToken=lhsToken{1};
        else
            lhsToken='';
        end

        obj=resolveobject(evt,lhsToken);
        if~isempty(obj)
            sessionIDs=horzcat(sessionIDs,obj.SessionID);%#ok<AGROW>
            lhsSessionID(i)=obj.SessionID;
        else
            unresolved{end+1}=lhsToken;%#ok<AGROW>
            lhsSessionID(i)=-1;
        end

        [sessionIDs,unresolved]=resolvetokens(evt,rhs{i},sessionIDs,unresolved);
    end

    info.sessionIDs=unique(sessionIDs);
    info.unresolved=unique(unresolved);
    info.lhsSessionID=lhsSessionID;

end

function info=getObservableInfo(obs)

    info.SessionID=obs.SessionID;
    info.UUID=obs.UUID;
    info.type=obs.Type;
    info.name=obs.Name;
    info.expression=obs.Expression;
    info.active=obs.Active;
    info.units=obs.Units;
    info.validunits=obs.isValidUnits(obs.Units);
    info.notes=obs.Notes;
    info.hasDuplicateName=obs.HasDuplicateName;


    sessionIDs=[];
    unresolved={};
    tokens=parseexpression(obs);
    [sessionIDs,unresolved]=resolvetokens(obs,tokens,sessionIDs,unresolved);
    info.sessionIDs=unique(sessionIDs);
    info.unresolved=unique(unresolved);


end

function lhsIDs=getInitialAssignmentLHS(model,varargin)

    lhsIDs=getAssignmentLHS(model,'initialAssignment',varargin{:});



end

function lhsIDs=getRepeatAssignmentLHS(model,varargin)

    lhsIDs=getAssignmentLHS(model,'repeatedAssignment',varargin{:});


end

function lhsIDs=getAssignmentLHS(model,type,varargin)

    r=sbioselect(model,'Type','rule','RuleType',type);
    ruleToExclude=[];
    lhsIDs={};

    if(nargin==3)
        ruleToExclude=varargin{1};
    end

    for i=1:length(r)
        if~isequal(r(i),ruleToExclude)
            lhs=parserule(r(i));

            if~isempty(lhs)
                obj=resolveobject(r(i),lhs{1});
                if~isempty(obj)
                    lhsIDs{end+1}=obj.SessionID;%#ok<AGROW>
                end
            end
        end
    end

    lhsIDs=unique([lhsIDs{:}]);


end

function lhsIDs=getEventLHS(model,varargin)

    events=model.Events;
    eventsToExclude=[];
    lhsIDs={};

    if(nargin==2)
        eventsToExclude=varargin{1};
    end

    for i=1:length(events)
        if~isequal(events(i),eventsToExclude)
            lhs=parseeventfcns(events(i));
            for j=1:length(lhs)
                if~isempty(lhs{j})
                    obj=resolveobject(events(i),lhs{j}{1});
                    if~isempty(obj)
                        lhsIDs{end+1}=obj.SessionID;%#ok<AGROW>
                    end
                end
            end
        end
    end

    lhsIDs=unique([lhsIDs{:}]);

end

function info=getVariantInfo(v)

    info.SessionID=v.SessionID;
    info.UUID=v.UUID;
    info.name=v.Name;
    info.active=v.Active;
    info.type=v.Type;
    info.notes=v.Notes;
    info.use=true;
    info.properties=[];
    info.hasDuplicateName=v.HasDuplicateName;



    content=v.Content;
    contentObjs=privateresolve(v,v.Parent);


    contentInfo=struct('SessionID',-1,'value',0,'name','','type','');
    contentInfo=repmat(contentInfo,1,length(content));

    for i=1:length(contentObjs)
        obj=contentObjs(i);

        if isvalid(obj)
            contentProperty=content{i}{3};
            valueProperty=SimBiology.web.codegenerationutil('getValuePropertyForState',obj);




            if strcmpi(contentProperty,valueProperty)||strcmpi(contentProperty,'value')
                value=content{i}{4};
            else
                value=get(obj,valueProperty);
            end

            contentInfo(i).SessionID=obj.SessionID;
            contentInfo(i).value=value;
            contentInfo(i).type=obj.Type;
            contentInfo(i).name=content{i}{2};
        else
            contentInfo(i).SessionID=-1;
            contentInfo(i).value=content{i}{4};
            contentInfo(i).type=content{i}{1};
            contentInfo(i).name=content{i}{2};
        end
    end

    if~isempty(content)
        info.properties.Content=contentInfo;
    else
        info.properties.Content=[];
    end

end

function info=getDoseInfo(d)

    info.SessionID=d.SessionID;
    info.UUID=d.UUID;
    info.active=d.Active;
    info.name=d.Name;
    info.type=d.Type;
    info.notes=d.Notes;
    info.use=true;
    info.properties=[];
    info.hasDuplicateName=d.HasDuplicateName;


    info.properties.TargetName=getTargetInfo(d);

    if strcmp(info.type,'repeatdose')
        info.properties.Amount=d.Amount;
        info.properties.AmountUnits=d.AmountUnits;
        info.properties.Interval=d.Interval;
        info.properties.Rate=d.Rate;
        info.properties.RateUnits=d.RateUnits;
        info.properties.RepeatCount=d.RepeatCount;
        info.properties.StartTime=d.StartTime;
        info.properties.TimeUnits=d.TimeUnits;
        info.properties.DurationParameterName=d.DurationParameterName;
        info.properties.LagParameterName=d.LagParameterName;
        info.properties.EventMode=d.EventMode;
    else
        info.properties.Amount=d.Amount;
        info.properties.AmountUnits=d.AmountUnits;
        info.properties.Rate=d.Rate;
        info.properties.RateUnits=d.RateUnits;
        info.properties.Time=d.Time;
        info.properties.TimeUnits=d.TimeUnits;
        info.properties.DurationParameterName=d.DurationParameterName;
        info.properties.LagParameterName=d.LagParameterName;
        info.properties.EventMode=d.EventMode;
    end

    info.properties.ValidTimeUnits=true;
    info.properties.ValidAmountUnits=true;
    info.properties.ValidRateUnits=true;

    if~isempty(d.TimeUnits)
        info.properties.ValidTimeUnits=SimBiology.internal.isValidTimeUnit(d.TimeUnits);
    end

    if~isempty(d.AmountUnits)
        info.properties.ValidAmountUnits=SimBiology.internal.isValidAmountUnit(d.AmountUnits);
    end

    if~isempty(d.RateUnits)
        info.properties.ValidRateUnits=SimBiology.internal.isValidRateUnit(d.RateUnits);
    end

    target=resolvetarget(d,d.Parent);
    if~isempty(target)
        info.properties.TargetSessionID=target.SessionID;
    else
        info.properties.TargetSessionID=-1;
    end

    info.properties.LagParameterSessionID=getDoseParameterSessionID(d,d.Parent,info.properties.LagParameterName);
    info.properties.DurationParameterSessionID=getDoseParameterSessionID(d,d.Parent,info.properties.DurationParameterName);


    if strcmp(info.type,'repeatdose')
        info.properties.AmountSessionID=getDoseParameterSessionID(d,d.Parent,info.properties.Amount);
        info.properties.IntervalSessionID=getDoseParameterSessionID(d,d.Parent,info.properties.Interval);
        info.properties.RateSessionID=getDoseParameterSessionID(d,d.Parent,info.properties.Rate);
        info.properties.RepeatCountSessionID=getDoseParameterSessionID(d,d.Parent,info.properties.RepeatCount);
        info.properties.StartTimeSessionID=getDoseParameterSessionID(d,d.Parent,info.properties.StartTime);
    else
        info.properties.AmountSessionID=-1;
        info.properties.IntervalSessionID=-1;
        info.properties.RateSessionID=-1;
        info.properties.RepeatCountSessionID=-1;
        info.properties.StartTimeSessionID=-1;
    end

end

function out=getDoseParameterSessionID(dose,model,value)

    out=-1;
    if ischar(value)&&~isempty(value)
        param=resolveparameter(dose,model,value);
        if~isempty(param)
            out=param.SessionID;
        end
    end

end

function out=getTargetInfo(d)

    out=d.TargetName;
    model=d.Parent;

    if~isempty(model)
        target=d.resolvetarget(model);
        if~isempty(target)
            out=target.PartiallyQualifiedNameReally;
        end
    end

end

function id=getModelID(m)

    id=m.SessionID;

end

function id=getModelSessionID(comp)

    try
        id=comp.ParentModelSessionID;
    catch ex %#ok<NASGU>
        id=comp.Parent.SessionID;
    end

end

function out=getStatesToLog(action,input)

    model=getModelFromSessionID(input.modelID);
    cs=getconfigset(model,'default');
    states=cs.RuntimeOptions.StatesToLog;


    pqns=get(states,{'PartiallyQualifiedName'});
    sessionIDs=get(states,{'SessionID'});
    types=get(states,{'Type'});



    numCompartments=length(model.Compartments);
    if(numCompartments==1)
        for i=1:length(states)
            if strcmp(types{i},'species')
                comp=states(i).Parent.Name;
                name=states(i).Name;
                pqns{i}=[comp,'.',name];
            end
        end
    end


    if(numCompartments>1)
        compIndex=strcmp('compartment',types);
        if any(compIndex)
            names=get(states,{'Name'});
            names=names(compIndex);

            compIndex=find(compIndex);
            for i=1:length(compIndex)
                pqns{compIndex(i)}=names{i};
            end
        end
    end

    info.pqns=pqns;
    info.sessionIDs=sessionIDs;
    info.types=types;

    out={action,info};

end

function[sessionIDs,unresolved]=resolvetokens(parent,tokens,sessionIDs,unresolved)

    for i=1:length(tokens)
        obj=resolveobject(parent,tokens{i});
        if~isempty(obj)
            sessionIDs=horzcat(sessionIDs,obj.SessionID);%#ok<AGROW>
        else
            unresolved{end+1}=tokens{i};%#ok<AGROW>
        end
    end


    unresolved(strcmp(unresolved,'time'))=[];

end

function sessionIDs=getSessionIDs(objs,sessionIDs)

    for i=1:length(objs)
        sessionIDs=horzcat(sessionIDs,objs(i).SessionID);%#ok<AGROW>
    end

end

function out=configureModelProperty(input)


    modelSessionID=input.modelSessionID;
    property=input.property;
    value=input.value;
    modelObj=getModelFromSessionID(modelSessionID);
    errorOccurred=false;
    transaction=SimBiology.Transaction.create(modelObj);


    try
        set(modelObj,property,value);



        transaction.commit;
    catch
        errorOccurred=true;
    end

    out.error=errorOccurred;
    out.property=input.property;
    out.modelSessionID=input.modelSessionID;

    if strcmpi(property,'unitconversion')||strcmpi(property,'dimensionalanalysis')
        cs=getconfigset(modelObj,'default');
        out.value=get(cs.CompileOptions,'property');
    else
        out.value=get(modelObj,property);
    end

    SimBiology.web.codecapturehandler('postModelPropertyChangedEvent',modelObj,property,value,errorOccurred);

end

function configureContentProperty(input)

    modelSessionID=input.modelSessionID;
    modelObj=getModelFromSessionID(modelSessionID);
    values=input.content;
    vobj=sbioselect(modelObj,'SessionID',values(1).sessionID);
    transaction=SimBiology.Transaction.create(vobj);

    for i=1:length(values)
        v=sbioselect(modelObj,'SessionID',values(i).sessionID);
        set(v,'Content',values(i).content);
        SimBiology.web.codecapturehandler('postSinglePropertyChangedEvent',modelSessionID,v,'Content',v.Content);
    end

    transaction.commit;

end

function configureDoseSchedule(input)

    modelSessionID=input.modelSessionID;
    modelObj=getModelFromSessionID(modelSessionID);
    componentID=input.sessionID;
    component=sbioselect(modelObj,'SessionID',componentID);
    transaction=SimBiology.Transaction.create(component);

    set(component,'Time',input.time,'Amount',input.amount,'Rate',input.rate);

    transaction.commit;

end

function out=configureObjectProperty(input)


    modelSessionID=input.modelSessionID;
    modelObj=getModelFromSessionID(modelSessionID);
    componentID=input.sessionID;
    property=input.property;
    value=input.value;

    template=struct('sessionID',-1,'property',property,'value','',...
    'error',false,'message','','propInfo','','codeInfo','',...
    'commands','','warningMessage','');

    out=repmat(template,1,length(componentID));
    component=sbioselect(modelObj,'SessionID',componentID(1));

    if isa(component,'SimBiology.Variant')||isa(component,'SimBiology.Dose')
        transaction=SimBiology.Transaction.create(component);
    else
        transaction=SimBiology.Transaction.create(modelObj);
    end

    for i=1:length(componentID)
        component=sbioselect(modelObj,'SessionID',componentID(i));
        out(i)=configureSingleObjectProperty(modelObj,component,property,value,input);
    end

    transaction.commit;


    if strcmpi(property,'partiallyqualifiedname')
        input.value=out(1).value;
    end
    SimBiology.web.codecapturehandler('postPropertyChangedEvent',input,{out.error},{out.codeInfo},{out.commands});

end

function out=configureSingleObjectProperty(modelObj,component,property,value,input)

    originalProperty=property;
    errorOccurred=false;
    message='';
    propInfo=[];
    codeInfo=[];
    commands=[];


    switch lower(property)
    case 'value'
        if ischar(value)
            value=str2double(value);
        end
        property=getValuePropertyForState(component);
    case 'units'
        property=[getValuePropertyForState(component),'Units'];
        propInfo=SimBiology.web.unithandler('getUnitType',value);
    case{'amountunits','rateunits','timeunits'}
        propInfo=SimBiology.web.unithandler('getUnitType',value);
    case 'constant'
        property=getConstantPropertyForState(component);
        value=isequal(value,'true');
    case 'boundarycondition'
        value=isequal(value,'true');
    case 'active'
        if ischar(value)
            value=isequal(value,'true');
        end
    case 'reversible'
        value=isequal(value,'true');
    case 'ruletype'
        value=convertRuleType(value);
    case 'owner'
        if isempty(value)
            value=[];
        else
            value=sbioselect(modelObj,'Type','compartment','Name',value);
            if isempty(value)
                errorOccurred=true;
                message='Compartment with this name does not exist.';
            end
        end
    end


    if~errorOccurred

        oldWarningState=warning('off');
        warningStateCleanup=onCleanup(@()warning(oldWarningState));


        logfile=[SimBiology.web.internal.desktopTempname(),'.xml'];
        matlab.internal.diagnostic.log.open(logfile);
        fileCleanup=onCleanup(@()deleteFile(logfile));

        try
            switch lower(property)
            case 'name'
                codeInfo=struct('name',component.Name);
                if isQuantity(component)||isa(component,'SimBiology.Observable')
                    rename(component,value);
                else
                    set(component,property,value);
                end
            case 'partiallyqualifiedname'


                codeInfo=struct('name',component.Name);
                configureNameProperty(component,value);
            case 'kineticlaw'
                [codeInfo,commands]=configureKineticLaw(component,value);
            case 'kineticlawtoken'
                commands=configureKineticLawToken(component,value);
            case{'amountunits','rateunits','timeunits','units','initialamountunits','capacityunits','valueunits'}
                errorOccurred=configureUnitProperty(component,property,value);
            case 'nameexpression'
                [commands,codeInfo]=configureNameExpression(modelObj,component,value);
            case 'reversible'
                set(component,property,value);
                commands=updateAfterReactionConfig(component,input);
            case 'reaction'
                state=component.Reversible;
                set(component,property,value);
                if(component.Reversible~=state)
                    commands=updateAfterReactionConfig(component,input);
                end
            otherwise
                set(component,property,value);
            end
        catch ex
            errorOccurred=true;
            message=SimBiology.web.internal.errortranslator(ex);
        end
    end

    info.sessionID=component.SessionID;
    info.property=originalProperty;
    info.error=errorOccurred;
    info.message=message;
    info.propInfo=propInfo;
    info.codeInfo=codeInfo;
    info.commands=commands;

    if any(strcmpi(property,{'kineticlaw','kineticlawtoken'}))
        info.value=value;
    elseif strcmpi(property,'nameexpression')
        info.value=get(component,{'Name','Expression'});
    elseif strcmpi(property,'partiallyqualifiedname')
        info.value=get(component,'Name');
    elseif strcmpi(property,'owner')
        owner=get(component,property);
        if isempty(owner)
            info.value='';
        else
            info.value=owner.Name;
        end
    else
        info.value=get(component,property);
    end

    if isnumeric(info.value)
        info.value=num2str(info.value);
    end


    info.warningMessage=handleMessagesAfterConfigure(logfile);

    out=info;

end

function configureNameProperty(component,value)

    if isa(component,'SimBiology.Parameter')
        parent=component.Parent;
        if isa(parent,'SimBiology.Model')
            rename(component,value);
        else


            tokens=SimBiology.web.internal.splitName(value);

            parent=parent.Parent;
            if numel(tokens)==1
                parentName=parent.Name;
                value=tokens{1};
            elseif numel(tokens)==2
                parentName=tokens{1};
                value=tokens{2};
            else
                parentName='';
                value=tokens{1};
            end

            if strcmp(parentName,parent.Name)
                rename(component,value);
            else
                error('SimBiology:ConfigureNameProperty:InvalidName','The scope of the parameter cannot be changed.');
            end
        end
    elseif isa(component,'SimBiology.Species')

        tokens=SimBiology.web.internal.splitName(value);

        parent=component.Parent;
        if numel(tokens)==1
            parentName=parent.Name;
            value=tokens{1};
        elseif numel(tokens)==2
            parentName=tokens{1};
            value=tokens{2};
        else
            parentName='';
            value=tokens{1};
        end

        if strcmp(parentName,parent.Name)
            rename(component,value);
        else
            error('SimBiology:ConfigureNameProperty:InvalidName','The scope of the species cannot be changed.');
        end
    elseif isa(component,'SimBiology.Compartment')||isa(component,'SimBiology.Observable')
        rename(component,value);
    else
        set(component,'Name',value);
    end

end

function[commands,codeInfo]=configureNameExpression(modelObj,component,value)


    originalName=component.Name;
    originalExpr=component.Expression;


    [name,expression]=parseNameExpression(value);
    rename(component,name);
    set(component,'Expression',expression);
    addObservableTokensToStatesToLog(modelObj,component);


    commands={};
    codeInfo=struct('name',originalName);
    if~strcmp(originalName,component.Name)
        commands{end+1}=createCodeCaptureConfigureObjectCommand(component,'Name',name);
    end

    if~strcmp(originalExpr,component.Expression)
        commands{end+1}=createCodeCaptureConfigureObjectCommand(component,'Expression',expression);
    end

end

function msg=handleMessagesAfterConfigure(logfile)

    msg='';


    matlab.internal.diagnostic.log.close(logfile);


    warningLog=matlab.internal.diagnostic.log.load(logfile);


    for i=1:numel(warningLog)
        identifier=warningLog(i).identifier;

        if strcmp(identifier,'SimBiology:InvalidExpressionDuringRename')
            msg=SimBiology.web.internal.errortranslator(warningLog(i));
        end
    end

end

function commands=updateAfterReactionConfig(reaction,input)

    commands={};
    klaw=reaction.KineticLaw;

    if~isempty(klaw)
        klawName=klaw.KineticLawName;
        if strcmp(klawName,'MassAction')&&reaction.Reversible&&isempty(reaction.ReactionRate)&&input.prefs.createParameter
            pname='kr';

            if(input.prefs.scopeToReaction)
                names=get(get(klaw,'Parameters'),{'Name'});
                if~any(strcmp(names,pname))
                    p=addparameter(klaw,pname);
                    commands{end+1}=createCodeCaptureAddObjectCommand(p);
                end
            else
                model=reaction.Parent;
                p=sbioselect(model.Parameters,'Name',pname);
                if isempty(p)||~isempty(p.findUsages)
                    names=get(get(model,'Parameters'),{'Name'});
                    pname=SimBiology.web.codegenerationutil('findUniqueName',names,pname);
                    p=addparameter(model,pname);
                    commands{end+1}=createCodeCaptureAddObjectCommand(p);
                end
            end


            setparameter(klaw,'Reverse Rate Parameter',pname);
            commands{end+1}=createCodeCaptureConfigureObjectCommand(reaction,'ParameterVariableNames',klaw.ParameterVariableNames);
        end
    end

end

function errorOccurred=configureUnitProperty(component,property,value)

    oldWarningState=warning('off');
    warningStateCleanup=onCleanup(@()warning(oldWarningState));

    set(component,property,value);

    try
        if isa(component,'SimBiology.RepeatDose')||isa(component,'SimBiology.ScheduleDose')
            errorOccurred=false;
            if~isempty(value)
                switch lower(property)
                case 'amountunits'
                    errorOccurred=~SimBiology.internal.isValidAmountUnit(value);
                case 'timeunits'
                    errorOccurred=~SimBiology.internal.isValidTimeUnit(value);
                case 'rateunits'
                    errorOccurred=~SimBiology.internal.isValidRateUnit(value);
                end
            end
        else
            errorOccurred=~component.isValidUnits(value);
        end
    catch
        errorOccurred=false;
    end

end

function out=isValidUnit(input)

    if isempty(input.value)
        isvalid=true;
    else
        isvalid=false;
    end

    if~isempty(input.value)
        switch lower(input.property)
        case 'amountunits'
            isvalid=SimBiology.internal.isValidAmountUnit(input.value);
        case 'timeunits'
            isvalid=SimBiology.internal.isValidTimeUnit(input.value);
        case 'rateunits'
            isvalid=SimBiology.internal.isValidRateUnit(input.value);
        end
    end

    out.isvalid=isvalid;
    out.property=input.property;

end

function createObjects(inputs)

    if iscell(inputs)
        inputs=[inputs{:}];
    end

    modelSessionID=inputs(1).modelSessionID;
    modelObj=getModelFromSessionID(modelSessionID);
    transaction=SimBiology.Transaction.create(modelObj);

    for i=1:length(inputs)
        createObjectInternal(inputs(i));
    end

    transaction.commit;

end

function out=createObject(input)

    modelSessionID=input.modelSessionID;
    modelObj=getModelFromSessionID(modelSessionID);
    transaction=SimBiology.Transaction.create(modelObj);
    out=createObjectInternal(input);

    transaction.commit;

end

function out=createObjectInternal(input)

    out.message='';
    out.input=input;
    modelSessionID=input.modelSessionID;
    modelObj=getModelFromSessionID(modelSessionID);
    objAdded=[];
    commands={};
    errorOccurred=false;

    try
        switch(input.type)
        case 'rule'
            objAdded=addrule(modelObj,input.value,convertRuleType(input.ruleType));
        case 'reaction'
            objAdded=addreaction(modelObj,input.value);
            commands=configureReactionPreferences(modelObj,objAdded,input);
        case 'event'
            objAdded=addevent(modelObj,input.value,{});
        case 'parameter'
            scope=[];
            if isfield(input,'scope')
                if~strcmpi(input.scope,'model')
                    scope=sbioselect(modelObj,'Type','reaction','Name',input.scope);
                    if~isempty(scope)
                        scope=scope.KineticLaw;
                    end
                end
            end

            if isempty(scope)
                scope=modelObj;
            end

            objAdded=addparameter(scope,input.value);
        case 'reactionScopedParameter'
            r=sbioselect(modelObj,'Type','reaction','SessionID',input.sessionID);
            objAdded=addparameter(r.KineticLaw,input.value);
        case 'compartment'
            if ischar(input.scope)
                scope=sbioselect(modelObj,'Type','compartment','Name',input.scope);
            else
                scope=sbioselect(modelObj,'Type','compartment','SessionID',input.scope);
            end
            if isempty(scope)
                scope=modelObj;
            end
            objAdded=addcompartment(scope,input.value);
        case 'species'
            scope=input.scope;
            if ischar(scope)
                if startsWith(scope,'[')
                    scope=scope(2:length(scope)-1);
                end
                comp=sbioselect(modelObj,'Type','compartment','Name',scope);
            else
                comp=sbioselect(modelObj,'Type','compartment','SessionID',input.scope);
            end
            compName=[comp.Name,'.'];
            compNameBrackets=['[',comp.Name,'].'];
            speciesName=input.value;
            if startsWith(speciesName,compName)
                speciesName=speciesName(length(compName)+1:end);
            elseif startsWith(speciesName,compNameBrackets)
                speciesName=speciesName(length(compNameBrackets)+1:end);
            end
            objAdded=addspecies(comp,speciesName);
        case 'observable'
            objAdded=addObservableToModel(modelObj,input.value);
        case 'variant'
            objAdded=addvariant(modelObj,input.value);
        case 'scheduledose'
            objAdded=adddose(modelObj,input.value,'schedule');
        case 'repeatdose'
            objAdded=adddose(modelObj,input.value,'repeat');
        otherwise
            error(message('SimBiology:Internal:InternalError'))
        end
    catch ex
        out.message=SimBiology.web.internal.errortranslator(ex);
        errorOccurred=true;
    end

    if~errorOccurred
        SimBiology.web.codecapturehandler('postObjectAddedEvent',modelSessionID,objAdded,commands,errorOccurred);
    end

end

function obs=addObservableToModel(modelObj,value)

    obs=[];
    [name,expression]=parseNameExpression(value);
    if~isempty(name)
        obs=addobservable(modelObj,name,expression);
        addObservableTokensToStatesToLog(modelObj,obs);
    end

end

function[name,expression]=parseNameExpression(value)

    name='';
    expression='';
    value=strtrim(value);

    if~isempty(value)
        if strcmp(value(1),'[')
            index=strfind(value,']');
            if~isempty(index)
                index=index(1);
                name=value(1:index);
                name=name(2:end-1);


                expression=value(index+1:end);
                index=strfind(expression,'=');
                if~isempty(index)
                    expression=expression(index(1)+1:end);
                end
            end
        else
            index=strfind(value,'=');
            if~isempty(index)
                index=index(1);
                name=value(1:index-1);
                expression=value(index+1:end);
            else
                name=value;
            end
        end
    end

    name=strtrim(name);
    expression=strtrim(expression);





end

function addObservableTokensToStatesToLog(modelObj,obs)

    cs=getconfigset(modelObj,'default');
    statesToLog=cs.RuntimeOptions.StatesToLog;
    tokens=unique(parseexpression(obs));

    for i=1:length(tokens)
        obj=resolveobject(obs,tokens{i});
        if~isempty(obj)&&~any(obj==statesToLog)&&~isa(obj,'SimBiology.Observable')
            statesToLog(end+1)=obj;%#ok<AGROW>
        end
    end

    cs.RunTimeOptions.StatesToLog=statesToLog;

end

function commands=configureReactionPreferences(model,obj,input)

    commands={};
    if~isfield(input,'prefs')
        return
    end

    defaultKineticLaw=input.prefs.defaultKineticLaw;
    if~strcmp(defaultKineticLaw,'None')
        klaw=addkineticlaw(obj,defaultKineticLaw);
        commands=configureKineticLawParametersFromPrefs(model,klaw,input.prefs);
        klawCommand=createCodeCaptureConfigureObjectCommand(obj,'KineticLaw',defaultKineticLaw);
        klawCommand.codeInfo=struct('type','add');
        commands=horzcat({klawCommand},commands);
    end

end

function[codeInfo,commands]=configureKineticLaw(r,input)

    value=input.value;
    klaw=r.KineticLaw;
    codeInfo=struct('type','none');
    commands={};

    if strcmp(value,'None')
        if~isempty(klaw)
            codeInfo.type='delete';
            delete(klaw);
        end
        return
    end

    if isempty(klaw)
        klaw=addkineticlaw(r,value);
        codeInfo.type='add';
    else
        set(r.KineticLaw,'KineticLawName',value);
        codeInfo.type='set';
    end

    if strcmp(value,'MassAction')
        commands=configureMassActionParametersFromPrefs(r,klaw,input.prefs);
    else
        commands=configureKineticLawParametersFromPrefs(r.Parent,klaw,input.prefs);
    end

end

function commands=configureMassActionParametersFromPrefs(r,klaw,prefs)

    commands={};
    createParameter=prefs.createParameter;
    scopeToReaction=prefs.scopeToReaction;
    model=r.Parent;
    params=klaw.Parameters;
    pnames=get(params,{'Name'});




    created=ones(1,length(pnames));



    if(createParameter)
        if isempty(pnames)
            pnames={'kf'};
            created=0;
        end
        if(r.Reversible)&&(length(pnames)==1)
            pnames{2}='kr';
            created=[created,0];
        end
    end

    if~isempty(pnames)
        if createParameter&&~created(1)
            if(scopeToReaction)
                names=get(get(klaw,'Parameters'),{'Name'});
                if~any(strcmp(names,pnames{1}))
                    p=addparameter(klaw,pnames{1});
                    commands{end+1}=createCodeCaptureAddObjectCommand(p);
                end
            else



                p=sbioselect(model,'Type','parameter','Name',pnames{1},'depth',1);
                if~isempty(p)
                    usages=findUsages(p);
                    if~isempty(usages)
                        p=[];
                    end
                end



                if isempty(p)
                    names=get(get(model,'Parameters'),{'Name'});
                    pnames{1}=SimBiology.web.codegenerationutil('findUniqueName',names,pnames{1});
                    p=addparameter(model,pnames{1});
                    commands{end+1}=createCodeCaptureAddObjectCommand(p);
                end
            end
        end


        setparameter(klaw,'Forward Rate Parameter',pnames{1});

        if(r.Reversible)
            if createParameter&&~created(2)
                if(scopeToReaction)
                    names=get(get(klaw,'Parameters'),{'Name'});
                    if~any(strcmp(names,pnames{2}))
                        p=addparameter(klaw,pnames{2});
                        commands{end+1}=createCodeCaptureAddObjectCommand(p);
                    end
                else



                    p=sbioselect(model,'Type','parameter','Name',pnames{2},'depth',1);
                    if~isempty(p)
                        usages=findUsages(p);
                        if~isempty(usages)
                            p=[];
                        end
                    end



                    if isempty(p)
                        names=get(get(model,'Parameters'),{'Name'});
                        pnames{2}=SimBiology.web.codegenerationutil('findUniqueName',names,pnames{2});
                        p=addparameter(model,pnames{2});
                        commands{end+1}=createCodeCaptureAddObjectCommand(p);
                    end
                end
            end


            setparameter(klaw,'Reverse Rate Parameter',pnames{2});
        end

        commands{end+1}=createCodeCaptureConfigureObjectCommand(r,'ParameterVariableNames',klaw.ParameterVariableNames);
    end

end

function commands=configureKineticLawParametersFromPrefs(model,klaw,prefs)

    commands=[];
    obj=klaw.Parent;
    createParameter=prefs.createParameter;
    scopeToReaction=prefs.scopeToReaction;

    paramVariables=get(klaw,'ParameterVariables');
    paramsToCreate=paramVariables;

    if(createParameter)
        if strcmp(klaw.KineticLawName,'MassAction')
            paramsToCreate{1}='kf';
            if obj.Reversible
                paramsToCreate{2}='kr';
            end
        end

        for i=1:length(paramsToCreate)
            if(scopeToReaction)
                params=get(klaw,'Parameters');
                pnames=get(params,{'Name'});
                pname=paramsToCreate{i};
                if~any(strcmp(pnames,pname))
                    p=addparameter(klaw,pname);
                    commands{end+1}=createCodeCaptureAddObjectCommand(p);%#ok<AGROW>
                end
                setparameter(klaw,paramVariables{i},pname);
            else

                params=get(klaw,'Parameters');
                if(length(params)>=i)
                    p=params(i);
                else



                    p=sbioselect(model,'Type','parameter','Name',paramsToCreate{i},'depth',1);
                    if~isempty(p)
                        usages=findUsages(p);
                        if~isempty(usages)
                            p=[];
                        end
                    end



                    if isempty(p)
                        params=get(model,'Parameters');
                        pnames=get(params,{'Name'});

                        pname=SimBiology.web.codegenerationutil('findUniqueName',pnames,paramsToCreate{i});
                        p=addparameter(model,pname);
                        commands{end+1}=createCodeCaptureAddObjectCommand(p);%#ok<AGROW>
                    end
                end

                setparameter(klaw,paramVariables{i},p.Name);
            end
        end

        if~isempty(klaw.ParameterVariableNames)
            commands{end+1}=createCodeCaptureConfigureObjectCommand(obj,'ParameterVariableNames',klaw.ParameterVariableNames);
        end
    end

end

function commands=configureKineticLawToken(r,input)

    commands={};
    klaw=r.KineticLaw;
    params=klaw.ParameterVariables;
    species=klaw.SpeciesVariables;
    token=input.label;
    value=input.value;
    prefs=input.prefs;
    isReactionScoped=prefs.scopeToReaction;

    if strcmp(klaw.KineticLawName,'MassAction')
        if strcmpi(token,'forward')
            token='Forward Rate Parameter';
        elseif strcmpi(token,'reverse')
            token='Reverse Rate Parameter';
        end
    end

    if any(strcmp(token,params))
        originalToken=getparameters(klaw,token);




        existingParam=sbioselect(klaw,'Type','parameter','Name',value);
        if~isempty(existingParam)
            create=false;
            param=existingParam;
        else
            [create,param]=onKineticLawTokenConfigureCreateParameter(r,klaw,originalToken,value,isReactionScoped);
        end

        setparameter(klaw,token,value);

        if(create)
            if isReactionScoped
                p=addparameter(klaw,value);
            else
                p=addparameter(r.Parent,value);
            end

            commands{end+1}=createCodeCaptureAddObjectCommand(p);
        elseif~isempty(param)
            codeInfo=struct('name',param.Name);
            rename(param,value);
            commands{end+1}=createCodeCaptureConfigureObjectCommand(param,'Name',param.Name,codeInfo);
        end

        commands{end+1}=createCodeCaptureConfigureObjectCommand(r,'ParameterVariableNames',klaw.ParameterVariableNames);

    elseif any(strcmp(token,species))
        setspecies(klaw,token,value);
        commands{end+1}=createCodeCaptureConfigureObjectCommand(r,'SpeciesVariableNames',klaw.SpeciesVariableNames);
    end

end

function[create,param]=onKineticLawTokenConfigureCreateParameter(reaction,klaw,originalToken,pname,isReactionScoped)

    if isReactionScoped
        pnames=get(klaw.Parameters,{'Name'});
    else
        pnames=get(reaction.Parent.Parameters,{'Name'});
    end


    if any(strcmp(pnames,pname))
        create=false;
        param=[];
        return;
    end




    if~isempty(originalToken)
        if isReactionScoped
            param=sbioselect(reaction,'Type','parameter','Name',originalToken.Name);
        else
            param=sbioselect(reaction.Parent.Parameters,'Name',originalToken.Name);
        end
    else
        param=[];
    end

    if isempty(param)
        create=true;
        param=[];
        return;
    end

    usages=findUsages(param);
    if length(usages)==1&&isequal(usages,reaction)

        create=false;
    elseif length(usages)==2&&isequal(usages(1),reaction)&&isequal(usages(2),klaw)
        create=false;
    else
        create=true;
        param=[];
    end

end

function deleteUnusedQuantities(input)

    modelSessionID=input.modelSessionID;
    modelObj=getModelFromSessionID(modelSessionID);
    sessionIDs=input.objectIDs;
    commands=cell(1,numel(sessionIDs));
    transaction=SimBiology.Transaction.create(modelObj);

    for i=1:length(sessionIDs)
        obj=sbioselect(modelObj,'SessionID',sessionIDs(i));
        commands{i}=createCodeCaptureDeleteObjectCommand(obj);
        delete(obj);
    end

    SimBiology.web.codecapturehandler('postObjectDeletedEvent',modelSessionID,commands);

    transaction.commit;

end

function deleteAllObjects(input)

    modelSessionID=input.modelSessionID;
    modelObj=getModelFromSessionID(modelSessionID);
    transaction=SimBiology.Transaction.create(modelObj);




    types={'variant','repeatdose','scheduledose','parameter','rule','event','reaction','observable','species','compartment'};
    for i=1:length(types)
        args=struct;
        args.modelSessionID=input.modelSessionID;
        args.type=types{i};
        args.objectIDs=unique(sbioselect(input.objArray,'Type',types{i}));
        args.forceDelete=true;
        if~isempty(args.objectIDs)
            deleteObjectInternal(args);
        end
    end

    transaction.commit;

end

function out=deleteObject(input)

    modelSessionID=input.modelSessionID;
    modelObj=getModelFromSessionID(modelSessionID);
    type=input.type;
    if iscell(type)
        type=type{1};
    end

    if any(strcmp(type,{'variant','repeatdose','scheduledose'}))
        obj=sbioselect(modelObj,'Type',type,'SessionID',input.objectIDs(1));
        transaction=SimBiology.Transaction.create(obj);
    else
        transaction=SimBiology.Transaction.create(modelObj);
    end

    out=deleteObjectInternal(input);

    if strcmp(input.type,'Quantity')
        input.objectIDs=input.speciesIDs;
        input.type='species';
        out=deleteObjectInternal(input);

        input.objectIDs=input.compIDs;
        input.type='compartment';
        deleteObjectInternal(input);
    end

    transaction.commit;

end

function out=deleteObjectInternal(input)

    out.message='';
    modelSessionID=input.modelSessionID;
    modelObj=getModelFromSessionID(modelSessionID);
    sessionIDs=input.objectIDs;
    commands={};



    oldWarningState=warning('off','SimBiology:DELETE_SPECIES_BEING_USED');
    warningStateCleanup=onCleanup(@()warning(oldWarningState));

    rmReactantState=warning('off','SimBiology:RMREACTANT_INVALIDSPECIES');
    rmReactantStateCleanup=onCleanup(@()warning(rmReactantState));

    rmProductState=warning('off','SimBiology:RMPRODUCT_INVALIDSPECIES');
    rmProductStateCleanup=onCleanup(@()warning(rmProductState));

    comps={};

    for i=1:length(sessionIDs)
        if isnumeric(sessionIDs(i))
            obj=sbioselect(modelObj,'Type',input.type,'SessionID',sessionIDs(i));
        else
            obj=sessionIDs(i);
        end

        if strcmp(input.type,'compartment')
            comps{end+1}=obj;%#ok<AGROW>
            continue;
        end



        type=obj.Type;

        if input.forceDelete&&strcmp(type,'species')
            usages=obj.findUsages;
            reactions=usages((ismember({usages.Type},'reaction')));

            for j=1:numel(reactions)
                reactions(j).rmreactant(obj);
                reactions(j).rmproduct(obj);
                commands{end+1}=createCodeCaptureConfigureObjectCommand(reactions(j),'Reaction',reactions(j).Reaction);%#ok<AGROW>
            end
        end


        commands{end+1}=createCodeCaptureDeleteObjectCommand(obj);%#ok<AGROW>
        delete(obj);



        if strcmp(type,'species')
            if isvalid(obj)
                out.message='One or more species were not deleted. It is being used by a reaction.';
            end
        end
    end

    if~isempty(comps)
        comps=[comps{:}];
        while~isempty(comps)
            next=sbioselect(comps,'Compartments',SimBiology.Compartment.empty(0,1));
            next=unique(next);
            for i=1:numel(next)
                commands{end+1}=createCodeCaptureDeleteObjectCommand(next(i));%#ok<AGROW>
            end
            delete(next);
            comps=comps(isvalid(comps));
        end
    end

    SimBiology.web.codecapturehandler('postObjectDeletedEvent',modelSessionID,commands);

end

function verifyModel(input)

    sessionID=input.sessionID;
    modelObj=getModelFromSessionID(sessionID);
    configset=modelObj.getconfigset('default');%#ok<NASGU>
    variants=modelObj.getvariant;
    doses=modelObj.getdose;


    variants=sbioselect(variants,'Active',true);%#ok<NASGU>
    doses=sbioselect(doses,'Active',true);%#ok<NASGU>


    evalc('SimBiology.internal.verifyHelper(modelObj, configset, variants, doses, ''SendAllMessages'', true);');

end

function removeModel(varargin)


    inputs=[varargin{:}];

    results=repmat(struct('type',{'modelRemoved'},'sessionID',{''}),1,numel(inputs));
    for i=1:numel(inputs)
        input=inputs(i);
        sessionID=input.sessionID;
        modelObj=getModelFromSessionID(sessionID);
        turnOffEvents(modelObj);


        results(i).sessionID=sessionID;
    end

    if strcmp(input.appType,'ModelingApp')
        SimBiology.web.desktophandler('postEventToModelAnalyzer',results);
    else
        SimBiology.web.desktophandler('postEventToModelBuilder',results);
    end
end

function name=findUniqueName(allNames,nameIn)

    if isempty(allNames)||~any(strcmp(allNames,nameIn))
        name=nameIn;
        return;
    end

    index=1;
    newName=[nameIn,'_',num2str(index)];
    while any(strcmp(allNames,newName))
        index=index+1;
        newName=[nameIn,'_',num2str(index)];
    end
    name=newName;

end

function out=getValuePropertyForState(state)

    out=SimBiology.web.codegenerationutil('getValuePropertyForState',state);

end

function out=getConstantPropertyForState(state)

    out=SimBiology.web.codegenerationutil('getConstantPropertyForState',state);

end

function out=convertRuleType(type)

    switch(type)
    case 'initial assignment'
        out='initialAssignment';
    case 'repeated assignment'
        out='repeatedAssignment';
    otherwise
        out=type;
    end

end

function out=isQuantity(state)

    out=isa(state,'SimBiology.Species')||isa(state,'SimBiology.Parameter')||isa(state,'SimBiology.Compartment');

end

function cleanupOnProjectClose(input)

    sessionIDs=input.sessionIDs;
    for i=1:length(sessionIDs)
        modelObj=getModelFromSessionID(sessionIDs(i));
        turnOffEvents(modelObj);
    end

    SimBiology.web.projecthandler('clearTempDirectory');

end

function turnOnEvents(m)

    m.SendSaveNeededEvent=true;
    m.sendEvent=true;

    try
        SimBiology.Transaction.addstack(m);
    catch
    end

end

function forceEvents(input)

    sessionID=input.sessionID;
    m=getModelFromSessionID(sessionID);

    m.sendInvalidExpressionEvents;

end

function turnOffEvents(m)

    if~isempty(m)
        m.SendSaveNeededEvent=false;
        m.sendEvent=false;


        cleanupDiagram(m)


        try
            SimBiology.Transaction.removestack(m);
        catch


        end
    end

end

function out=getUndoState(input)

    template=struct('sessionID','','undoState',false,'redoState',false);
    out=repmat(template,1,numel(input.sessionIDs));

    for i=1:numel(input.sessionIDs)
        out(i).sessionID=input.sessionIDs(i);
        model=getModelFromSessionID(input.sessionIDs(i));
        [out(i).undoState,out(i).redoState]=SimBiology.Transaction.hasUndoRedo(model);
    end

end

function cleanupDiagram(m)



    if m.hasDiagramEditor
        m.deleteDiagramEditor;
    end

    if m.hasDiagramSyntax
        m.deleteDiagramSyntax;
    end

end

function out=getModelEquations(action,input)


    info.repeatedAssignments={};
    info.odes={};
    info.fluxes={};
    info.isValid=true;
    info.msg='';
    model=getModelFromSessionID(input.sessionID);
    embedFluxes=input.embedFluxes;


    vobj=input.variants;
    dobj=input.doses;


    csobj=getconfigset(model,'default');


    try
        SimBiology.internal.verifyHelper(model,csobj,dobj,"RequireObservableDependencies",false);
    catch ex
        info.isValid=false;
        info.msg=SimBiology.web.internal.errortranslator(ex);

        out={action,info};
        return;
    end


    [h,repeatedAssignments]=SimBiology.internal.Equations.genEquations(model,csobj,vobj,dobj,'EmbedFlux',embedFluxes,'WarnIfInitialConditionSetByAlgebraicRule',false);

    pat='\n+';
    s=regexp(h,pat,'split');

    odeIndex=find(strcmp(s,SimBiology.internal.Equations.EquationView.ODEHeading));
    fluxIndex=find(strcmp(s,SimBiology.internal.Equations.EquationView.FluxesHeading));
    ruleIndex=find(strcmp(s,SimBiology.internal.Equations.EquationView.AlgebraicConstraintsHeading));

    if isempty(ruleIndex)
        ruleIndex=find(strcmp(s,SimBiology.internal.Equations.EquationView.RepeatedAssignmentHeading));
    end

    if isempty(ruleIndex)
        ruleIndex=find(strcmp(s,SimBiology.internal.Equations.EquationView.ParameterValuesHeading));
    end

    if isempty(ruleIndex)
        ruleIndex=find(strcmp(s,SimBiology.internal.Equations.EquationView.InitialConditionsHeading));
    end

    if isempty(odeIndex)

        odes={};
        fluxes={};
    elseif isempty(fluxIndex)

        odes=s(odeIndex+1:ruleIndex-1);
        fluxes={};
    else

        odes=s(odeIndex+1:fluxIndex-1);
        fluxes=s(fluxIndex+1:ruleIndex-1);
    end

    if embedFluxes
        fluxes={};
    end


    info.repeatedAssignments=repeatedAssignments;
    info.odes=odes;
    info.fluxes=fluxes;
    info.isValid=true;
    info.msg='';

    out={action,info};

end

function out=exportModelToHTML(inputs)

    out=SimBiology.web.internal.exportModel('exportModelToHTML',inputs);

end

function out=exportDiagram(inputs)

    out=SimBiology.web.internal.exportModel('exportDiagram',inputs);

end

function out=getScreenSizeInInches(inputs)

    out=SimBiology.web.internal.exportModel('getScreenSizeInInches',inputs);

end

function out=exportExpressionsToHTML(inputs)

    out=SimBiology.web.internal.exportModel('exportExpressionsToHTML',inputs);

end

function configureRuleUsingQuantity(rule,quantity)

    [~,~,~,rhs]=parserule(rule);

    if isempty(rhs)
        value=get(rule,'Rule');
        index=strfind(value,'=');
        if~isempty(index)
            rhs=strtrim(value(index+1:end));
        else
            rhs='1';
        end
    end

    if~strcmp(rule.RuleType,'initialAssignment')
        if isa(quantity,'SimBiology.Parameter')
            quantity.ConstantValue=false;
        elseif isa(quantity,'SimBiology.Species')
            quantity.ConstantAmount=false;
        elseif isa(quantity,'SimBiology.Compartment')
            quantity.ConstantCapacity=false;
        end
    end

    expr=sprintf('%s = %s',quantity.PartiallyQualifiedNameReally,rhs);



    set(rule,'Rule',expr);

    SimBiology.web.codecapturehandler('postSinglePropertyChangedEvent',rule.Parent.SessionID,rule,'Rule',expr);

end

function addQuantityToEvent(event,quantity)



    if isa(quantity,'SimBiology.Parameter')
        quantity.ConstantValue=false;
    elseif isa(quantity,'SimBiology.Species')
        quantity.ConstantAmount=false;
    elseif isa(quantity,'SimBiology.Compartment')
        quantity.ConstantCapacity=false;
    end

    newExpr=sprintf('%s = 0',quantity.PartiallyQualifiedNameReally);
    eventfcn=get(event,'EventFcns');

    if length(eventfcn)==1&&strcmp(eventfcn{1},'null = 0')
        eventfcn{1}=newExpr;
    else
        eventfcn{end+1}=newExpr;
    end



    set(event,'EventFcns',eventfcn);

    SimBiology.web.codecapturehandler('postSinglePropertyChangedEvent',event.Parent.SessionID,event,'EventFcns',eventfcn);

end

function replaceEventLHS(event,quantity,oldLHS)



    if isa(quantity,'SimBiology.Parameter')
        quantity.ConstantValue=false;
    elseif isa(quantity,'SimBiology.Species')
        quantity.ConstantAmount=false;
    elseif isa(quantity,'SimBiology.Compartment')
        quantity.ConstantCapacity=false;
    end


    index=findEventFcnIndex(event,oldLHS);
    if~isempty(index)
        eventfcn=get(event,'EventFcns');
        [~,~,~,rhs]=parseeventfcns(event);
        lhs=quantity.PartiallyQualifiedNameReally;


        for i=1:length(index)
            newExpr=[lhs,' = ',rhs{index(i)}];
            eventfcn{index(i)}=newExpr;
        end

        set(event,'EventFcns',eventfcn);

        SimBiology.web.codecapturehandler('postSinglePropertyChangedEvent',event.Parent.SessionID,event,'EventFcns',eventfcn);
    end

end

function out=findEventFcnIndex(event,lhsObj)

    lhs=parseeventfcns(event);
    outCell=cell(1,numel(lhs));
    for i=1:length(lhs)
        next=lhs{i};
        if~isempty(next)
            nextObj=resolveobject(event,next{1});
            if~isempty(nextObj)&&isequal(nextObj,lhsObj)
                outCell{i}=i;
            end
        end
    end
    out=[outCell{:}];

end

function replaceQuantityInReaction(reaction,newSpecies,oldSpecies)

    reactants=reaction.Reactants;
    products=reaction.Products;
    stoich=reaction.Stoichiometry;


    isReactant=any(oldSpecies==reactants);
    isProduct=any(oldSpecies==products);


    rstoich=-1;
    if isReactant
        rstoich=sum(stoich(oldSpecies==reactants));
    end

    pstoich=1;
    if isProduct
        pindex=find(oldSpecies==products)+numel(reactants);
        pstoich=sum(stoich(pindex));
    end

    if isReactant
        rmreactant(reaction,oldSpecies);
        addreactant(reaction,newSpecies);
    end

    if isProduct
        rmproduct(reaction,oldSpecies);
        addproduct(reaction,newSpecies);
    end

    reactants=reaction.Reactants;
    products=reaction.Products;
    stoich=reaction.Stoichiometry;

    if isReactant
        stoich(newSpecies==reactants)=rstoich;
    end

    if isProduct
        pindex=find(newSpecies==products)+numel(reactants);
        stoich(pindex)=pstoich;
    end

    reaction.Stoichiometry=stoich;

    SimBiology.web.codecapturehandler('postSinglePropertyChangedEvent',reaction.Parent.SessionID,reaction,'Reaction',reaction.Reaction);



    if isempty(reaction.KineticLaw)||strcmp(reaction.KineticLaw.KineticLawName,'Unknown')

        tokens=reaction.parserate;


        rRate=reaction.ReactionRate;






        for i=1:numel(tokens)
            resolvedObj=resolveobject(reaction,tokens{i});
            if resolvedObj==oldSpecies
                rRate=SimBiology.internal.Utils.Parser.traverseSubstitute(rRate,tokens{i},newSpecies.PartiallyQualifiedName);
            end
        end


        if~strcmp(reaction.ReactionRate,rRate)
            reaction.ReactionRate=rRate;
            SimBiology.web.codecapturehandler('postSinglePropertyChangedEvent',reaction.Parent.SessionID,reaction,'ReactionRate',rRate);
        end
    elseif~strcmp(reaction.KineticLaw.KineticLawName,'MassAction')

        speciesNames=reaction.KineticLaw.SpeciesVariableNames;
        valueChanged=false;

        for i=1:numel(speciesNames)
            resolvedObj=resolveobject(reaction,speciesNames{i});
            if resolvedObj==oldSpecies
                valueChanged=true;
                speciesNames{i}=newSpecies.PartiallyQualifiedName;
            end
        end

        if valueChanged
            reaction.KineticLaw.SpeciesVariableNames=speciesNames;
            SimBiology.web.codecapturehandler('postSinglePropertyChangedEvent',reaction.Parent.SessionID,reaction,'SpeciesVariableNames',speciesNames);
        end
    end

end

function addReactantOrProductToReaction(reaction,species,isreactant)

    if isreactant
        addreactant(reaction,species);
    else
        addproduct(reaction,species);
    end

    SimBiology.web.codecapturehandler('postSinglePropertyChangedEvent',reaction.Parent.SessionID,reaction,'Reaction',reaction.Reaction);

end

function out=addSpeciesToCompartment(input)

    modelObj=getModelFromSessionID(input.modelSessionID);
    comp=sbioselect(modelObj,'Type','compartment','SessionID',input.sessionID);
    names=input.names;
    invalid={};
    firstValid=-1;
    transaction=SimBiology.Transaction.create(modelObj);

    for i=1:length(names)
        try
            s=addspecies(comp,names{i});
            SimBiology.web.codecapturehandler('postObjectAddedEvent',input.modelSessionID,s,[],false);

            if firstValid==-1
                firstValid=s.SessionID;
            end
        catch
            invalid{end+1}=names{i};%#ok<AGROW>
        end
    end

    transaction.commit;

    if isempty(invalid)
        out.invalid='';
    else
        out.invalid=invalid;
    end

    out.firstValid=firstValid;
    out.sessionID=input.sessionID;

end

function removeQuantityFromRule(rule,quantity)

    if isempty(rule)
        return;
    end

    [lhsToken,~,~,rhs]=parserule(rule);

    if isempty(rhs)
        value=get(rule,'Rule');
        index=strfind(value,'=');
        if~isempty(index)
            rhs=strtrim(value(index+1:end));
        else
            rhs='1';
        end
    end

    if~isempty(lhsToken)&&length(lhsToken)==1
        lhsObj=resolveobject(rule,lhsToken{1});
        if~isempty(lhsObj)&&isequal(quantity,lhsObj)
            expr=['null = ',rhs];
            set(rule,'Rule',expr);

            SimBiology.web.codecapturehandler('postSinglePropertyChangedEvent',rule.Parent.SessionID,rule,'Rule',expr);
        end
    end

end

function removeQuantityFromReaction(reaction,species)

    reactants=reaction.Reactants.get({'SessionID'});
    products=reaction.Products.get({'SessionID'});

    reactants=[reactants{:}];
    products=[products{:}];

    isReactant=any(reactants==species.SessionID);
    isProduct=any(products==species.SessionID);

    if isReactant

        rmreactant(reaction,species);
    end

    if isProduct

        rmproduct(reaction,species);
    end

    if isReactant||isProduct
        SimBiology.web.codecapturehandler('postSinglePropertyChangedEvent',reaction.Parent.SessionID,reaction,'Reaction',reaction.Reaction);
    end

end

function out=getModelFromSessionID(sessionID)

    out=findobj(SimBiology.Root.getroot.Models,'-depth',0,'SessionID',sessionID);

end

function saveCode(input)

    code='function runcode(m1)';
    code=appendCode(code,'% This code requires a SimBiology model as an input argument. To export a');
    code=appendCode(code,'% model from the SimBiology Model Builder, from the Export button in the');
    code=appendCode(code,'% Home Toolstrip tab select Export Model to MATLAB Workspace.');
    code=appendCode(code,'');
    code=appendCode(code,input.code);
    code=appendCode(code,'end');

    matlab.desktop.editor.newDocument(code);

end

function code=appendCode(code,newCode)

    code=SimBiology.web.codegenerationutil('appendCode',code,newCode);

end

function command=createCodeCaptureAddObjectCommand(obj)

    command=SimBiology.web.codecapturehandler('createAddObjectCommand',obj);

end

function command=createCodeCaptureDeleteObjectCommand(obj)

    command=SimBiology.web.codecapturehandler('creatDeleteObjectCommand',obj);

end

function command=createCodeCaptureConfigureObjectCommand(obj,property,value,varargin)

    command=SimBiology.web.codecapturehandler('createConfigureObjectCommand',obj,property,value,varargin{:});

end

function deleteFile(name)

    oldWarnState=warning('off','MATLAB:DELETE:Permission');
    cleanup=onCleanup(@()warning(oldWarnState));

    if exist(name,'file')
        oldState=recycle;
        recycle('off');
        delete(name)
        recycle(oldState);
    end
end
