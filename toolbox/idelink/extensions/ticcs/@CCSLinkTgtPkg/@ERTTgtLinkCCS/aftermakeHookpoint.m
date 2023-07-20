function target_state=aftermakeHookpoint(h,...
    target_state,...
    modelInfo)










    additionalSrcFiles={};

    target_state=i_aftermakeHookpoint(h,...
    target_state,...
    'CCSLinkTgtPkg',...
    modelInfo,...
    additionalSrcFiles);
