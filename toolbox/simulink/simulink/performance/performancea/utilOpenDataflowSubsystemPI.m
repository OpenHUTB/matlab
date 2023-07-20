function utilOpenDataflowSubsystemPI(sid)





    bp=Simulink.BlockPath(sid);
    bp.open();
    set_param(gcb,'Selected','off');
    Simulink.DomainSpecPropertyDDG.openDomainPropertyInspector('Subsystem');
end
