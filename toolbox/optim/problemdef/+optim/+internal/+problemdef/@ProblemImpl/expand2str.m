function probStr=expand2str(prob,addBolding,varargin)

















    if isempty(prob.ObjectivesStore)&&isempty(prob.ConstraintsStore)
        probStr='';
        return;
    end


    if isempty(prob.Variables)


        probStr='';
    else

        variableNamesStr=expandVariableNames2str(prob,addBolding,varargin{:});
        probStr=sprintf('\n\n%s',variableNamesStr);
    end


    objectivesStr=expandObjectives2str(prob,addBolding,varargin{:});

    probStr=sprintf('%s\n%s',probStr,objectivesStr);


    constraintsStr=expandConstraints2str(prob,addBolding,varargin{:});

    probStr=sprintf('%s\n%s',probStr,constraintsStr);


    strVar="";
    vars=prob.Variables;
    varNames=fieldnames(vars);
    nVars=numel(varNames);
    for i=1:nVars
        thisVar=vars.(varNames{i});
        thisVarStr=getBoundStr(thisVar,false,7);
        strVar=strVar+thisVarStr;
    end

    strVar=deblank(strVar);
    if strlength(strVar)>0
        if addBolding
            probStr=sprintf('%s\n\t<strong>variable bounds:</strong>%s',probStr,strVar);
        else
            probStr=sprintf('%s\n\tvariable bounds:%s',probStr,strVar);
        end
    end

end