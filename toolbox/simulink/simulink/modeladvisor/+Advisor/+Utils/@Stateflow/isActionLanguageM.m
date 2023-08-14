










function booleanResult=isActionLanguageM(stateflowObject)

    booleanResult=false;

    if isa(stateflowObject,'Stateflow.Chart')||isa(stateflowObject,'Stateflow.StateTransitionTableChart')
        if strcmp(stateflowObject.ActionLanguage,'MATLAB')
            booleanResult=true;
        end
    elseif isprop(stateflowObject,'Chart');
        booleanResult=...
        Advisor.Utils.Stateflow.isActionLanguageM(stateflowObject.Chart);
    end

end

