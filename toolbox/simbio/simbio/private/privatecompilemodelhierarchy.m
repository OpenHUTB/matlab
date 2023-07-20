function[cmodel,cdata]=privatecompilemodelhierarchy(model,cdata,doses)


































































    if~exist('cdata','var')
        cdata=[];
    end
    if~exist('doses','var')
        doses=[];
    end
    [cmodel,cdata]=localCompileModel(model,cdata,doses);
end


function[cmodel,cdata]=localCompileModel(model,cdata,doses)












    [MCOsp,MCOpa,compartmentObjs]=model.findSpeciesAndParametersInCompileOrder();

    isParamConstant=vertcat(MCOpa.ConstantValue);
    cmodel.parameters=MCOpa(isParamConstant);
    stateVariables=cat(1,MCOsp,MCOpa(~isParamConstant));


    isCompConst=vertcat(compartmentObjs.ConstantCapacity);
    cmodel.parameters=cat(1,cmodel.parameters,compartmentObjs(isCompConst));
    stateVariables=cat(1,stateVariables,compartmentObjs(~isCompConst));


    cmodel.constantX=localfind(model.Species,'ConstantAmount',true);






    freeVariables=localSetDiff(stateVariables,cmodel.constantX);


    [cmodel.Stoich,...
    cmodel.reactionX,...
    cmodel.activeReactions,...
    cmodel.inactiveReactions,cdata]=localGetReactionSystem(model,MCOsp,cdata);


    freeVariables=localSetDiff(freeVariables,cmodel.reactionX);


    [cmodel.rateX,...
    cmodel.speciesRateX,...
    cmodel.activeRateRules,...
    cmodel.inactiveRateRules,...
    freeVariables]=localGetRateRules(model,freeVariables);



    eventLHS=getListOfLHSForEventFunctions(model);
    [cmodel.activeInitialAssignRules,cmodel.activeRepeatedAssignRules,...
    cmodel.repeatedX,cmodel.initialX,freeVariables]=localGetAssignmentRules(model,freeVariables,eventLHS);


    [cmodel.algebraicX,...
    cmodel.activeAlgRules,...
    cmodel.inactiveAlgRules,...
    freeVariables]=localGetAlgebraicRules(model,freeVariables);










    [cmodel.doseRateX,cmodel.rateDoseObjects,freeVariables]=localGetRateDoses(doses,cmodel.reactionX,freeVariables,model);



    if~isempty(freeVariables)

        cmodel.constantX=[cmodel.constantX;freeVariables];
    end


    cmodel.activeEvents=localfind(model.Events,'Active',true);
    cmodel.inactiveEvents=localfind(model.Events,'Active',false);


    cmodel.activeDoses=doses;


    cmodel=orderfields(cmodel,{...
    'reactionX';...
    'rateX';...
    'speciesRateX';...
    'algebraicX';...
    'constantX';...
    'repeatedX';...
    'initialX';...
    'parameters';...
    'Stoich';...
    'activeReactions';...
    'activeRateRules';...
    'activeAlgRules';...
    'activeInitialAssignRules';...
    'activeRepeatedAssignRules';...
    'activeEvents';...
    'activeDoses';...
    'inactiveReactions';...
    'inactiveRateRules';...
    'inactiveAlgRules';...
    'inactiveEvents';...
    'rateDoseObjects';...
    'doseRateX'});

end


function[Stoich,reactionX,activeReacts,inactiveReacts,cdata]=localGetReactionSystem(model,species,cdata)





    if isempty(model.Reactions)||isempty(species)
        Stoich=[];
        reactionX=SimBiology.Species.empty(0,1);
        activeReacts=SimBiology.Reaction.empty(0,1);
        inactiveReacts=model.Reactions;
        return
    end



    Stoich=model.getstoichmatrix();


    constflags=vertcat(species.ConstantAmount);
    bcflags=vertcat(species.BoundaryCondition);
    resysflags=~constflags&~bcflags;
    activeflags=vertcat(model.Reactions.Active);

    Stoich=Stoich(resysflags,activeflags);
    reactionX=species(resysflags);
    activeReacts=model.Reactions(activeflags);




    nzrows=any(Stoich,2);
    nzcols=any(Stoich,1).';

    Stoich=Stoich(nzrows,nzcols);
    reactionX=reactionX(nzrows);


    activeReacts=activeReacts(nzcols);
    if~isempty(cdata)
        cdata.reactionDimExplicitlySpecifiedAndValid=cdata.reactionDimExplicitlySpecifiedAndValid(nzcols);
        cdata.reactionIsPerUnitLengthX=cdata.reactionIsPerUnitLengthX(nzcols);
    end
    inactiveReacts=localSetDiff(model.Reactions,activeReacts);

end


function[ruleX,speciesRateX,activeRateRules,inactiveRateRules,freeVariables]...
    =localGetRateRules(model,freeVariables)

    activeRateRules=localfind(model.Rules,'RuleType','Rate','Active',1);
    inactiveRateRules=localfind(model.Rules,'RuleType','Rate','Active',0);

    speciesRateX=SimBiology.ModelComponent.empty;

    ruleX=SimBiology.ModelComponent.empty;

    for j=1:length(activeRateRules)

        [lhsobj,lhstok]=localGetLHSOfRateOrAssignmentRule(activeRateRules(j));


        [tf,loc]=ismember(lhsobj,freeVariables);
        if tf
            if strcmp('species',lhsobj.Type)

                speciesRateX(end+1,1)=lhsobj;%#ok<AGROW>
            else

                ruleX(end+1,1)=lhsobj;%#ok<AGROW>
            end

            freeVariables(loc,:)=[];
        else
            error(message('SimBiology:odebuilder:INVALID_RULEVARIABLE',...
            lhstok,localGetRuleString(activeRateRules(j))));
        end
    end
end


function[algebraicX,activeAlgRules,inactiveAlgRules,freeVariables]...
    =localGetAlgebraicRules(model,freeVariables)



    activeAlgRules=localfind(model.Rules,'RuleType','Algebraic','Active',1);
    inactiveAlgRules=localfind(model.Rules,'RuleType','Algebraic','Active',0);
    algebraicX=SimBiology.ModelComponent.empty;

    if isempty(activeAlgRules)

        return
    end

    freeVariableUUIDs=get(freeVariables,{'UUID'});
    freeVariablePQNs=get(freeVariables,{'PartiallyQualifiedName'});

    tfUsedInAlgebraics=false(size(freeVariables));



    ruleVarGraph=sparse(numel(activeAlgRules),numel(freeVariables));

    for iRule=1:numel(activeAlgRules)

        parsevars=activeAlgRules(iRule).parserule;
        parsevars=SimBiology.internal.removeReservedTokens(parsevars);


        for iVar=1:numel(parsevars)
            obj=activeAlgRules(iRule).resolveobject(parsevars{iVar});
            if~isempty(obj)
                parsevars{iVar}=obj.UUID;
            else
                error(message('SimBiology:Internal:InternalError'));
            end
        end

        if isempty(parsevars)
            error(message('SimBiology:odebuilder:INVALID_ALGEBRAICRULE_NO_VARIABLES',...
            localGetRuleString(activeAlgRules(iRule))));
        end


        [tf,iVar]=ismember(parsevars,freeVariableUUIDs);
        if any(tf)

            ruleVarGraph(iRule,iVar(tf))=1;%#ok<SPRIX>

            tfUsedInAlgebraics(iVar(tf))=true;
        else
            error(message('SimBiology:odebuilder:INVALID_ALGEBRAICRULE_NO_FREE_VARIABLES',...
            localGetRuleString(activeAlgRules(iRule))));
        end
    end

    [p,q,~,~,cc,rr]=dmperm(ruleVarGraph(:,tfUsedInAlgebraics));

    iRuleUnder=sort(p(rr(1):rr(2)-1));
    iRuleWell=sort(p(rr(2):rr(3)-1));
    iRuleOver=sort(p(rr(3):rr(5)-1));


    usedIdxToAllIdx=find(tfUsedInAlgebraics);
    iVarUnder=sort(usedIdxToAllIdx(q(cc(1):cc(3)-1)));
    iVarWell=sort(usedIdxToAllIdx(q(cc(3):cc(4)-1)));
    iVarOver=sort(usedIdxToAllIdx(q(cc(4):cc(5)-1)));
    if~isempty(iVarOver)
        nRuleOver=numel(iRuleOver);
        ruleList=cell(nRuleOver,1);
        for i=1:nRuleOver
            ruleList{i}=localGetRuleString(activeAlgRules(iRuleOver(i)));
        end
        ruleString=SimBiology.internal.getCommaSeparatedStringFromCellstr(ruleList,'''%s''');
        varString=SimBiology.internal.getCommaSeparatedStringFromCellstr(freeVariablePQNs(iVarOver));
        error(message('SimBiology:odebuilder:OVERDETERMINED_ALGEBRAIC_SYSTEM',...
        ruleString,varString));
    end
    if~isempty(iVarUnder)

        nRuleUnder=numel(iRuleUnder);
        iConstrained=iVarUnder(1:nRuleUnder);
        iConstant=iVarUnder(nRuleUnder+1:end);
        ruleList=cell(nRuleUnder,1);
        for i=1:nRuleUnder
            ruleList{i}=localGetRuleString(activeAlgRules(iRuleUnder(i)));
        end
        ruleString=SimBiology.internal.getCommaSeparatedStringFromCellstr(ruleList,'''%s''');
        varString=SimBiology.internal.getCommaSeparatedStringFromCellstr(freeVariablePQNs(iVarUnder));
        constVarString=SimBiology.internal.getCommaSeparatedStringFromCellstr(freeVariablePQNs(iConstant));
        localStackedWarning(message('SimBiology:odebuilder:UNDERDETERMINED_ALGEBRAIC_SYSTEM',...
        ruleString,varString,constVarString));
        algebraicX(iRuleUnder,1)=freeVariables(iConstrained);
        algebraicX(iRuleWell,1)=freeVariables(iVarWell);


        freeVariables([iVarWell;iConstrained])=[];
    else
        algebraicX(iRuleWell,1)=freeVariables(iVarWell);
        freeVariables(iVarWell)=[];
    end
end







function[doseRateX,rateDoseObjects,freeVariables]=localGetRateDoses(doses,reactionSystemVariables,freeVariables,model)
    freeVariableUUIDs=get(freeVariables,{'UUID'});
    reactionSystemUUIDs=get(reactionSystemVariables,{'UUID'});

    doseRateX=SimBiology.ModelComponent.empty;
    rateDoseObjects=SimBiology.ModelComponent.empty;

    for j=1:length(doses)

        targetObject=doses(j).resolvetarget(model);
        if~ismember(targetObject.UUID,[freeVariableUUIDs;reactionSystemUUIDs])
            error(message('SimBiology:odebuilder:INVALID_DOSETARGET',...
            targetObject.Name,doses(j).Name));
        elseif ischar(doses(j).Rate)||any(doses(j).Rate>0)


            rateDoseObjects=cat(1,rateDoseObjects,doses(j));


            [~,index]=ismember(targetObject.UUID,freeVariableUUIDs);


            if index~=0&&~any(doseRateX==targetObject)
                doseRateX=cat(1,doseRateX,targetObject);
                freeVariables(index)=[];
            end
        end

        if isa(doses(j),'SimBiology.RepeatDose')


            propsToCheck={'LagParameterName','DurationParameterName','Amount','Interval','StartTime','RepeatCount','Rate'};
            for k=1:numel(propsToCheck)
                thisProp=propsToCheck{k};
                thisValue=doses(j).(thisProp);
                if~ischar(thisValue)
                    continue
                end
                thisParamObj=doses(j).resolveparameter(model,thisValue);
                if isempty(thisParamObj)
                    continue
                end
                if~isConstant(thisParamObj)&&~ismember(thisParamObj.UUID,freeVariableUUIDs)
                    error(message('SimBiology:odebuilder:INVALID_DOSEPARAMETER',...
                    thisProp,targetObject.Name,doses(j).Name));
                end
            end
        end

    end
end


function eventLHS=getListOfLHSForEventFunctions(model)
    eventLHS=SimBiology.ModelComponent.empty;
    activeEvents=localfind(model.Events,'Active',true);
    for i=1:length(activeEvents)
        eventObj=activeEvents(i);
        lhsTokens=eventObj.parseeventfcns;
        for j=1:length(lhsTokens)
            eventLHS=cat(1,eventLHS,eventObj.resolveobject(lhsTokens{j}{1}));
        end
    end
end


function[activeInitialRules,activeRepeatedRules,repeatedX,initialX,freeVariables]=localGetAssignmentRules(model,freeVariables,eventLHS)

    activeInitialRules=localfind(model.Rules,'RuleType','initialAssignment','Active',1);
    activeRepeatedRules=localfind(model.Rules,'RuleType','repeatedAssignment','Active',1);


    map=SimBiology.internal.ComponentMap;



    initialXCell=cell(length(activeInitialRules),1);
    for i=1:length(activeInitialRules)

        [lhsobj,lhstok]=localGetLHSOfRateOrAssignmentRule(activeInitialRules(i));
        if~map.isKey(lhsobj)
            map.insert(lhsobj,true);
        else

            error(message('SimBiology:odebuilder:INVALID_RULE',...
            'initialAssignment',localGetRuleString(activeInitialRules(i)),lhstok));
        end
        initialXCell{i}=lhsobj;
    end
    initialX=vertcat(SimBiology.ModelComponent.empty(0,1),initialXCell{:});



    repeatedX=SimBiology.ModelComponent.empty;
    for i=1:length(activeRepeatedRules)

        [lhsobj,lhstok]=localGetLHSOfRateOrAssignmentRule(activeRepeatedRules(i));
        if~isKey(map,lhsobj)
            map.insert(lhsobj,true);
        else

            error(message('SimBiology:odebuilder:INVALID_RULE',...
            'repeatedAssignment',localGetRuleString(activeRepeatedRules(i)),lhstok));
        end

        tf=ismember(freeVariables,lhsobj);
        j=find(tf,1);

        if~isempty(j)




            if any(find(freeVariables(j)==eventLHS))
                error(message('SimBiology:odebuilder:INVALID_RULE_AND_EVENT',...
                localGetRuleString(activeRepeatedRules(i)),lhstok));
            end

            repeatedX=cat(1,repeatedX,freeVariables(j));
            freeVariables(j)=[];
        else




            error(message('SimBiology:odebuilder:INVALID_REPEATEDASSIGNRULE',...
            localGetRuleString(activeRepeatedRules(i)),lhstok));
        end
    end
end





function[lhsobj,lhstok]=localGetLHSOfRateOrAssignmentRule(robj)




    lhstok=robj.parserule;

    if numel(lhstok)~=1
        switch robj.ruletype
        case 'rate'
            emsg=message('SimBiology:odebuilder:INVALID_RATERULE',localGetRuleString(robj));
        case 'assignment'
            emsg=message('SimBiology:odebuilder:INVALID_ASSIGNMENTRULE',localGetRuleString(robj));
        otherwise
            error(message('SimBiology:Internal:InternalError'));
        end
        error(emsg);
    end

    lhstok=lhstok{1};

    if SimBiology.internal.isReservedToken(lhstok)
        error(message('SimBiology:odebuilder:INVALID_RULEVARIABLE2',...
        lhstok,robj.RuleType,localGetRuleString(robj),lhstok));
    end

    lhsobj=robj.resolveobject(lhstok);

    if isempty(lhsobj)
        error(message('SimBiology:odebuilder:INVALID_RULEVARIABLE3',...
        lhstok,robj.RuleType,localGetRuleString(robj)));
    end


    lhstok=get(lhsobj,'PartiallyQualifiedName');

end


function D=localSetDiff(A,B)






    tf=ismember(A,B);
    D=A(~tf);

end


function str=localGetRuleString(robj)

    if~isempty(robj.Name)
        str=robj.Name;
    else
        str=robj.Rule;
    end

end




function ret=localfind(obj,varargin)
    ret=[];
    if~isempty(obj)
        ret=findobj(obj,varargin{:});
    end
end


function localStackedWarning(messageObj)
    privatemessagecalls('addwarning',...
    {getString(messageObj),...
    messageObj.Identifier,...
    'ODE Compilation',...
    [],...
    });
end


function localWarnAboutFreeVariables(freeVariables,eventLHS)%#ok<DEFNU>

    vars=setdiff(freeVariables,eventLHS);
    if isempty(vars)

        return
    end
    varNames=get(vars,{'PartiallyQualifiedName'});
    varString=SimBiology.internal.getCommaSeparatedStringFromCellstr(varNames);
    localStackedWarning(message('SimBiology:odebuilder:UNCONSTRAINED_NONCONSTANT_OBJECTS',varString));
end

function tf=isConstant(obj)
    if isa(obj,'SimBiology.Parameter')
        tf=obj.ConstantValue;
    else
        assert(isa(obj,'SimBiology.Species'));
        tf=obj.ConstantAmount;
    end
end
