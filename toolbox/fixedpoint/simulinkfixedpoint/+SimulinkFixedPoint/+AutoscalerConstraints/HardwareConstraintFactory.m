classdef HardwareConstraintFactory<handle








    methods(Static)
        function constraint=getConstraint(modelName)
            if~iscell(modelName)

                modelName={modelName};
            end
            constraint=SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint.empty;
            for ii=1:numel(modelName)
                currentModelName={bdroot(modelName{ii})};
                if SimulinkFixedPoint.AutoscalerUtils.isMicroprocessor(currentModelName{1})

                    newConstraint=SimulinkFixedPoint.AutoscalerConstraints.MicroProcessorConstraint(currentModelName);
                else

                    newConstraint=SimulinkFixedPoint.AutoscalerConstraints.FPGAConstraint(currentModelName);
                end
                constraint=constraint+newConstraint;
            end
        end
    end
end


