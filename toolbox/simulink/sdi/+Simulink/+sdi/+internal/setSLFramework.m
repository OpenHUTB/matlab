function setSLFramework





    if license('test','SIMULINK')
        interface=Simulink.sdi.internal.SLFramework;
        Simulink.sdi.internal.Framework.framework(interface);
    end

end
