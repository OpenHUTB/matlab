function invokeProfiler()





    type=matlab.internal.profileviewer.ProfilerType.MATLAB;
    matlab.internal.profileviewer.notifyUI('viewer',type);
    profileViewerService=matlab.internal.profileviewer.ProfileViewerService.getInstance(type);
    profileViewerService.startService();

end