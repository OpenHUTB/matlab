


classdef SignalBuilder<stm.internal.InputReader.Base
    properties
        Block(1,1)stm.internal.blocks.SignalSourceBlock;
    end

    methods
        function this=SignalBuilder(simIn,runTestCfg,simWatcher)
            this=this@stm.internal.InputReader.Base(simIn,runTestCfg,simWatcher);
        end

        function setup(this)
            import stm.internal.blocks.SignalSourceBlock;
            this.Block=SignalSourceBlock.getBlock(...
            this.RunTestCfg.modelToRun,...
            this.RunTestCfg.testSettings.input.SigBuilderGroupName);
            this.RunTestCfg.out.SigBuilderInfo=this.getSigSourceInfo;
        end

        function override(this)
            [handle,idx]=this.Block.setActiveComponent(this.Block.overrideScenario);


            this.SimWatcher.cleanupIteration.SignalBuilder=handle;
            this.SimWatcher.cleanupIteration.SigBuilderIndex=idx;
        end

        function getExternalInputRunData(this)
            stm.internal.InputReader.SignalEditor.getExternalInputRunDataHelper(this);
        end
    end
end
