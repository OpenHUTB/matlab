function profiler
    matlab.internal.profileviewer.ProfileViewerService.getInstance(matlab.internal.profileviewer.ProfilerType.MATLAB).openExistingOrFreshViewer();
end