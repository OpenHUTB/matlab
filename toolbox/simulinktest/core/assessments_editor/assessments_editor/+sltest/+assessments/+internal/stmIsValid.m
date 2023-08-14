function res=stmIsValid(clientId)

    stmViewInstance=stm.internal.ViewInstance.getInstance();
    res=~isempty(stmViewInstance.cefObj)&&...
    strcmp(stm.internal.getTestType(str2double(clientId)),'unknown')==false;
end
