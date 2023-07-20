










function booleanResult=isActionLanguageC(stateflowObject)

    booleanResult=false;

    if isa(stateflowObject,'Stateflow.Chart')||isa(stateflowObject,'Stateflow.StateTransitionTableChart')
        if strcmp(stateflowObject.ActionLanguage,'C')
            booleanResult=true;
        end
    elseif isa(stateflowObject,'Stateflow.TruthTable')
        if strcmp(stateflowObject.Language,'C')
            booleanResult=true;
        end
    elseif isprop(stateflowObject,'Chart')
        booleanResult=...
        Advisor.Utils.Stateflow.isActionLanguageC(stateflowObject.Chart);
    end

end

