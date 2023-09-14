classdef BrowserInterfaceFactory

    enumeration
browser
webwindow
connector
uifigure
    end

    methods(Static)
        function names=browserInterfaceNames()
            en=enumeration('map.webmap.internal.BrowserInterfaceFactory');
            names=string(en);
        end


        function name=browserInterfaceDefaultName()
            env=map.webmap.internal.BrowserInterfaceEnvironmentManager.instance();
            name=string(env.BrowserInterfaceFactory);
        end


        function browserIfc=createBrowserInterface(name)
            factory=map.webmap.internal.BrowserInterfaceFactory(name);
            switch factory
            case map.webmap.internal.BrowserInterfaceFactory.uifigure


                browserIfc=map.webmap.internal.UIHTMLBrowserInterface;

            case map.webmap.internal.BrowserInterfaceFactory.browser


                browserIfc=map.webmap.internal.ExternalBrowserInterface;

            case map.webmap.internal.BrowserInterfaceFactory.webwindow


                browserIfc=map.webmap.internal.WebWindowBrowserInterface;

            case map.webmap.internal.BrowserInterfaceFactory.connector


                browserIfc=map.webmap.internal.ConnectorWebWindowBrowserInterface;

            otherwise
                browserIfc=map.webmap.internal.WebMapBrowserInterface;
            end
        end

        function browserIfc=createDefaultBrowserInterface()
            name=map.webmap.internal.BrowserInterfaceFactory.browserInterfaceDefaultName;
            browserIfc=map.webmap.internal.BrowserInterfaceFactory.createBrowserInterface(name);
        end
    end
end
