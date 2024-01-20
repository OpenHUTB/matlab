function clearPreferences()

    Simulink.sdi.internalClearPreferences;

    eng=Simulink.sdi.Instance.engine;
    prefs=eng.getPrefOptions();
    Simulink.sdi.enablePCTSupport(prefs.pctSupportMode);
end