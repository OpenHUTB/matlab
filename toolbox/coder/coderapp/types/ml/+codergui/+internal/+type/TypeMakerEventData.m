classdef(Sealed,ConstructOnLoad)TypeMakerEventData<event.EventData




    properties(SetAccess=immutable)

RootChanges


NodeChanges

AddedNodeIds

RemovedNodeIds
    end

    methods
        function this=TypeMakerEventData(rootChanges,nodeChanges,addedIds,removedIds)
            this.RootChanges=rootChanges;
            this.NodeChanges=nodeChanges;
            this.AddedNodeIds=addedIds;
            this.RemovedNodeIds=removedIds;
        end
    end
end
