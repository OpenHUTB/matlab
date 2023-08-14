function name=constructEventName(eventID)




    prefix=DAStudio.message('soc:scheduler:CustomEventNamePrefix');
    name=[prefix,eventID];
end
