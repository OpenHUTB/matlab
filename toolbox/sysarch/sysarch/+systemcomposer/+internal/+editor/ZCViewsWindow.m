classdef ZCViewsWindow





    properties(Constant)
        WindowSize=[100,100,1500,1000];
    end

    methods(Static)
        function openInCEF(url)
            url=connector.getUrl(url);
            geometry=systemcomposer.internal.editor.ZCViewsWindow.WindowSize;
            opts={'Position';geometry};
            this.CEFWindow=matlab.internal.webwindow(url,opts{:});
            iconExt='.png';
            if ispc
                iconExt='.ico';
            end
            iconPath=fullfile(matlabroot,'toolbox','sysarch',...
            'sysarch','+systemcomposer','+internal',...
            '+editor',['openArchitectureViews_16',iconExt]);
            this.CEFWindow.Icon=iconPath;
            this.CustomCloseCB=@()delete(this);
            this.CEFWindow.setMinSize([350,350]);

            this.CEFWindow.show();
            this.CEFWindow.bringToFront();
        end

        function openInBrowser(url)
            url=connector.getUrl(url);
            web(url,'-browser');
        end

        function closeCEFWithURL(url)
            try
                cefWindow=systemcomposer.internal.editor.ZCViewsWindow.getCEFWithURL(url);
                for i=1:numel(cefWindow)
                    cefWindow(i).close();
                    cefWindow(i).delete();
                end
            catch
                return;
            end
        end

        function showStudio(url)
            cefWindow=systemcomposer.internal.editor.ZCViewsWindow.getCEFWithURL(url);
            if(numel(cefWindow)==0)

                systemcomposer.internal.editor.ZCViewsWindow.openInCEF(url)
            else
                for i=1:numel(cefWindow)
                    cefWindow(i).bringToFront;
                end
            end
        end

        function updateCEFTitle(url,modelName,isDirty)
            if isDirty
                title=[modelName,' * - ',char(message('SystemArchitecture:ViewsToolstrip:Title').string)];
            else
                title=[modelName,' - ',char(message('SystemArchitecture:ViewsToolstrip:Title').string)];
            end

            cefWindow=systemcomposer.internal.editor.ZCViewsWindow.getCEFWithURL(url);
            for i=1:numel(cefWindow)
                cefWindow(i).Title=title;
            end
        end
    end

    methods(Static,Hidden)
        function cef=getCEFWithURL(url)
            cef=[];
            try
                wm=matlab.internal.webwindowmanager.instance;
                openedWindows=wm.windowList;


                urlToFind=connector.getUrl(url);


                urlToFind=urlToFind(1:strfind(urlToFind,'&snc=')-1);


                urlToFind=urlToFind(1:strfind(urlToFind,'&syntax=')-1);

                for i=1:numel(openedWindows)
                    openedUrl=openedWindows(i).URL;

                    openedUrl=openedUrl(1:strfind(openedUrl,'&snc=')-1);


                    openedUrl=openedUrl(1:strfind(openedUrl,'&syntax=')-1);

                    if(strcmp(urlToFind,openedUrl))
                        cef=[cef,openedWindows(i)];
                    end
                end
            catch
            end
        end
    end
end

