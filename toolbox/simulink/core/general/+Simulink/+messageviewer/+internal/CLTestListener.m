classdef CLTestListener<event.listener


    methods(Access='public')
        function obj=CLTestListener(aCreator,aListenerFcn)
            obj=obj@event.listener(aCreator,'PushCLMsgEvent',aListenerFcn)%#ok<MCSCT>
            Simulink.messageviewer.internal.CLTestListenerCreator.notifyCreation(aCreator);
            Simulink.messageviewer.internal.CLTestListenerCreator.incrementListenerCount();
        end

        function delete(this)
            Simulink.messageviewer.internal.CLTestListenerCreator.decrementListenerCount();
        end

    end

end
