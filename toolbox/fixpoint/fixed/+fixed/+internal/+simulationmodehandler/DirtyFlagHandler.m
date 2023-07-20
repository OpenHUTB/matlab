classdef DirtyFlagHandler<fixed.internal.simulationmodehandler.SimulationModeHandler




    methods

        function restore(this)

            for modelObj=this.ModelMode
                modelObj.restoreDirtyFlag();
            end
        end

    end

    methods(Access=protected)

        function setModelMode(this)
            refMdls=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(this.TopModel);


            for idx=1:numel(refMdls)
                mdl=refMdls{idx};
                this.ModelMode(end+1)=fixed.internal.simulationmodehandler.ModelReference(mdl);
            end
        end

    end
end
