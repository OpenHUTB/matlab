

function exportToBaseWorkspace(model,domain,baseWorkspaceVarName,fmt)
    data=Simulink.sdi.internal.getExportDataForStreamout(model,domain,fmt);
    variableExist=isVariableExistInWorkspace(baseWorkspaceVarName);
    if~variableExist
        assignin('base',baseWorkspaceVarName,data);
    end
end

function flag=isVariableExistInWorkspace(varName)
    cmd=sprintf('exist(''%s'')',varName);
    flag=(evalin('base',cmd)==1);
end

