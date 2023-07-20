function listener=subscribe(eventName,functionHandle)




    eventHandler=evolutions.internal.session.SessionManager.getEventHandler;
    listener=subscribeEvent(eventHandler,eventName,functionHandle);
end
