classdef ConfigSetRightClickBuild<Simulink.ModelReference.Conversion.ConfigSet
    methods(Access=public)
        function this=ConfigSetRightClickBuild(varargin)
            this@Simulink.ModelReference.Conversion.ConfigSet(varargin);
        end
    end
    methods(Access=protected)
        function checkSolverMode(this,modelHandle)

            if~strcmp(get_param(modelHandle,'SystemTargetFile'),'rsim.tlc')
                set_param(modelHandle,'SolverType','Fixed-step');
            end
            this.checkSolverMode@Simulink.ModelReference.Conversion.ConfigSet(modelHandle);
        end

        function turnOffLogging(this,modelHandle)
            set_param(modelHandle,'LoadInitialState','off');
            set_param(modelHandle,'SaveOutput','off');
        end

        function setModelReferenceNumInstancesAllowed(this,modelRef,srcModel)






            conf=get_param(srcModel,'ModelReferenceNumInstancesAllowed');
            set_param(modelRef,'ModelReferenceNumInstancesAllowed',conf);
        end

        function resolveConfigSetReferenceWarning(this,modelRefHandle,activeConfigSet,logger)%#ok
        end
    end
end