classdef BrowserInterfaceEnvironmentManager<handle

    properties

        BrowserInterfaceFactory map.webmap.internal.BrowserInterfaceFactory
    end

    methods(Access=private)
        function this=BrowserInterfaceEnvironmentManager()
        end
    end


    methods(Static)
        function this=instance()
mlock
            persistent uniqueInstanceOfBrowserEnvironmentManager
            if isempty(uniqueInstanceOfBrowserEnvironmentManager)||~isvalid(uniqueInstanceOfBrowserEnvironmentManager)
                this=map.webmap.internal.BrowserInterfaceEnvironmentManager();




                hasLocalClient=matlab.internal.lang.capability.Capability.isSupported('LocalClient');
                if hasLocalClient
                    this.BrowserInterfaceFactory=map.webmap.internal.BrowserInterfaceFactory.uifigure;
                else
                    this.BrowserInterfaceFactory=map.webmap.internal.BrowserInterfaceFactory.connector;
                end
                uniqueInstanceOfBrowserEnvironmentManager=this;
            else
                this=uniqueInstanceOfBrowserEnvironmentManager;
            end
        end
    end
end
