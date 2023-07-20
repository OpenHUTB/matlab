function map=GetAddConditionalPauseDialogPortMap







    mlock;

    persistent portConditionalPauseAddDialogObjectMap;
    if~isa(portConditionalPauseAddDialogObjectMap,'containers.Map')
        portConditionalPauseAddDialogObjectMap=...
        containers.Map('KeyType','double','ValueType','any');
    end
    map=portConditionalPauseAddDialogObjectMap;

end
