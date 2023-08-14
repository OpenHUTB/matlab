classdef ImageBrowserCore<handle




    properties(GetAccess={?uitest.factory.Tester},...
        SetAccess=private,Transient)
App

BrowserComponent
        ImdsLoadDialog=[]
        ExportDialog=[]

StatusBar
StatusLabel
CopyToClipBoardButton

AppFigureDocument
    end

    properties(Access=private,Transient)
ThumbnailFigureGroup
TabGroup
MainTab

NewSessionButton
AddSplitButton

SizeSlider
SlideLabel

TogglePreviewButton

Gallery
GalleryItems

ExportSplitButton


        ThumbnailFig=[]

PreviewPanel
        PreviewFig=[]
PreviewComponent

MouseMotionListeners
    end

    properties(Access=private)

CollectionName

        ThumbnailSize=[125,125];

        CurrentSelection=[];


        SelectionIndex=1;

        StatusText='';
        NotificationTimer=[];


FileList


InputDataStore


CurrentFigure

        FullImageCache=images.internal.app.imageBrowser.web.FullImageCache;
    end

    methods

        function tool=ImageBrowserCore()


            appOptions.Tag="ImageBrowser"+"_"+matlab.lang.internal.uuid;
            appOptions.Title=getString(message('images:imageBrowser:appName'));
            [x,y,width,height]=imageslib.internal.app.utilities.ScreenUtilities.getInitialToolPosition();
            appOptions.WindowBounds=[x,y,width,height];
            appOptions.Product="Image Processing Toolbox";
            appOptions.Scope="Image Browser";
            appOptions.CanCloseFcn=@(~)false;
            tool.App=matlab.ui.container.internal.AppContainer(appOptions);


            helpButton=matlab.ui.internal.toolstrip.qab.QABHelpButton();
            helpButton.ButtonPushedFcn=@(~,~)doc('imageBrowser');
            tool.App.add(helpButton);

            import matlab.ui.internal.toolstrip.*;
            tool.TabGroup=TabGroup();
            tool.TabGroup.Tag='MainTabGroup';
            tool.MainTab=Tab(getString(message('images:imageBrowser:Browse')));

            section=tool.MainTab.addSection(getString(message('images:imageBrowser:File')));

            c=section.addColumn();
            tool.NewSessionButton=Button(getString(message('images:imageBrowser:new')),Icon.NEW_24);
            tool.NewSessionButton.Tag='NewSession';
            tool.NewSessionButton.Enabled=false;
            tool.NewSessionButton.Description=getString(message('images:imageBrowser:newSessionToolTip'));
            tool.NewSessionButton.ButtonPushedFcn=@(varargin)tool.clearSession();
            c.add(tool.NewSessionButton);

            c=section.addColumn();
            tool.AddSplitButton=SplitButton(getString(message('images:imageBrowser:Add')),Icon.ADD_24);
            tool.AddSplitButton.Tag='Add';
            tool.AddSplitButton.Description=getString(message('images:imageBrowser:AddToolTip'));
            tool.AddSplitButton.ButtonPushedFcn=@(varargin)tool.loadFolderUI(false);
            tool.AddSplitButton.DynamicPopupFcn=@(x,y)buildDynamicPopupListForAddImages();
            c.add(tool.AddSplitButton);

            function popup=buildDynamicPopupListForAddImages()
                import matlab.ui.internal.toolstrip.*
                popup=PopupList();
                popup.Tag='AddButtonPopUp';

                item=ListItem(getString(message('images:imageBrowser:Folder')),Icon.OPEN_16);
                item.Tag='AddFolder';
                item.ShowDescription=false;
                item.ItemPushedFcn=@(varargin)tool.loadFolderUI(false);
                popup.add(item);

                item=ListItem(getString(message('images:imageBrowser:FolderWithSub')),Icon.OPEN_16);
                item.Tag='AddFolderAndSubfolders';
                item.ShowDescription=false;
                item.ItemPushedFcn=@(varargin)tool.loadFolderUI(true);
                popup.add(item);

                item=ListItem(getString(message('images:imageBrowser:IMDS')),Icon.ADD_16);
                item.Tag='AddDatastore';
                item.ShowDescription=false;
                item.ItemPushedFcn=@(varargin)tool.loadimdsUI();
                popup.add(item);
            end


            section=tool.MainTab.addSection(getString(message('images:imageBrowser:Thumbnails')));


            topCol=section.addColumn('width',150,...
            'HorizontalAlignment','center');
            tool.SizeSlider=Slider();
            tool.SizeSlider.Tag='ThumbnailSize';
            tool.SizeSlider.Description=getString(message('images:imageBrowser:ThumbnailSizeTooltip'));
            tool.SizeSlider.Enabled=false;
            tool.SizeSlider.Limits=[90,800];
            tool.SizeSlider.Ticks=5;
            tool.SizeSlider.Value=tool.ThumbnailSize(1);
            addlistener(tool.SizeSlider,'ValueChanging',@(varargin)tool.applyThumnailSizeChange);
            addlistener(tool.SizeSlider,'ValueChanged',@(varargin)tool.applyThumnailSizeChange);
            topCol.add(tool.SizeSlider);

            tool.SlideLabel=Label(getString(message('images:imageBrowser:ThumbnailSize')));
            tool.SlideLabel.Tag='ThumbnailSizeLabel';
            tool.SlideLabel.Enabled=false;
            topCol.add(tool.SlideLabel);



            section=tool.MainTab.addSection(getString(message('images:imageBrowser:Preview')));
            topCol=section.addColumn();
            tool.TogglePreviewButton=ToggleButton(getString(message('images:imageBrowser:Preview')),Icon.SEARCH_24);
            tool.TogglePreviewButton.Tag='Preview';
            tool.TogglePreviewButton.Description=getString(message('images:imageBrowser:PreviewTooltip'));
            tool.TogglePreviewButton.Enabled=false;
            tool.TogglePreviewButton.ValueChangedFcn=@(varargin)tool.togglePreview();
            topCol.add(tool.TogglePreviewButton);


            section=tool.MainTab.addSection(getString(message('images:commonUIString:Launcher')));
            topCol=section.addColumn();
            popup=GalleryPopup();
            popup.Tag='GalleryPopup';


            vizCat=GalleryCategory(getString(message('images:imageBrowser:Visualization')));
            vizCat.Tag='VisualizationCategory';
            analysisCat=GalleryCategory(getString(message('images:imageBrowser:Analysis')));
            analysisCat.Tag='AnalysisCategory';
            popup.add(vizCat);
            popup.add(analysisCat);


            imtoolIconImage=fullfile(matlabroot,'toolbox','images','icons','image_app_24.png');
            tool.GalleryItems.imtoolItem=GalleryItem(getString(message('images:desktop:Tool_imtool_Label')),Icon(imtoolIconImage));
            tool.GalleryItems.imtoolItem.Tag='Imtool';
            tool.GalleryItems.imtoolItem.Enabled=false;
            tool.GalleryItems.imtoolItem.Description=getString(message('images:desktop:Tool_imtool_Description'));
            tool.GalleryItems.imtoolItem.ItemPushedFcn=@(varargin)tool.launchImtool;
            vizCat.add(tool.GalleryItems.imtoolItem);


            colorThreshIcon=fullfile(matlabroot,'toolbox','images','icons','color_thresholder_24.png');
            tool.GalleryItems.colorThreshItem=GalleryItem(getString(message('images:desktop:Tool_colorThresholder_Label')),Icon(colorThreshIcon));
            tool.GalleryItems.colorThreshItem.Tag='ColorThresholder';
            tool.GalleryItems.colorThreshItem.Enabled=false;
            tool.GalleryItems.colorThreshItem.Description=getString(message('images:desktop:Tool_colorThresholder_Description'));
            tool.GalleryItems.colorThreshItem.ItemPushedFcn=@(varargin)tool.launchColorThresh;
            analysisCat.add(tool.GalleryItems.colorThreshItem);


            segAppIcon=fullfile(matlabroot,'toolbox','images','icons','imageSegmenter_AppIcon_24.png');
            tool.GalleryItems.segItem=GalleryItem(getString(message('images:desktop:Tool_imageSegmenter_Label')),Icon(segAppIcon));
            tool.GalleryItems.segItem.Tag='ImageSegmenter';
            tool.GalleryItems.segItem.Enabled=false;
            tool.GalleryItems.segItem.Description=getString(message('images:desktop:Tool_imageSegmenter_Description'));
            tool.GalleryItems.segItem.ItemPushedFcn=@(varargin)tool.launchSegApp;
            analysisCat.add(tool.GalleryItems.segItem);


            regionAnalyAppIcon=fullfile(matlabroot,'toolbox','images','icons','ImageRegionAnalyzer_AppIcon_24px.png');
            tool.GalleryItems.regionAnalyItem=GalleryItem(getString(message('images:desktop:Tool_imageRegionAnalyzer_Label')),Icon(regionAnalyAppIcon));
            tool.GalleryItems.regionAnalyItem.Tag='ImageRegionAnalyzer';
            tool.GalleryItems.regionAnalyItem.Enabled=false;
            tool.GalleryItems.regionAnalyItem.Description=getString(message('images:desktop:Tool_imageRegionAnalyzer_Description'));
            tool.GalleryItems.regionAnalyItem.ItemPushedFcn=@(varargin)tool.launchRegionApp;
            analysisCat.add(tool.GalleryItems.regionAnalyItem);

            tool.Gallery=Gallery(popup,'MaxColumnCount',3,'MinColumnCount',2);
            tool.Gallery.Tag='AppGallery';
            topCol.add(tool.Gallery);


            section=tool.MainTab.addSection(getString(message('images:commonUIString:export')));
            section.Tag='';
            c=section.addColumn();
            tool.ExportSplitButton=SplitButton(getString(message('images:commonUIString:export')),Icon.CONFIRM_24);
            tool.ExportSplitButton.Enabled=false;
            tool.ExportSplitButton.Tag='Export';
            tool.ExportSplitButton.Description=getString(message('images:imageBrowser:exportTooltip'));
            tool.ExportSplitButton.ButtonPushedFcn=@(varargin)tool.exportToDataStore(false);
            tool.ExportSplitButton.DynamicPopupFcn=@(x,y)buildDynamicPopupListForExportImages();
            c.add(tool.ExportSplitButton);

            function popup=buildDynamicPopupListForExportImages()
                import matlab.ui.internal.toolstrip.*
                popup=PopupList();
                popup.Tag='ExportButtonPopUp';

                item=ListItem(getString(message('images:imageBrowser:exportAll')),Icon.CONFIRM_16);
                item.Tag='ExportAll';
                item.ShowDescription=false;
                item.ItemPushedFcn=@(varargin)tool.exportToDataStore(false);
                popup.add(item);

                item=ListItem(getString(message('images:imageBrowser:exportSelected')),Icon.CONFIRM_16);
                item.Tag='ExportSelected';
                item.ShowDescription=false;
                item.ItemPushedFcn=@(varargin)tool.exportToDataStore(true);
                popup.add(item);
            end


            tool.StatusBar=matlab.ui.internal.statusbar.StatusBar();
            tool.StatusBar.Tag="statusBar";
            tool.StatusLabel=matlab.ui.internal.statusbar.StatusLabel();
            tool.StatusLabel.Tag="statusLabel";
            tool.StatusLabel.Text="";
            tool.StatusLabel.Region="right";
            tool.CopyToClipBoardButton=matlab.ui.internal.statusbar.StatusButton();
            tool.CopyToClipBoardButton.Tag="copyToClipBoardButton";
            tool.CopyToClipBoardButton.Icon=Icon.COPY_16;
            tool.CopyToClipBoardButton.ButtonPushedFcn=@tool.copyFileNameToClipBoard;
            tool.CopyToClipBoardButton.Region="right";
            tool.CopyToClipBoardButton.Enabled=false;
            tool.StatusBar.add(tool.CopyToClipBoardButton);
            tool.StatusBar.add(tool.StatusLabel);
            tool.App.add(tool.StatusBar);


            tool.TabGroup.add(tool.MainTab);
            tool.TabGroup.SelectedTab=tool.MainTab;
            tool.App.add(tool.TabGroup);


            tool.ThumbnailFigureGroup=matlab.ui.internal.FigureDocumentGroup();
            tool.ThumbnailFigureGroup.Title="ThumbnailGroup";
            tool.App.add(tool.ThumbnailFigureGroup);


            tool.App.Visible=true;
            if tool.App.State~=matlab.ui.container.internal.appcontainer.AppState.RUNNING
                waitfor(tool.App,'State');
            end
            if~isvalid(tool.App)||tool.App.State==matlab.ui.container.internal.appcontainer.AppState.TERMINATED
                return;
            end

            tool.FullImageCache.reset();

drawnow

            tool.App.CanCloseFcn=@(~)closeApp(tool);
        end


        function loadFolderUI(tool,recursiveTF)




            s=settings;
            prevFolder=s.images.imagebatchprocessingtool.BatchLocations.ActiveValue;
            if isempty(prevFolder)||~isfolder(prevFolder)

                prevFolder=pwd;
            else
                prevFolder=prevFolder{1};
            end

            dirname=uigetdir(prevFolder,getString(message('images:imageBrowser:SelectFolder')));
            if(dirname)
                tool.loadFolder(dirname,recursiveTF);
            end

            if ispc||ismac
                bringToFront(tool.App)
            end
        end

        function loadFolder(tool,dirname,recursiveTF)


            tool.showAsBusy;
            resetWait=onCleanup(@()tool.unshowAsBusy);

            tool.setNotificationMessage(getString(message('images:imageBrowser:loadingFolder',dirname)));

            try
                imds=imageDatastore(dirname,...
                'IncludeSubfolders',recursiveTF,...
                'ReadFcn',@images.internal.app.utilities.readAllIPTFormats,...
                'FileExtensions',images.internal.app.utilities.supportedFormats(true));

                dirname=char(dirname);
                if dirname(end)==filesep

                    dirname(end)=[];
                end
                if strcmp(dirname,'.')

                    dirname=pwd;
                end

                [~,collectionName]=fileparts(dirname);

                if isempty(tool.ThumbnailFig)||~isvalid(tool.ThumbnailFig)
                    tool.createThumbFigure(collectionName,imds);
                else
                    tool.addImagesFrom(imds);
                end


                s=settings;
                s.images.imagebatchprocessingtool.BatchLocations.PersonalValue={dirname};

            catch ALL
                if(strcmp(ALL.identifier,'MATLAB:datastoreio:pathlookup:emptyFolderNoSuggestion'))
                    uialert(tool.App,...
                    getString(message('images:imageBatchProcessor:noImagesFoundDetail',dirname)),...
                    getString(message('images:imageBatchProcessor:noImagesFound')));
                else

                    uialert(tool.App,...
                    getString(message('images:imageBrowser:unableToLoad',dirname)),...
                    getString(message('images:imageBrowser:unableToLoadTitle')));
                end
            end
        end

        function loadimdsUI(tool)


            tool.showAsBusy;
            resetWait=onCleanup(@()tool.unshowAsBusy);

            loc=imageslib.internal.app.utilities.ScreenUtilities.getToolCenter(tool.App);
            tool.ImdsLoadDialog=images.internal.app.utilities.VariableDialog(loc,...
            getString(message('images:imageBrowser:IMDS')),...
            getString(message('images:imageBrowser:importImageDataStore')),...
            'imageDatastore');
            wait(tool.ImdsLoadDialog);

            if tool.ImdsLoadDialog.Canceled
                return;
            else
                imds=evalin('base',tool.ImdsLoadDialog.SelectedVariable);
                tool.warnIfLabelsPresent(imds);

                if isempty(tool.ThumbnailFig)||~isvalid(tool.ThumbnailFig)
                    tool.createThumbFigure(tool.ImdsLoadDialog.SelectedVariable,imds);
                else
                    tool.addImagesFrom(imds);
                end
            end


            delete(tool.ImdsLoadDialog)
        end


        function applyThumnailSizeChange(tool)
            tool.ThumbnailSize(1)=tool.SizeSlider.Value;
            tool.ThumbnailSize(2)=tool.SizeSlider.Value;
            tool.BrowserComponent.ThumbnailSize=round(tool.ThumbnailSize);
            drawnow limitrate
        end


        function togglePreview(tool)


            if tool.TogglePreviewButton.Value
                if isempty(tool.PreviewFig)

                    panelOptions.Title=getString(message('images:imageBrowser:Preview'));
                    panelOptions.Region="right";
                    tool.PreviewPanel=matlab.ui.internal.FigurePanel(panelOptions);
                    tool.PreviewPanel.Closable=false;



                    addlistener(tool.PreviewPanel,'PropertyChanged',@(~,~)tool.updatePreview());

                    tool.App.add(tool.PreviewPanel);

                    tool.PreviewFig=tool.PreviewPanel.Figure;
                    addlistener(tool.PreviewFig,'WindowScrollWheel',@tool.windowScroll);
                    addlistener(tool.PreviewFig,'WindowMouseMotion',@tool.windowMotion);

                    tool.PreviewFig.AutoResizeChildren=false;
                    tool.PreviewFig.UserData.CurrentlyShownIndex=[];

                    tool.PreviewComponent=images.internal.app.imageBrowser.web.ImagePreviewPanel(tool.PreviewFig);
                    addlistener(tool.PreviewComponent,'NavigateLR',@tool.goLRInPreview);
                end


                tool.PreviewPanel.Opened=true;
                tool.updatePreview();



                tool.MouseMotionListeners=addlistener(tool.PreviewFig,'WindowMouseMotion',...
                @(src,evt)tool.PreviewComponent.motionCallback(src,evt));
                tool.MouseMotionListeners(2)=addlistener(tool.ThumbnailFig,'WindowMouseMotion',...
                @(src,evt)tool.PreviewComponent.motionCallback(src,evt));

            else

                tool.PreviewPanel.Opened=false;
                delete(tool.MouseMotionListeners);
            end
        end

        function markPreviewAsStale(tool)
            if~tool.TogglePreviewButton.Value||~tool.PreviewPanel.Showing

                return;
            end
            tool.PreviewFig.UserData.CurrentlyShownIndex=[];
        end

        function updatePreview(tool)
            if~tool.TogglePreviewButton.Value||~tool.PreviewPanel.Showing

                return;
            end

            tool.PreviewFig.UserData.curSelection=tool.CurrentSelection;

            tool.SelectionIndex=1;

            currentlyShownIndex=tool.CurrentSelection(tool.SelectionIndex);
            if~isequal(tool.PreviewFig.UserData.CurrentlyShownIndex,currentlyShownIndex)
                tool.showImageInPreview();
            end

            tool.PreviewComponent.LRButtonsEnabled=numel(tool.CurrentSelection)>1;
        end

        function showImageInPreview(tool)

            imageNum=tool.CurrentSelection(tool.SelectionIndex);
            tool.PreviewFig.UserData.CurrentlyShownIndex=imageNum;

            fullPath=tool.BrowserComponent.Sources{imageNum};
            fullImage=tool.readFcnWrapper(fullPath);

            userData=tool.BrowserComponent.getUserData(imageNum);
            if isequal(userData,struct())
                userData.OriginalSize=[];
                userData.ClassUnderlying='';
            end

            [~,topLabel,ext]=fileparts(fullPath);
            topLabel=[topLabel,ext];

            bottomLabel=[
            getString(message('images:imageBrowser:size')),...
            ' [',num2str(userData.OriginalSize),']',...
            '    ',...
            getString(message('images:imageBrowser:class')),...
            ' ',char(userData.ClassUnderlying)];

            tool.PreviewComponent.draw(fullImage,topLabel,bottomLabel);
        end

        function clearPreview(tool)

            if tool.TogglePreviewButton.Value
                tool.PreviewComponent.draw([],'','')
            end
        end

        function goLRInPreview(tool,~,evt)
            if evt.ScrollDirection=='l'
                newIndex=tool.SelectionIndex-1;
            else
                newIndex=tool.SelectionIndex+1;
            end

            if newIndex>numel(tool.CurrentSelection)

                tool.SelectionIndex=1;
            elseif newIndex==0

                tool.SelectionIndex=numel(tool.CurrentSelection);
            else
                tool.SelectionIndex=newIndex;
            end

            tool.showImageInPreview();
            drawnow limitrate;
        end


        function createThumbFigure(tool,collectionName,imds)
            tool.showAsBusy;
            resetWait=onCleanup(@()tool.unshowAsBusy);

            tool.CollectionName=collectionName;
            if numel(imds.Files)==0
                uialert(tool.App,...
                getString(message('images:imageBrowser:noImagesInImdsFoundDetail',collectionName)),...
                getString(message('images:imageBatchProcessor:noImagesFound')))
                return;
            end

            tool.AddSplitButton.Enabled=true;

            tool.InputDataStore=imds;


            figOptions.DocumentGroupTag=tool.ThumbnailFigureGroup.Tag;
            tool.AppFigureDocument=matlab.ui.internal.FigureDocument(figOptions);
            tool.AppFigureDocument.Closable=false;
            tool.App.add(tool.AppFigureDocument);
            tool.ThumbnailFig=tool.AppFigureDocument.Figure;
            tool.ThumbnailFig.Tag='ThumbnailFigure';
            tool.ThumbnailFig.AutoResizeChildren=false;


            figPos=tool.ThumbnailFig.Position;
            tool.BrowserComponent=...
            images.internal.app.browser.Browser(...
            tool.ThumbnailFig,[1,1,figPos(3:4)]);
            tool.BrowserComponent.ThumbnailSize=tool.ThumbnailSize;
            tool.BrowserComponent.LabelVisible=true;
            tool.BrowserComponent.ReadFcn=@tool.readFcnWrapper;

            tool.BrowserComponent.add(imds.Files);


            menu=uicontextmenu('Parent',tool.ThumbnailFig);
            uimenu(menu,'Text',getString(message('images:commonUIString:removeSelected')),...
            'MenuSelectedFcn',@(~,~)tool.removeThumbnails);
            uimenu(menu,'Text',getString(message('images:commonUIString:exportToWS')),...
            'MenuSelectedFcn',@(~,~)tool.exportSelectionFromRightClick);
            tool.BrowserComponent.ContextMenu=menu;

            addlistener(tool.BrowserComponent,'OpenSelection',@tool.openThumbnailInPreview);
            addlistener(tool.BrowserComponent,'SelectionChanged',@tool.thumbnailSelectionChanged);

            addlistener(tool.ThumbnailFig,'WindowScrollWheel',@tool.windowScroll);
            addlistener(tool.ThumbnailFig,'WindowMouseMotion',@tool.windowMotion);
            addlistener(tool.ThumbnailFig,'KeyPress',@tool.keyPress);
            tool.ThumbnailFig.SizeChangedFcn=@tool.resizeBrowserComponent;


            tool.BrowserComponent.select(1);


            tool.SizeSlider.Enabled=true;
            tool.SlideLabel.Enabled=true;
            tool.TogglePreviewButton.Enabled=true;
            tool.ExportSplitButton.Enabled=true;

            tool.AppFigureDocument.Title=...
            [collectionName,...
            ' (',num2str(tool.BrowserComponent.NumImages),')'];
            tool.setNotificationMessage(getString(...
            message('images:imageBrowser:loadedN',...
            tool.BrowserComponent.NumImages)));
            tool.NewSessionButton.Enabled=true;
        end

        function addImagesFrom(tool,imds)
            tool.BrowserComponent.add(imds.Files);

            tool.BrowserComponent.select(tool.BrowserComponent.NumImages);
            tool.updateImageCountInTitle(true);
            tool.setNotificationMessage(getString(...
            message('images:imageBrowser:addedN',...
            numel(imds.Files))));
        end


        function openThumbnailInPreview(tool,~,~)
            if~tool.TogglePreviewButton.Value
                tool.TogglePreviewButton.Value=true;
                tool.togglePreview();
            end
        end

        function thumbnailSelectionChanged(tool,hBrowser,evt)
            tool.CurrentSelection=evt.Selected;

            if numel(evt.Selected)>1
                tool.StatusText='';
                tool.setNotificationMessage(...
                getString(message('images:imageBrowser:selectedN',num2str(numel(evt.Selected)))));
                tool.GalleryItems.imtoolItem.Enabled=false;
                tool.GalleryItems.colorThreshItem.Enabled=false;
                tool.GalleryItems.segItem.Enabled=false;
                tool.GalleryItems.regionAnalyItem.Enabled=false;
                tool.updatePreview();

            elseif numel(evt.Selected)==1

                tool.SelectionIndex=1;

                selectedFileName=hBrowser.Sources{evt.Selected};
                tool.setStatus(selectedFileName);

                userData=hBrowser.getUserData(evt.Selected);
                if isempty(userData)||isequal(userData,struct())...
                    ||numel(userData.OriginalSize)>3...
                    ||(numel(userData.OriginalSize)==3&&userData.OriginalSize(3)~=3)


                    tool.GalleryItems.imtoolItem.Enabled=false;
                    tool.GalleryItems.colorThreshItem.Enabled=false;
                    tool.GalleryItems.regionAnalyItem.Enabled=false;
                    tool.GalleryItems.segItem.Enabled=false;
                else
                    isGray=numel(userData.OriginalSize)==2;
                    isRGB=numel(userData.OriginalSize)==3&&userData.OriginalSize(3)==3;
                    isLogical2D=userData.ClassUnderlying=="logical"...
                    &&isGray;

                    if isGray||isRGB
                        tool.GalleryItems.imtoolItem.Enabled=true;
                    end
                    if isLogical2D
                        tool.GalleryItems.regionAnalyItem.Enabled=true;
                        tool.GalleryItems.segItem.Enabled=false;
                    else
                        tool.GalleryItems.regionAnalyItem.Enabled=false;
                        tool.GalleryItems.segItem.Enabled=true;
                    end
                    if isRGB

                        tool.GalleryItems.colorThreshItem.Enabled=true;
                    else
                        tool.GalleryItems.colorThreshItem.Enabled=false;
                    end
                end
                tool.updatePreview();
            end

        end

        function removeThumbnails(tool)


            numRemoving=numel(tool.BrowserComponent.Selected);
            removedInd=max(tool.BrowserComponent.Selected);
            removedInd=max(1,removedInd-numRemoving+1);


            newIndex=min(removedInd,tool.BrowserComponent.NumImages-numRemoving);


            tool.BrowserComponent.remove(tool.BrowserComponent.Selected);
            if tool.BrowserComponent.NumImages==0

                tool.resetApp()
            else
                tool.BrowserComponent.select(newIndex);
                tool.updateImageCountInTitle(false);
            end


            tool.FullImageCache.reset();
            tool.markPreviewAsStale();
            tool.updatePreview();
        end


        function launchImtool(tool)
            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);
            im=tool.readFullImage(tool.CurrentSelection(1));
            imtool(im);
        end

        function launchColorThresh(tool,varargin)
            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);
            im=tool.readFullImage(tool.CurrentSelection(1));
            colorThresholder(im);
        end

        function launchSegApp(tool,varargin)
            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);
            im=tool.readFullImage(tool.CurrentSelection(1));
            s=warning('off','images:imageSegmenter:convertToGray');
            restoreWarningStateObj=onCleanup(@()warning(s));
            imageSegmenter(im);
        end

        function launchRegionApp(tool,varargin)
            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);
            im=tool.readFullImage(tool.CurrentSelection(1));
            imageRegionAnalyzer(im);
        end


        function exportSelectionFromRightClick(tool)
            if numel(tool.BrowserComponent.Selected)==1
                im=tool.readFullImage(tool.BrowserComponent.Selected);
                tool.exportUI([getString(message('images:commonUIString:exportImageToWS')),':'],...
                "im",im);
            else
                tool.exportToDataStore(true);
            end
        end

        function exportToDataStore(tool,selectedOnlyTF)
            defaultVarName=matlab.lang.makeValidName(tool.CollectionName);

            if selectedOnlyTF
                fileList=tool.BrowserComponent.Sources(tool.CurrentSelection);
            else
                fileList=tool.BrowserComponent.Sources;
            end



            defaultIMDSExts=["png","jpg","jpeg"];
            defaultSupportTF=endsWith(fileList,defaultIMDSExts,"IgnoreCase",true);
            if all(defaultSupportTF)


                imds=imageDatastore(fileList);
            else
                imds=imageDatastore(fileList,...
                'ReadFcn',tool.InputDataStore.ReadFcn,...
                'FileExtensions',images.internal.app.utilities.supportedFormats(true));
            end


            tool.exportUI(getString(message('images:imageBrowser:exportTooltip')),...
            string(defaultVarName),imds);
        end

        function exportUI(tool,title,varName,var)
            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);

            loc=imageslib.internal.app.utilities.ScreenUtilities.getToolCenter(tool.App);
            tool.ExportDialog=images.internal.app.utilities.ExportToWorkspaceDialog(loc,...
            title,varName,string(getString(message('images:imageBrowser:exportVariableLabel'))));
            wait(tool.ExportDialog);

            if~tool.ExportDialog.Canceled
                assignin('base',tool.ExportDialog.VariableName(1),var);
            end


            delete(tool.ExportDialog);
        end


        function showAsBusy(tool)
            tool.App.Busy=true;
            tool.App.CanCloseFcn=@(~)false;
            tool.setNotificationMessage(...
            images.internal.app.registration.ui.getMessageString('busy'));
        end

        function unshowAsBusy(tool)
            tool.App.Busy=false;
            tool.App.CanCloseFcn=@(~)closeApp(tool);
        end


        function setStatus(tool,text)
            tool.StatusText=text;
            if(isempty(tool.NotificationTimer)||...
                strcmp(tool.NotificationTimer.Running,'off'))
                if isvalid(tool.App)
                    tool.StatusLabel.Text=tool.StatusText;
                    tool.CopyToClipBoardButton.Enabled=~isempty(tool.StatusText);
                end
            end
        end

        function setNotificationMessage(tool,notificationText)

            tool.StatusLabel.Text=notificationText;
            tool.CopyToClipBoardButton.Enabled=false;

            if(isempty(tool.NotificationTimer))
                cb=@(varargin)tool.resetStatusText;
                cbhandler=@(e,d)matlab.graphics.internal.drawnow.callback(cb);
                tool.NotificationTimer=timer(...
                'ExecutionMode','singleShot',...
                'StartDelay',3,...
                'TimerFcn',cbhandler);
            end
            stop(tool.NotificationTimer);
            start(tool.NotificationTimer);
        end

        function resetStatusText(tool)
            if isvalid(tool)&&isvalid(tool.App)&&tool.App.State=="RUNNING"
                tool.StatusLabel.Text=tool.StatusText;
                tool.CopyToClipBoardButton.Enabled=~isempty(tool.StatusText);
            end
        end

        function copyFileNameToClipBoard(tool,~,~)
            clipboard('copy',tool.StatusText);
            tool.setNotificationMessage(...
            getString(message('images:imageBrowser:copiedToClipBoard')));
        end


        function clearSession(tool)
            selectedOption=uiconfirm(tool.ThumbnailFig,...
            getString(message('images:imageBrowser:clearContent')),...
            getString(message('images:imageBrowser:clearContentTitle')),...
            'Options',{getString(message('images:commonUIString:no')),getString(message('images:commonUIString:yes'))},...
            'Icon','question',...
            'CancelOption',getString(message('images:commonUIString:no')));

            if isequal(selectedOption,getString(message('images:commonUIString:yes')))
                tool.resetApp()
            end
        end

        function windowMotion(tool,src,~)
            if isvalid(tool)
                tool.CurrentFigure=src;
            end
        end

        function windowScroll(tool,~,evt)
            if~isempty(tool.PreviewFig)&&isvalid(tool.PreviewFig)&&tool.CurrentFigure==tool.PreviewFig
                scroll(tool.PreviewComponent,evt);
            else
                scroll(tool.BrowserComponent,evt.VerticalScrollCount);
            end
        end

        function keyPress(tool,~,evt)
            if contains(evt.Key,["delete","backspace"])
                tool.removeThumbnails();
            else
                images.internal.app.browser.helper.keyPressCallback(tool.BrowserComponent,evt);
            end
        end

        function[im,label,badge,userData]=readFcnWrapper(tool,source)

            try

                if isequal(tool.InputDataStore.ReadFcn,@images.internal.app.utilities.readAllIPTFormats)
                    [im,cmap]=tool.InputDataStore.ReadFcn(source,true);
                else
                    im=tool.InputDataStore.ReadFcn(source);
                    cmap=[];
                end
                [~,fileName]=fileparts(source);
                label=string(fileName);

                userData.ClassUnderlying=string(class(im));
                userData.OriginalSize=size(im);
                if~(ismatrix(im)&&isempty(cmap)&&isa(im,'uint8'))

                    im=images.internal.app.utilities.makeRGB(im,cmap);
                end
            catch

                label="";
                userData=struct();
                im=imread(fullfile(matlabroot,'toolbox','images','imuitools','+images','+internal','+app','+browser','+icons','BrokenPlaceholder_100.png'));
            end

            badge=images.internal.app.browser.data.Badge.Empty;

        end

        function warnIfLabelsPresent(~,imds)
            if~isempty(imds.Labels)
                uialert(tool.App,...
                getString(message('images:imageBrowser:noLabelsWarning')),...
                getString(message('images:imageBrowser:noLabelsWarningTitle')));
            end
        end

        function[im,fullPath]=readFullImage(tool,imageNum)

            fullPath=tool.BrowserComponent.Sources{imageNum};
            im=tool.FullImageCache.getFullImage(imageNum);
            if isempty(im)


                if isequal(tool.InputDataStore.ReadFcn,@images.internal.app.utilities.readAllIPTFormats)
                    [im,cmap]=tool.InputDataStore.ReadFcn(fullPath,true);
                else
                    im=tool.InputDataStore.ReadFcn(fullPath);
                    cmap=[];
                end
                if~isempty(cmap)
                    im=ind2rgb(im,cmap);
                end
                tool.FullImageCache.insertFullImage(imageNum,im);
            end
        end

        function updateImageCountInTitle(tool,isAdding)
            if isAdding


                tool.CollectionName=getString(message('images:imageBrowser:various'));
            end
            tool.AppFigureDocument.Title=...
            [tool.CollectionName,...
            ' (',num2str(tool.BrowserComponent.NumImages),')'];
        end

        function resizeBrowserComponent(tool,src,~)
            if isvalid(tool)
                resize(tool.BrowserComponent,[1,1,src.Position(3:4)])
            end
        end

        function resetApp(tool)
            if tool.TogglePreviewButton.Value
                tool.TogglePreviewButton.Value=false;
                tool.togglePreview();
            end

            delete(tool.BrowserComponent);
            delete(tool.ThumbnailFig);
            tool.FullImageCache.reset();

            tool.NewSessionButton.Enabled=false;
            tool.AddSplitButton.Enabled=true;


            tool.SizeSlider.Enabled=false;
            tool.SlideLabel.Enabled=false;

            tool.TogglePreviewButton.Value=false;
            tool.TogglePreviewButton.Enabled=false;

            tool.GalleryItems.imtoolItem.Enabled=false;
            tool.GalleryItems.colorThreshItem.Enabled=false;
            tool.GalleryItems.segItem.Enabled=false;
            tool.GalleryItems.regionAnalyItem.Enabled=false;

            tool.ExportSplitButton.Enabled=false;

            tool.setStatus('');
        end

        function TF=closeApp(tool)
            TF=true;
            delete(tool)
        end

        function delete(tool)
            if~isempty(tool.NotificationTimer)&&isvalid(tool.NotificationTimer)
                stop(tool.NotificationTimer)
            end
            delete(tool.NotificationTimer);

            if~isempty(tool.BrowserComponent)
                delete(tool.BrowserComponent)
            end
        end
    end
end
