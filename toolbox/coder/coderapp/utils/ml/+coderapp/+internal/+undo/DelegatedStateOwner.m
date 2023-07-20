classdef(Sealed)DelegatedStateOwner<coderapp.internal.undo.StateOwner




    properties(GetAccess=private,SetAccess=immutable)
        StateRestorer{mustBeFunctionArg}=function_handle.empty()
    end

    properties(Access=private)
        IdCounter=uint32(0)
PendingUpdates
PendingExitIds
TrackedIds
        States struct=checkStateStructArg([])
    end

    methods
        function this=DelegatedStateOwner(stateRestorer)
            this.StateRestorer=stateRestorer;
        end

        function replace(this,replacement)




            narginchk(2,2);
            replacement=checkStateStructArg(replacement);
            this.PendingUpdates=replacement;
            allIds=([replacement.trackableId]);
            this.PendingExitIds=setdiff(this.TrackedIds,allIds);
            this.TrackedIds=allIds;
        end

        function overlay(this,states,unchangedIds)






            narginchk(2,3);
            states=checkStateStructArg(states);
            trackableIds=[states.trackableId];

            [~,preservedIdx]=setdiff([this.PendingUpdates.trackableId],trackableIds);
            this.PendingUpdates=[this.PendingUpdates(preservedIdx);reshape(states,[],1)];

            if nargin<3
                this.PendingExitIds=[this.PendingExitIds,setdiff(this.TrackedIds,trackableIds)];
                this.TrackedIds=union(this.TrackedIds,trackableIds);
            else
                [redeemed,redeemedIdx]=intersect(this.PendingExitIds,[trackableIds,reshape(unchangedIds,1,[])]);
                this.PendingExitIds(redeemedIdx)=[];
                this.TrackedIds=union(this.TrackedIds,[trackableIds,redeemed]);
            end
        end

        function exit(this,exitIds)


            novelExitIds=reshape(setdiff(exitIds,this.PendingExitIds),1,[]);
            this.TrackedIds=setdiff(this.TrackedIds,novelExitIds);
            this.PendingExitIds=[this.PendingExitIds,novelExitIds];
        end

        function trackableIds=generateAndTrackIds(this,count)
            if nargin<2
                count=1;
            end
            trackableIds=this.generateIds(count);
            this.trackIds(trackableIds);
        end

        function trackIds(this,trackableIds)
            this.TrackedIds=unique([this.TrackedIds,reshape(trackableIds,1,[])]);
        end

        function trackableIds=generateIds(this,count)
            if nargin<2||isempty(count)
                count=1;
            end
            trackableIds=this.IdCounter+1:this.IdCounter+count;
            this.IdCounter=this.IdCounter+count;
        end
    end

    methods(Access={?coderapp.internal.undo.StateOwner,?coderapp.internal.undo.StateTracker})
        function[changedState,unchangedIds]=getTrackableState(this,full)
            changedState=this.PendingUpdates;
            if~isempty(changedState)
                unchangedIds=setdiff(this.TrackedIds,[changedState.trackableId]);
            else
                unchangedIds=[];
            end


            if~isempty(this.PendingExitIds)
                this.States(ismember([this.States.trackableId],this.PendingExitIds))=[];
            end
            if~isempty(changedState)
                oldIds=[this.States.trackableId];
                newIds=[changedState.trackableId];
                [~,aIdx,bIdx]=intersect(oldIds,newIds);
                this.States(aIdx)=changedState(bIdx);
                [~,nIdx]=setdiff(newIds,oldIds);
                this.States(end+1:end+numel(nIdx))=changedState(nIdx);
            end

            if full
                changedState=this.States;
            end
            this.reset();
        end

        function applyTrackedState(this,enteredStates,changedStates,exitedIds)
            feval(this.StateRestorer,enteredStates,changedStates,exitedIds);
        end
    end

    methods(Access=private)
        function reset(this)
            this.PendingUpdates=[];
            this.PendingExitIds=[];
            this.TrackedIds=[];
        end
    end
end


function arg=checkStateStructArg(arg)
    if isempty(arg)
        arg=struct('trackableId',{},'state',{});
    elseif~istruct(arg)||~all(isfield(arg,{'trackableId','state'}))
        error('Not a valid state struct');
    end
end


function mustBeFunctionArg(arg)
    if~coder.internal.isScalarText(arg)&&~isa(arg,'function_handle')
        error('Argument must be a function handle or the name of a function on path');
    end
end