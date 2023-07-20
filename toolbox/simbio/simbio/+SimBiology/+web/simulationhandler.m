function out=simulationhandler(action,varargin)











    out={action};

    switch(action)
    case 'getConfigsetInfo'
        out=getConfigsetInfo(action,varargin{:});
    case 'configureConfigsetProperty'
        out=configureConfigsetProperty(action,varargin{:});
    case 'getStateInfo'
        out=getStateInfo(action,varargin{:});
    case 'verifyOutputTimes'
        out=verifyOutputTimes(action,varargin{:});
    end

end

function out=getStateInfo(action,input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.model);
    input.model=model;
    input.cs=getconfigset(model,'default');

    info.RuntimeOptions.StatesToLog=getStatesToLog(input);

    out={action,info};

end

function out=getConfigsetInfo(action,input)

    model=SimBiology.web.modelhandler('getModelFromSessionID',input.model);
    cs=getconfigset(model,'default');


    info.SolverType=cs.SolverType;


    info.StopTime=num2str(cs.StopTime);
    info.TimeUnits=cs.TimeUnits;
    info.MaximumNumberOfLogs=num2str(cs.MaximumNumberOfLogs);
    info.MaximumWallClock=num2str(cs.MaximumWallClock);


    info=getSolverInfo(info,cs);


    info.CompileOptions.DimensionalAnalysis=cs.CompileOptions.DimensionalAnalysis;
    info.CompileOptions.UnitConversion=cs.CompileOptions.UnitConversion;
    info.CompileOptions.DefaultSpeciesDimension=cs.CompileOptions.DefaultSpeciesDimension;


    input.model=model;
    input.cs=cs;

    info.RuntimeOptions.StatesToLog=getStatesToLog(input);

    out={action,info};

end

function info=getSolverInfo(info,cs)

    solverType=cs.SolverType;

    switch(solverType)
    case 'ssa'
        info.SolverOptions.RandomState=cs.SolverOptions.RandomState;
        info.SolverOptions.LogDecimation=cs.SolverOptions.LogDecimation;

        if isempty(cs.SolverOptions.RandomState)
            info.SolverOptions.RandomState='[]';
        end
    case 'expltau'
        info.SolverOptions.RandomState=cs.SolverOptions.RandomState;
        info.SolverOptions.ErrorTolerance=cs.SolverOptions.ErrorTolerance;
        info.SolverOptions.LogDecimation=cs.SolverOptions.LogDecimation;

        if isempty(cs.SolverOptions.RandomState)
            info.SolverOptions.RandomState='[]';
        end
    case 'impltau'
        info.SolverOptions.AbsoluteTolerance=cs.SolverOptions.AbsoluteTolerance;
        info.SolverOptions.RandomState=cs.SolverOptions.RandomState;
        info.SolverOptions.ErrorTolerance=cs.SolverOptions.ErrorTolerance;
        info.SolverOptions.MaxIterations=cs.SolverOptions.MaxIterations;
        info.SolverOptions.LogDecimation=cs.SolverOptions.LogDecimation;

        if isempty(cs.SolverOptions.RandomState)
            info.SolverOptions.RandomState='[]';
        end
    case{'ode45','ode15s','ode23t','sundials'}
        info.SolverOptions.AbsoluteToleranceScaling=cs.SolverOptions.AbsoluteToleranceScaling;
        info.SolverOptions.AbsoluteToleranceStepSize=cs.SolverOptions.AbsoluteToleranceStepSize;
        info.SolverOptions.AbsoluteTolerance=cs.SolverOptions.AbsoluteTolerance;
        info.SolverOptions.RelativeTolerance=cs.SolverOptions.RelativeTolerance;
        info.SolverOptions.MaxStep=cs.SolverOptions.MaxStep;
        info.SolverOptions.OutputTimes=cs.SolverOptions.OutputTimes;

        if isempty(cs.SolverOptions.MaxStep)
            info.SolverOptions.MaxStep='[]';
        elseif isinf(cs.SolverOptions.MaxStep)
            info.SolverOptions.MaxStep=sprintf('%d',cs.SolverOptions.MaxStep);
        end

        if isempty(cs.SolverOptions.AbsoluteToleranceStepSize)
            info.SolverOptions.AbsoluteToleranceStepSize='[]';
        end
    end

end

function out=verifyOutputTimes(action,outputTimes)


    info=struct('isError',false,'value','[]','maxOutputTime',NaN);


    simOpts=SimBiology.internal.SimulationOptions;
    try


        simOpts.OutputTimes=eval(['[',outputTimes,']']);

        info.outputTimes=simOpts.OutputTimes;
    catch
        info.isError=true;
    end

    out.action=action;
    out.info=info;
end

function info=getStatesToLog(input)

    allStates=input.allStates;
    if ischar(allStates)
        allStates=strcmp(allStates,'true');
    end


    states=getstates(input.model);
    if~allStates
        states=filterConstantParametersCompartments(states);
    end


    statesBeingLogged=input.cs.RuntimeOptions.StatesToLog;


    templateStruct=struct('id','','isLogged',true,'name','','type','','scope','');
    info=repmat(templateStruct,length(states),1);


    types=get(states,{'Type'});
    names=get(states,{'Name'});
    id=get(states,{'SessionID'});

    for i=1:length(states)
        info(i).id=id{i};
        info(i).isLogged=isLogged(statesBeingLogged,states(i));
        info(i).name=names{i};
        info(i).type=types{i};
        info(i).scope=getScope(states(i),types{i});
    end

end

function out=getScope(obj,type)

    switch(type)
    case 'species'
        out=obj.Parent.Name;
    case 'parameter'

        if isa(obj.Parent,'SimBiology.Model')
            out=obj.Parent.Name;
        else
            out=obj.Parent.Parent.Name;
        end
    case 'compartment'

        owner=obj.Owner;
        if isempty(owner)
            out=obj.Parent.Name;
        else
            out=owner.Name;
        end
    end


end

function out=isLogged(statesBeingLogged,obj)

    out=~isempty(find(obj==statesBeingLogged,1));


end

function states=filterConstantParametersCompartments(states)

    states=sbioselect(states,...
    'Type','parameter','ConstantValue',false,...
    'or','Type','species',...
    'or','Type','compartment','ConstantCapacity',false,'depth',0);


end

function out=configureConfigsetProperty(action,input)






    model=SimBiology.web.modelhandler('getModelFromSessionID',input.model);
    cs=getconfigset(model,'default');
    property=input.property;
    value=input.value;
    errorOccurred=false;


    info.property=property;


    switch(property)
    case 'SolverType'
        cs.SolverType=value;
        info=getSolverInfo(info,cs);
    case{'StopTime','MaximumWallClock','MaximumNumberOfLogs'}
        try
            set(cs,property,str2double(value));
        catch ex %#ok<*NASGU>
            errorOccurred=true;
        end

        info.value=num2str(get(cs,property));
    case 'TimeUnits'
        try
            set(cs,property,value);
        catch ex %#ok<*NASGU>
            errorOccurred=true;
        end

        info.value=get(cs,property);
    end


    switch(property)
    case 'StatesToLog'
        if strcmp(input.value,'all')
            if(input.checked)
                set(cs.RuntimeOptions,'StatesToLog',getstates(model));
            else
                set(cs.RuntimeOptions,'StatesToLog','all');
            end
        elseif strcmp(input.value,'none')
            set(cs.RuntimeOptions,'StatesToLog',[]);
        else
            states=get(cs.RuntimeOptions,'StatesToLog');
            state=sbioselect(model,'SessionID',input.state);
            if value
                states=[states;state];
            else
                states(state==states)=[];
            end
            set(cs.RuntimeOptions,'StatesToLog',states);
        end
    end


    switch(property)
    case 'AbsoluteToleranceScaling'
        set(cs.SolverOptions,property,strcmp(value,'true'));
        info=getSolverInfo(info,cs);
    case{'AbsoluteToleranceStepSize','AbsoluteTolerance','RelativeTolerance',...
        'MaxStep','RandomState','LogDecimation','ErrorTolerance','MaxIterations'}
        try
            if strcmp(value,'[]')
                value=[];
            else


                value=str2double(value);
            end

            set(cs.SolverOptions,property,value);
        catch ex %#ok<*NASGU>
            errorOccurred=true;
        end
        info=getSolverInfo(info,cs);
    case 'OutputTimes'
        try
            value=eval(value);
            set(cs.SolverOptions,property,value);
        catch ex %#ok<*NASGU>
            errorOccurred=true;
        end
        info=getSolverInfo(info,cs);
    end


    switch(property)
    case{'DimensionalAnalysis','UnitConversion'}

        warningID='SimBiology:UnitConvRequiresDimAnal';
        originalWarning=warning('query',warningID);
        warning('off',warningID);

        set(cs.CompileOptions,property,strcmp(value,'true'));
        info.value=get(cs.CompileOptions,property);


        warning(originalWarning.state,warningID);



        props={'DimensionalAnalysis','UnitConversion'};
        info=repmat(info,1,numel(props));

        for i=1:numel(props)
            info(i).property=props{i};
            info(i).value=get(cs.CompileOptions,props{i});
        end

    case 'DefaultSpeciesDimension'
        set(cs.CompileOptions,property,value);
        info.value=get(cs.CompileOptions,property);
    end

    out={action,info};

    SimBiology.web.codecapturehandler('postConfigsetPropertyChangedEvent',model.SessionID,property,value,errorOccurred);
end
