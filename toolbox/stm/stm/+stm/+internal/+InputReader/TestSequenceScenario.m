


classdef TestSequenceScenario<stm.internal.InputReader.Base
    properties
tsBlockPath
chart
overrideScenario
    end
    methods
        function this=TestSequenceScenario(simIn,runTestCfg,simWatcher)
            this=this@stm.internal.InputReader.Base(simIn,runTestCfg,simWatcher);
        end

        function setup(this)
            this.tsBlockPath=this.SimIn.TestSequenceBlock;
            if isempty(this.tsBlockPath)
                error(message('stm:general:TestSequenceBlockEmpty'));
            end
            try
                find_system(this.tsBlockPath,'SearchDepth',1);
            catch
                error(message('stm:general:TestSequenceNotFound',this.tsBlockPath));
            end
            rt=sfroot();
            this.chart=rt.find('-isa','Stateflow.ReactiveTestingTableChart','Path',this.tsBlockPath);
            if isempty(this.chart)
                error(message('stm:general:NotTestSequenceBlock',this.tsBlockPath));
            end

            if~sltest.testsequence.isUsingScenarios(this.tsBlockPath)
                error(message('stm:general:TestSequenceNoScenario',this.tsBlockPath));
            end

            if isempty(this.RunTestCfg.testSettings.input.TestSequenceScenario)
                if sltest.testsequence.getScenarioControlSource(this.tsBlockPath)==sltest.testsequence.ScenarioControlSource.Block
                    this.overrideScenario=sltest.testsequence.getActiveScenario(this.tsBlockPath);
                else


                    this.overrideScenario='';
                end
            else
                this.overrideScenario=this.RunTestCfg.testSettings.input.TestSequenceScenario;
            end
            this.RunTestCfg.out.TestSequenceInfo=struct(...
            'TestSequenceBlock',this.tsBlockPath,...
            'TestSequenceScenario',this.overrideScenario);
        end

        function override(this)
            sttman=Stateflow.STT.StateEventTableMan(this.chart.Id);
            viewManager=sttman.viewManager;
            if~isempty(this.overrideScenario)
                [tf,activeIndex]=ismember(this.overrideScenario,sltest.testsequence.internal.getAllScenarios(this.SimIn.TestSequenceBlock));
                if~tf
                    error(message('stm:general:InvalidTestSequenceScenario',this.overrideScenario,this.tsBlockPath));
                end


                activeIndex=activeIndex-1;
                originalValue=viewManager.scenarioParamVal();
                viewManager.jsActiveScenario(activeIndex);
            else
                originalValue=viewManager.scenarioParamVal();
            end
            this.SimWatcher.cleanupIteration.prevScenarioParamInitVal=originalValue;
            this.SimWatcher.cleanupIteration.testSeqPath=this.tsBlockPath;
        end

        function getExternalInputRunData(this)

        end
    end
end