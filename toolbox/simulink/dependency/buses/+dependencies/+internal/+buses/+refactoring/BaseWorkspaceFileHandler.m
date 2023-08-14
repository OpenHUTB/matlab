classdef BaseWorkspaceFileHandler<dependencies.internal.buses.refactoring.FileHandler




    properties(Constant)
        Type=dependencies.internal.buses.analysis.BaseWorkspaceNodeAnalyzer.BaseType;
    end

    methods

        function changeName(~,~,oldVariableName,newVariableName)
            evalin("base",sprintf("%s=%s; clear %s;",...
            newVariableName,oldVariableName,oldVariableName));
        end

        function modifyObject(~,~,variableName,updateSignalFunc)
            object=evalin("base",variableName);
            object=updateSignalFunc(object);
            assignin("base",variableName,object);
        end

    end

end
