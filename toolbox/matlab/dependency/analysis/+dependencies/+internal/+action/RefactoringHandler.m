classdef(Abstract)RefactoringHandler<handle&matlab.mixin.Heterogeneous

    properties(Abstract,SetAccess=immutable)

        Types(:,1)cell;

        RenameOnly(1,1)logical;
    end

    methods
        refactor(this,dependency,newPath);

    end

end
