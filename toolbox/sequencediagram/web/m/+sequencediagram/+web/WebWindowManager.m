classdef WebWindowManager<handle






    properties
        webWindows;
    end

    methods(Access=private)
        function obj=WebWindowManager()
            obj.webWindows=containers.Map();
        end
    end

    methods





        function CEFWindow=createWebWindow(obj,windowId,props)
            assert(~obj.hasWebWindow(windowId),...
            "The web window with the ID "+windowId+" already exist");
            assert(~isempty(props.URL),...
            "URL for the web window must be specified");
            assert(~isempty(props.Title),...
            "Title for the web window must be specified");
            position=[100,100,1000,800];
            opts={'Position';position};
            if isfield(props,'debugPort')

                opts=[opts;'DebugPort';props.debugPort];
            end
            CEFWindow=matlab.internal.webwindow(props.URL,opts{:});
            CEFWindow.setMinSize([350,350]);
            CEFWindow.Title=props.Title;
            CEFWindow.CustomWindowClosingCallback=props.closeCallback;

            CEFWindow.show();
            CEFWindow.bringToFront();

            obj.webWindows(windowId)=CEFWindow;
        end

        function CEFWindow=getWebWindow(obj,windowId)
            assert(obj.hasWebWindow(windowId),...
            "The web window with the ID "+windowId+" does not exist");

            CEFWindow=obj.webWindows(windowId);
        end

        function exist=hasWebWindow(obj,windowId)
            exist=obj.webWindows.isKey(windowId);
        end

        function destroyWebWindow(obj,windowId)
            if(obj.hasWebWindow(windowId))
                CEFWindow=obj.webWindows(windowId);
                if(CEFWindow.isvalid&&CEFWindow.isWindowValid())
                    CEFWindow.close();
                    delete(CEFWindow);
                end
                remove(obj.webWindows,windowId);
            end
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent uniqueObj;
            if(isempty(uniqueObj))
                uniqueObj=sequencediagram.web.WebWindowManager();
            end
            obj=uniqueObj;

        end

        function closeWebWindow(windowId)
            webWindowMgr=sequencediagram.web.WebWindowManager.getInstance();
            webWindowMgr.destroyWebWindow(windowId);
        end
    end
end

