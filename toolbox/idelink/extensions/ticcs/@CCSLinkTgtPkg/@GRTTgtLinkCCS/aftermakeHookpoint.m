function target_state=aftermakeHookpoint(h,target_state,modelInfo)









    additionalSrcFiles={[matlabroot,'\rtw\c\src\rt_sim.c']};
    target_state=i_aftermakeHookpoint(h,...
    target_state,...
    'CCSLinkTgtPkg',...
    modelInfo,...
    additionalSrcFiles);
