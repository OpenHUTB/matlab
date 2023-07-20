classdef(Sealed)TypeMaker<coderapp.internal.undo.StateOwner&codergui.internal.util.OrderedListenerMixin



    properties(Dependent,SetAccess=immutable)

        Roots codergui.internal.type.TypeMakerNode

Nodes

IsPending
    end

    properties(SetAccess=immutable)
        MetaTypeSchema codergui.internal.type.MetaTypeSchema
        EnforceUniqueRoots logical=true
    end

    properties
        AutoSnapshot logical=true
        StateTracker coderapp.internal.undo.StateTracker=coderapp.internal.undo.StateTracker.empty()
    end

    properties(GetAccess={?codergui.internal.type.TypeMaker,?codergui.internal.type.TypeMakerNode},SetAccess=private)
        IsDeserializing logical=false
    end

    properties(GetAccess=private,SetAccess=immutable)
        RootsHolder codergui.internal.type.FlushableValue
StateTrackerListener
    end

    properties(Access=private)
        IdCounter uint32=uint32(0)
ChangeRoots
        Additions codergui.internal.type.TypeMakerNode=codergui.internal.type.TypeMakerNode.empty()
        Removals codergui.internal.type.TypeMakerNode=codergui.internal.type.TypeMakerNode.empty()
        NodesById=containers.Map()%#ok<MCHDP>
        UntrackedChangeNodeIds=[]
    end

    events
ModelChanged
    end

    methods
        function this=TypeMaker(schema,varargin)
            ip=inputParser();
            ip.addParameter('StateTracker',[],@(v)isempty(v)||isa(v,'coderapp.internal.undo.StateTracker'));
            ip.addParameter('EnforceUniqueRoots',true,@islogical);
            ip.parse(varargin{:});

            if nargin>0&&~isempty(schema)
                this.MetaTypeSchema=schema;
            else
                this.MetaTypeSchema=codergui.internal.type.MetaTypeSchema.default();
            end
            this.MetaTypeSchema.seal();

            if~isempty(ip.Results.StateTracker)
                this.StateTracker=ip.Results.StateTracker;
            else
                this.StateTracker=coderapp.internal.undo.StateTracker();
            end

            this.EnforceUniqueRoots=ip.Results.EnforceUniqueRoots;

            this.RootsHolder=codergui.internal.type.FlushableValue(codergui.internal.type.TypeMakerNode.empty());
        end

        function root=addRoot(this)
            transacting=this.IsPending;
            this.begin();

            root=this.createNodes();
            if~isempty(this.MetaTypeSchema.DefaultClass)
                root.Class=this.MetaTypeSchema.DefaultClass;
            end

            this.Additions(end+1)=root;
            this.ChangeRoots(end+1)=root;
            this.RootsHolder.Next=[this.RootsHolder.Current,root];

            if~transacting
                this.finish();
            end
        end

        function removeRoot(this,root)
            roots=this.Roots;
            if isnumeric(root)
                match=[roots.Id]==root;
            else
                match=roots==root;
            end
            removal=roots(match);
            if isempty(removal)
                return
            end

            transacting=this.IsPending;
            this.begin();
            this.Removals(end+1)=removal;

            roots(match)=[];
            this.RootsHolder.Next=roots;

            if~transacting
                this.finish();
            end
        end

        function begin(this)
            if this.IsPending
                return
            end
            this.ChangeRoots=codergui.internal.type.TypeMakerNode.empty();
        end

        function allChanges=finish(this)
            allChanges=cell2struct(cell(1,4),{'rootChanges','nodeChanges','addedNodeIds','removedNodeIds'},2);
            if~this.IsPending
                return
            end


            this.ChangeRoots=unique([this.ChangeRoots,setdiff(this.Additions,this.ChangeRoots)],'stable');

            [~,order]=sort([this.ChangeRoots.Id],'descend');
            try
                [allChanges.nodeChanges,allAdditions,allRemoved]=this.ChangeRoots(order).applyChanges();
            catch me
                this.rollback();
                me.rethrow();
            end
            this.RootsHolder.flush();



            removedNodeIds=unique([allRemoved.Id,this.Removals.getSubtree().Id]);
            common=setdiff(cell2mat(this.NodesById.keys()),removedNodeIds,'stable');
            nextKeys=[common,allAdditions.Id];
            if~isempty(nextKeys)
                commonValues=this.NodesById.values(num2cell(common));
                this.NodesById=containers.Map(num2cell(nextKeys),[commonValues,reshape(num2cell(allAdditions),1,[])]);
            else
                this.NodesById=containers.Map('KeyType','uint32','ValueType','any');
            end


            addChanges=struct(...
            'type',repmat({codergui.internal.type.ChangeType.RootAdded},size(this.Additions)),...
            'node',num2cell(this.Additions));
            removeChanges=struct(...
            'type',repmat({codergui.internal.type.ChangeType.RootRemoved},size(this.Removals)),...
            'node',num2cell(this.Removals));
            allChanges.rootChanges=[addChanges,removeChanges];

            if isempty(allChanges.rootChanges)
                allChanges.rootChanges=struct('type',{},'node',{});
            end
            if isempty(allChanges.nodeChanges)
                allChanges.nodeChanges=codergui.internal.type.TypeMakerNode.EMPTY_CHANGE;
            end
            allChanges.addedNodeIds=uint32(union([this.Additions.Id],[allAdditions.Id]));
            allChanges.removedNodeIds=uint32(removedNodeIds);


            if~isempty(this.StateTracker)&&~this.IsRestoring&&~this.IsDeserializing
                changedNodes=unique([allChanges.nodeChanges.node,allChanges.rootChanges.node]);
                if~isempty(changedNodes)||~isempty(allChanges.removedNodeIds)||~isempty(allChanges.addedNodeIds)
                    this.UntrackedChangeNodeIds=intersect([this.UntrackedChangeNodeIds,changedNodes.Id],nextKeys);
                    if this.AutoSnapshot
                        this.StateTracker.snapshot();
                    end
                end
            end


            this.clearTransitionalState();

            if~isempty(allChanges.rootChanges)||~isempty(allChanges.nodeChanges)
                this.notify('ModelChanged',codergui.internal.type.TypeMakerEventData(...
                allChanges.rootChanges,allChanges.nodeChanges,allChanges.addedNodeIds,allChanges.removedNodeIds));
            end
        end

        function cancel(this)
            if this.IsPending
                this.ChangeRoots.clearPendingChanges();
                this.clearTransitionalState();
            end
        end

        function nodes=getNodes(this,nodeIds)

            if~iscell(nodeIds)
                nodeIds=num2cell(nodeIds);
            end
            nodes=this.NodesById.values(nodeIds);
            nodes=[nodes{:}];
        end

        function ids=getAllNodeIds(this)

            ids=this.NodesById.keys();
            ids=[ids{:}];
        end

        function delete(this)
            this.MetaTypeSchema.unseal();
        end

        function pending=get.IsPending(this)
            pending=isa(this.ChangeRoots,'codergui.internal.type.TypeMakerNode')...
            ||~isempty(this.Removals)||this.IsRestoring||this.IsDeserializing;
        end

        function nodes=get.Nodes(this)
            if~isempty(this.NodesById)
                nodes=this.NodesById.values();
                nodes=[nodes{:}];
            else
                nodes=codergui.internal.type.TypeMakerNode.empty();
            end
        end

        function roots=get.Roots(this)
            roots=this.RootsHolder.Current;
        end

        function set.AutoSnapshot(this,autoSnapshot)
            this.AutoSnapshot=autoSnapshot;
            if autoSnapshot&&~isempty(this.StateTracker)&&~isempty(this.UntrackedChangeNodeIds)%#ok<MCSUP>
                this.StateTracker.snapshot();%#ok<MCSUP>
            end
        end

        function set.StateTracker(this,stateTracker)
            if~isempty(this.StateTracker)
                this.StateTracker.removeStateOwner(this);
            end
            if~isempty(stateTracker)
                this.StateTracker=stateTracker;
                stateTracker.addStateOwner(this);
            else
                this.StateTracker=coderapp.internal.undo.StateTracker.empty();
            end
        end
    end

    methods(Hidden)
        function state=getSerializableState(this)
            if~isempty(this.Roots)
                state.nodes=this.Roots.getPersistableSubtreeState();
            else
                state.nodes=[];
            end
        end

        function load(this,storeOrState)
            if isa(storeOrState,'codergui.internal.util.Store')
            else
                state=storeOrState;
            end
            this.deserialize(state.nodes);
        end
    end

    methods(Access={?codergui.internal.type.TypeMaker,?codergui.internal.type.TypeMakerNode})
        function nodes=createNodes(this,parent,count)
            if nargin<3
                if nargin<2
                    parent=[];
                end
                count=1;
            end
            if isempty(parent)
                parent=codergui.internal.type.TypeMakerNode.empty();
            end
            nodes=codergui.internal.type.TypeMakerNode(this.IdCounter+1:this.IdCounter+count,this,parent);
            this.IdCounter=this.IdCounter+count;
        end

        function commitNode(this,node)
            if this.IsPending
                if isa(this.ChangeRoots,'codergui.internal.type.TypeMakerNode')
                    this.ChangeRoots(end+1:end+numel(node))=node;
                else
                    this.ChangeRoots=node;
                end
            else
                this.ChangeRoots=node;
                this.finish();
            end
        end

        function rollback(this,node)
            if~this.IsPending
                if nargin>1
                    node.clearPendingChanges();
                end
                return;
            elseif nargin>1
                if isempty(this.ChangeRoots)
                    this.ChangeRoots=node;
                else
                    this.ChangeRoots(end+1)=node;
                end
            end
            nodes=unique([this.ChangeRoots,setdiff(this.Additions,this.ChangeRoots)],'stable');
            if~isempty(nodes)
                nodes.clearPendingChanges();
            end
            this.clearTransitionalState();
        end
    end

    methods(Access=private)
        function clearTransitionalState(this)
            this.RootsHolder.clear();
            emptyNodes=codergui.internal.type.TypeMakerNode.empty();
            this.ChangeRoots=[];
            this.Additions=emptyNodes;
            this.Removals=emptyNodes;
        end

        function deserialize(this,states)
            this.rollback();
            this.begin();
            this.IsDeserializing=true;
            cleanup=onCleanup(@this.clearDeserializationFlag);

            oldRoots=this.Roots;
            for i=1:numel(oldRoots)
                this.removeRoot(oldRoots(i));
            end
            this.finish();
            if isempty(states)
                return;
            end

            this.begin();
            try
                for rootIdx=find([states.isRoot])
                    root=this.addRoot();
                    root.deserializeNode(rootIdx,states);
                end
            catch me
                this.rollback();
                me.rethrow();
                return;
            end


            cleanup=[];%#ok<NASGU>
            this.finish();
        end

        function clearDeserializationFlag(this)
            this.IsDeserializing=false;
        end
    end

    methods(Access={?coderapp.internal.undo.StateOwner,?coderapp.internal.undo.StateTracker})
        function[changedState,unchangedIds]=getTrackableState(this,full)
            allNodes=this.Nodes;
            if full
                untrackedNodes=allNodes;
                unchangedIds=[];
            else
                untrackedNodes=allNodes(ismember([allNodes.Id],this.UntrackedChangeNodeIds));
                unchangedIds=setdiff([allNodes.Id],[untrackedNodes.Id]);
            end
            this.UntrackedChangeNodeIds=[];
            if~isempty(untrackedNodes)
                changedState=struct(...
                'trackableId',num2cell([untrackedNodes.Id]),...
                'state',num2cell(untrackedNodes.getTransientNodeState(false)));
            else
                changedState=[];
            end
        end

        function applyTrackedState(this,enteredStates,changedStates,exitedIds)
            this.begin();

            enteredStates=[enteredStates.state];
            changedStates=[changedStates.state];

            if~isempty(this.NodesById)
                currentNodes=this.NodesById.values();
                currentNodes=[currentNodes{:}];
            else
                currentNodes=codergui.internal.type.TypeMakerNode.empty();
            end


            if~isempty(exitedIds)


                removedNodes=this.getNodes(sort(exitedIds));
                removalFilter=containers.Map([removedNodes.Id],true(1,numel(removedNodes)));
                for i=1:numel(removedNodes)
                    node=removedNodes(i);
                    if~removalFilter(node.Id)
                        continue
                    end
                    subtree=node.getSubtree();
                    subtree(1)=[];
                    for j=1:numel(subtree)
                        removalFilter(subtree(j).Id)=false;
                    end
                end
                removedNodes=removedNodes(cell2mat(removalFilter.values({removedNodes.Id})));


                [removedRoots,removedIdx]=intersect(this.Roots,removedNodes);
                removedNodes=setdiff(removedNodes,removedRoots);
                [uParents,~,parentIdx]=unique([removedNodes.Parent],'stable');
                for i=1:numel(uParents)
                    uParents(i).remove(removedNodes(parentIdx==i));
                end

                if~isempty(removedRoots)
                    nextRoots=this.Roots;
                    nextRoots(removedIdx)=[];
                    this.RootsHolder.Next=nextRoots;
                    this.Removals=removedRoots;
                end
                currentNodes=setdiff(currentNodes,[removedNodes,removedRoots]);
            end


            if~isempty(enteredStates)
                addedIds=[enteredStates.id];
                added=codergui.internal.type.TypeMakerNode(addedIds,this);

                currentNodes=[added,currentNodes];
                restored=true(1,numel(currentNodes));
                restored(1:numel(added))=false;
                possibleParents=[currentNodes.Id];
                [~,parentIdx]=ismember([enteredStates.parent],possibleParents);

                for i=setdiff(unique(parentIdx),0)
                    if~restored(i)
                        currentNodes(i).restoreOwnState(enteredStates(i));
                        restored(i)=true;
                    end
                    currentNodes(i).internalAppend(added(parentIdx==i));
                end

                notRestored=~restored(1:numel(added))|ismember(addedIds,possibleParents);
                added(notRestored).restoreOwnState(enteredStates(notRestored));

                addedRoots=added(parentIdx==0);
                if~isempty(addedRoots)
                    this.RootsHolder.Next=[this.Roots,addedRoots];
                    this.Additions=addedRoots;
                end
            end


            if~isempty(changedStates)
                changedNodes=this.getNodes([changedStates.id]);
                changedNodes.restoreOwnState(changedStates);
            end

            this.finish();
        end
    end
end
