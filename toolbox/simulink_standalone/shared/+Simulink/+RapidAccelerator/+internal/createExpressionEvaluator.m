function expressionEvaluator=createExpressionEvaluator(topModel,simInputWorkspaces)



    narginchk(1,2);



    expressionEvaluator=...
    Simulink.standalone.ExpressionEvaluator();

    dataDictionaryName=get_param(topModel,'DataDictionary');

    dataDictionaryVariableEvaluator=...
    Simulink.standalone.DataDictionaryVariableEvaluator(dataDictionaryName);

    expressionEvaluator.push_back(dataDictionaryVariableEvaluator);

    if~isempty(simInputWorkspaces)
        simInputGlobalWSIndex=...
        find(strcmp({simInputWorkspaces.name},'global-workspace'));

        assert(length(simInputGlobalWSIndex)<=1);

        if(~isempty(simInputGlobalWSIndex))
            simInputGlobalWS=...
            simInputWorkspaces(simInputGlobalWSIndex).workspace;

            expressionEvaluator.push_back(simInputGlobalWS);
        end
    end

    modelWS=locCopyModelWorkspace(topModel);
    expressionEvaluator.push_back(modelWS);

    if~isempty(simInputWorkspaces)
        topModelSimInputModelWSIndex=...
        find(strcmp({simInputWorkspaces.name},topModel));

        assert(length(topModelSimInputModelWSIndex)<=1);

        if(~isempty(topModelSimInputModelWSIndex))
            topModelSimInputModelWS=...
            simInputWorkspaces(topModelSimInputModelWSIndex).workspace;

            expressionEvaluator.push_back(topModelSimInputModelWS);
        end
    end

end



function modelWSCopy=locCopyModelWorkspace(model)
    modelWSCopy=Simulink.standalone.MatlabWorkspace;

    if~Simulink.isRaccelDeployed
        modelWS=get_param(model,'ModelWorkspace');

        if isempty(modelWS)
            return
        end

        varList=modelWS.whos();

        varList=arrayfun(...
        @(x)struct('name',{x.name},'value',{modelWS.getVariable(x.name)}),...
varList...
        );
    else
        mi=Simulink.RapidAccelerator.getStandaloneModelInterface(model);
        modelWS=mi.getModelWorkspaceStruct();

        varList=fieldnames(modelWS);
        varList=cellfun(@(x)struct('name',{x},'value',{modelWS.(x)}),varList);
    end

    modelWSCopy=assignVarsToWorkspace(varList,modelWSCopy);
end



function workspace=assignVarsToWorkspace(varList,workspace)
    for varIdx=1:length(varList)
        varName=varList(varIdx).name;

        if isempty(varName)
            continue
        end

        if ishandle(varList(varIdx).value)
            try
                varValue=copy(varList(varIdx).value);
            catch

                continue
            end
        else
            varValue=varList(varIdx).value;
        end

        workspace.assign(varName,varValue);
    end
end
