classdef VariableRefactoringHandler<dependencies.internal.action.RefactoringHandler





    properties(SetAccess=immutable)
        Types;
        RenameOnly;
    end

    properties(SetAccess=immutable,GetAccess=private)
        FileHandlers(1,:)dependencies.internal.buses.refactoring.FileHandler;
        VariableHandlers(1,:)dependencies.internal.buses.refactoring.VariableHandler;
        GraphTypes(:,:)dependencies.internal.graph.Type;
    end

    methods
        function this=VariableRefactoringHandler()
            import dependencies.internal.graph.Type;
            this.RenameOnly=true;
            this.FileHandlers=[
            dependencies.internal.buses.refactoring.BaseWorkspaceFileHandler
            dependencies.internal.buses.refactoring.DataDictionaryFileHandler
            dependencies.internal.buses.refactoring.MatFileHandler
            dependencies.internal.buses.refactoring.ModelWorkspaceFileHandler
            ];
            this.VariableHandlers=[
            dependencies.internal.buses.refactoring.BusObjectHandler
            dependencies.internal.buses.refactoring.BusElementObjectHandler
            dependencies.internal.buses.refactoring.SignalObjectHandler
            dependencies.internal.buses.refactoring.StructHandler
            ];
            fileHandlerTypeStr=repmat([this.FileHandlers.Type]',1,length(this.VariableHandlers));
            variableHandlerTypeStr=repmat([this.VariableHandlers.SubType],length(this.FileHandlers),1);
            fullTypes=fileHandlerTypeStr+","+variableHandlerTypeStr;
            this.GraphTypes=arrayfun(...
            @(type,subType)dependencies.internal.graph.Type([type,subType]),...
            fileHandlerTypeStr,variableHandlerTypeStr);
            this.Types=cellstr(fullTypes(:));
        end

        function refactor(this,dependency,newPath)
            newElements=split(string(newPath),".");
            [row,col]=find(dependency.Type==this.GraphTypes);
            fileHandler=this.FileHandlers(row);
            variableHandler=this.VariableHandlers(col);
            variableHandler.refactor(dependency,newElements,fileHandler);
        end
    end
end
