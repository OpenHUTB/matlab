function eventhandler(action,varargin)











    if~messageServiceAvailable()
        return
    end

    switch(action)
    case 'saveNeeded'
        saveNeeded(varargin{:});
    case 'statusChange'
        statusChange(varargin{:});
    case 'objectMoved'
        objectMoved(varargin{:});
    case 'objectAdded'
        objectAddedArray(varargin{:});
    case 'objectDeleted'
        [deletedObj,message]=deal(varargin{:});
        if isTypeOK(deletedObj)
            objectDeleted(deletedObj,message)
        end

        if isRepeatAssignment(deletedObj)
            repeatAssignmentDeleted(deletedObj);
        end
        if isInitialAssignment(deletedObj)
            initialAssignmentDeleted(deletedObj);
        end
        if isEvent(deletedObj)
            eventDeleted(deletedObj);
        end
    case 'removedFromLibrary'
        switch varargin{2}
        case 'unit'
            unitAddedOrDeleted('unitDeleted',varargin{1});
        case 'abstract_kinetic_law'
            abstractKineticLawDeleted(varargin{1});
        case 'unitPrefix'
            unitAddedOrDeleted('unitPrefixDeleted',varargin{1});
        end
    case 'propertyChanged'

        if~strcmp(varargin{2},'ConfigSets')
            propertyChanged(varargin{:});
        end
    case 'configsetPropertyChanged'

        configsetPropertyChanged(varargin{:});
    case 'reorderEvent'


        reorderEvent(varargin{:});
    case 'message'


        postMessage(varargin{:});
    case 'warning'



        postWarning(varargin{:});
    case 'runprogram'

        runprogram(varargin{:});
    case 'incrementScanRun'

        incrementScanRun;
    case 'incrementFitRun'

    case 'inUseCount'
        inUseCount(varargin{:});
    case 'duplicateNameStatus'
        duplicateNameStatus(varargin{:});
    case 'expressionStatus'
        expressionStatus(varargin{:});
    case 'equationsChanged'
        equationsChanged(varargin{:});
    case 'undoRedoStatus'
        undoStatusChanged(varargin{:});
    case 'transactionFocus'
        transactionFocusChanged(varargin{:});
    case 'undoInDiagram'

        undoInDiagram(varargin{:});
    case 'lhsChange'
        lhsChangedEvent(varargin{:});
    end

end

function ok=isTypeOK(object)

    switch object.type
    case{'sbiomodel','species','compartment','parameter','variant','repeatdose','scheduledose','reaction','rule','event','observable'}
        ok=true;
    case{'abstract_kinetic_law','kineticlaw','unit','unitprefix','configset'}
        ok=false;
    otherwise
        ok=false;
    end

end

function ok=isUnit(object)

    switch object.type
    case{'unit'}
        ok=true;
    otherwise
        ok=false;
    end

end

function ok=isUnitPrefix(object)

    switch object.type
    case{'unitprefix'}
        ok=true;
    otherwise
        ok=false;
    end

end

function ok=isAbstractKineticLaw(object)

    switch object.type
    case{'abstract_kinetic_law'}
        ok=true;
    otherwise
        ok=false;
    end

end

function ok=isEvent(object)

    switch object.type
    case{'event'}
        ok=true;
    otherwise
        ok=false;
    end

end

function ok=isRepeatAssignment(object)

    switch object.type
    case{'rule'}
        ok=strcmp(object.RuleType,'repeatedAssignment');
    otherwise
        ok=false;
    end

end

function ok=isInitialAssignment(object)

    switch object.type
    case{'rule'}
        ok=strcmp(object.RuleType,'initialAssignment');
    otherwise
        ok=false;
    end

end

function saveNeeded(object)

    evt.type='saveNeeded';
    evt.model=object.SessionID;

    publish('/SimBiology/project',evt);

end

function objectAddedArray(varargin)

    objects=varargin{1};
    message=varargin{2};
    objList={};
    repeat={};
    initial={};
    event={};

    for i=1:numel(objects)
        object=objects(i);
        if isTypeOK(object)
            objList{end+1}=object;%#ok<AGROW>
        elseif isUnit(object)
            unitAddedOrDeleted('unitAdded',object);
        elseif isUnitPrefix(object)
            unitAddedOrDeleted('unitPrefixAdded',object);
        elseif isAbstractKineticLaw(object)
            abstractKineticLawAdded(object);
        end

        if isRepeatAssignment(object)
            repeat{end+1}=object;%#ok<AGROW>
        elseif isInitialAssignment(object)
            initial{end+1}=object;%#ok<AGROW>
        elseif isEvent(object)
            event{end+1}=object;%#ok<AGROW>
        end
    end

    if~isempty(objList)
        objectAdded([objList{:}],message);
    end

    if~isempty(repeat)
        repeatAssignmentAdded([repeat{:}]);
    end

    if~isempty(initial)
        initialAssignmentAdded([initial{:}]);
    end

    if~isempty(event)
        eventAdded([event{:}]);
    end

end

function objectAdded(objects,message)

    template=struct('info','','type','objectAdded','objType','','model','','index','','source',message);
    evt=repmat(template,1,numel(objects));
    params=[];
    species=[];

    for i=1:numel(objects)
        object=objects(i);
        evt(i).info=SimBiology.web.modelhandler('getComponentInfo',object);

        if~isempty(evt(i).info)

            evt(i).type='objectAdded';
            evt(i).objType=object.Type;
            evt(i).model=SimBiology.web.modelhandler('getModelSessionID',object);




            parent=object.Parent;

            if isa(object,'SimBiology.Species')
                if isempty(species)
                    species=SimBiology.web.modelhandler('getModelSpecies',parent.Parent);
                end
                allObjs=species;
            elseif isa(object,'SimBiology.Parameter')
                if isempty(params)
                    params=SimBiology.web.modelhandler('getModelParameters',parent);
                end
                allObjs=params;
            elseif isa(object,'SimBiology.Dose')
                allObjs=getdose(parent);
            else
                allObjs=get(parent,object.Type);
            end

            evt(i).index=find(object==allObjs);
        end
    end

    next=evt;
    [~,idx]=sort([next.index]);
    next=next(idx);




    types={next.objType};
    comps=next(strcmp('compartment',types));
    other=next(~strcmp('compartment',types));
    next=horzcat(comps,other);


    types={next.objType};
    params=next(strcmp('parameter',types));
    other=next(~strcmp('parameter',types));
    next=horzcat(other,params);

    publish('/SimBiology/object',next);


    species=sbioselect(objects,'Type','species');
    if~isempty(species)
        sendStatesToLogChangedEvent(species,true);
    end

    params=sbioselect(objects,'Type','parameter');
    if~isempty(params)
        sendReactionScopedParameterEvent(params);
    end



    next=evt;
    types={next.objType};
    cidx=strcmp('compartment',types);
    sidx=strcmp('species',types);
    pidx=strcmp('parameter',types);
    oidx=~strcmp('compartment',types)&~strcmp('species',types)&~strcmp('parameter',types);

    comps=next(cidx);
    species=next(sidx);
    params=next(pidx);
    other=next(oidx);
    evt=horzcat(comps,species,params,other);

    cObjs=objects(cidx);
    sObjs=objects(sidx);
    pObjs=objects(pidx);
    oObjs=objects(oidx);
    objects=horzcat(cObjs,sObjs,pObjs,oObjs);


    if~any(strcmp(message,{'undo','redo'}))
        for i=1:length(evt)
            notifyDiagram('objectAdded',evt(i),objects(i));
        end
    end






    if strcmp(message,'redo')
        for i=1:numel(evt)
            modelSessionID=SimBiology.web.modelhandler('getModelSessionID',objects(i));
            model=SimBiology.web.modelhandler('getModelFromSessionID',modelSessionID);
            if model.hasDiagramSyntax
                SimBiology.web.diagram.eventhandler('blockAdded',evt(i),model,objects(i));
            end
        end
    end


end

function initialAssignmentAdded(object)

    assignmentAdded(object,'initialAssignmentAdded');

end

function repeatAssignmentAdded(object)

    assignmentAdded(object,'repeatAssignmentAdded');

end

function assignmentAdded(objects,type)

    template=struct('type',type,'obj','','lhsID','','model','');
    evt=repmat(template,1,numel(objects));
    count=0;

    for i=1:numel(objects)
        obj=objects(i);
        lhs=parserule(obj);


        if~isempty(lhs)
            lhsObj=resolveobject(obj,lhs{1});
            if~isempty(lhsObj)
                evt(count+1).type=type;
                evt(count+1).obj=obj.SessionID;
                evt(count+1).lhsID=lhsObj.SessionID;
                evt(count+1).model=SimBiology.web.modelhandler('getModelSessionID',obj);
                count=count+1;
            end
        end
    end

    if count>0
        evt=evt(1:count);
        publish('/SimBiology/object',evt);
    end

end

function objectDeleted(object,message)

    evt.type='objectDeleted';
    evt.obj=object.SessionID;
    evt.model=object.ParentModelSessionID;
    evt.objType=object.Type;

    if isa(object,'SimBiology.Model')
        evt.model=object.SessionID;
    else
        evt.model=SimBiology.web.modelhandler('getModelSessionID',object);
    end

    publish('/SimBiology/object',evt);


    if strcmp(evt.objType,'species')
        sendStatesToLogChangedEvent(object,false);
    elseif strcmp(evt.objType,'parameter')
        sendReactionScopedParameterEvent(object);
    end


    evt.message=message;
    notifyDiagram('objectDeleted',evt,object);

end

function sendStatesToLogChangedEvent(objs,isAdd)

    model=objs(1).Parent.Parent;
    cs=getconfigset(model,'default');
    setToAll=~get(cs.RuntimeOptions,'StatesToLogSet');

    if(setToAll)
        evt.type='configsetPropertyChanged';
        evt.property='StatesToLog';
        evt.value=get(cs.RuntimeOptions,'StatesToLog');
        evt.model=model.SessionID;
        evt.sessionID=model.SessionID;
        evt.value=get(evt.value,{'SessionID'});
        evt.StatesToLogAll=setToAll;

        if~isAdd
            for i=1:length(objs)
                tvalue=[evt.value{:}];
                idx=(objs(i).SessionID~=tvalue);
                evt.value=evt.value(idx);
            end
        end

        publish('/SimBiology/object',evt);
    end

end

function reorderEvent(obj,type)


    if isa(obj,'SimBiology.Compartment')
        model=obj.Parent;
    elseif isa(obj,'SimBiology.KineticLaw')
        model=obj.Parent.Parent;
    else
        model=obj;
    end

    switch lower(type)
    case 'species'
        allObjs=SimBiology.web.modelhandler('getModelSpecies',model);
    case 'parameters'
        allObjs=SimBiology.web.modelhandler('getModelParameters',model);
    otherwise
        allObjs=get(model,type);
    end

    if numel(allObjs)>1
        evt.type='reorder';
        evt.objType=allObjs(1).Type;
        evt.model=model.SessionID;
        evt.sessionIDs=[allObjs.SessionID];

        publish('/SimBiology/object',evt);
    end

end

function unitAddedOrDeleted(evtType,nameOrObj)

    evt.type=evtType;

    if isa(nameOrObj,'SimBiology.Unit')
        evt.value=nameOrObj.Composition;
        evt.name=nameOrObj.Name;
        evt.multiplier=nameOrObj.Multiplier;
    elseif isa(nameOrObj,'SimBiology.UnitPrefix')
        evt.value=nameOrObj.Exponent;
        evt.name=nameOrObj.Name;
    else
        evt.name=nameOrObj;
    end


    sbr=sbioroot;
    mObjs=sbr.Models;


    mObjs=mObjs([mObjs.SendEvents]);


    template=struct('model',-1,'valid','','invalid','');
    info=repmat(template,1,length(mObjs));
    for i=1:length(mObjs)
        info(i).model=mObjs(i).SessionID;
        objs=sbioselect(mObjs(i),'Type',{'parameter','species','compartment'},...
        '-function',@(obj)~obj.isValidUnits(obj.Units));
        if~isempty(objs)
            info(i).invalid=[objs.SessionID];
        end

        objs=sbioselect(mObjs(i),'Type',{'repeatdose','scheduledose'},...
        '-function',@(obj)~isempty(obj.AmountUnits)&&~SimBiology.internal.isValidAmountUnit(obj.AmountUnits));

        if~isempty(objs)
            info(i).invalidAmountUnits=[objs.SessionID];
        end

        objs=sbioselect(mObjs(i),'Type',{'repeatdose','scheduledose'},...
        '-function',@(obj)~isempty(obj.RateUnits)&&~SimBiology.internal.isValidRateUnit(obj.RateUnits));

        if~isempty(objs)
            info(i).invalidRateUnits=[objs.SessionID];
        end

        objs=sbioselect(mObjs(i),'Type',{'repeatdose','scheduledose'},...
        '-function',@(obj)~isempty(obj.TimeUnits)&&~SimBiology.internal.isValidTimeUnit(obj.TimeUnits));

        if~isempty(objs)
            info(i).invalidTimeUnits=[objs.SessionID];
        end
    end

    evt.info=info;

    publish('/SimBiology/unit',evt);


end

function abstractKineticLawAdded(obj)

    evt.type='abstractKineticLawAdded';
    evt.name=obj.Name;
    evt.expression=obj.Expression;
    evt.parameters=obj.ParameterVariables;
    evt.species=obj.SpeciesVariables;

    publish('/SimBiology/akl',evt);

end

function abstractKineticLawDeleted(obj)

    evt.type='abstractKineticLawDeleted';
    evt.name=obj;

    publish('/SimBiology/akl',evt);

end

function eventAdded(object)


    lhsIDs=SimBiology.web.modelhandler('getEventLHS',object(1).Parent,[]);
    postEventFcnChanged(object(1),lhsIDs);

end

function eventDeleted(object)



    lhsIDs=SimBiology.web.modelhandler('getEventLHS',object.Parent,object);
    postEventFcnChanged(object,lhsIDs);

end

function eventFcnChanged(object)


    lhsIDs=SimBiology.web.modelhandler('getEventLHS',object.Parent,[]);
    postEventFcnChanged(object,lhsIDs);

end

function postEventFcnChanged(object,lhsIDs)

    evt.type='eventFcnChanged';
    evt.obj=object.SessionID;
    evt.lhsIDs=lhsIDs;
    evt.model=SimBiology.web.modelhandler('getModelSessionID',object);

    publish('/SimBiology/object',evt);

end

function initialAssignmentDeleted(object)



    lhsIDs=SimBiology.web.modelhandler('getInitialAssignmentLHS',object.Parent,object);
    assignmentDeleted(object,'initialAssignmentLHSChanged',lhsIDs);

end

function repeatAssignmentDeleted(object)



    lhsIDs=SimBiology.web.modelhandler('getRepeatAssignmentLHS',object.Parent,object);
    assignmentDeleted(object,'repeatAssignmentLHSChanged',lhsIDs);

end

function assignmentDeleted(object,type,lhsIDs)



    lhs=parserule(object);

    if~isempty(lhs)
        obj=resolveobject(object,lhs{1});
        if~isempty(obj)
            evt.type=type;
            evt.obj=object.SessionID;
            evt.lhsIDs=lhsIDs;
            evt.model=SimBiology.web.modelhandler('getModelSessionID',object);

            publish('/SimBiology/object',evt);
        end
    end

end

function initialAssignmentChanged(object)


    lhsIDs=SimBiology.web.modelhandler('getInitialAssignmentLHS',object.Parent,[]);
    assignmentChanged(object,'initialAssignmentLHSChanged',lhsIDs);

end

function repeatAssignmentChanged(object)


    lhsIDs=SimBiology.web.modelhandler('getRepeatAssignmentLHS',object.Parent,[]);
    assignmentChanged(object,'repeatAssignmentLHSChanged',lhsIDs);

end

function assignmentChanged(object,type,lhsIDs)

    evt.type=type;
    evt.obj=object.SessionID;
    evt.lhsIDs=lhsIDs;
    evt.model=SimBiology.web.modelhandler('getModelSessionID',object);

    publish('/SimBiology/object',evt);

end

function statusChange(object)

    if isa(object,'SimBiology.Variant')
        propertyChanged(object,'Content','');
    elseif isa(object,'SimBiology.Dose')
        evt.type='objectNeedsRefresh';
        evt.obj=object.SessionID;
        evt.objType=object.Type;
        evt.model=SimBiology.web.modelhandler('getModelSessionID',object);
        objInfo=SimBiology.web.modelhandler('getComponentInfo',object);
        evt.TargetSessionID=objInfo.properties.TargetSessionID;
        evt.DurationParameterSessionID=objInfo.properties.DurationParameterSessionID;
        evt.LagParameterSessionID=objInfo.properties.LagParameterSessionID;
        evt.AmountSessionID=objInfo.properties.AmountSessionID;
        evt.IntervalSessionID=objInfo.properties.IntervalSessionID;
        evt.RateSessionID=objInfo.properties.RateSessionID;
        evt.RepeatCountSessionID=objInfo.properties.RepeatCountSessionID;
        evt.StartTimeSessionID=objInfo.properties.StartTimeSessionID;

        publish('/SimBiology/object',evt);
    end

end

function sendReactionScopedParameterEvent(objects)

    template=struct('type','propertyChanged','model','','obj','',...
    'objType','','property','','value','','sessionIDs','',...
    'unresolved','','kineticlaw','','reversible','','reactionrate','');
    evt=repmat(template,1,numel(objects));
    count=0;

    for i=1:numel(objects)
        object=objects(i);
        parent=object.Parent;
        if isa(parent,'SimBiology.KineticLaw')
            count=count+1;
            reaction=parent.Parent;
            property='Reaction';
            objInfo=SimBiology.web.modelhandler('getComponentInfo',reaction);

            evt(count).type='propertyChanged';
            evt(count).model=SimBiology.web.modelhandler('getModelSessionID',object);
            evt(count).obj=reaction.SessionID;
            evt(count).objType=reaction.Type;
            evt(count).property=property;
            evt(count).value=get(reaction,property);
            evt(count).sessionIDs=objInfo.sessionIDs;
            evt(count).unresolved=objInfo.unresolved;
            evt(count).kineticlaw=objInfo.kineticlaw;
            evt(count).reversible=objInfo.reversible;
            evt(count).reactionrate=objInfo.reactionrate;
        end
    end

    if count>0
        evt=evt(1:count);
        publish('/SimBiology/object',evt);
    end

end

function propertyChanged(object,property,message)

    if strcmp(property,'Rule')&&isRepeatAssignment(object)
        repeatAssignmentChanged(object);
    elseif strcmp(property,'Rule')&&isInitialAssignment(object)
        initialAssignmentChanged(object);
    elseif strcmp(property,'Active')&&isRepeatAssignment(object)
        repeatAssignmentChanged(object);
    elseif strcmp(property,'Active')&&isInitialAssignment(object)
        initialAssignmentChanged(object);
    elseif strcmp(property,'RuleType')
        repeatAssignmentChanged(object);
        initialAssignmentChanged(object);
    elseif strcmp(property,'EventFcns')
        eventFcnChanged(object);
    elseif strcmp(property,'ParameterVariableNames')||strcmp(property,'SpeciesVariableNames')
        return;
    end

    evt.type='propertyChanged';
    evt.obj=object.SessionID;
    evt.objType=object.Type;
    evt.property=property;
    evt.value=get(object,property);

    if strcmpi(property,'content')
        evt.value=SimBiology.web.modelhandler('getVariantInfo',object);
        evt.value=evt.value.properties.Content;
    end

    if any(strcmpi(property,{'Rule','Trigger','EventFcns'}))
        objInfo=SimBiology.web.modelhandler('getComponentInfo',object);
        evt.sessionIDs=objInfo.sessionIDs;
        evt.unresolved=objInfo.unresolved;
    elseif strcmpi(property,'Reaction')

        objInfo=SimBiology.web.modelhandler('getComponentInfo',object);
        evt.sessionIDs=objInfo.sessionIDs;
        evt.unresolved=objInfo.unresolved;
        evt.kineticlaw=objInfo.kineticlaw;
        evt.reversible=objInfo.reversible;
        evt.reactionrate=objInfo.reactionrate;
    elseif strcmpi(property,'Reversible')

        objInfo=SimBiology.web.modelhandler('getComponentInfo',object);
        evt.sessionIDs=objInfo.sessionIDs;
        evt.unresolved=objInfo.unresolved;
        evt.kineticlaw=objInfo.kineticlaw;
        evt.reaction=objInfo.reaction;
        evt.reactionrate=objInfo.reactionrate;
    elseif strcmpi(property,'KineticLaw')

        objInfo=SimBiology.web.modelhandler('getComponentInfo',object);
        evt.sessionIDs=objInfo.sessionIDs;
        evt.unresolved=objInfo.unresolved;
        evt.kineticlaw=objInfo.kineticlaw;
        evt.reactionrate=objInfo.reactionrate;
    elseif strcmpi(property,'ReactionRate')

        objInfo=SimBiology.web.modelhandler('getComponentInfo',object);
        evt.sessionIDs=objInfo.sessionIDs;
        evt.unresolved=objInfo.unresolved;
        evt.kineticlaw=objInfo.kineticlaw;
    elseif any(strcmpi(property,{'TargetName','DurationParameterName','LagParameterName','Amount','Interval','Rate','RepeatCount','StartTime'}))
        if isempty(object.Parent)

            return;
        end
        objInfo=SimBiology.web.modelhandler('getComponentInfo',object);
        evt.TargetSessionID=objInfo.properties.TargetSessionID;
        evt.DurationParameterSessionID=objInfo.properties.DurationParameterSessionID;
        evt.LagParameterSessionID=objInfo.properties.LagParameterSessionID;
        evt.AmountSessionID=objInfo.properties.AmountSessionID;
        evt.IntervalSessionID=objInfo.properties.IntervalSessionID;
        evt.RateSessionID=objInfo.properties.RateSessionID;
        evt.RepeatCountSessionID=objInfo.properties.RepeatCountSessionID;
        evt.StartTimeSessionID=objInfo.properties.StartTimeSessionID;


        if(strcmpi(property,'TargetName')&&evt.TargetSessionID~=-1)
            evt.value=objInfo.properties.TargetName;
        end

    elseif any(strcmpi(property,{'Units','InitialAmountUnits','CapacityUnits','ValueUnits'}))
        try
            evt.validunits=object.isValidUnits(object.Units);
        catch

            evt.validunits=true;
        end
    elseif strcmpi(property,'amountunits')
        if isempty(evt.value)
            evt.validunits=true;
        else
            evt.validunits=SimBiology.internal.isValidAmountUnit(evt.value);
        end
    elseif strcmpi(property,'rateunits')
        if isempty(evt.value)
            evt.validunits=true;
        else
            evt.validunits=SimBiology.internal.isValidRateUnit(evt.value);
        end
    elseif strcmpi(property,'timeunits')
        if isempty(evt.value)
            evt.validunits=true;
        else
            evt.validunits=SimBiology.internal.isValidTimeUnit(evt.value);
        end
    elseif strcmp(property,'Value')
        if isnan(evt.value)
            evt.value='NaN';
        elseif isinf(evt.value)
            evt.value=num2str(evt.value);
        end
    elseif strcmp(property,'Owner')
        if isempty(evt.value)
            evt.value=-1;
        end
    end


    if isa(evt.value,'SimBiology.Object')
        if~isscalar(evt.value)

            return;
        end
        evt.value=evt.value.SessionID;
    end

    evt.model=SimBiology.web.modelhandler('getModelSessionID',object);

    if any(find(strcmp(evt.objType,{'species','compartment','parameter','observable'})))
        evt.pqn=object.PartiallyQualifiedNameReally;
    end



    if~isempty(evt.model)
        if strcmp(evt.objType,'reaction')
            handleReactionEvent(object,evt);
            publish('/SimBiology/object',evt);
        else
            publish('/SimBiology/object',evt);
        end


        evt.message=message;
        notifyDiagram('propertyChanged',evt,object);
    end

end

function handleReactionEvent(object,evt)

    if strcmp(evt.property,'Name')||strcmp(evt.property,'Reaction')
        klaw=object.KineticLaw;
        if~isempty(klaw)
            params=get(klaw,'Parameters');
            if~isempty(params)
                newevt.type='reactionscopechanged';
                newevt.objType=evt.objType;
                newevt.params=get(params,{'SessionID'});
                newevt.value=get(object,'Name');
                newevt.model=evt.model;

                publish('/SimBiology/object',newevt);
            end
        end
    end

end

function lhsChangedEvent(objArray,oldLHS,newLHS,message)




    if~isempty(objArray)
        if~any(strcmp(message,{'undo','redo'}))
            evt.obj=objArray;
            evt.oldLHS=oldLHS;
            evt.newLHS=newLHS;
            evt.model=objArray(1).Parent.SessionID;
            notifyDiagram('lhsChanged',evt,objArray);
        end
    end

    for i=1:numel(objArray)



        if isa(objArray(i),'SimBiology.Rule')
            initialAssignmentChanged(objArray(i));
            repeatAssignmentChanged(objArray(i));
        elseif isa(objArray(i),'SimBiology.Event')
            eventFcnChanged(objArray(i));
        end
    end

end

function configsetPropertyChanged(model,cs,object,property,eventMessage)

    assert(strcmp(cs.Name,'default'));


    csProperties={'StopTime','TimeUnits','SolverType','LogDecimation',...
    'StatesToLog','StatesToLogSet','DimensionalAnalysis',...
    'UnitConversion','OutputTimes','MaximumNumberOfLogs','MaximumWallClock'};
    if~ismember(property,csProperties)
        return;
    end

    evt.type='configsetPropertyChanged';
    evt.property=property;
    evt.value=get(object,property);
    evt.model=model.SessionID;
    evt.sessionID=model.SessionID;

    if strcmp(property,'SolverType')&&any(strcmp(cs.SolverType,{'ssa','expltau','impltau'}))


        evt.logDecimation=cs.SolverOptions.LogDecimation;
    end

    if ismember(property,{'MaximumNumberOfLogs','MaximumWallClock'})

        evt.value=num2str(evt.value);
    end

    if strcmp(property,'StatesToLog')
        evt.value=get(evt.value,{'SessionID'});
        evt.StatesToLogAll=~get(object,'StatesToLogSet');
    end

    publish('/SimBiology/object',evt);

end

function inUseCount(object,count)

    evt.type='propertyChanged';
    evt.obj=object.SessionID;
    evt.objType=object.Type;
    evt.property='UsedInModel';
    evt.value=(count>=1);
    evt.model=SimBiology.web.modelhandler('getModelSessionID',object);

    publish('/SimBiology/object',evt);

end

function duplicateNameStatus(object,hasDuplicateName)

    evt.type='propertyChanged';
    evt.obj=object.SessionID;
    evt.objType=object.Type;
    evt.property='HasDuplicateName';
    evt.value=hasDuplicateName;
    evt.model=SimBiology.web.modelhandler('getModelSessionID',object);

    publish('/SimBiology/object',evt);

end

function expressionStatus(objs,statuses,updateStatus,message)

    for i=1:numel(objs)
        obj=objs{i};
        status=statuses{i};
        evt.type='expressionStatusChanged';
        evt.sessionID=obj.SessionID;
        evt.objType=obj.Type;
        evt.model=SimBiology.web.modelhandler('getModelSessionID',obj);
        evt.info=SimBiology.web.modelhandler('getComponentInfo',obj);
        evt.status=status;
        evt.updateStatus=updateStatus;

        publish('/SimBiology/expressionStatus',evt);









        if updateStatus

            evt.message=message;
            notifyDiagram('expressionStatusChanged',evt,obj);
        end
    end

end

function equationsChanged(model)

    evt.type='equationsChanged';
    evt.model=model.SessionID;

    publish('/SimBiology/equationsChanged',evt);

end

function objectMoved(obj,eventMessage)

    evt.type='objectMoved';
    evt.sessionID=obj.SessionID;
    evt.objType=obj.Type;
    evt.model=SimBiology.web.modelhandler('getModelSessionID',obj);
    evt.info=SimBiology.web.modelhandler('getComponentInfo',obj);
    evt.message=eventMessage;
    model=SimBiology.web.modelhandler('getModelFromSessionID',evt.model);

    switch lower(evt.objType)
    case 'species'
        allObjs=SimBiology.web.modelhandler('getModelSpecies',model);
    case 'parameter'
        allObjs=SimBiology.web.modelhandler('getModelParameters',model);
    otherwise
        allObjs=get(model,evt.objType);
    end

    evt.sessionIDs=[allObjs.SessionID];

    publish('/SimBiology/object',evt);

    notifyDiagram('objectMoved',evt,obj);

end

function runprogram(stepID,running)

    evt.type='programRun';
    evt.stepID=stepID;
    evt.running=running;

    publish('/SimBiology/programRun',evt);

end

function incrementScanRun()





    evt.type='incrementScanRun';
    publish('/SimBiology/incrementScanRun',evt);
    drawnow;

end

function incrementFitRun(value)%#ok<DEFNU>

    evt.type='incrementFitRun';
    evt.run=value;
    publish('/SimBiology/incrementFitRun',evt);

end

function postMessage(messageStruct)














    template=struct('type','stackedMessage','sessionID','','objType','','modelSessionID','',...
    'source','','message','','id','','isError','','force',false);

    evt=repmat(template,1,numel(messageStruct));

    for i=1:numel(messageStruct)
        evt(i).source=messageStruct(i).source;
        evt(i).message=SimBiology.web.internal.errortranslator(messageStruct(i).messageID,messageStruct(i).message);
        evt(i).id=messageStruct(i).messageID;
        evt(i).isError=messageStruct(i).isError;

        if~isempty(messageStruct(i).component)
            evt(i).sessionID=messageStruct(i).component.SessionID;
            evt(i).objType=messageStruct(i).component.Type;
            evt(i).modelSessionID=messageStruct(i).component.ParentModelSessionID;
        else
            messageStruct(i).sessionID=-1;
            messageStruct(i).objType=-1;
            messageStruct(i).modelSessionID=-1;
        end

        if isfield(messageStruct(i),'force')
            evt(i).force=messageStruct(i).force;
        end
    end

    publish('/SimBiology/stackedMessage',evt);

end

function postWarning(warningID,varargin)
    messageStruct=struct('component',[],'source',-1,...
    'message',getString(message(warningID,varargin{:})),...
    'messageID',warningID,'isError',false);
    postMessage(messageStruct);


end

function undoStatusChanged(model,hasUndo,hasRedo)

    evt.type='undoStatusChanged';
    evt.model=model.SessionID;
    evt.undoState=hasUndo;
    evt.redoState=hasRedo;

    publish('/SimBiology/object',evt);

end

function transactionFocusChanged(model,focus)

    evt.type='undoFocusChanged';
    evt.model=model.SessionID;
    evt.focus=focus;

    publish('/SimBiology/object',evt);

end

function undoInDiagram(modelSessionID,sessionIDs,isVisible)

    evt.type='undoFocusChanged';
    evt.model=modelSessionID;
    evt.focus='diagram';
    evt.sessionIDs=sessionIDs;
    evt.isVisible=isVisible;

    publish('/SimBiology/object',evt);

end

function publish(channel,evt)

    message.publish(channel,evt);

end

function isAvailable=messageServiceAvailable

    if isdeployed

        isAvailable=false;
    else
        try

            isAvailable=~parallel.internal.pool.isPoolWorker();
        catch



            isAvailable=true;
        end
    end

end

function notifyDiagram(evtType,evt,obj)

    if isempty(obj)
        assert(isfield(evt,'model'));
        model=SimBiology.web.modelhandler('getModelFromSessionID',evt.model);
    else
        model=getModel(obj(1));
    end


    if model.hasDiagramSyntax
        SimBiology.web.diagram.eventhandler(evtType,evt,model);
    end

end

function model=getModel(obj)

    if isa(obj,'SimBiology.Model')
        model=obj;
    else
        model=getModel(obj.Parent);
    end
end
