function firePropertyChange(h)




    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyChangedEvent',h);

