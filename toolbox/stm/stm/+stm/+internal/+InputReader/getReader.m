


function reader=getReader(simIn,runTestCfg,simWatcher)
    reader=[];
    if runTestCfg.testSettings.input.IsSigBuilderUsed
        reader=getSignalBlockReader(simIn,runTestCfg,simWatcher);
    end

    if~isempty(runTestCfg.testSettings.input.TestSequenceBlock)||...
        ~isempty(runTestCfg.testSettings.input.TestSequenceScenario)
        reader=[reader,stm.internal.InputReader.TestSequenceScenario(simIn,runTestCfg,simWatcher)];
    end

    if~isempty(simIn.InputFilePath)
        reader=[reader,stm.internal.InputReader.MappedInput(simIn,runTestCfg,simWatcher)];
    end
end

function reader=getSignalBlockReader(simIn,runTestCfg,simWatcher)
    block=stm.internal.blocks.SignalSourceBlock.getBlock(runTestCfg.modelToRun);
    if isempty(block.handle)
        reader=[];
    elseif isa(block,'stm.internal.blocks.SignalEditorBlock')
        reader=stm.internal.InputReader.SignalEditor(simIn,runTestCfg,simWatcher);
    else
        reader=stm.internal.InputReader.SignalBuilder(simIn,runTestCfg,simWatcher);
    end
end
