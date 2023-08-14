


classdef SignalEditor<stm.internal.InputReader.Base
    properties
        Block(1,1)stm.internal.blocks.SignalSourceBlock;
    end

    methods
        function this=SignalEditor(simIn,runTestCfg,simWatcher)
            this=this@stm.internal.InputReader.Base(simIn,runTestCfg,simWatcher);
        end

        function setup(this)
            import stm.internal.blocks.SignalSourceBlock;
            scenario=this.RunTestCfg.testSettings.input.SigBuilderGroupName;
            this.Block=SignalSourceBlock.getBlock(this.RunTestCfg.modelToRun,scenario);
            this.Block.validateScenario(scenario);
            this.RunTestCfg.out.SigBuilderInfo=this.getSigSourceInfo;
        end

        function override(this)

            this.RunTestCfg.SimulationInput=this.RunTestCfg.SimulationInput.setBlockParameter(...
            this.Block.handle,'ActiveScenario',this.Block.overrideScenario);
        end

        function getExternalInputRunData(this)
            stm.internal.InputReader.SignalEditor.getExternalInputRunDataHelper(this);
        end
    end

    methods(Static)
        function getExternalInputRunDataHelper(this)
            if this.SimIn.IncludeExternalInputs||this.SimIn.StopSimAtLastTimePoint
                runData=struct(...
                'runID',this.Block.getSignalFromComponent(this.Block.overrideScenario,''),...
                'type',this.Block.getSignalBlockType);

                prevData=this.RunTestCfg.out.ExternalInputRunData;
                this.RunTestCfg.out.ExternalInputRunData=[prevData,runData];
            end
        end
    end
end
