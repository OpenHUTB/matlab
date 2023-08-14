classdef RunnableAsInitFunctionBlock<autosar.mm.mm2sl.RunnableBuilder





    methods
        function this=RunnableAsInitFunctionBlock(m3iRun,changeLogger)
            this@autosar.mm.mm2sl.RunnableBuilder(m3iRun,changeLogger);
        end

        function[runnablePath,subsystemPath]=create(this,parentSystem)
            subsystemPath=this.createInitFunctionBlock(parentSystem);
            runnablePath=subsystemPath;
        end

        function subsystemPath=update(this,subsystemPath,~)

            if~isempty(subsystemPath)
                this.updateInitFunctionBlock(subsystemPath);
            end
        end
    end

    methods(Access=private)
        function blockPath=createInitFunctionBlock(this,parentSystem)
            m3iRun=this.M3iRunnable;



            initFcnBlocks=autosar.utils.InitResetTermFcnBlock.findInitFunctionBlocks(parentSystem);
            if((length(initFcnBlocks)==1)&&strcmp(get_param(initFcnBlocks{1},'Parent'),parentSystem))
                blockPath=initFcnBlocks{1};
            else
                blockPath='';
            end

            if isempty(blockPath)
                blockPath=this.addOrGetBlock('SubSystem',...
                m3iRun.Name,parentSystem,...
                {'Position',[200,500,400,700]});

                this.addOrGetBlock('EventListener',...
                'Event Listener',blockPath,...
                {'EventType','Initialize',...
                'Position',[235,25,255,45]});
            end

            this.updateInitFunctionBlock(blockPath);
        end

        function updateInitFunctionBlock(this,blockPath)
            this.updateDescription(blockPath);
        end
    end
end
