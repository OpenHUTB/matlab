function[obj,isInBaseWorkspace]=getObjectFromBaseWorkspace(variableName,objectType)





    obj=eval(objectType).empty;
    isInBaseWorkspace=true;



    if~isempty(variableName)


        isInBaseWorkspace=fixed.internal.workspaceutils.isObjectInBaseWorkspace(variableName,objectType);


        if isInBaseWorkspace
            obj=evalin('base',variableName);
        end
    end

end

