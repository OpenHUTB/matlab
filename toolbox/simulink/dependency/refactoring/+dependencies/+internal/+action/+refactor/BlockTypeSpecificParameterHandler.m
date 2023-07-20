classdef BlockTypeSpecificParameterHandler<dependencies.internal.action.RefactoringHandler





    properties(Abstract,Constant)

ParamForBlock
    end

    properties(SetAccess=immutable)
        RenameOnly=false;
    end

    methods
        function refactor(this,dependency,newPath)
            block=dependency.UpstreamComponent.Path;

            blockType=get_param(block,"ReferenceBlock");

            paramName=this.ParamForBlock(blockType);

            import dependencies.internal.action.refactor.refactorParameter;
            refactorParameter(dependency,paramName,newPath);
        end
    end
end
