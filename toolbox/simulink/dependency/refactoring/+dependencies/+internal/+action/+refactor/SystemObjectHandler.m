classdef SystemObjectHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=cellstr(dependencies.internal.analysis.simulink.SystemObjectsAnalyzer.SystemObjectType.ID);
        RenameOnly=true;
    end

    methods
        function refactor(~,dependency,newPath)
            block=dependency.UpstreamComponent.Path;
            [~,newRef]=fileparts(newPath);

            set_param(block,'System',newRef);
        end
    end
end
