classdef RunnableAsAtomicSubsys<autosar.mm.mm2sl.RunnableBuilder





    methods
        function this=RunnableAsAtomicSubsys(m3iRun,changeLogger)
            this@autosar.mm.mm2sl.RunnableBuilder(m3iRun,changeLogger);
        end

        function[runnablePath,subsystemPath]=create(this,parentSystem)

            m3iRun=this.M3iRunnable;
            subsystemPath=this.addOrGetBlock('SubSystem',[m3iRun.Name,'_sys'],parentSystem,...
            {'Position',[200,500,400,700]});
            runnablePath=subsystemPath;


            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,subsystemPath,...
            'TreatAsAtomicUnit','on',...
            'SystemSampleTime',autosar.mm.mm2sl.RunnableAsAtomicSubsys.getRunnablePeriod(m3iRun));

            this.updateDescription(subsystemPath);
        end

        function subsystemPath=update(~,~,~)
            subsystemPath='';

        end
    end

    methods(Static,Access=private)
        function periodStr=getRunnablePeriod(m3iRun)
            [isPeriodic,m3iEvent]=autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
            Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass);

            if~slfeature('AUTOSARImportAsAtomicSubsystems')
                assert(isPeriodic,'%s should be invoked by TimingEvent.',m3iRun.Name);
            end

            if~isPeriodic
                periodStr=Simulink.metamodel.arplatform.getRealStringCompact(-1);
                return
            end

            periodStr=Simulink.metamodel.arplatform.getRealStringCompact(m3iEvent.Period);
        end
    end
end
