function schema=streamStateflowStateActivity(cbinfo,objectType)





    import Simulink.sdi.internal.SignalObserverMenu;

    schema=SignalObserverMenu.getStateflowSchema(cbinfo,objectType);

end