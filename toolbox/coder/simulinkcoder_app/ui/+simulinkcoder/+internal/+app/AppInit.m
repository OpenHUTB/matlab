classdef(Sealed)AppInit<handle
    methods(Access=private)
        function obj=AppInit
        end
    end

    methods(Static)
        function singleInst=getInstance
            persistent localInst
            if isempty(localInst)||~isvalid(localInst)
                localInst=simulinkcoder.internal.app.AppInit;
            end
            singleInst=localInst;
        end
    end

    properties(Access=private)
        SubscribersInitialized=false;
    end

    methods
        function initializeSubscribers(self)
            if~self.SubscribersInitialized
                self.SubscribersInitialized=true;

                Simulink.HMI.initializeSubscriber('/coder/coderApp','coder_app_message_handler',false);

                Simulink.HMI.initializeSubscriber('/prototypeTable/store','table_message_handler',false);
            end
        end
    end
end
