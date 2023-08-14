classdef(Hidden=true)BreakpointLauncher<linkfoundation.pil.Launcher





    methods
        function this=BreakpointLauncher(componentArgs,...
            builder)
            narginchk(2,2);


            this@linkfoundation.pil.Launcher(componentArgs,builder);

            if this.isMakeFile()
                error(message('ERRORHANDLER:pjtgenerator:DebuggerPILNotSupportedInMakefile'));
            end
        end

        function stopApplication(this)

            stopApplication@linkfoundation.pil.Launcher(this);

            linkObject=this.getLinkObject;
            linkObject.remove(linkObject.address('pilDataBreakpoint'));
        end
    end

    methods(Access='protected')
        function loadApplication(this,applicationToLoad)

            loadApplication@linkfoundation.pil.Launcher(this,applicationToLoad);

            linkObject=this.getLinkObject;
            if(linkObject.isrunning)
                linkObject.halt;
            end
            linkObject.insert(linkObject.address('pilDataBreakpoint'));
        end

        function runApplication(this)
            linkObject=this.getLinkObject;

            linkObject.run('runtohalt');
        end
    end
end
