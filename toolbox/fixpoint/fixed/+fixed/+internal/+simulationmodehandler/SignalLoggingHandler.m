classdef SignalLoggingHandler<fixed.internal.simulationmodehandler.SimulationModeHandler




    methods

        function restore(this)

            for modelObj=this.ModelMode
                modelObj.restoreSignalLoggingMode();
            end
        end

    end

    methods(Access=protected)

        function setModelMode(this)
            refMdls=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(this.TopModel);


            for idx=1:numel(refMdls)
                mdl=refMdls{idx};
                modelObj=fixed.internal.simulationmodehandler.ModelReference(mdl);
                modelObj.switchSignalLoggingMode('on');
                this.ModelMode(end+1)=modelObj;
            end

        end

    end
end
