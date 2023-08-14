function eventSources=getTaskEventSources(mdlName)





    internalEventIdx=str2double(message('codertarget:utils:InternalIdx').getString());
    internalEventLbl=message('codertarget:utils:InternalEvent').getString();
    unspecifEventIdx=str2double(message('codertarget:utils:UnspecifiedIdx').getString());
    unspecifEventLbl=message('codertarget:utils:UnspecifiedEvent').getString();
    eventSources{internalEventIdx}=internalEventLbl;
    eventSources{unspecifEventIdx}=unspecifEventLbl;

    if codertarget.utils.isMdlConfiguredForSoC(getActiveConfigSet(mdlName))
        if socfeature('registerTestEventSources')
            eventSources{end+1}='ADC';
            eventSources{end+1}='Watchdog';
        end
    end

    isrNames=codertarget.interrupts.internal.getAllIrqNames(mdlName);
    if~isempty(isrNames)
        eventSources=[eventSources,isrNames];
    end
end
