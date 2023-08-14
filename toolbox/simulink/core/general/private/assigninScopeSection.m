function assigninScopeSection(model,varName,varValue,ddSection)













    if ischar(model)
        load_system(model);
    end

    ddSpec=get_param(model,'DataDictionary');

    if isempty(ddSpec)


        assignin('base',varName,varValue);
    else


        ddConn=Simulink.dd.open(ddSpec);
        ddConn.assignin(varName,varValue,ddSection);
    end

