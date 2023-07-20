classdef RunnableAsFcnCallSubsys<autosar.mm.mm2sl.RunnableBuilder





    methods
        function this=RunnableAsFcnCallSubsys(m3iRun,changeLogger)
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


            triggerPortBlkPath=this.addOrGetTriggerPort(subsystemPath);


            variantPath='';
            if~fcnCallInportAlreadyExist
                modelName=bdroot(parentSystem);
                variantBlockBuilder=autosar.mm.mm2sl.BlockVariantBuilder(...
                modelName,this.ChangeLogger);
                variantPath=variantBlockBuilder.addVariantForBlock(fcnCallInportBlkPath,...
                'Inport',m3iRun.variationPoint,parentSystem);
            end


            portHandles=get_param(subsystemPath,'PortHandles');
            isAlreadyConnected=(get(portHandles.Trigger,'Line')~=-1);
            if~isAlreadyConnected
                if isempty(variantPath)
                    srcBlock=fcnCallInportBlkPath;
                else
                    srcBlock=variantPath;
                end
                dstBlock=[subsystemPath,'/Trigger'];
                autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentSystem,RunnableBuilder.removeSystemName(parentSystem,[srcBlock,'/1']),...
                RunnableBuilder.removeSystemName(parentSystem,dstBlock));
            end


            [isPeriodic,m3iEvent]=autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
            Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass);
            if isPeriodic
                period=m3iEvent.Period;
            else
                period=-1;
            end

            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,fcnCallInportBlkPath,...
            'SampleTime',Simulink.metamodel.arplatform.getRealStringCompact(period));

            if period==-1
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                triggerPortBlkPath,'SampleTimeType','triggered');
            else
                if~strcmp(get_param(triggerPortBlkPath,'SampleTimeType'),'periodic')
                    autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                    triggerPortBlkPath,'SampleTimeType','periodic','SampleTime','-1');
                end
            end

            this.updateDescription(fcnCallInportBlkPath);
        end
    end
end


