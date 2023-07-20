function refresh
    % This function will refresh the Workspace Browser
    
    % Copyright 2020-2021 The MathWorks, Inc.
    
    import matlab.internal.lang.capability.Capability;

    % TODO: Remove once JSD is default
    if usejava('jvm') && Capability.isSupported(Capability.LocalClient)
        % Call the Java method to refresh the Java Workspace Browser
        com.mathworks.mde.workspace.WorkspaceBrowser.refresh();
    else
        % Trigger a Workspace Event as if the workspace changed, causing the
        % entire Workspace Browser list to be re-evaluated and redisplayed if
        % necessary.
        internal.matlab.datatoolsservices.WorkspaceListener.workspaceUpdatedCorrectContext(...
            [], false, ...
            internal.matlab.datatoolsservices.WorkspaceEventType.WORKSPACE_CHANGED);
    end
end
