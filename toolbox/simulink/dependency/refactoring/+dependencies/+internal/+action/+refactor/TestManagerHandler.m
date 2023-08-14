classdef TestManagerHandler<dependencies.internal.action.RefactoringHandler




    properties(SetAccess=immutable)
        Types={getString(message('stm:Dependency:SystemUnderTest'))
        getString(message('stm:Dependency:ConfigSetReference'))
        getString(message('stm:Dependency:ParameterOverride'))
        getString(message('stm:Dependency:Baseline'))
        getString(message('stm:Dependency:ExternalInput'))};
        RenameOnly=false;
    end

    methods
        function refactor(~,dependency,newPath)
            dependencies.internal.action.refactor.runTestManagerRefactoring(...
            dependency,newPath);
        end
    end
end
