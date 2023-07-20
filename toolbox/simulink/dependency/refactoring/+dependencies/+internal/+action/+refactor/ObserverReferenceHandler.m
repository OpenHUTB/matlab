classdef ObserverReferenceHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types={dependencies.internal.analysis.simulink.ObserverReferenceAnalyzer.ObserverBlockType};
        RenameOnly=true;
    end

    methods
        function refactor(~,dependency,newPath)
            block=dependency.UpstreamComponent.Path;
            [~,name,ext]=fileparts(newPath);
            newRef=[name,ext];

            set_param(block,'ObserverModelName',newRef);
        end
    end

end
