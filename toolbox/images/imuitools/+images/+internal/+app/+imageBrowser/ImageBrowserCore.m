classdef ImageBrowserCore<handle


    properties(Constant=true)


        LIconImage=...
        imread(fullfile(matlabroot,'toolbox','images','icons','leftArrow.png'));
        RIconImage=...
        imread(fullfile(matlabroot,'toolbox','images','icons','rightArrow.png'));
    end

    properties
ToolGroup
tabGroup
mainTab

        loadSplitButton;

        sizeSlider;
        slideLabel;

        togglePreviewButton;

        gallery;
        galleryItems;

        exportButton;
        wasAnythingExported=false;

        hThumbnailFig=matlab.graphics.primitive.Image.empty();
        hThumbnailComponent;
        thumbnailSize=[125,125];


        CurrentSelection=[];
        selectionIndex=[];

        hPreviewFig=matlab.graphics.primitive.Image.empty();
        hPreviewPanel=[];
        hPreviewImageAxes=matlab.graphics.axis.Axes.empty();
        hPreviewLRButtons=[];

        statusBar;
        statusText='';
        notificationTimer=[];

        supportedImageFormats={};

    end

    methods

        function tool=ImageBrowserCore()


            tool.ToolGroup=matlab.ui.internal.desktop.ToolGroup(getString(message('images:imageBrowser:appName')));
            tool.ToolGroup.setClosingApprovalNeeded(true);


            tool.ToolGroup.setContextualHelpCallback(@(es,ed)doc('Image Browser'));


            images.internal.app.utilities.addDDUXLogging(tool.ToolGroup,'Image Processing Toolbox','Image Browser');

            import matlab.ui.internal.toolstrip.*;
            tool.tabGroup=TabGroup();
            tool.mainTab=Tab(getString(message('images:imageBrowser:Browse')));


            section=tool.mainTab.addSection(getString(message('images:imageBrowser:Load')));

            c=section.addColumn();
            tool.loadSplitButton=SplitButton(getString(message('images:imageBrowser:Load')),Icon.IMPORT_24);
            tool.loadSplitButton.Tag='LoadSplitButton';
            tool.loadSplitButton.Description=getString(message('images:imageBrowser:LoadToolTip'));
            tool.loadSplitButton.ButtonPushedFcn=@(varargin)tool.loadFolderUI(false);
            tool.loadSplitButton.DynamicPopupFcn=@(x,y)buildDynamicPopupListForLoadImages();
            c.add(tool.loadSplitButton);

            function popup=buildDynamicPopupListForLoadImages()
                import matlab.ui.internal.toolstrip.*
                popup=PopupList();
                popup.Tag='LoadButtonPopUp';

                item=ListItem(getString(message('images:imageBrowser:LoadFolder')),Icon.IMPORT_16);
                item.Tag='LoadFolder';
                item.ShowDescription=false;
                item.ItemPushedFcn=@(varargin)tool.loadFolderUI(false);
                popup.add(item);

                item=ListItem(getString(message('images:imageBrowser:LoadFolderWithSub')),Icon.IMPORT_16);
                item.Tag='LoadFolderAndSubfolders';
                item.ShowDescription=false;
                item.ItemPushedFcn=@(varargin)tool.loadFolderUI(true);
                popup.add(item);

                item=ListItem(getString(message('images:imageBrowser:LoadIMDS')),Icon.IMPORT_16);
                item.Tag='LoadDatastore';
                item.ShowDescription=false;
                item.ItemPushedFcn=@(varargin)tool.loadimdsUI();
                popup.add(item);
            end


            section=tool.mainTab.addSection(getString(message('images:imageBrowser:Thumbnails')));


            topCol=section.addColumn('width',150,...
            'HorizontalAlignment','center');
            tool.sizeSlider=Slider();
            tool.sizeSlider.Tag='Slider';
            tool.sizeSlider.Description=getString(message('images:imageBrowser:ThumbnailSizeTooltip'));
            tool.sizeSlider.Enabled=false;
            tool.sizeSlider.Limits=[50,800];
            tool.sizeSlider.Ticks=5;
            tool.sizeSlider.Value=tool.thumbnailSize(1);
            tool.sizeSlider.ValueChangedFcn=@(varargin)tool.applyThumnailSizeChange;
            topCol.add(tool.sizeSlider);

            tool.slideLabel=Label(getString(message('images:imageBrowser:ThumbnailSize')));
            tool.slideLabel.Tag='SliderLabel';
            tool.slideLabel.Enabled=false;

            topCol.add(tool.slideLabel);



            section=tool.mainTab.addSection(getString(message('images:imageBrowser:Preview')));

            topCol=section.addColumn();
            tool.togglePreviewButton=ToggleButton(getString(message('images:imageBrowser:Preview')),Icon.SEARCH_24);
            tool.togglePreviewButton.Tag='PreviewToggle';
            tool.togglePreviewButton.Description=getString(message('images:imageBrowser:PreviewTooltip'));
            tool.togglePreviewButton.Enabled=false;
            tool.togglePreviewButton.ValueChangedFcn=@(varargin)tool.togglePreview();
            topCol.add(tool.togglePreviewButton);


            section=tool.mainTab.addSection(getString(message('images:commonUIString:Launcher')));
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
            tool.galleryItems.imtoolItem=GalleryItem(getString(message('images:desktop:Tool_imtool_Label')),Icon(imtoolIconImage));
            tool.galleryItems.imtoolItem.Tag='Launcher_imtool';
            tool.galleryItems.imtoolItem.Enabled=false;
            tool.galleryItems.imtoolItem.Description=getString(message('images:desktop:Tool_imtool_Description'));
            tool.galleryItems.imtoolItem.ItemPushedFcn=@(varargin)tool.launchImtool;
            vizCat.add(tool.galleryItems.imtoolItem);


            colorThreshIcon=fullfile(matlabroot,'toolbox','images','icons','color_thresholder_24.png');
            tool.galleryItems.colorThreshItem=GalleryItem(getString(message('images:desktop:Tool_colorThresholder_Label')),Icon(colorThreshIcon));
            tool.galleryItems.colorThreshItem.Tag='Launcher_colorThresholder';
            tool.galleryItems.colorThreshItem.Enabled=false;
            tool.galleryItems.colorThreshItem.Description=getString(message('images:desktop:Tool_colorThresholder_Description'));
            tool.galleryItems.colorThreshItem.ItemPushedFcn=@(varargin)tool.launchColorThresh;
            analysisCat.add(tool.galleryItems.colorThreshItem);


            segAppIcon=fullfile(matlabroot,'toolbox','images','icons','imageSegmenter_AppIcon_24.png');
            tool.galleryItems.segItem=GalleryItem(getString(message('images:desktop:Tool_imageSegmenter_Label')),Icon(segAppIcon));
            tool.galleryItems.segItem.Tag='Launcher_imageSegmenter';
            tool.galleryItems.segItem.Enabled=false;
            tool.galleryItems.segItem.Description=getString(message('images:desktop:Tool_imageSegmenter_Description'));
            tool.galleryItems.segItem.ItemPushedFcn=@(varargin)tool.launchSegApp;
            analysisCat.add(tool.galleryItems.segItem);


            regionAnalyAppIcon=fullfile(matlabroot,'toolbox','images','icons','ImageRegionAnalyzer_AppIcon_24px.png');
            tool.galleryItems.regionAnalyItem=GalleryItem(getString(message('images:desktop:Tool_imageRegionAnalyzer_Label')),Icon(regionAnalyAppIcon));
            tool.galleryItems.regionAnalyItem.Tag='Launcher_imageRegionAnalyzer';
            tool.galleryItems.regionAnalyItem.Enabled=false;
            tool.galleryItems.regionAnalyItem.Description=getString(message('images:desktop:Tool_imageRegionAnalyzer_Description'));
            tool.galleryItems.regionAnalyItem.ItemPushedFcn=@(varargin)tool.launchRegionApp;
            analysisCat.add(tool.galleryItems.regionAnalyItem);


            tool.gallery=Gallery(popup,'MaxColumnCount',4,'MinColumnCount',2);
            topCol.add(tool.gallery);


            section=tool.mainTab.addSection(getString(message('images:commonUIString:export')));
            section.Tag='';
            topCol=section.addColumn();
            tool.exportButton=Button(getString(message('images:imageBrowser:exportAll')),Icon.CONFIRM_24);
            tool.exportButton.Description=getString(message('images:imageBrowser:exportAllTooltip'));
            tool.exportButton.Tag='ExportButton';
            tool.exportButton.Enabled=false;
            tool.exportButton.ButtonPushedFcn=@(varargin)tool.exportToDataStore();
            topCol.add(tool.exportButton);


            imf=imformats;
            tool.supportedImageFormats=strcat('.',[imf.ext]);
            tool.supportedImageFormats{end+1}='.dcm';
            tool.supportedImageFormats{end+1}='.dic';
            tool.supportedImageFormats{end+1}='.ima';
            tool.supportedImageFormats{end+1}='.ntf';
            tool.supportedImageFormats{end+1}='.nitf';
            tool.supportedImageFormats{end+1}='.dpx';


            tool.tabGroup.add(tool.mainTab);
            tool.tabGroup.SelectedTab=tool.mainTab;
            tool.ToolGroup.addTabGroup(tool.tabGroup);
            tool.ToolGroup.hideViewTab();


            g=tool.ToolGroup.Peer.getWrappedComponent;
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.PERMIT_DOCUMENT_BAR_HIDE,false);


            dropListener=com.mathworks.widgets.desk.DTGroupProperty.IGNORE_ALL_DROPS;
            group=tool.ToolGroup.Peer.getWrappedComponent;
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.DROP_LISTENER,dropListener);

            [x,y,width,height]=imageslib.internal.apputil.ScreenUtilities.getInitialToolPosition();
            tool.ToolGroup.setPosition(x,y,width,height);

            tool.ToolGroup.disableDataBrowser();


            tool.ToolGroup.open();


            internal.setJavaCustomData(tool.ToolGroup.Peer,tool);

            addlistener(tool.ToolGroup,'GroupAction',@(src,hEvent)tool.closeCallback(hEvent));

            tool.setStatus(getString(message('images:imageBrowser:clickLoad')));
        end


        function loadFolderUI(tool,recursiveTF)
            if~isempty(tool.hThumbnailFig)&&isvalid(tool.hThumbnailFig)
                if tool.okToClearExisting()
                    tool.deleteThumbnailFigure();
                    tool.resetApp();
                else
                    return;
                end
            end

            dirname=uigetdir(pwd,getString(message('images:imageBrowser:SelectFolder')));
            if(dirname)
                tool.loadFolder(dirname,recursiveTF);
            end
        end
        function loadFolder(tool,dirname,recursiveTF)
            tool.showAsBusy;

            drawnow;
            resetWait=onCleanup(@()tool.unshowAsBusy);

            tool.setStatus(getString(message('images:imageBrowser:loadingFolder',dirname)));

            try
                imds=imageDatastore(dirname,...
                'IncludeSubfolders',recursiveTF,...
                'ReadFcn',@images.internal.app.imageBrowser.readAllIPTFormats,...
                'FileExtensions',tool.supportedImageFormats);

                if dirname(end)=='/'||dirname(end)=='\'

                    dirname(end)=[];
                end
                if strcmp(dirname,'.')

                    dirname=pwd;
                end

                [~,cname]=fileparts(dirname);

                tool.newFileCollectionFig(cname);

                if numel(imds.Files)>0
                    tool.hThumbnailComponent.imds=imds;
                    tool.hThumbnailFig.Name=[cname,' (',num2str(numel(imds.Files)),' ',getString(message('images:imageBrowser:images')),')'];
                    tool.hThumbnailFig.Tag=cname;
                    tool.setNotificationMessage(getString(message('images:imageBrowser:loadedN',num2str(numel(imds.Files)))));
                    tool.hThumbnailComponent.setSelection(1);
                else
                    hw=warndlg(getString(message('images:imageBatchProcessor:noImagesFoundDetail',dirname)),...
                    getString(message('images:imageBatchProcessor:noImagesFound')),...
                    'modal');
                    uiwait(hw);
                    tool.deleteThumbnailFigure();
                    tool.resetApp();
                end
            catch ALL
                if(strcmp(ALL.identifier,'MATLAB:datastoreio:pathlookup:emptyFolderNoSuggestion'))
                    hw=warndlg(getString(message('images:imageBatchProcessor:noImagesFoundDetail',dirname)),...
                    getString(message('images:imageBatchProcessor:noImagesFound')),...
                    'modal');
                    uiwait(hw);
                else

                    hw=warndlg(getString(message('images:imageBrowser:unableToLoad',dirname)),...
                    getString(message('images:imageBrowser:unableToLoadTitle')),...
                    'modal');
                    uiwait(hw);
                end
            end


        end
        function loadimdsUI(tool)
            if~isempty(tool.hThumbnailFig)&&isvalid(tool.hThumbnailFig)
                if tool.okToClearExisting()
                    tool.deleteThumbnailFigure();
                    tool.resetApp();
                else
                    return;
                end
            end

            varInfo=evalin('base','whos');
            imdsVars=varInfo(strcmp({varInfo.class},'matlab.io.datastore.ImageDatastore'));

            if isempty(imdsVars)
                errordlg(getString(message('images:imageBrowser:noimds')),...
                getString(message('images:imageBrowser:noimdsTitle')),...
                'modal');
                return;
            end

            hd=dialog('Visible','on',...
            'Name',getString(message('images:imageBrowser:importImageDataStore')),...
            'Units','char');
            hd.Position(3:4)=[70,20];

            okCancelRowHeight=2;


            hl=uicontrol('Style','listbox',...
            'Units','char',...
            'Fontname','Courier',...
            'Value',1,...
            'Parent',hd,...
            'Tag','ListBoxIMDS',...
            'Position',[0,okCancelRowHeight+2,hd.Position(3),hd.Position(4)-okCancelRowHeight-2-1],...
            'String',{imdsVars.name});


            hOk=uicontrol('Style','pushbutton',...
            'Parent',hd,...
            'Units','char',...
            'Callback',@(varargin)importimds,...
            'Position',[hd.Position(3)-10-2,1,10,okCancelRowHeight],...
            'Tag','importOk',...
            'String',getString(message('images:commonUIString:ok')));
            hCancel=uicontrol('Style','pushbutton',...
            'Parent',hd,...
            'Units','char',...
            'Callback',@(varargin)delete(hd),...
            'Position',[2,1,10,okCancelRowHeight],...
            'Tag','importCancel',...
            'String',getString(message('images:commonUIString:cancel')));

            hd.Units='pixels';
            hd.Position=imageslib.internal.apputil.ScreenUtilities.getModalDialogPos(...
            tool.ToolGroup.Name,hd.Position(3:4));
            hd.Visible='on';


            movegui(hd,'center');

            function importimds
                hOk.Enable='off';
                hCancel.Enable='off';
                varName=hl.String{hl.Value};
                imds=evalin('base',varName);
                delete(hd);
                tool.newVarCollectionFig(varName,imds);
            end

        end

        function tf=okToClearExisting(~)
            tf=false;
            noStr=getString(message('images:commonUIString:no'));
            yesStr=getString(message('images:commonUIString:yes'));

            selectedStr=questdlg(...
            getString(message('images:imageBrowser:clearContent')),...
            getString(message('images:imageBrowser:clearContentTitle')),...
            yesStr,noStr,noStr);
            if(strcmp(selectedStr,yesStr))
                tf=true;
            end
        end


        function applyThumnailSizeChange(tool)
            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);

            tool.thumbnailSize(1)=tool.sizeSlider.Value;
            tool.thumbnailSize(2)=tool.sizeSlider.Value;


            tool.hThumbnailComponent.updateThumbnailSize(tool.thumbnailSize);
        end


        function togglePreview(tool)
            if(tool.togglePreviewButton.Value)

                tool.hPreviewFig=figure('NumberTitle','off',...
                'Name',getString(message('images:imageBrowser:Preview')),...
                'Color','w',...
                'Renderer','painters',...
                'IntegerHandle','off',...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'Tag','PreviewFigure',...
                'WindowKeyPressFcn',@tool.arrowKeyNavInPreview,...
                'CloseRequestFcn',@(varargin)toggleOffPreview,...
                'HandleVisibility','off');

                tool.hPreviewFig.UserData.imageNum=[];

                tool.ToolGroup.addFigure(tool.hPreviewFig);

                tool.hPreviewPanel=uipanel('Parent',tool.hPreviewFig,...
                'BackgroundColor','w',...
                'BorderType','none',...
                'Tag','PreviewPanel',...
                'Visible','off',...
                'Units','pixels');

                tool.hPreviewLRButtons=uicontrol('style','pushbutton',...
                'Parent',tool.hPreviewFig,...
                'Units','pixels',...
                'Visible','off',...
                'Tag','PreviewLeftButton',...
                'Tooltip',getString(message('images:imageBrowser:lrButtonToolTips')),...
                'Callback',@(varargin)tool.goLeftInPreview,...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'CData',tool.LIconImage,...
                'String','');
                tool.hPreviewLRButtons(2)=uicontrol('style','pushbutton',...
                'Parent',tool.hPreviewFig,...
                'Units','pixels',...
                'Visible','off',...
                'Tag','PreviewRightButton',...
                'Tooltip',getString(message('images:imageBrowser:lrButtonToolTips')),...
                'Callback',@(varargin)tool.goRightInPreview,...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'CData',tool.RIconImage,...
                'String','');
                tool.hPreviewImageAxes=...
                iptui.internal.imshowWithCaption(tool.hPreviewPanel,...
                false,'','im');
                if isvalid(tool.hPreviewImageAxes)
                    images.internal.utils.customAxesInteraction(tool.hPreviewImageAxes);
                end

                tool.hPreviewImageAxes.Tag='ImageAxes';
                colormap(tool.hPreviewImageAxes,gray);


                tool.hPreviewFig.SizeChangedFcn=@(varargin)tool.positionPreviewControls();

                tool.positionFigures();
                tool.updatePreview();


                tool.hPreviewPanel.Visible='on';
                drawnow;
            else

                toggleOffPreview();
            end

            function toggleOffPreview
                if~isvalid(tool)
                    return;
                end

                delete(tool.hPreviewFig);


                tool.hThumbnailComponent.unBold();

                tool.togglePreviewButton.Value=false;

                tool.positionFigures();
            end

        end

        function positionPreviewControls(tool)
            if~isvalid(tool.hPreviewFig)

                return;
            end


            lowerMargin=20;
            buttonWidth=40;



            hCenter=tool.hPreviewFig.Position(3)/2;
            tool.hPreviewLRButtons(1).Position=[hCenter-(buttonWidth+buttonWidth/2),lowerMargin,buttonWidth,buttonWidth];
            tool.hPreviewLRButtons(2).Position=[hCenter+buttonWidth/2,lowerMargin,buttonWidth,buttonWidth];


            drawnow;

            leftrightMargin=20;
            width=max(1,tool.hPreviewFig.Position(3)-2*leftrightMargin);
            height=max(1,tool.hPreviewFig.Position(4)-buttonWidth-lowerMargin);
            tool.hPreviewPanel.Position=[leftrightMargin,buttonWidth+lowerMargin...
            ,width,height];
        end

        function updatePreview(tool)
            if~tool.togglePreviewButton.Value...
                ||isempty(tool.hPreviewFig)...
                ||~isvalid(tool.hPreviewFig)...
                ||isempty(tool.hThumbnailComponent.CurrentSelection)

                return;
            end
            tool.CurrentSelection=tool.hThumbnailComponent.CurrentSelection;


            tool.hPreviewFig.UserData.curSelection=tool.CurrentSelection;

            tool.selectionIndex=1;

            imageNum=tool.CurrentSelection(tool.selectionIndex);
            if~isequal(tool.hPreviewFig.UserData.imageNum,imageNum)
                tool.showImageInPreview();
            end

            numSelections=numel(tool.CurrentSelection);
            if(numSelections>1)
                set(tool.hPreviewLRButtons,'Visible','on');
                tool.hThumbnailComponent.enBolden(imageNum);
            else
                set(tool.hPreviewLRButtons,'Visible','off');
            end
        end

        function showImageInPreview(tool)
            if isempty(tool.hPreviewFig)||isempty(tool.hPreviewImageAxes)
                return;
            end

            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);


            imageNum=tool.CurrentSelection(tool.selectionIndex);
            tool.hPreviewFig.UserData.imageNum=imageNum;
            fullImage=tool.hThumbnailComponent.readFullImage(imageNum);


            sizeAndClass=['[',num2str(size(fullImage)),'] ',class(fullImage)];
            fullPath=tool.hThumbnailComponent.getOneLineDescription(imageNum);
            [~,fname,ext]=fileparts(fullPath);
            titleString=[fname,ext,'  ',sizeAndClass];


            delete(findall(tool.hPreviewFig,'Type','uicontextmenu'));


            tool.hPreviewImageAxes.Children.CData=fullImage;
            tool.hPreviewImageAxes.XLim=[.5,size(fullImage,2)+.5];
            tool.hPreviewImageAxes.YLim=[.5,size(fullImage,1)+.5];




            zoom(tool.hPreviewFig,'reset');

            if(islogical(fullImage))
                tool.hPreviewImageAxes.CLim=[0,1];
            else
                cLimMax=255;
                if~isa(fullImage,'uint8')

                    cLimMax=max(fullImage(:));
                end
                tool.hPreviewImageAxes.CLim=[0,cLimMax];
            end
            tool.hPreviewImageAxes.Title.String=titleString;


            hImage=tool.hPreviewImageAxes.Children;
            iptui.internal.installSaveToWorkSpaceContextMenu(hImage,titleString,'im');
        end

        function arrowKeyNavInPreview(tool,~,hEvent)
            switch hEvent.Key
            case 'uparrow'
                tool.goLeftInPreview();
            case 'downarrow'
                tool.goRightInPreview();
            otherwise
                tool.arrowKeyCommon(hEvent);
            end
        end


        function positionFigures(tool)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            hFig=tool.hPreviewFig;

            if~isempty(hFig)&&isvalid(hFig)

                md.setDocumentArrangement(tool.ToolGroup.Name,md.TILED,java.awt.Dimension(2,1));
                loc=com.mathworks.widgets.desk.DTLocation.create(1);
                md.setClientLocation(hFig.Name,tool.ToolGroup.Name,loc);

                md.setDocumentArrangement(tool.ToolGroup.Name,md.TILED,java.awt.Dimension(2,1));

                md.setDocumentColumnWidths(tool.ToolGroup.Name,[0.5,0.5]);
            else

                md.setDocumentArrangement(tool.ToolGroup.Name,md.TILED,java.awt.Dimension(1,1));
            end

        end

        function arrowKeyCommon(tool,hEvent)
            switch hEvent.Key
            case 'leftarrow'
                tool.goLeftInPreview();
            case 'rightarrow'
                tool.goRightInPreview();
            case 'home'
                tool.selectionIndex=1;
                tool.showImageInPreview();
            case 'end'
                tool.selectionIndex=numel(tool.CurrentSelection);
                tool.showImageInPreview();
            end
        end

        function goLeftInPreview(tool)
            newIndex=tool.selectionIndex-1;
            if(newIndex>0)
                tool.selectionIndex=newIndex;
            else

                tool.selectionIndex=numel(tool.CurrentSelection);
            end
            tool.showImageInPreview();



            drawnow;
            imageNum=tool.CurrentSelection(tool.selectionIndex);
            tool.hThumbnailComponent.enBolden(imageNum);
        end

        function goRightInPreview(tool)
            newIndex=tool.selectionIndex+1;
            if(newIndex>numel(tool.CurrentSelection))

                tool.selectionIndex=1;
            else
                tool.selectionIndex=newIndex;
            end
            tool.showImageInPreview();
            drawnow;
            imageNum=tool.CurrentSelection(tool.selectionIndex);
            tool.hThumbnailComponent.enBolden(imageNum);
        end


        function hp=commonNewCollectionFigCreation(tool)
            tool.hThumbnailFig=figure('NumberTitle','off',...
            'Color','w',...
            'Visible','off',...
            'Renderer','painters',...
            'Name','Thumbnails',...
            'IntegerHandle','off',...
            'Interruptible','off',...
            'BusyAction','cancel',...
            'Tag','ThumbnailFigure',...
            'HandleVisibility','off');

            drawnow;
            tool.ToolGroup.addFigure(tool.hThumbnailFig);


            hp=uipanel('Parent',tool.hThumbnailFig,...
            'Units','Normalized','Position',[0,0,1,1],...
            'Tag','ThumbnailPanel',...
            'BorderType','none');


            drawnow;
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            prop=com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
            state=java.lang.Boolean.FALSE;
            md.getClient(tool.hThumbnailFig.Name,tool.ToolGroup.Name).putClientProperty(prop,state);



            tool.sizeSlider.Enabled=true;
            tool.slideLabel.Enabled=true;
            tool.togglePreviewButton.Enabled=true;
        end

        function commonNewCollectionFigPostSetup(tool,hThumbnailFig)
            addlistener(tool.hThumbnailComponent,'OpenSelection',@tool.openThumbnail);
            addlistener(tool.hThumbnailComponent,'SelectionChange',@tool.thumbnailSelectionChanged);

            hThumbnailFig.WindowButtonDownFcn=@(varargin)tool.hThumbnailComponent.mouseButtonDownFcn(varargin{:});
            hThumbnailFig.WindowScrollWheelFcn=@(varargin)tool.hThumbnailComponent.mouseWheelFcn(varargin{:});
            hThumbnailFig.WindowKeyPressFcn=@(varargin)tool.hThumbnailComponent.keyPressFcn(varargin{:});

            hThumbnailFig.Visible='on';

            if tool.hThumbnailComponent.NumberOfThumbnails>1
                tool.hThumbnailComponent.setSelection(1);
            end
        end

        function newFileCollectionFig(tool,cName)
            hp=tool.commonNewCollectionFigCreation();
            tool.hThumbnailFig.Name=cName;

            tool.hThumbnailComponent=images.internal.app.imageBrowser.FileThumbnails(hp,tool.thumbnailSize);

            addlistener(tool.hThumbnailComponent,'CountChanged',@(varargin)tool.numberOfThumbnailsChanged);

            tool.commonNewCollectionFigPostSetup(tool.hThumbnailFig);
            tool.exportButton.Enabled=true;
        end

        function numberOfThumbnailsChanged(tool)
            if(tool.hThumbnailComponent.NumberOfThumbnails==0)

                tool.deleteThumbnailFigure();
                delete(tool.hPreviewFig);
                tool.resetApp();
            else


                tool.hThumbnailFig.Name=...
                [tool.hThumbnailFig.Tag,...
                ' (',num2str(tool.hThumbnailComponent.NumberOfThumbnails),...
                ' ',getString(message('images:imageBrowser:images')),')'];
            end

            if~isempty(tool.hPreviewFig)&&isvalid(tool.hPreviewFig)

                tool.hPreviewFig.UserData.imageNum=[];
            end
        end

        function newVarCollectionFig(tool,varName,var)
            if numel(var.Files)==0
                hw=warndlg(getString(message('images:imageBrowser:noImagesInImdsFoundDetail',varName)),...
                getString(message('images:imageBatchProcessor:noImagesFound')),...
                'modal');
                uiwait(hw);
                return;
            end

            hp=tool.commonNewCollectionFigCreation();
            tool.hThumbnailComponent=...
            images.internal.app.imageBrowser.ImageDatastoreThumbnails(...
            hp,tool.thumbnailSize,var);
            tool.hThumbnailFig.Name=...
            [varName,...
            ' (imageDatastore, ',num2str(tool.hThumbnailComponent.NumberOfThumbnails),...
            ' ',getString(message('images:imageBrowser:images')),')'];
            tool.hThumbnailFig.Tag=varName;

            tool.commonNewCollectionFigPostSetup(tool.hThumbnailFig);

            tool.exportButton.Enabled=false;

            tool.setNotificationMessage(getString(...
            message('images:imageBrowser:loadedN',...
            tool.hThumbnailComponent.NumberOfThumbnails)));
        end

        function resetApp(tool)
            if isvalid(tool.hPreviewFig)
                delete(tool.hPreviewFig);
            end
            tool.hThumbnailFig=[];


            tool.sizeSlider.Enabled=false;
            tool.slideLabel.Enabled=false;

            tool.togglePreviewButton.Value=false;
            tool.togglePreviewButton.Enabled=false;

            tool.galleryItems.imtoolItem.Enabled=false;
            tool.galleryItems.colorThreshItem.Enabled=false;
            tool.galleryItems.segItem.Enabled=false;
            tool.galleryItems.regionAnalyItem.Enabled=false;


            tool.exportButton.Enabled=false;

            tool.setStatus(getString(message('images:imageBrowser:clickLoad')));
        end


        function openThumbnail(tool,~,~)
            if isempty(tool.hPreviewFig)||~isvalid(tool.hPreviewFig)

                tool.togglePreviewButton.Value=true;
                tool.togglePreview();
            else
                tool.updatePreview();
            end
        end

        function thumbnailSelectionChanged(tool,~,~)
            tool.galleryItems.imtoolItem.Enabled=false;
            tool.galleryItems.colorThreshItem.Enabled=false;
            tool.galleryItems.segItem.Enabled=false;
            tool.galleryItems.regionAnalyItem.Enabled=false;

            if(nargin==1)
                hFig=tool.getActiveThumbnailFigure();
                if isempty(hFig)||~isvalid(hFig)
                    return;
                end
            end

            if numel(tool.hThumbnailComponent.CurrentSelection)>1
                tool.setStatus(getString(message('images:imageBrowser:selectedN',num2str(numel(tool.hThumbnailComponent.CurrentSelection)))));
            elseif numel(tool.hThumbnailComponent.CurrentSelection)==1




                tool.hThumbnailComponent.unBold();

                tool.setStatus(tool.hThumbnailComponent.getOneLineDescription(tool.hThumbnailComponent.CurrentSelection));

                tnMeta=tool.hThumbnailComponent.getBasicMetaDataFromThumbnail(tool.hThumbnailComponent.CurrentSelection);

                if~isempty(tnMeta)&&~tnMeta.isPlaceholder&&~tnMeta.isStack
                    tool.galleryItems.imtoolItem.Enabled=true;
                    if strcmp(tnMeta.class,'logical')
                        tool.galleryItems.regionAnalyItem.Enabled=true;
                        tool.galleryItems.segItem.Enabled=false;
                    else
                        tool.galleryItems.regionAnalyItem.Enabled=false;
                        tool.galleryItems.segItem.Enabled=true;
                    end
                    if numel(tnMeta.size)==3&&tnMeta.size(3)==3

                        tool.galleryItems.colorThreshItem.Enabled=true;
                    else
                        tool.galleryItems.colorThreshItem.Enabled=false;
                    end
                end
            end

            tool.updatePreview();
        end


        function launchImtool(tool)
            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);
            hFig=tool.hThumbnailFig;
            if isempty(hFig)||~isvalid(hFig)
                return;
            end
            im=tool.hThumbnailComponent.readFullImage(tool.hThumbnailComponent.CurrentSelection(1));
            imtool(im);
        end

        function launchColorThresh(tool,varargin)
            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);
            hFig=tool.hThumbnailFig;
            if isempty(hFig)||~isvalid(hFig)
                return;
            end
            im=tool.hThumbnailComponent.readFullImage(tool.hThumbnailComponent.CurrentSelection(1));
            colorThresholder(im);
        end

        function launchSegApp(tool,varargin)
            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);
            hFig=tool.hThumbnailFig;
            if isempty(hFig)||~isvalid(hFig)
                return;
            end
            im=tool.hThumbnailComponent.readFullImage(tool.hThumbnailComponent.CurrentSelection(1));
            s=warning('off','images:imageSegmenter:convertToGray');
            restoreWarningStateObj=onCleanup(@()warning(s));
            imageSegmenter(im);
        end

        function launchRegionApp(tool,varargin)
            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);
            hFig=tool.hThumbnailFig;
            if isempty(hFig)||~isvalid(hFig)
                return;
            end
            im=tool.hThumbnailComponent.readFullImage(tool.hThumbnailComponent.CurrentSelection(1));
            imageRegionAnalyzer(im);
        end


        function exportToDataStore(tool)
            tool.showAsBusy;
            unlockWhenDone=onCleanup(@()tool.unshowAsBusy);
            hFig=tool.hThumbnailFig;
            if isempty(hFig)||~isvalid(hFig)
                return;
            end
            defaultVarName=matlab.lang.makeValidName(hFig.Tag);

            export2wsdlg({[getString(message('images:imageBrowser:exportAllTooltip')),':']},...
            {defaultVarName},...
            {tool.hThumbnailComponent.imds});
        end


        function showAsBusy(tool)
            tool.ToolGroup.setWaiting(true);
        end

        function unshowAsBusy(tool)
            tool.ToolGroup.setWaiting(false)
        end


        function setStatus(tool,text)
            tool.statusText=text;
            if(isempty(tool.notificationTimer)||...
                strcmp(tool.notificationTimer.Running,'off'))
                md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                f=md.getFrameContainingGroup(tool.ToolGroup.Name);
                if~isempty(f)

                    javaMethodEDT('setStatusText',f,text);
                end
            end
        end

        function setNotificationMessage(tool,text)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            f=md.getFrameContainingGroup(tool.ToolGroup.Name);
            javaMethodEDT('setStatusText',f,text);

            if(isempty(tool.notificationTimer))
                cb=@(varargin)tool.resetStatusText;
                cbhandler=@(e,d)matlab.graphics.internal.drawnow.callback(cb);
                tool.notificationTimer=timer(...
                'ExecutionMode','singleShot',...
                'StartDelay',3,...
                'TimerFcn',cbhandler);
            end
            stop(tool.notificationTimer);
            start(tool.notificationTimer);
        end

        function resetStatusText(tool)
            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            f=md.getFrameContainingGroup(tool.ToolGroup.Name);
            javaMethodEDT('setStatusText',f,tool.statusText);
        end


        function delete(tool)
            if~isempty(tool.notificationTimer)&&isvalid(tool.notificationTimer)
                stop(tool.notificationTimer)
            end
            delete(tool.notificationTimer);

            if~isempty(tool.ToolGroup)&&isvalid(tool.ToolGroup)
                delete(tool.ToolGroup);
            end
        end

        function deleteThumbnailFigure(tool)
            delete(tool.hThumbnailComponent);
            delete(tool.hThumbnailFig);
        end

        function closeCallback(tool,hEvent)
            ET=hEvent.EventData.EventType;
            if strcmp(ET,'CLOSING')
                drawnow;
                tool.ToolGroup.approveClose();
                tool.deleteThumbnailFigure();
                delete(tool.hPreviewFig);
                delete(tool);
            end
        end
    end

end
