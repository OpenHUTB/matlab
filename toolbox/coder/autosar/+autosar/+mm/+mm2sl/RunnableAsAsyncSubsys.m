classdef RunnableAsAsyncSubsys<autosar.mm.mm2sl.RunnableBuilder





    methods
        function this=RunnableAsAsyncSubsys(m3iRun,changeLogger)
            this@autosar.mm.mm2sl.RunnableBuilder(m3iRun,changeLogger);
        end

        function[runnablePath,subsystemPath]=create(this,parentSystem)
            [runnablePath,subsystemPath]=this.createOrUpdate('',parentSystem);
        end

        function subsystemPath=update(this,fcnCallInportBlkPath,parentSystem)
            [~,subsystemPath]=this.createOrUpdate(fcnCallInportBlkPath,parentSystem);
        end
    end

    methods(Access=private)
        function[runnablePath,subsystemPath]=createOrUpdate(this,fcnCallInportBlkPath,parentSystem)

            import autosar.mm.mm2sl.RunnableBuilder

            m3iRun=this.M3iRunnable;


            [fcnCallInportBlkPath,fcnCallInportAlreadyExist]=...
            this.addOrGetFcnCallInport(fcnCallInportBlkPath,parentSystem);
            runnablePath=fcnCallInportBlkPath;


            subsystemPath=this.addOrGetFcnCallSubsystem(...
            fcnCallInportBlkPath,[m3iRun.Name,'_sys'],parentSystem);

            if~strcmp(get_param(subsystemPath,'BlockType'),'SubSystem')
                DAStudio.error('autosarstandard:importer:UnableToUpdateModelRefRunnable');
            end


            this.addOrGetTriggerPort(subsystemPath);


            pc=get_param(fcnCallInportBlkPath,'PortConnectivity');
            if~isempty(pc.DstBlock)
                taskSpecBlkPath=[get(pc.DstBlock,'Path'),'/',get(pc.DstBlock,'Name')];
            else

                taskSpecBlkPath=this.addBlock('AsynchronousTaskSpecification',...
                'AsynchronousTaskSpecification',parentSystem,...
                {'ShowName','off','TaskPriority','[]'});
            end


            variantBlock='';
            fcnCallInportBlock=RunnableBuilder.removeSystemName(parentSystem,fcnCallInportBlkPath);
            if~fcnCallInportAlreadyExist
                modelName=bdroot(parentSystem);
                variantBlockBuilder=autosar.mm.mm2sl.BlockVariantBuilder(...
                modelName,this.ChangeLogger);
                variantPath=variantBlockBuilder.addVariantForBlock(fcnCallInportBlkPath,...
                'Inport',m3iRun.variationPoint,parentSystem);
                if~isempty(variantPath)



                    variantBlock=RunnableBuilder.removeSystemName(parentSystem,variantPath);
                    delete_line(parentSystem,[fcnCallInportBlock,'/1'],[variantBlock,'/1']);
                end
            end


            portHandles=get_param(subsystemPath,'PortHandles');
            isAlreadyConnected=(get(portHandles.Trigger,'Line')~=-1);
            if~isAlreadyConnected
                runnableBlock=RunnableBuilder.removeSystemName(parentSystem,subsystemPath);
                taskAsyncBlock=RunnableBuilder.removeSystemName(parentSystem,taskSpecBlkPath);
                if isempty(variantBlock)
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentSystem,...
                    [taskAsyncBlock,'/1'],[runnableBlock,'/Trigger']);
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentSystem,...
                    [fcnCallInportBlock,'/1'],[taskAsyncBlock,'/1']);
                else
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentSystem,...
                    [variantBlock,'/1'],[runnableBlock,'/Trigger']);
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentSystem,...
                    [fcnCallInportBlock,'/1'],[taskAsyncBlock,'/1']);
                    autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentSystem,...
                    [taskAsyncBlock,'/1'],[variantBlock,'/1']);
                end
            end

            this.updateDescription(subsystemPath);
        end
    end
end


