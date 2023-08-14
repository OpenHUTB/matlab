classdef FMUHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types=cellstr(dependencies.internal.analysis.simulink.FMUAnalyzer.FMUType.ID);
        RenameOnly=true;
    end

    methods
        function refactor(~,dependency,newPath)
            block=dependency.UpstreamComponent.Path;
            [~,name,ext]=fileparts(newPath);
            newRef=[name,ext];

            set_param(block,'FMUName',newRef);
        end
    end

end
