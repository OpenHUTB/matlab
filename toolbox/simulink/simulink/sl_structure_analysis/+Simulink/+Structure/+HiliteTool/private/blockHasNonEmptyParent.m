function bool=blockHasNonEmptyParent(blockHandle)



    currentGraph=get_param(blockHandle,'Parent');
    currentGraphHandle=get_param(currentGraph,'handle');
    parentGraph=get_param(currentGraph,'Parent');
    isBdInSubsystem=~isempty(parentGraph);
    bool=isBdInSubsystem||...
    isBdReferencedByModelBlock(currentGraphHandle);
end
