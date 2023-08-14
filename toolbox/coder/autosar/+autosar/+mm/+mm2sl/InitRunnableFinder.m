classdef InitRunnableFinder<autosar.mm.mm2sl.EventRunnableFinder





    properties(Constant,Access=public)
        UndefinedInitRunnableName='<Undefined>';
    end

    methods(Access=public)



        function this=InitRunnableFinder()
        end

        function initRunnable=find(~,initRunnable,m3iComp)



            if~isempty(initRunnable)
                if strcmp(initRunnable,autosar.mm.mm2sl.InitRunnableFinder.UndefinedInitRunnableName)

                    initRunnable='';
                    return;
                end


                m3iInitRun=autosar.mm.Model.findRunnableByName(initRunnable,m3iComp);
                if isempty(m3iInitRun)
                    DAStudio.error('RTW:autosar:invalidInitRunnable',initRunnable);
                end



                if m3iInitRun.Events.size()>1
                    DAStudio.error('autosarstandard:importer:InitRunTriggeredByMultipleEvents',initRunnable);
                end



                for evtIdx=1:m3iInitRun.Events.size()
                    m3iEvt=m3iInitRun.Events.at(evtIdx);
                    if~autosar.mm.mm2sl.InitRunnableFinder.supportedEvent(m3iEvt)
                        DAStudio.error('autosarstandard:importer:InitRunTriggeredByIncorrectEvent',initRunnable,m3iEvt.Name);
                    end
                end
            else

                initRunnables={};
                numRunnables=0;
                if m3iComp.Behavior.isvalid()
                    m3iBehavior=m3iComp.Behavior;
                    numRunnables=m3iBehavior.Runnables.size();
                    initEventIdx=logical([]);
                    for runIdx=1:numRunnables
                        m3iRun=m3iBehavior.Runnables.at(runIdx);
                        [isInitRunnable,isRunnableTriggeredByInitEvent]=...
                        autosar.mm.mm2sl.InitRunnableFinder.isInitRunnable(m3iRun);
                        if isInitRunnable
                            initRunnables=[initRunnables,m3iRun.Name];%#ok<AGROW>
                            initEventIdx=[initEventIdx,isRunnableTriggeredByInitEvent];%#ok<AGROW>
                        end
                    end
                end


                initRunnable='';
                if numRunnables>1
                    if length(initRunnables)==1
                        initRunnable=initRunnables{1};
                    elseif length(initRunnables(initEventIdx))==1



                        initRunnable=initRunnables{initEventIdx};
                    end
                end
            end
        end
    end

    methods(Static,Access=public)

        function isSupported=supportedEvent(m3iEvent)

            switch m3iEvent.getMetaClass()
            case{...
                Simulink.metamodel.arplatform.behavior.InitEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.ModeSwitchEvent.MetaClass...
                }
                isSupported=true;
            case{...
                Simulink.metamodel.arplatform.behavior.DataReceiveErrorEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.DataReceivedEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.DataSendCompletedEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.DataWriteCompletedEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.OperationInvokedEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.ExternalTriggerOccurredEvent.MetaClass...
                ,Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent.MetaClass...
                }
                isSupported=false;
            case Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass
                isSupported=(m3iEvent.Period==0);
            otherwise
                assert(false,'Did not recognize event type %s',m3iEvent.getMetaClass().qualifiedName);
            end
        end

    end

    methods(Static,Access=private)

        function[isInitRunnable,isTriggeredByInitEvent]=isInitRunnable(m3iRun)

            isInitRunnable=false;
            isTriggeredByInitEvent=false;

            if m3iRun.Events.isEmpty()
                isInitRunnable=true;
            else
                for evtIdx=1:m3iRun.Events.size()
                    m3iEvt=m3iRun.Events.at(evtIdx);
                    isInitRunnable=autosar.mm.mm2sl.InitRunnableFinder.supportedEvent(m3iEvt);
                    if~isInitRunnable
                        break;
                    end
                end


                if isInitRunnable
                    isTriggeredByInitEvent=(m3iEvt.getMetaClass()==...
                    Simulink.metamodel.arplatform.behavior.InitEvent.MetaClass);
                end
            end
        end
    end
end




