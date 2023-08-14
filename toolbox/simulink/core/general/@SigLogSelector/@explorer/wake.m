function wake(h)





    if(h.sleepCount>0)
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('MEWakeEvent');
        h.sleepCount=h.sleepCount-1;
    end

end
