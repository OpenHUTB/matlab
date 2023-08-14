function vars=getBaseWorkspaceVarsAsStruct()









    varList=evalin('base','who');

    vars=struct;
    for i=1:numel(varList)
        vars.(varList{i})=evalin('base',varList{i});
    end
end