function varargout=desktop(option)














    mlock;

    if nargin>0
        switch option
        case '-inuse'
            if isJSDModeOn()
                varargout{1}=isJSDRunning();
            else
                varargout{1}=queryJavaDesktop();
            end
        case '-norestore'
            startupDesktop(false);
        otherwise
            error(message('MATLAB:desktop:FirstArgInvalid'));
        end
    else
        startupDesktop(true);
    end

    function startupDesktop(restorePreviousConfig)
        if isJSDModeOn()
            startupJSD(restorePreviousConfig);
        elseif usejava('swing')
            startupJavaDesktop(restorePreviousConfig)
        else

            error(message('MATLAB:desktop:UnsupportedConfiguration'));
        end
    end

    function running=isJSDRunning()
        running=matlab.desktop.internal.webdesktop('-inuse');
    end

    function JSDMode=isJSDModeOn()
        JSDMode=feature('webui');
    end

    function startupJSD(restore)
        import matlab.internal.lang.capability.Capability;

        if isJSDRunning()
            return;
        end


        Capability.require(Capability.InteractiveCommandLine);
        Capability.require(Capability.WebWindow);
        Capability.require(Capability.LocalClient);

        s=settings;
        if~restore
            s.matlab.desktop.RestoreDesktopConfig.TemporaryValue=false;
        else
            s.matlab.desktop.RestoreDesktopConfig.TemporaryValue=true;
        end

        try
            matlab.desktop.internal.webdesktop
            connector.ensureServiceOn
        catch

            s.matlab.desktop.RestoreDesktopConfig.TemporaryValue=true;
            error(message('MATLAB:desktop:DesktopFailure'));
        end
    end

    function startupJavaDesktop(restore)
        import matlab.internal.lang.capability.Capability;
        Capability.require(Capability.InteractiveCommandLine);
        try
            com.mathworks.mde.desk.MLDesktop.getInstance.useAsynchronousStartup(0);%#ok<*JAPIMATHWORKS>
            if restore
                com.mathworks.mde.desk.MLDesktop.getInstance.initMainFrame(0,1);%#ok<*JAPIMATHWORKS>
            else
                com.mathworks.mde.desk.MLDesktop.getInstance.initMainFrame(0,0);%#ok<*JAPIMATHWORKS>
            end
        catch
            error(message('MATLAB:desktop:DesktopFailure'));
        end
    end

    function out=queryJavaDesktop
        if~usejava('swing')
            out=false;
            return;
        end

        try
            out=com.mathworks.mde.desk.MLDesktop.getInstance.hasMainFrame;%#ok<*JAPIMATHWORKS>
        catch
            error(message('MATLAB:desktop:DesktopQueryFailure'));
        end
    end

end
