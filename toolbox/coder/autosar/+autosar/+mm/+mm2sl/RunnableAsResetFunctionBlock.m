classdef RunnableAsResetFunctionBlock<autosar.mm.mm2sl.RunnableBuilder





    methods
        function this=RunnableAsResetFunctionBlock(m3iRun,changeLogger)
            this@autosar.mm.mm2sl.RunnableBuilder(m3iRun,changeLogger);
        end

        function[runnablePath,subsystemPath]=create(this,parentSystem)
            subsystemPath=this.createResetFunctionBlock(parentSystem);
            runnablePath=subsystemPath;
        end

        function subsystemPath=update(this,subsystemPath,~)

            if~isempty(subsystemPath)
                this.updateResetFunctionBlock(subsystemPath);
            end
        end
    end

    methods(Access=private)
        function blockPath=createResetFunctionBlock(this,parentSystem)
            m3iRun=this.M3iRunnable;
            blockPath=this.addOrGetBlock('SubSystem',...
            m3iRun.Name,parentSystem,...
            {'Position',[200,500,400,700]});




            if m3iRun.Events.size>0
                lEventName=m3iRun.Events.at(1).Name;
            else
                lEventName=['Reset_',m3iRun.Name];
            end

            this.addOrGetBlock('EventListener',...
            'Event Listener',blockPath,...
            {'EventType','Reset',...
            'EventName',lEventName,...
            'Position',[235,25,255,45]});
            this.updateResetFunctionBlock(blockPath);
        end

        function updateResetFunctionBlock(this,blockPath)
            this.updateDescription(blockPath);
        end
    end
end
