function out=removeAllEventsFixit(model)

    out='';

    em=sltp.EventManager(model);
    events=em.getEvents();

    for event=events
        em.removeEvent(event)
    end

end