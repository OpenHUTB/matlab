function[isEnabled,mode]=isPCTSupportEnabled()





    eng=Simulink.sdi.Instance.engine();
    isEnabled=isPCTSupportEnabled(eng);
    mode=eng.PCTSupportMode;
end
