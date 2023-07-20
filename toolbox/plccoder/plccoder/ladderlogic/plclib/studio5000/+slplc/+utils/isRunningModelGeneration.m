function tf=isRunningModelGeneration(block)
    tf=ismember(slplc.utils.getModelGenerationStatus(block),...
    {'LibraryGeneation','ModelGeneration'});
end