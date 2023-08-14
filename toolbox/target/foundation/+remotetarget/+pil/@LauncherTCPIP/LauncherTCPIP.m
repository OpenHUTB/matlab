classdef(Hidden=true)LauncherTCPIP<linkfoundation.pil.Launcher





    properties(SetAccess='private',GetAccess='private')
        ArgString='';
        remoteobject='';
        username='';
        password='';
        builddir='';
    end

    methods
        function this=LauncherTCPIP(componentArgs,builder,boardParams)
            narginchk(3,3);

            this@linkfoundation.pil.Launcher(componentArgs,builder);
            assert(isa(boardParams,'remotetarget.util.BoardParameters'));
            [~,this.username,this.password,this.builddir]=boardParams.getBoardParameters();
        end

        function startApplication(this)
            executable=this.getBuilder.getApplicationExecutable;
            this.remoteobject=...
            remotetarget.util.sshDownload(executable,...
            linkfoundation.pil.getServerHostName,...
            this.username,...
            this.password,...
            this.builddir);
            this.remoteobject.download;
            this.remoteobject.launch;
        end

        function stopApplication(this)
            this.remoteobject.killExecutable;

        end

        function setArgString(this,argString)
            this.ArgString=argString;
        end
    end

    methods(Access='protected')

        function loadApplication(this,~)%#ok<INUSD>

        end

        function runApplication(this)%#ok<MANU>

        end

    end
end
