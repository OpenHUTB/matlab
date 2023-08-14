classdef DialogManagerInterface<handle






    methods
        function obj=DialogManagerInterface
        end
    end

    methods(Abstract)

        getFileDependencies(h,project);
        getUIAlert(h);
        getUIConfirm(h);
        addFiles(h,project);
        getEvolutionName(h);
        getEvolutionTreeName(h);
    end
end
