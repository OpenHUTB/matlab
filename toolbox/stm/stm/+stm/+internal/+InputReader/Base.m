


classdef(Abstract)Base<handle&matlab.mixin.Heterogeneous

    properties(SetAccess=immutable)
        RunTestCfg(1,1)stm.internal.RunTestConfiguration;
    end

    properties(SetAccess=protected)
        SimIn(1,1)struct;
        SimWatcher(1,1)stm.internal.util.SimulationWatcher;
    end

    methods
        function this=Base(simIn,runTestCfg,simWatcher)
            narginchk(3,3);
            this.SimIn=simIn;
            this.RunTestCfg=runTestCfg;
            this.SimWatcher=simWatcher;
        end

        function setStopTime(this)
            import stm.internal.util.SimulinkModel;
            if~this.SimIn.StopSimAtLastTimePoint
                return;
            elseif isempty(this.RunTestCfg.out.ExternalInputRunData)
                error(message('stm:InputsView:StopSimAtError'));
            end


            tMax=SimulinkModel.getLastTimePoint(this.RunTestCfg.out.ExternalInputRunData);
            tMaxString=SimulinkModel.formatSimTime(tMax);
            this.RunTestCfg.SimulationInput=...
            this.RunTestCfg.SimulationInput.setModelParameter('StopTime',tMaxString);


            logString=stm.internal.MRT.share.getString('stm:InputsView:InputTimeModified',tMaxString);
            this.RunTestCfg.addMessages({logString},{false});
        end

        function setMappingStatusMessage(this)
            if~isempty(this.SimIn.InputMappingStatus)


                if this.SimIn.InputType~=double(stm.internal.InputTypes.Sldv)
                    [mapWarn,mapLog]=stm.internal.MRT.share.verifyMappingStatus(this.SimIn.InputMappingStatus);
                    if~isempty(mapWarn)

                        this.RunTestCfg.addMessages({mapWarn},{mapLog});
                    end
                end
            end
        end

        function teardown(this)
            if~this.SimIn.IncludeExternalInputs&&this.SimIn.StopSimAtLastTimePoint



                runID=[this.RunTestCfg.out.ExternalInputRunData.runID];
                arrayfun(@(id)Simulink.sdi.deleteRun(id),runID);
                this.RunTestCfg.out.ExternalInputRunData=repmat(struct('type',[],'runID',[]),1,0);
            end
        end

        setup(this);
        override(this);
        getExternalInputRunData(this);
    end

    methods(Access=protected)
        function sigSourceInfo=getSigSourceInfo(this)
            sigSourceInfo=struct(...
            'SignalSourceComponent',this.Block.overrideScenario,...
            'SignalSourceBlock',getfullname(this.Block.handle),...
            'SignalSourceType',double(isa(this.Block,'stm.internal.blocks.SignalEditorBlock')));
        end
    end
end
