classdef RunnableHelper<handle




    methods(Static)


        function[isInvoked,m3iEvent]=isInvokedByEvent(m3iRun,eventMetaClass)

            assert(isa(eventMetaClass,'M3I.ImmutableClass'),...
            'eventMetaClass is not a valid M3I.ImmutableClass.');

            isInvoked=false;
            m3iEvent=[];
            for evtIdx=1:m3iRun.Events.size()
                event=m3iRun.Events.at(evtIdx);
                if(event.MetaClass==eventMetaClass)

                    if(event.MetaClass==Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass)&&event.Period==0
                        continue
                    end
                    isInvoked=true;
                    m3iEvent=event;
                    break;
                end
            end
        end

        function hasConnections=hasIrvOrIOConnections(m3iRun)

            hasConnections=m3iRun.dataAccess.size()||m3iRun.ModeAccessPoint.size()...
            ||m3iRun.ModeSwitchPoint.size()||m3iRun.irvRead.size()||m3iRun.irvWrite.size();
        end

        function isSrvRun=isServerRunnable(m3iRun)
            isSrvRun=autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
            Simulink.metamodel.arplatform.behavior.OperationInvokedEvent.MetaClass);
        end

        function isIntTrigRun=isInternallyTriggeredRunnable(m3iRun)
            isIntTrigRun=autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
            Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent.MetaClass);
        end



        function periodicRunnablesCount=getPeriodicRunnablesCount(m3iComp)
            periodicRunnablesCount=0;
            if~autosar.composition.Utils.isM3IComposition(m3iComp)&&m3iComp.Behavior.isvalid()
                for rIndex=1:m3iComp.Behavior.Runnables.size()
                    m3iRun=m3iComp.Behavior.Runnables.at(rIndex);
                    if autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
                        Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass)
                        periodicRunnablesCount=periodicRunnablesCount+1;
                    end
                end
            end
        end
    end
end
