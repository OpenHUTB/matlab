classdef ModelWorkspaceFileHandler<dependencies.internal.buses.refactoring.FileHandler




    properties(Constant)
        Type=dependencies.internal.buses.analysis.ModelWorkspaceAnalyzer.BaseType;
    end

    methods

        function changeName(this,filePath,oldVariableName,newVariableName)
            ws=this.getWorkspace(filePath);
            ws.evalin(sprintf("%s=%s; clear %s;",...
            newVariableName,oldVariableName,oldVariableName));
        end

        function modifyObject(this,filePath,variableName,updateSignalFunc)
            ws=this.getWorkspace(filePath);
            object=ws.getVariable(variableName);
            object=updateSignalFunc(object);
            ws.assignin(variableName,object);
        end

    end

    methods(Static,Access=private)

        function ws=getWorkspace(filePath)
            [~,model]=fileparts(filePath);
            ws=get_param(model,"ModelWorkspace");
        end

    end

end
