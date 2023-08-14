function bIsVisible=getNodeIsVisible(h,bViewMasks,bViewLinks,bViewAll)





    bIsVisible=true;


    if~bViewLinks&&h.daobject.isLinked
        bIsVisible=false;
        return;
    end


    isSFMaskedSubSystem=h.daobject.isa('Simulink.Block')&&slprivate('is_stateflow_based_block',h.daobject.Handle);
    if~bViewMasks&&h.daobject.isMasked&&...
        ~isSFMaskedSubSystem
        bIsVisible=false;
        return;
    end



    if~bViewAll&&strcmp(class(h.daobject),'Simulink.SubSystem')
        if~h.getHasLoggingSettingsHereOrBelow(bViewMasks,bViewLinks)
            bIsVisible=false;
            return;
        end
    end

end
