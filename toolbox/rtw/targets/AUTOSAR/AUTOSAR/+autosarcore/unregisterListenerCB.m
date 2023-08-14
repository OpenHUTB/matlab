




function success=unregisterListenerCB(m3iObject)
    success=false;


    if~isempty(m3iObject)

        try
            M3I.unregisterObservingListener(m3iObject,...
            'autosar.ui.utils.listenerCallback');
            success=true;
        catch me %#ok<NASGU>

        end
    end
end


