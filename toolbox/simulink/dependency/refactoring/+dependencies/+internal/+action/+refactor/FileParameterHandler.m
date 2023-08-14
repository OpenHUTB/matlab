classdef FileParameterHandler<dependencies.internal.action.RefactoringHandler





    properties(SetAccess=immutable)
        RenameOnly=false;
    end

    properties(Abstract,Constant)
        ParameterName;
    end

    methods
        function refactor(this,dependency,newPath)
            import dependencies.internal.action.refactor.refactorParameter;
            refactorParameter(dependency,this.ParameterName,newPath)
        end
    end
end
