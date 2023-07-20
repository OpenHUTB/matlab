classdef ToolStripContextMgr<handle













    methods(Access=private)



        function obj=ToolStripContextMgr()
        end
    end

    methods(Access=public,Static)
        function ctx=getContext(modelNameOrHandle)
            ctx=coder.internal.toolstrip.HardwareBoardContextManager.getContext(modelNameOrHandle);
        end
    end

    methods(Access=public,Static,Hidden)
        function avail=getAvailableTargets()
            targets=slrealtime.Targets;
            avail=targets.getTargetNames;

            persistent listenersCreated;
            if isempty(listenersCreated)
                listenersCreated=true;
                addlistener(targets,'AddedTarget',@(src,event)slrealtime.internal.ToolStripContextMgr.slrealtimeTargetAddedOrRemoved());
                addlistener(targets,'RemovedTarget',@(src,event)slrealtime.internal.ToolStripContextMgr.slrealtimeTargetAddedOrRemoved());
                addlistener(targets,'TargetNameChanged',@(src,event)slrealtime.internal.ToolStripContextMgr.targetRenamed(event.oldName,event.newName));
            end
        end

        function default=getDefaultTarget()
            targets=slrealtime.Targets;
            default=targets.getDefaultTargetName;
        end

        function slrealtimeTargetAddedOrRemoved(~,~)
            availTargets=slrealtime.internal.ToolStripContextMgr.getAvailableTargets();
            contexts=coder.internal.toolstrip.HardwareBoardContextManager.getAllContexts();
            for index=1:length(contexts)
                context=contexts{index};
                if isa(context,'slrealtime.internal.ToolStripContext')
                    context.targetEntries=availTargets;
                end
            end
        end

        function targetRenamed(targetName,newName)

            contexts=coder.internal.toolstrip.HardwareBoardContextManager.getAllContexts();
            for index=1:length(contexts)
                context=contexts{index};
                if isa(context,'slrealtime.internal.ToolStripContext')
                    if strcmp(context.selectedTarget,targetName)
                        context.selectedTarget=newName;
                    end
                end
            end
        end

    end
end
