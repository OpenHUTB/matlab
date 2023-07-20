classdef(Abstract,Hidden)OfficeApp<handle






















    properties(Abstract,Constant)
Name
    end

    properties(Access=private)
NETObj
    end

    methods(Abstract,Static)
instance
    end

    methods(Abstract)
        show(this)
        hide(this)
        tf=close(this,varargin)
        tf=isVisible(this)
    end

    methods
        function this=OfficeApp()
            import matlab.internal.lang.capability.Capability

            if~ispc()
                error(message("mlreportgen:utils:error:supportedOnlyOnWindows"));
            end

            if~Capability.isSupported(Capability.LocalClient)
                error(message("mlreportgen:utils:error:OfficeAutomationRemoteClient"));
            end

            if~Capability.isSupported(Capability.InteractiveCommandLine)
                error(message("mlreportgen:utils:error:OfficeAutomationNoninteractiveSession"));
            end


            NET.addAssembly("system");
            cp=System.Diagnostics.Process.GetCurrentProcess;
            if(cp.SessionId==0)
                error(message("mlreportgen:utils:error:OfficeAutomationSession0"));
            end
        end

        function delete(this)
            if isOpen(this)
                close(this);
            end
        end

        function hNETObj=netobj(this)





            if~isOpen(this)
                error(message("mlreportgen:utils:error:appClosed",this.Name));
            end
            hNETObj=this.NETObj;
        end

        function tf=isOpen(this)





            try
                if~isempty(this.NETObj)
                    this.NETObj.Version;
                    tf=true;
                else
                    tf=false;
                end
            catch
                reset(this,[]);
                tf=false;
            end
        end
    end

    methods(Access=protected)
        function reset(this,hNETObj)
            this.NETObj=hNETObj;
        end
    end
end