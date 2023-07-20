classdef AccelModeHandler<fixed.internal.simulationmodehandler.SimulationModeHandler




    methods

        function switchToNormalMode(this)

            for modelObj=this.ModelMode
                modelObj.switchSimulationMode('normal');
            end
        end

        function restoreSimulationMode(this)

            for modelObj=this.ModelMode
                modelObj.restoreSimulationMode();
            end

        end

    end

    methods(Access=protected)

        function setModelMode(this)

            [refMdls,mdlBlks]=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(this.TopModel);



            for idx=1:numel(mdlBlks)
                mdl=mdlBlks{idx};
                this.ModelMode(end+1)=fixed.internal.simulationmodehandler.ModelBlock(mdl);
            end

            for idx=1:numel(refMdls)
                mdl=refMdls{idx};
                this.ModelMode(end+1)=fixed.internal.simulationmodehandler.ModelReference(mdl);
            end


        end

    end
end
