function highlightSignalInSDI(runID,sigID)




    if runID&&sigID
        eng=Simulink.sdi.Instance().engine;
        if~isValidRunID(eng,runID)
            error(message('SDI:sdi:InvalidRunID'));
        end
        if~isValidSignalID(eng,sigID)
            error(message('SDI:sdi:InvalidSignalID'));
        end


        s=Simulink.sdi.getSignal(sigID);
        children=s.Children;
        if~isempty(children)
            s=children(1);
        end


        try
            s.Checked=true;
        catch me
            Simulink.sdi.view(Simulink.sdi.GUITabType.InspectSignals);
            pause(1);

            msgStr=me.message;
            titleStr=getString(message('SDI:sdi:mgError'));
            okStr=getString(message('SDI:sdi:OKShortcut'));
            Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
            'sdi',...
            titleStr,...
            msgStr,...
            {okStr},...
            0,...
            -1,...
            []);

            return
        end


        Simulink.sdi.view(Simulink.sdi.GUITabType.InspectSignals,s.ID);
    end
end
