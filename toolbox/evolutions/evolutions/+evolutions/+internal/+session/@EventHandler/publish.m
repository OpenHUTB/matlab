function publish(eventName,varargin)




    eventHandler=evolutions.internal.session.SessionManager.getEventHandler;
    publishEvent(eventHandler,eventName,varargin{:});
end
