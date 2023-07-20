classdef(Hidden=true)LauncherTCPIP<linkfoundation.pil.Launcher




    properties
        ArgString='';
    end

    methods
        function this=LauncherTCPIP(componentArgs,builder)
            narginchk(2,2);

            this@linkfoundation.pil.Launcher(componentArgs,builder);
        end

        function stopApplication(this)

            stopApplication@linkfoundation.pil.Launcher(this);
        end

        function setArgString(this,argString)
            this.ArgString=argString;
        end
    end

    methods(Access='protected')
        function loadApplication(this,applicationToLoad)

            loadApplication@linkfoundation.pil.Launcher(this,...
            applicationToLoad);
        end
    end
end
