function workspaceVarDetails=getWorkspaceVariableDetails(variablesList,requestedVariable)




    workspaceVarDetails=struct("Name",{},"CodeValue",{});


    if nargin<1
        return;
    end

    numberofVars=size(variablesList);
    for i=1:numberofVars(1)
        variable=variablesList(i);
        if strcmp(variable.Name,requestedVariable)
            workspaceVarDetails(1)=getVariableDetail(variable);
            break;
        end
    end
end

function newVariable=getVariableDetail(variable)
    newVariable.Name=variable.Name;
    newVariable.CodeValue=evalin('base',variable.Name);
end