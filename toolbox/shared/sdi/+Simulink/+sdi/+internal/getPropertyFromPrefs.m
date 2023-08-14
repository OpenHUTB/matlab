function ret=getPropertyFromPrefs(propName)
    prefs=Simulink.sdi.internal.Engine.getPrefOptions();
    ret=prefs.(propName);
end