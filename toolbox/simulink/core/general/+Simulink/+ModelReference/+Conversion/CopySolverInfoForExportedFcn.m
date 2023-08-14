classdef CopySolverInfoForExportedFcn<handle
    methods(Access=public)
        function this=CopySolverInfoForExportedFcn(subsys,model,~)
            Simulink.ModelReference.Conversion.CopySolverInfoForExportedFcn.exec(subsys,model);
        end
    end


    methods(Static,Access=private)
        function exec(~,model,~)
            set_param(model,'SolverType','Fixed-Step');
            set_param(model,'FixedStep','auto');
            set_param(model,'ModelReferenceNumInstancesAllowed','single');
        end
    end
end
