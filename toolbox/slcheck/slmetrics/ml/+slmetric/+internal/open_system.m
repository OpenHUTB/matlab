function open_system(componentID)




    isLinkedSF=Advisor.component.internal.isStateflowLibraryInstanceComponentID(componentID);
    if isLinkedSF
        sid=Advisor.component.internal.getLibraryObjectSID(componentID);
    else
        sid=componentID;
    end


    model=Simulink.ID.getModel(sid);

    if~bdIsLoaded(model)
        load_system(model);
    end



    if~Simulink.ID.isValid(sid)
        DAStudio.error('slcheck:metricengine:ComponentNotAvailable',sid);
    end

    try



        open_system(sid,'force');

        if strcmp(bdroot(sid),sid)
            open_system(sid);
        end
    catch



        Simulink.ID.hilite(sid);
    end
end