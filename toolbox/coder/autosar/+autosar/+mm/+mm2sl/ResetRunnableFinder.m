classdef ResetRunnableFinder<autosar.mm.mm2sl.EventRunnableFinder





    methods(Access=public)
        function resetRunnables=find(obj,resetRunnables,m3iComp)
            assert(iscellstr(resetRunnables)||isstring(resetRunnables));
            for kReset=1:numel(resetRunnables)
                curRunnableName=resetRunnables{kReset};
                if curRunnableName==""


                    continue;
                end
                m3iResetRun=autosar.mm.Model.findRunnableByName(curRunnableName,m3iComp);
                if isempty(m3iResetRun)
                    DAStudio.error('autosarstandard:importer:ResetRunInvalid',curRunnableName);
                end


                if m3iResetRun.Events.size()>1
                    DAStudio.error('autosarstandard:importer:ResetRunTriggeredByMultipleEvents',curRunnableName);
                end


                for evtIdx=1:m3iResetRun.Events.size()
                    m3iEvt=m3iResetRun.Events.at(evtIdx);
                    if~obj.supportedEvent(m3iEvt)
                        DAStudio.error('autosarstandard:importer:ResetRunTriggeredByIncorrectEvent',curRunnableName,m3iEvt.Name);
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


