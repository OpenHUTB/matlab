classdef SimscapeHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types={dependencies.internal.analysis.simulink.SimscapeAnalyzer.SimscapeComponentType};
        RenameOnly=true;
    end

    methods
        function refactor(~,dependency,newPath)
            block=dependency.UpstreamComponent.Path;
            [~,newRef]=fileparts(newPath);

            set_param(block,'SourceFile',newRef);
        end
    end

end
