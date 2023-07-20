classdef ProfileEditorWindows







    properties(Constant,Hidden)
        REL_URL='toolbox/systemcomposer/profile/editor/index.html';
        DEBUG_URL='toolbox/systemcomposer/profile/editor/index-debug.html';
    end
    properties(Access=public)
        mdl;
        channel;
        sync;
    end




    properties(Access=private)
        CEFWindow;
    end



    methods(Static)


        function didOpenNew=openInCEF(url)
            cefWindow=systemcomposer.internal.profile.ProfileEditorWindows.getCEFWithURL(url);
            if(numel(cefWindow)==0)

                didOpenNew=true;
                systemcomposer.internal.profile.ProfileEditorWindows.createCEFWithURL(url)
            else
                didOpenNew=false;
                for i=1:numel(cefWindow)
                    cefWindow(i).bringToFront;
                end
            end
        end

        function closeCEFWithURL(url)
            try
                cefWindow=systemcomposer.internal.profile.ProfileEditorWindows.getCEFWithURL(url);
                for i=1:numel(cefWindow)
                    cefWindow(i).close();
                    cefWindow(i).delete();
                end
            catch
                return;
            end
        end

        function openInBrowser(url)
            url=connector.getUrl(url);
            web(url,'-browser');
        end

        function showStudio()
            app=systemcomposer.internal.profile.app.ProfileEditorApp.getInstance();
            if~app.isStudioOpenInDebug
                app.showStudio;
            end
        end
    end




    methods(Hidden,Static)


        function isDebug=debugMode(varargin)

            profileCatalog=systemcomposer.internal.profile.ProfileCatalog.getInstance;
            if~profileCatalog.isStudioOpenInDebug
                isDebug=false;
            else
                isDebug=true;
            end
        end



        function ret=getGeometry(~)
            width=1200;
            height=800;

            r=groot;
            screenWidth=r.ScreenSize(3);
            screenHeight=r.ScreenSize(4);
            maxWidth=0.8*screenWidth;
            maxHeight=0.8*screenHeight;
            if maxWidth>0&&width>maxWidth
                width=maxWidth;
            end
            if maxHeight>0&&height>maxHeight
                height=maxHeight;
            end

            xOffset=(screenWidth-width)/2;
            yOffset=(screenHeight-height)/2;

            ret=[xOffset,yOffset,width,height];
        end

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

        function createCEFWithURL(url)
            url=connector.getUrl(url);
            position=systemcomposer.internal.profile.ProfileEditorWindows.getGeometry;
            opts={'Position';position};
            this.CEFWindow=matlab.internal.webwindow(url,opts{:});
            this.CEFWindow.CustomWindowClosingCallback=@systemcomposer.internal.profile.ProfileEditorWindows.handleCloseEditor;
            iconExt='.png';
            if ispc
                iconExt='.ico';
            end
            this.CEFWindow.setMinSize([350,350]);
            this.CEFWindow.show();
            this.CEFWindow.bringToFront();
        end

        function handleCloseEditor(obj,~)
            obj.close();
            obj.delete();
        end
    end
end

