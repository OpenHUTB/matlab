function workspace(NVPairs)
    %WORKSPACE 打开工作区浏览器来管理工作区
    %   WORKSPACE Opens the Workspace browser with a view of the variables
    %   in the current Workspace.  Displayed variables may be viewed,
    %   manipulated, saved, and cleared.
    %
    %   See also WHOS, OPENVAR, SAVE.

    %   Copyright 1984-2021 The MathWorks, Inc.

    arguments
        % Optional input argument
        NVPairs.Visible (1,1) logical = true
    end

    import matlab.internal.lang.capability.Capability;

    if desktop('-inuse') && (feature('webui') || ~Capability.isSupported(Capability.LocalClient)) 
        try
            rootApp = matlab.ui.container.internal.RootApp.getInstance();
            if rootApp.hasPanel('workspace')
                wbPanel = rootApp.getPanel('workspace');
                setWorkspacePanelProperties(wbPanel);
            else
                % wait for panel to become available
                rootAppListener = addlistener(rootApp, 'PropertyChanged', @(event, data)handleRootAppPropertyChange(data));
            end
        catch
            error(message('MATLAB:workspace:workspaceFailed'));
        end
    elseif feature('webui') && ~desktop('-inuse') % In JSD mode but JSD is not yet running
        error(message('MATLAB:desktop:desktopNotFoundCommandFailure'));
    else
        % Java Desktop
        % Check for required level of Java support
        Capability.require(Capability.InteractiveCommandLine);
        Capability.require(Capability.LocalClient);
        
        err = javachk('mwt', 'The Workspace browser');
        if (~isempty(err))
            error('MATLAB:workspace:UnsupportedPlatform', err.message);
        end

        % Launch or close the Workspace
        try
            if NVPairs.Visible
                % Call initprefs, which checks for components which have registered context menu
                % actions for certain datatypes
                initprefs;

                com.mathworks.mlservices.MLWorkspaceServices.invoke;
            else
                hDesktop = com.mathworks.mlservices.MatlabDesktopServices.getDesktop();
                hDesktop.closeWorkspaceBrowser();
            end
        catch
            error(message('MATLAB:workspace:workspaceFailed'));
        end
    end

    function handleRootAppPropertyChange(data)
        if data.PropertyName=="PanelLayout"
            wbPanel = rootApp.getPanel('workspace');
            setWorkspacePanelProperties(wbPanel);
            delete(rootAppListener)
        end
    end

    function setWorkspacePanelProperties(hPanel)
        if NVPairs.Visible
            if ~hPanel.Opened
                hPanel.Opened = true;
            end
            hPanel.Selected = true;
        else
            hPanel.Opened = false;
        end
    end
end




