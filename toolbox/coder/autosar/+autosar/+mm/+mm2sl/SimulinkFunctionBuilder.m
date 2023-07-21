classdef SimulinkFunctionBuilder<autosar.mm.mm2sl.RunnableBuilder




    methods
        function this=SimulinkFunctionBuilder(m3iRun,changeLogger)
            this@autosar.mm.mm2sl.RunnableBuilder(m3iRun,changeLogger);
        end

        function[runnablePath,subsystemPath]=create(this,parentSystem)
            subsystemPath=this.createOrUpdate('',parentSystem);
            runnablePath=subsystemPath;
        end

        function subsystemPath=update(this,blockPath,parentSystem)
            subsystemPath=this.createOrUpdate(blockPath,parentSystem);
        end
    end

    methods(Abstract,Access=protected)
        createOrUpdate(this,blockPath,parentSystem);
        functionName=getFunctionName(this);
        subsysName=getSubsysName(this);
    end

    methods(Access=protected)
        function[subsystemPath,triggerPortBlkPath]=addOrGetSLFunctionAndTriggerBlock(this,blockPath,parentSystem)


            runnableAlreadyExists=~isempty(blockPath);
            if~runnableAlreadyExists
                subsystemPath=this.addOrGetBlock('SubSystem',this.getSubsysName(),parentSystem,...
                {'Position',[200,500,400,700]});
            else
                subsystemPath=blockPath;
            end


            this.updateDescription(subsystemPath);


            triggerPortBlkPath=this.addOrGetTriggerPort(subsystemPath);
            autosar.mm.mm2sl.SLModelBuilder.set_param(...
            this.ChangeLogger,triggerPortBlkPath,...
            'FunctionName',this.getFunctionName,...
            'IsSimulinkFunction','on');


            set_param(triggerPortBlkPath,'FunctionName',this.getFunctionName);
        end
    end
end


