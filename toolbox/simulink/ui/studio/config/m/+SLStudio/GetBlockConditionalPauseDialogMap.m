function map=GetBlockConditionalPauseDialogMap





    mlock;

    persistent BlockConditionalPauseAddDialogObjectMap;

    if~isa(BlockConditionalPauseAddDialogObjectMap,'containers.Map')
        BlockConditionalPauseAddDialogObjectMap=...
        containers.Map('KeyType','double','ValueType','any');
    end
    map=BlockConditionalPauseAddDialogObjectMap;
