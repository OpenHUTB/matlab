classdef TerminateRunnableFinder<autosar.mm.mm2sl.EventRunnableFinder





    methods(Access=public)
        function terminateRunnable=find(obj,terminateRunnable,m3iComp)
            if isempty(terminateRunnable)
                terminateRunnable='';
            else
                m3iTerminateRun=autosar.mm.Model.findRunnableByName(terminateRunnable,m3iComp);
                if isempty(m3iTerminateRun)
                    DAStudio.error('autosarstandard:importer:TerminateRunInvalid',terminateRunnable);
                end


                if m3iTerminateRun.Events.size()>1
                    DAStudio.error('autosarstandard:importer:TerminateRunTriggeredByMultipleEvents',terminateRunnable);
                end


                for evtIdx=1:m3iTerminateRun.Events.size()
                    m3iEvt=m3iTerminateRun.Events.at(evtIdx);
                    if~obj.supportedEvent(m3iEvt)
                        DAStudio.error('autosarstandard:importer:TerminateRunTriggeredByIncorrectEvent',terminateRunnable,m3iEvt.Name);
                    end
                end
            end
        end
    end

    methods(Static,Access=public)

        function isSupported=supportedEvent(m3iEvent)

            switch m3iEvent.getMetaClass()
            case{...
                Simulink.metamodel.arplatform.behavior.ExternalTriggerOccurredEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.ModeSwitchEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.InitEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.DataReceiveErrorEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.DataReceivedEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.DataSendCompletedEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.DataWriteCompletedEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.OperationInvokedEvent.MetaClass...
                }
                isSupported=true;
            case{...
                Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass
                }
                isSupported=false;
            otherwise
                assert(false,'Did not recognize event type %s',m3iEvent.getMetaClass().qualifiedName);
            end
        end

    end
end
