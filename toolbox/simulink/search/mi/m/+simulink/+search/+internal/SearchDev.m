


classdef SearchDev<handle
    methods(Access=public)
    end

    methods(Static,Access=public)
        function showInspector()
            import simulink.search.internal.Util;
            comp=Util.getFinderComponent();
            if isempty(comp)
                disp('Cannot find finder component.');
                return;
            end
            comp.showInspector();
        end

        function showRevertInspector()
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            title='Revert replace';
            if~isempty(allStudios)
                studio=allStudios(1);
                modelName=get_param(studio.App.blockDiagramHandle,'Name');
                title=[title,' - ',modelName];
            end
            windowList=matlab.internal.webwindowmanager.instance.windowList;
            blockIconStudioWindow=windowList(...
            strcmp({windowList.Title},title)...
            );
            blockIconStudioWindow.executeJS('cefclient.sendMessage("openDevTools")');
        end

        function showFirstInspector()
            windowList=matlab.internal.webwindowmanager.instance.windowList;
            if isempty(windowList)
                return;
            end
            windowList(1).executeJS('cefclient.sendMessage("openDevTools")');
        end

        function fullViewMode()
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if isempty(allStudios)
                return;
            end
            studio=allStudios(1);
            studioTag=studio.getStudioTag();
            find_slobj('ChangeViewMode',studioTag,'fullView')
        end

        function showUnitTestAutoGen()
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(allStudios)
                studio=allStudios(1);
                modelName=get_param(studio.App.blockDiagramHandle,'Name');
            end
            connector.ensureServiceOn;
            dialogUrl=connector.getUrl(...
            ['/toolbox/simulink/search/web/test/unitTestAutoGen.html'...
            ,'?studioTag=',studio.getStudioTag()...
            ,'&test=false&viewMode=fullView']...
            );
            webWin=matlab.internal.webwindow(dialogUrl);
            webWin.show();
            webWin.executeJS('cefclient.sendMessage("openDevTools")');
        end

        function setDebugMode(isDebugMode)
            find_slobj('setDebugMode',isDebugMode);
        end
    end
end
