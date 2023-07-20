function out=postprocesshandler(action,varargin)











    out={action};

    switch(action)
    case 'verifyModelObservables'
        out=verifyModelObservables(varargin{1});
    case 'verifySimDataObservables'
        out=verifySimDataObservables(varargin{1});
    case 'addModelObservable'
        out=addModelObservable(varargin{1});
    case 'updateModelObservable'
        out=updateModelObservable(varargin{1});
    case 'deleteModelObservable'
        out=deleteModelObservable(varargin{1});
    end

    out={action,out};
end

function out=verifySimDataObservables(input)
    out='';

    dataRow=input.dataRow;
    rows=input.rows;
    obsNames={rows.name};
    obsNames=obsNames([rows.use]);


    data=loadVariable(dataRow.matfileName,dataRow.matfileVariableName);
    dataInfo=dataRow.dataInfo;

    if strcmpi(dataRow.type,'programdata')
        if~iscell(dataInfo)
            dataInfo={dataInfo};
        end


        for i=1:numel(dataInfo)
            if strcmp(dataInfo{i}.type,'SimData')
                dataInfo=dataInfo{i};
                break;
            end
        end
        propName=dataInfo.name;


        data=data.(propName);
    end



    w=warning('off','all');
    cleanupVar=onCleanup(@()warning(w));

    knownNames=data.DataNames;

    for i=1:length(rows)
        expression=rows(i).expression;
        rows(i).matlabError={};

        if isempty(expression)
            rows(i).matlabError={'Expression must be specified'};
        else

            obj=data.selectbyname(rows(i).name);
            if~isempty(obj(1).Data)&&~strcmp(obj(1).DataInfo{1}.Type,'observable')
                rows(i).matlabError{end+1}=sprintf('The observable name ''%s'' is a state in the SimData',rows(i).name);
            end

            [tokens,~,validatedExpression]=SimBiology.internal.parseExpression(expression,smartConcat(knownNames,obsNames));
            if isempty(validatedExpression)
                rows(i).matlabError{end+1}=sprintf('The expression used to calculate column %s in the SimData contains an error',expression);
                continue
            end


            for j=1:length(tokens)
                nextToken=tokens{j};


                if~strcmp(nextToken,'time')
                    obj=data.selectbyname(nextToken);



                    isStateInSimData=~isempty(vertcat(obj.DataNames));
                    isStateStatName=any(ismember(obsNames,nextToken));

                    if~isStateInSimData&&~isStateStatName
                        rows(i).matlabError{end+1}=['Expression contains component ''',nextToken,''' that does not exist in SimData'];
                    end
                end
            end
        end
    end

    out.rows=rows;
end

function out=verifyModelObservables(input)

    modelInfo=input.modelInfo;
    rows=input.rows;
    obsNames={rows.name};
    obsNames=obsNames([rows.use]);


    model=SimBiology.web.modelhandler('getModelFromSessionID',modelInfo.modelID);


    statesToLogInfo=modelInfo.statesToLogInfo;
    if statesToLogInfo.statesToLogUseConfigset
        cs=getconfigset(model,'default');
        statesToLog=cs.RuntimeOptions.StatesToLog;
    else
        statesToLogCell=cell(numel(statesToLogInfo.statesToLog),1);
        for i=1:numel(statesToLogInfo.statesToLog)
            if statesToLogInfo.statesToLog(i).use
                state=sbioselect(model,'UUID',statesToLogInfo.statesToLog(i).UUID);
                if~isempty(state)
                    statesToLogCell{i}=state;
                end
            end
        end
        statesToLog=vertcat(SimBiology.Species.empty(),statesToLogCell{:});
    end

    stateNames={statesToLog.Name};
    for i=1:length(rows)
        expression=rows(i).expression;
        rows(i).matlabError={};

        if isempty(expression)
            rows(i).matlabError={'Expression must be specified.'};
        else
            [tokens,~,validatedExpression]=SimBiology.internal.parseExpression(expression,smartConcat(stateNames,obsNames));
            if isempty(validatedExpression)
                rows(i).matlabError={'Invalid expression. If there are invalid variable names in the expression, enclose them with brackets [].<br>Use isvarname at the command line to check if a variable name is valid.'};
                continue
            end


            for j=1:length(tokens)
                nextToken=tokens{j};
                if~strcmp(nextToken,'time')&&~any(ismember(nextToken,obsNames))

                    obj=SimBiology.internal.getObjectFromPQN(model,nextToken);
                    if isempty(obj)
                        rows(i).matlabError{end+1}=['Expression contains state ''',nextToken,''' that does not exist in the model'];
                    elseif numel(obj)>1
                        rows(i).matlabError{end+1}=['Multiple states found with name ''',nextToken,'''. Define the expression using qualified names for the components'];
                    elseif strcmp(obj.Type,'observable')
                        rows(i).matlabError{end+1}=['Expression contains observable ''',nextToken,''' that is not being calculated'];
                    elseif~any(obj==statesToLog)
                        if input.programHasStatesToLog
                            rows(i).matlabError{end+1}=['Expression contains state ''',nextToken,''' that is not being logged. Log the state in the States To Log table in the Model Step'];
                        else
                            rows(i).matlabError{end+1}=['Expression contains state ''',nextToken,''' that is not being logged. Log the state using the Simulation Settings dialog'];
                        end
                    end
                end
            end
        end


        if~isempty(model)
            obs=sbioselect(model,'type','observable','Name',rows(i).name);
            if~isempty(obs)&&~obs.isValidUnits(rows(i).units)
                rows(i).matlabError{end+1}=sprintf('Unit ''%s'' is not a valid unit.',rows(i).units);
            end
        end
    end

    out.rows=rows;
end

function data=loadVariable(matfile,matfileVarName)

    if SimBiology.internal.variableExistsInMatFile(matfile,matfileVarName)
        data=load(matfile,matfileVarName);
        data=data.(matfileVarName);
    else
        data=[];
    end
end

function out=smartConcat(var1,var2)


    if size(var1,1)==1
        var1=var1';
    end

    if size(var2,1)==1
        var2=var2';
    end

    out=vertcat(var1,var2,'time');
end

function out=addModelObservable(input)
    out.msg='';

    try

        model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
        addobservable(model,input.name,input.expression);
    catch ex
        msg=SimBiology.web.internal.errortranslator(ex);

        out.msg=msg;
        input.observable.matlabError=msg;
    end

    out.input=input;
end

function out=updateModelObservable(input)


    out.msg='';
    out.input=input;
    try

        warnState=warning('off','SimBiology:InvalidExpressionDuringRename');
        cleanup=onCleanup(@()warning(warnState));


        model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
        obs=sbioselect(model,'SessionID',input.observable.sessionID);
        if~isempty(obs)
            switch input.property
            case 'name'
                rename(obs,input.value);
            case 'expression'
                obs.Expression=input.value;
            case 'units'
                if obs.isValidUnits(input.value)
                    obs.Units=input.value;
                else

                    w=warning('off','all');


                    obs.Units=input.value;


                    warning(w);

                    input.observable.matlabError=sprintf('Unit ''%s'' is not a valid unit.',input.value);
                    out.msg=input.observable.matlabError;
                end
            end
        else
            input.observable.matlabError='Component with the specified name already exists on the model. Observable names must be unique on a model.';
            out.msg=input.observable.matlabError;
        end
    catch ex
        msg=SimBiology.web.internal.errortranslator(ex);

        out.msg=msg;
        input.observable.matlabError=msg;
    end

    out.input=input;
end

function out=deleteModelObservable(input)

    out.msg='';
    out.input=input;

    try

        model=SimBiology.web.modelhandler('getModelFromSessionID',input.modelSessionID);
        transaction=SimBiology.Transaction.create(model);

        for i=1:numel(input.observables)
            obs=sbioselect(model,'SessionID',input.observables(i).sessionID);
            if~isempty(obs)
                delete(obs);
            end
        end

        transaction.commit;
    catch ex
        msg=SimBiology.web.internal.errortranslator(ex);

        out.msg=msg;
        input.observable.matlabError=msg;
    end

    out.input=input;
end
