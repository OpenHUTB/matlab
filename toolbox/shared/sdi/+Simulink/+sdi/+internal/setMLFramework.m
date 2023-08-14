function setMLFramework






    if isempty(Simulink.sdi.internal.Framework.framework)
        interface=Simulink.sdi.internal.MLFramework;
        Simulink.sdi.internal.Framework.framework(interface);
    end
end
