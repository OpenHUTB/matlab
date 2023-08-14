classdef RunnableAsTerminateFunctionBlock<autosar.mm.mm2sl.RunnableBuilder





    methods
        function this=RunnableAsTerminateFunctionBlock(m3iRun,changeLogger)
            this@autosar.mm.mm2sl.RunnableBuilder(m3iRun,changeLogger);
        end

        function[runnablePath,subsystemPath]=create(this,parentSystem)
            subsystemPath=this.createTerminateFunctionBlock(parentSystem);
            runnablePath=subsystemPath;
        end

        function subsystemPath=update(this,subsystemPath,~)

            if~isempty(subsystemPath)
                this.updateTerminateFunctionBlock(subsystemPath);
            end
        end
    end

    methods(Access=private)
        function blockPath=createTerminateFunctionBlock(this,parentSystem)
            m3iRun=this.M3iRunnable;
            blockPath=this.addOrGetBlock('SubSystem',...
            m3iRun.Name,parentSystem,...
            {'Position',[200,500,400,700]});
            this.addOrGetBlock('EventListener',...
            'Event Listener',blockPath,...
            {'EventType','Terminate',...
            'Position',[235,25,255,45]});
            this.updateTerminateFunctionBlock(blockPath);
        end

        function updateTerminateFunctionBlock(this,blockPath)
            this.updateDescription(blockPath);
        end
    end
end
