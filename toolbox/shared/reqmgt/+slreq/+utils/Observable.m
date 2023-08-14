



classdef Observable<handle

    properties


        eventListeners;
    end

    methods

        function this=Observable()
            this.eventListeners=containers.Map('KeyType','char','ValueType','Any');
        end


        function delete(this)
            this.clearObservers();
        end




        function added=registerListener(this,eventType,fcnHandle)
            added=false;
            eventListener=[];
            if this.eventListeners.isKey(eventType)
                eventListener=this.eventListeners(eventType);
            end

            if isempty(eventListener)
                eventListener=addlistener(this,eventType,fcnHandle);
                this.eventListeners(eventType)=eventListener;
                added=true;
            end
        end

        function unregisterListener(this,eventType)
            if this.eventListeners.isKey(eventType)
                eventListener=this.eventListeners(eventType);
                delete(eventListener);
                this.eventListeners.remove(eventType);
            end
        end


        function clearObservers(this)
            lstrns=this.eventListeners.values();
            for i=1:length(lstrns)
                delete(lstrns{i});
            end
            this.eventListeners.remove(this.eventListeners.keys());
        end


        function notifyObservers(this,eventType,eventData)
            if any(event.hasListener(this,eventType))
                this.notify(eventType,eventData);
            end
        end

    end
end

