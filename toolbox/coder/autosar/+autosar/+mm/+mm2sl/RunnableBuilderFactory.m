classdef RunnableBuilderFactory<handle





    methods(Static)
        function runnableBuilder=getBuilder(m3iRun,irtRunnableType,modelPeriodicRunnablesAs,changeLogger)

            switch irtRunnableType
            case autosar.mm.mm2sl.IRTRunnableType.Initialization
                runnableBuilder=autosar.mm.mm2sl.RunnableAsInitFunctionBlock(m3iRun,changeLogger);
                return;
            case autosar.mm.mm2sl.IRTRunnableType.Reset
                runnableBuilder=autosar.mm.mm2sl.RunnableAsResetFunctionBlock(m3iRun,changeLogger);
                return;
            case autosar.mm.mm2sl.IRTRunnableType.Terminate
                runnableBuilder=autosar.mm.mm2sl.RunnableAsTerminateFunctionBlock(m3iRun,changeLogger);
                return;
            case autosar.mm.mm2sl.IRTRunnableType.NotAnIRTRunnable

            otherwise
                assert(false,'Unexpected value of enumeration autosar.mm.mm2sl.IRTRunnableType');
            end

            switch(modelPeriodicRunnablesAs)
            case 'AtomicSubsystem'
                if slfeature('AUTOSARImportAsAtomicSubsystems')||...
                    autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
                    Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass)
                    runnableBuilder=autosar.mm.mm2sl.RunnableAsAtomicSubsys(m3iRun,changeLogger);
                else
                    runnableBuilder=autosar.mm.mm2sl.RunnableAsAsyncSubsys(m3iRun,changeLogger);
                end
            case 'FunctionCallSubsystem'
                if autosar.mm.mm2sl.RunnableHelper.isServerRunnable(m3iRun)||...
                    autosar.mm.mm2sl.RunnableHelper.isInternallyTriggeredRunnable(m3iRun)
                    runnableBuilder=autosar.mm.mm2sl.RunnableAsSimulinkFunction(m3iRun,changeLogger);
                else
                    runnableBuilder=autosar.mm.mm2sl.RunnableAsFcnCallSubsys(m3iRun,changeLogger);
                end
            otherwise
                assert(false,'modelPeriodicRunnablesAs should either be AtomicSubsystem or FunctionCallSubsystem.');
            end

        end
    end
end


