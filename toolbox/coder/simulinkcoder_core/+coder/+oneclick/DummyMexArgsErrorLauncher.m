classdef(Hidden=true)DummyMexArgsErrorLauncher<coder.oneclick.ILauncher





    properties(Access=private)
        MexArgs='';
    end

    methods
        function this=DummyMexArgsErrorLauncher(mexArgs)
            this.MexArgs=mexArgs;
        end

        function setExe(~)

        end

        function exe=getExe(~)

            exe='';
        end

        function startApplication(this,~,~)

            DAStudio.error(...
            'coder_xcp:host:ExtModeMexArgsUnbalancedQuote',...
            this.MexArgs);
        end

        function stopApplication(~,~,~)

        end

        function status=getApplicationStatus(~)

            status=rtw.connectivity.LauncherApplicationStatus.NOT_RUNNING;
        end

        function extModeEnable(~,~)

        end

        function componentCodePath=getComponentCodePath(~)

            componentCodePath=[];
        end
    end

end


