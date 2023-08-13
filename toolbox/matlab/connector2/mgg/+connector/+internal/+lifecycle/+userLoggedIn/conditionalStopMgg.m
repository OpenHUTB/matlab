function conditionalStopMgg(clientType)

    if~contains(clientType,{'motw','matlab-academy','jsd_rmt'})
        mls.internal.feature('graphicsAndGuis','off');

        connector.internal.setMobilePreferences(clientType);
    end

    try

        s=settings;
        s.matlab.graphics.showinteractioninfobar.TemporaryValue=false;
        clear s;
    catch ignore
    end
end
