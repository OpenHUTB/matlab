function out=equationshandler(action,varargin)











    out={action};

    switch(action)
    case 'getInitialConditions'
        out=getInitialConditions(varargin{:});
    case 'getODEs'
        out=getODEs(varargin{:});
    case 'getInitialConditionsAndODEs'
        out=getInitialConditionsAndODEs(varargin{:});
    end

end

function out=getInitialConditions(input)


    warnState=warning('off');
    cleanup=onCleanup(@()warning(warnState));


    out.modelSessionID=input.sessionID;
    out.sessionID=[];
    out.values=[];
    out.targets=[];
    out.doseValues=[];
    out.icMessage='';
    out.hasIC=true;
    out.hasODEs=false;
    out.isnan=[];

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.sessionID);
    cs=getconfigset(model,'default');

    if isa(input.variants,'SimBiology.Variant')
        vobj=input.variants;
    else
        vobj=cell(1,length(input.variants));
        for i=1:length(input.variants)
            vobj{i}=sbioselect(getvariant(model),'SessionID',input.variants(i));
        end
        vobj=[vobj{:}];
    end

    if isa(input.doses,'SimBiology.Dose')
        dobj=input.doses;
    else
        dobj=cell(1,length(input.doses));
        for i=1:length(input.doses)
            dobj{i}=sbioselect(getdose(model),'SessionID',input.doses(i));
        end

        dobj=[dobj{:}];
    end


    if isfield(input,'doseInfo')&&~isempty(input.doseInfo)
        doseInfo=input.doseInfo.doses;
        dosesToConstruct={};
        for i=1:length(doseInfo)
            if iscell(doseInfo)
                next=doseInfo{i};
            else
                next=doseInfo(i);
            end

            if strcmp(next.type,'data')&&next.use
                dosesToConstruct{end+1}=next;%#ok<AGROW>
            end
        end

        if~isempty(dosesToConstruct)
            additionalDoses=SimBiology.web.codegenerationutil('constructDosesFromData',dosesToConstruct);
            dobj=horzcat(dobj,additionalDoses);
        end
    end

    try
        SimBiology.internal.verifyHelper(model,cs,dobj,"RequireObservableDependencies",false);
        [objs,values,targets,doseValues,algebraicComponents]=SimBiology.internal.getModifiedInitialValues(model,cs,vobj,dobj);
        if~isempty(objs)
            out.sessionID=get(objs,{'SessionID'});
            out.sessionID=[out.sessionID{:}];
            out.values=values;
            out.isnan=isnan(values);
            out.values=num2cell(values);
        end

        if~isempty(algebraicComponents)
            sessionID=get(algebraicComponents,{'SessionID'});
            sessionID=[sessionID{:}];
            values=repmat({''},numel(sessionID),1);
            out.sessionID=horzcat(out.sessionID,sessionID);
            out.values=vertcat(out.values,values);
            out.isnan=vertcat(out.isnan,false(numel(sessionID),1));
        end

        if~isempty(targets)
            out.targets=get(targets,{'SessionID'});
            out.targets=[out.targets{:}];
            out.doseValues=doseValues;
        end
    catch ex %#ok<*NASGU>
        out.icMessage=SimBiology.web.internal.errortranslator(ex);
    end

end

function out=getODEs(input)


    warnState=warning('off');
    cleanup=onCleanup(@()warning(warnState));

    embedFluxes=input.embedFluxes;
    odes='';
    fluxes='';
    repeatAssignments='';
    odeMessage='';
    out.hasIC=false;
    out.hasODEs=true;

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.sessionID);
    cs=getconfigset(model,'default');
    vobj=cell(1,length(input.variants));
    dobj=cell(1,length(input.doses));

    for i=1:length(input.variants)
        vobj{i}=sbioselect(getvariant(model),'SessionID',input.variants(i));
    end

    for i=1:length(input.doses)
        dobj{i}=sbioselect(getdose(model),'SessionID',input.doses(i));
    end

    vobj=[vobj{:}];
    dobj=[dobj{:}];

    try
        [h,repeatAssignments]=SimBiology.internal.Equations.genEquations(model,cs,vobj,dobj,'EmbedFlux',embedFluxes,'WarnIfInitialConditionSetByAlgebraicRule',false);
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
    catch ex
        odeMessage=SimBiology.web.internal.errortranslator(ex);
    end

    out.odes=odes;
    out.fluxes=fluxes;
    out.odeMessage=odeMessage;

    if~isempty(repeatAssignments)
        out.repeatedAssignments=get(repeatAssignments,{'SessionID'});
    else
        out.repeatedAssignments='';
    end

end

function out=getInitialConditionsAndODEs(input)

    out=getInitialConditions(input);
    out2=getODEs(input);
    names=fieldnames(out2);

    for i=1:length(names)
        out.(names{i})=out2.(names{i});
    end

    out.hasIC=true;
    out.hasODEs=true;
end
