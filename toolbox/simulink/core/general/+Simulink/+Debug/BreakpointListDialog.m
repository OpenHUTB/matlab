




classdef BreakpointListDialog<Simulink.Debug.BaseItemsObserver

    properties
        subscriptions={};
    end

    methods


        function onItemRemoved(this,~)
            this.refresh();
        end

        function onItemAdded(this,~)
            this.refresh();
        end

        function onItemChanged(this,~)
            this.refresh();
        end

        function onItemListUpdate(this)
            this.refresh();
        end


        function this=BreakpointListDialog
            this=this@Simulink.Debug.BaseItemsObserver(@()Simulink.Debug.BreakpointList.getInstance);
            this.subscriptions{end+1}=Stateflow.MessageService.subscribe('/bpList/readyToRefresh',@(varargin)this.refresh(varargin));
            this.subscriptions{end+1}=Stateflow.MessageService.subscribe('/bpList/navigateTo',@(id)navigateToBpOwner(id));
            this.subscriptions{end+1}=Stateflow.MessageService.subscribe('/bpList/updateCondition',@(args)updateCondition(args));
            this.subscriptions{end+1}=Stateflow.MessageService.subscribe('/bpList/enableAllBps',@(args)Simulink.Debug.BreakpointList.toggleEnablednessForBreakpoints(true));
            this.subscriptions{end+1}=Stateflow.MessageService.subscribe('/bpList/disableAllBps',@(args)Simulink.Debug.BreakpointList.toggleEnablednessForBreakpoints(false));
            this.subscriptions{end+1}=Stateflow.MessageService.subscribe('/bpList/deleteSelectedBreakpoints',@(args)deleteSelectedBreakpoints(args));
            this.subscriptions{end+1}=Stateflow.MessageService.subscribe('/bpList/updateBpEnabledness',@(args)updateEnabledness(args));
        end

        function delete(obj)
            for i=1:length(obj.subscriptions)
                Stateflow.MessageService.unsubscribe(obj.subscriptions{i});
            end
        end

        function highlightBreakpointCondition(~,bpId)
            Stateflow.MessageService.publish('/bpList/highlightBreakpointCondition',bpId);
        end
    end

    methods(Access=private)
        function refresh(~,~)
            bpList=Simulink.Debug.BreakpointList.getShownInBreakpointDialogBreakpoints();
            messageToPublish=getJsonableMessage(bpList);
            Stateflow.MessageService.publish('/bpList/update',messageToPublish);
        end
    end
end

function navigateToBpOwner(idAsString)
    bp=findBreakpoint(idAsString);

    bp.navigateToOwner();
end

function updateCondition(args)
    bp=findBreakpoint(args{1});
    bp.condition=args{2};
    updateTruthTableBpCondition(bp);
end

function updateEnabledness(args)
    idAsString=args{1};
    bp=findBreakpoint(idAsString);

    shouldEnable=args{2};

    if shouldEnable
        bp.enable();
    else
        bp.disable();
    end
end

function deleteSelectedBreakpoints(ids)

    for i=1:numel(ids)
        bp=findBreakpoint(ids(i));
        Simulink.Debug.BreakpointList.removeBreakpointFromList(bp);
        deleter=bp.getDeleter();
        deleter.execute();
    end
end

function bp=findBreakpoint(id)
    tok=regexp(id,'\d+_breakpoint_(\d+)','tokens','once');
    bp=Simulink.Debug.BreakpointList.getBreakpointWithId(str2double(tok{1}));
    assert(~isempty(bp));
end

function message=getJsonableMessage(bpList)
    persistent counter
    if isempty(counter)
        counter=0;
    end

    numBps=numel(bpList);
    message=struct('id',{},'enabled',{},'isactive',{},'path',{},'condition',{},'numHits',{});
    for i=1:numBps
        bp=bpList{i};









        message(i).id=sprintf('%d_breakpoint_%d',counter,bp.id);

        message(i).enabled=bp.isEnabled;
        message(i).isActive=bp.isActive;
        message(i).path=bp.getPath;
        message(i).type=bp.getTypeAsString;
        message(i).condition=bp.condition;
        message(i).numHits=bp.numHits;
    end
    counter=counter+1;
end

function updateTruthTableBpCondition(bp)
    if sf('feature','Truth Table Breakpoint')&&isa(bp.ownerUdd,'Stateflow.Transition')...
        &&isprop(bp.ownerUdd,'Subviewer')&&isa(bp.ownerUdd.Subviewer,'Stateflow.TruthTable')
        ttman=Stateflow.TruthTable.TruthTableManager.getInstance(bp.ownerUdd.Subviewer.Id);
        if~ttman.TruthTableBreakPointInfo.disableBreakPointReactGF
            ttman.breakPointFrontendGFReact(bp.ownerUdd,bp.tagEnum);
        end
    end
end
