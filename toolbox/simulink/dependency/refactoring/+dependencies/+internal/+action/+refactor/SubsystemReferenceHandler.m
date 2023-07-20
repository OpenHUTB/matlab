classdef SubsystemReferenceHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types={dependencies.internal.analysis.simulink.SubsystemReferenceAnalyzer.SubsystemReferenceType};
        RenameOnly=true;
    end

    methods

        function refactor(~,dependency,newPath)
            block=dependency.UpstreamComponent.Path;
            [~,newRef,~]=fileparts(newPath);
            set_param(block,'ReferencedSubsystem',newRef);
        end

    end

end
