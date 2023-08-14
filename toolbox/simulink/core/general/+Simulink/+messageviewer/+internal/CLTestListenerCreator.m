classdef CLTestListenerCreator<handle



    methods(Access='private')
        function obj=CLTestListenerCreator()
            obj.m_listener_count=0;
        end

        function delete(this)
        end
    end



    methods(Static=true,Access='private')
        function obj=getStaticInst(aCreateIfNecessary)
            persistent s_self_Inst;
            if(aCreateIfNecessary)
                if(isempty(s_self_Inst))
                    s_self_Inst=Simulink.messageviewer.internal.CLTestListenerCreator();
                end
            end
            obj=s_self_Inst;
        end

    end



    methods(Static=true)
        function obj=createListener(aListenerFcn)
            inst=Simulink.messageviewer.internal.CLTestListenerCreator.getStaticInst(true);
            obj=Simulink.messageviewer.internal.CLTestListener(inst,aListenerFcn);
        end

        function notifyRecord(aRecord)
            inst=Simulink.messageviewer.internal.CLTestListenerCreator.getStaticInst(false);
            if isempty(inst)
                return;
            end
            notify(inst,'PushCLMsgEvent',Simulink.messageviewer.internal.PushMsgEventData(aRecord));
        end

        function notifyCreation(aCreator)
            inst=Simulink.messageviewer.internal.CLTestListenerCreator.getStaticInst(false);
            assert(isequal(inst,aCreator),...
            'Assertion: Illegal creation of CLTestListener!');
        end

        function incrementListenerCount()
            inst=Simulink.messageviewer.internal.CLTestListenerCreator.getStaticInst(false);
            if isempty(inst)
                return;
            end
            inst.m_listener_count=inst.m_listener_count+1;
            Simulink.output.internal_setCLTestListenerStatus(true);
        end

        function decrementListenerCount()
            inst=Simulink.messageviewer.internal.CLTestListenerCreator.getStaticInst(false);
            if isempty(inst)
                return;
            end
            assert(inst.m_listener_count>0,...
            'Assertion: Un-matched de-registration of CLTestListener');
            inst.m_listener_count=inst.m_listener_count-1;
            if(inst.m_listener_count==0)
                Simulink.output.internal_setCLTestListenerStatus(false);
            end
        end
    end

    events
        PushCLMsgEvent;
    end

    properties
        m_listener_count=0;
    end

end
