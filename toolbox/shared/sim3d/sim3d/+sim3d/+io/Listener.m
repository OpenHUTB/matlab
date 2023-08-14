classdef Listener<handle

    properties
        topic='';
        IsPublisherDisconnected=false;
    end

    methods
        function onSubscriptionChanged(self,info)

            if(info.kind==2)

                self.IsPublisherDisconnected=true;
            else

                self.IsPublisherDisconnected=false;
            end

        end
        function onLivelinessChanged(self,~)
            self.IsPublisherDisconnected=true;
        end

    end

end