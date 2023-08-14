function out=changescopehandler(action,varargin)











    out=[];

    switch(action)
    case 'changeScope'
        out=changeScope(varargin{:});
    case 'forceChangeParameterScope'
        forceChangeParameterScope(varargin{:});
    case 'changeScopeList'
        changeScopeList(varargin{:});
    end

end

function changeScopeList(input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
    target=sbioselect(model,'SessionID',input.targetSessionID);
    transaction=SimBiology.Transaction.create(model);

    for i=1:numel(input.sessionIDs)
        obj=sbioselect(model,'SessionID',input.sessionIDs(i));
        forceMove(obj,target);
    end

    transaction.commit;

end

function out=changeScope(input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
    obj=sbioselect(model,'SessionID',input.sessionID);
    out=struct;
    out.msg='';

    switch(obj.type)
    case{'compartment','species'}
        transaction=SimBiology.Transaction.create(model);
        scope=sbioselect(model,'SessionID',input.scopeSessionID);
        forceMove(obj,scope);
        transaction.commit;
    case 'parameter'
        if isa(obj.Parent,'SimBiology.KineticLaw')
            out=changeScopeFromReactionToModel(obj,model);
        else
            out=changeScopeFromModelToReaction(obj,model);
        end
    end

end

function out=changeScopeFromReactionToModel(param,model)

    out.msg='';
    out.forceAction='';


    paramsAtModelLevel=sbioselect(model,'Type','parameter','Name',param.Name,'depth',1);

    if~isempty(paramsAtModelLevel)
        out.msg=sprintf('A parameter with name ''%s'' already exists with the model. Changing scope will remove the parameter from the kinetic law, but not add a new parameter to the model. Do you want to continue?',param.Name);
        out.forceAction='Remove';
    else
        transaction=SimBiology.Transaction.create(model);
        forceMove(param,model);
        transaction.commit;
    end

end

function out=changeScopeFromModelToReaction(param,model)

    out=struct;
    out.msg='';
    out.forceAction='';


    reactionUsages=sbioselect(findUsages(param),'Type','reaction');

    if isempty(reactionUsages)
        out.msg='The scope could not be changed because the parameter is not used in any reactions.';
        return;
    end


    if isParameterUsedInRulesOrEvents(param)
        out.msg=sprintf('Parameter ''%s'' is used in rules and/or events, in addition to reactions. Changing scope may invalidate some rules or events. Do you want to continue?',param.Name);
        out.forceAction='Continue';
        return;
    end



    transaction=SimBiology.Transaction.create(model);
    changeScopeFromModelToReactionHelper(param,reactionUsages);
    transaction.commit;

end

function forceChangeParameterScope(input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
    param=sbioselect(model,'SessionID',input.sessionID);
    forceAction=input.forceAction;
    transaction=SimBiology.Transaction.create(model);

    if strcmp(forceAction,'Remove')




        command=SimBiology.web.codecapturehandler('creatDeleteObjectCommand',param);
        SimBiology.web.codecapturehandler('postObjectDeletedEvent',model.SessionID,{command});

        delete(param);
    elseif strcmp(forceAction,'Continue')




        reactionUsages=sbioselect(findUsages(param),'Type','reaction');
        changeScopeFromModelToReactionHelper(param,reactionUsages);
    end

    transaction.commit;

end

function changeScopeFromModelToReactionHelper(param,reactionUsages)



    parameterName=param.Name;
    modelSessionID=-1;
    commands={};

    if~isempty(reactionUsages)
        modelSessionID=reactionUsages(1).Parent.SessionID;
        forceMove(param,reactionUsages(1));
    end

    for i=2:length(reactionUsages)
        reaction=reactionUsages(i);
        kineticLaw=reaction.KineticLaw;

        if isempty(kineticLaw)
            kineticLaw=addkineticlaw(reaction,'Unknown');
            commands{end+1}=SimBiology.web.codecapturehandler('createConfigureObjectCommand',reaction,'AddKineticLaw','Unknown');%#ok<AGROW>
        end

        matches=sbioselect(kineticLaw.Parameters,'Name',parameterName);
        if isempty(matches)
            copyobj(param,kineticLaw);
            commands{end+1}=SimBiology.web.codecapturehandler('createCopyObjCommand',modelSessionID,param,reaction);%#ok<AGROW>
        end
    end

    if~isempty(commands)
        SimBiology.web.codecapturehandler('postCodeCaptureEvent',modelSessionID,commands);
    end

end

function result=isParameterUsedInRulesOrEvents(param)

    usages=findUsages(param);

    if~isempty(sbioselect(usages,'Type','rule'))
        result=true;
    elseif~isempty(sbioselect(usages,'Type','event'))
        result=true;
    else
        result=false;
    end

end

function forceMove(obj,newParent)

    forceMove=~isa(obj,'SimBiology.Compartment');
    if forceMove
        move(obj,newParent,'force');
    else
        move(obj,newParent);
    end

    SimBiology.web.codecapturehandler('postObjectMovedEvent',newParent,obj,forceMove);
end
