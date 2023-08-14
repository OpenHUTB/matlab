function b=isObjectInBaseWorkspace(variableName,objectType)






    baseWorkspace=Simulink.data.BaseWorkspace;


    variableList=baseWorkspace.whos(objectType);

    b=ismember(variableName,variableList);

end