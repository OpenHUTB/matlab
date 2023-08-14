classdef WindowManager





    methods(Static)
        function didOpenNew=openInCEF(url)
            cefWindow=systemcomposer.allocation.internal.editor.WindowManager.getCEFWithURL(url);
            if(numel(cefWindow)==0)

                didOpenNew=true;
                systemcomposer.allocation.internal.editor.WindowManager.createCEFWithURL(url)
            else
                didOpenNew=false;
                for i=1:numel(cefWindow)
                    cefWindow(i).bringToFront;
                end
            end
        end

        function openInBrowser(url)
            url=connector.getUrl(url);
            web(url,'-browser');
        end

        function closeCEFWithURL(url)
            try
                cefWindow=systemcomposer.allocation.internal.editor.WindowManager.getCEFWithURL(url);
                for i=1:numel(cefWindow)
                    cefWindow(i).close();
                    cefWindow(i).delete();
                end
            catch
                return;
            end
        end

        function showStudio()
            appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
            if~appCatalog.isStudioOpenInDebug
                appCatalog.showStudio;
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


                urlToFind=urlToFind(1:strfind(urlToFind,'&syntax=')-1);

                for i=1:numel(openedWindows)
                    openedUrl=openedWindows(i).URL;


                    openedUrl=openedUrl(1:strfind(openedUrl,'&syntax=')-1);

                    if(strcmp(urlToFind,openedUrl))
                        cef=[cef,openedWindows(i)];%#ok<AGROW>
                    end
                end
            catch
            end
        end

        function createCEFWithURL(url)
            url=connector.getUrl(url);
            position=systemcomposer.allocation.internal.editor.WindowManager.getDefaultPosition;
            opts={'Position';position};
            this.CEFWindow=matlab.internal.webwindow(url,opts{:});
            this.CEFWindow.CustomWindowClosingCallback=@systemcomposer.allocation.internal.editor.WindowManager.handleCloseEditor;
            iconExt='.png';
            if ispc
                iconExt='.ico';
            end
            iconPath=fullfile(matlabroot,'toolbox','systemcomposer',...
            'allocation','allocation',['allocSetIcon',iconExt]);
            this.CEFWindow.Icon=iconPath;
            this.CEFWindow.setMinSize([350,350]);
            this.CEFWindow.show();
            this.CEFWindow.bringToFront();
        end

        function handleCloseEditor(obj,~)

            appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
            allocSets=appCatalog.getAllocationSets;
            unsavedAllocSets=[];
            for i=1:numel(allocSets)
                if allocSets(i).p_IsDirty
                    unsavedAllocSets=[unsavedAllocSets,allocSets(i)];%#ok<AGROW>
                end
            end

            if~isempty(unsavedAllocSets)
                response=questdlg(...
                DAStudio.message('SystemArchitecture:AllocationAPI:UnsavedAllocSetsQuestion'),...
                DAStudio.message('SystemArchitecture:AllocationAPI:UnsavedAllocSetsTitle'),...
                DAStudio.message('SystemArchitecture:AllocationAPI:Save'),...
                DAStudio.message('SystemArchitecture:AllocationAPI:Discard'),...
                DAStudio.message('SystemArchitecture:AllocationAPI:Cancel'),...
                DAStudio.message('SystemArchitecture:AllocationAPI:Save'));
                switch response
                case DAStudio.message('SystemArchitecture:AllocationAPI:Save')

                    for i=1:numel(unsavedAllocSets)
                        appCatalog.saveAllocationSet(unsavedAllocSets(i).getName,'');
                    end
                case DAStudio.message('SystemArchitecture:AllocationAPI:Discard')

                    for i=1:numel(unsavedAllocSets)
                        appCatalog.closeAllocationSet(unsavedAllocSets(i).getName,true);
                    end
                otherwise

                end
            end

            obj.close();
            obj.delete();
        end

        function position=getDefaultPosition(~)


            graphObj=groot;
            width=1360;
            height=800;
            screenWidth=graphObj.ScreenSize(3);
            screenHeight=graphObj.ScreenSize(4);
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

            position=[xOffset,yOffset,width,height];
        end
    end
end

