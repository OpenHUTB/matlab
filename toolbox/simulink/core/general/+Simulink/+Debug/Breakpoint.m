




classdef Breakpoint<Simulink.Debug.BaseItem
    properties(SetAccess=private,SetObservable)
        isEnabled=true;
        numHits=0;
    end

    properties(SetObservable)
        condition='';
    end

    properties(Transient)
        id=[];
    end

    methods(Abstract)
        navigateToOwner(obj);
    end

    methods
        function obj=Breakpoint(modelName,domain)
            obj=obj@Simulink.Debug.BaseItem(modelName,domain);
            obj.id=Simulink.Debug.Breakpoint.getNextId();
        end

        function enable(obj)
            obj.isEnabled=true;
            if isprop(obj,'ownerUdd')&&~isempty(obj.ownerUdd)&&isvalid(obj.ownerUdd)
                Stateflow.Debug.refreshSLBPList(obj.ownerUdd.Id);
            end
        end

        function disable(obj)
            obj.isEnabled=false;
            if isprop(obj,'ownerUdd')&&~isempty(obj.ownerUdd)&&isvalid(obj.ownerUdd)
                Stateflow.Debug.refreshSLBPList(obj.ownerUdd.Id);
            end
        end

        function status=shouldShowInBreakpointDialog(obj)%#ok<MANU>
            status=true;
        end

        function incrementNumHits(obj)
            obj.numHits=obj.numHits+1;
            if isprop(obj,'ownerUdd')&&~isempty(obj.ownerUdd)
                Stateflow.Debug.handleBPHitEvent(obj);
            end
        end

        function resetNumHits(obj)
            obj.numHits=0;
            if isprop(obj,'ownerUdd')&&~isempty(obj.ownerUdd)&&isvalid(obj.ownerUdd)
                Stateflow.Debug.refreshSLBPList(obj.ownerUdd.Id);
            end
        end

        function set.condition(obj,newCondition)
            obj.condition=newCondition;
            obj.resetNumHits();
        end

        function loadSuccessfully=reload(obj)
            obj.id=Simulink.Debug.Breakpoint.getNextId();
            loadSuccessfully=true;
        end
    end

    methods(Static)
        function id=getNextId
            persistent index;

            mlock();
            if isempty(index)
                index=0;
            end

            index=index+1;
            id=index;
        end
    end
end
