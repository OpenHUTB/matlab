function paramList=getParameterOverrideHelper(stmFileName,sheet,simIndex,scenarioIndex,charOverrides)



    [~,~,ext]=fileparts(stmFileName);
    if strcmpi(ext,'.m')
        clearvars -except stmFileName;
        try
            run(stmFileName);
        catch
            run(which(stmFileName));
        end

        clear stmFileName;


        vars=whos;
        values=arrayfun(@(var)evalin('caller',var.name),vars,'Uniform',false);
        paramList=struct('Name',{vars.name},'Value',values',...
        'BlockPath','');
    elseif strcmpi(ext,'.mat')

        paramList=getSLDVParamValues(stmFileName,scenarioIndex);
    else
        paramList=getExcelParameters(stmFileName,sheet,simIndex,charOverrides);
    end
end

function paramList=getExcelParameters(fileName,sheet,simIndex,charOverrides)
    T=xls.internal.ReadTable(fileName,'Sheet',sheet);
    params=T.readParameters(simIndex);
    needsEval=true(numel(params),1);

    needsEval(ismember({params.Name},charOverrides))=false;
    paramList=xls.internal.SaveVariablesToScript.toValue(params,needsEval);
end

function paramList=getSLDVParamValues(fileName,scenarioIndex)
    [~,scenario]=stm.internal.MRT.share.loadSldvFile(fileName,scenarioIndex,false);
    if isfield(scenario,'paramValues')
        paramList=struct(...
        'Name',{scenario.paramValues.name},...
        'Value',{scenario.paramValues.value},...
        'BlockPath',''...
        );
    end
end
