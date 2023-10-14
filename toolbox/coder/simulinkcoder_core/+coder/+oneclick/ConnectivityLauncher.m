classdef ConnectivityLauncher < coder.oneclick.ILauncher

    properties ( Access = private )
        Launcher;
    end

    methods
        function this = ConnectivityLauncher( launcher )
            arguments
                launcher( 1, 1 )rtw.connectivity.Launcher
            end
            this.Launcher = launcher;
        end

        function setExe( this, exe )
            this.Launcher.setExe( exe );
        end

        function exe = getExe( this )
            exe = this.Launcher.getExe;
        end

        function startApplication( this )
            this.Launcher.startApplication;
        end

        function status = getApplicationStatus( this )
            status = this.Launcher.getApplicationStatus;
        end

        function stopApplication( this )
            this.Launcher.stopApplication;
        end

        function extModeEnable( this, enableConnection )
            if isa( this.Launcher, 'coder.oneclick.TCPIPHostLauncher' )
                this.Launcher.extModeEnable( enableConnection );
            end
        end

        function componentCodePath = getComponentCodePath( this )
            componentCodePath = this.Launcher.getComponentArgs.getComponentCodePath;
        end

        function launcher = getLauncher( this )

            launcher = this.Launcher;
        end
    end
end

