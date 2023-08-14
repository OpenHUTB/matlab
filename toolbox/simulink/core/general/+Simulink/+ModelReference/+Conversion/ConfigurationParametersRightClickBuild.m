classdef ConfigurationParametersRightClickBuild<Simulink.ModelReference.Conversion.ConfigurationParameters
    methods(Access=public)
        function this=ConfigurationParametersRightClickBuild(ActiveConfigSet,ConversionData,currentSubsystem,modelRefHandle,isCopyContent)
            this@Simulink.ModelReference.Conversion.ConfigurationParameters(ActiveConfigSet,ConversionData,currentSubsystem,modelRefHandle,isCopyContent);
        end
    end
    methods(Access=protected)
        function checkSolverMode(this)

            if slfeature('RightClickBuild')&&~strcmp(get_param(this.modelRefHandle,'SystemTargetFile'),'rsim.tlc')
                set_param(this.modelRefHandle,'SolverType','Fixed-step');
            end
            this.checkSolverModeImpl;
        end

        function turnOffLogging(this)



            if slfeature('RightClickBuild')~=0
                set_param(this.modelRefHandle,'LoadInitialState','off');
            else
                set_param(this.modelRefHandle,'SaveTime','off');
            end
            set_param(this.modelRefHandle,'SaveOutput','off');
        end

        function setModelReferenceNumInstancesAllowed(this)






            if slfeature('RightClickBuild')==0
                set_param(this.modelRefHandle,'ModelReferenceNumInstancesAllowed','Multi');
            else
                conf=get_param(this.Model,'ModelReferenceNumInstancesAllowed');
                set_param(this.modelRefHandle,'ModelReferenceNumInstancesAllowed',conf);
            end
        end

        function detachConfigureParameterReference(this)
            if~isempty(this.NewActiveConfigSet)
                [configSetEqual,~]=isequal(getActiveConfigSet(get_param(this.modelRefHandle,'Name')),getRefConfigSet(this.ActiveConfigSet));
                if configSetEqual
                    attachConfigSetCopy(get_param(this.modelRefHandle,'Name'),this.ActiveConfigSet,true)
                    setActiveConfigSet(this.modelRefHandle,activeConfigSet.Name);
                    detachConfigSet(this.modelRefHandle,this.DefaultConfigSetName);
                end
            end
        end
    end
end