









classdef ImageLabelerTool<vision.internal.labeler.tool.LabelerTool


    properties(Access=protected)
DialogManager
        SliderUpdate=false;
    end


    properties(Hidden)

        FrameChangeFromConnector=false;


        HasOverviewGenerated=false;

        ShowDrawProgressBar=true;




        BaseFolderForDicomSplit=[];
    end

    properties(Access=protected)
        NameNoneDisplay='Image';
        DefaultLayoutFileName='defaultLayoutIL.xml';
        DefaultLayoutWAttribFileName='defaultLayoutAttribIL.xml';


        OverviewDirName(1,:)char='Overview';
    end




    properties(SetObservable=true)
AreSignalsLoaded
    end




    properties


AlgorithmTabImage


AlgorithmTabBlockedImage

        ShowBlockedAutomationTutorial=true

AlgorithmInstanceFlag

BrowserPanelObj
    end

    properties(Dependent)
        DataMode(1,1)string
        IsDataBlockedImage(1,1)logical
    end


    methods(Access=public)
        function this=ImageLabelerTool()


            import vision.internal.labeler.tool.*
            import vision.internal.labeler.tool.display.*
            import vision.internal.imageLabeler.tool.*

            title=vision.getMessage('vision:labeler:ToolTitleIL');
            instanceName='imageLabeler';


            this=this@vision.internal.labeler.tool.LabelerTool(title,instanceName);
            createTabsSetActive(this);






            this.SessionManager=vision.internal.imageLabeler.tool.ImageLabelerSessionManager;


            this.DialogManager=vision.internal.imageLabeler.tool.dialogs.DialogManager;


            this.Session=vision.internal.imageLabeler.tool.Session;


            this.AlgorithmSetupHelper=vision.internal.labeler.tool.AlgorithmSetupHelper(this.InstanceName);
            addlistener(this.AlgorithmSetupHelper,'CaughtExceptionEvent',@(src,evt)this.showExceptionDialog(evt.ME,evt.DlgTitle));

            this.AreSignalsLoaded=false;


...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

















            this.addToolInstance();


            this.IsUIBusy=false;
        end

        function setupDocContainedObjs(this)

            import vision.internal.labeler.tool.*
            import vision.internal.labeler.tool.display.*
            import vision.internal.imageLabeler.tool.*



            thisFig=this.Container.NoneSignalFigure;
            this.DisplayManager=DisplayManager(thisFig,this.ToolType,this.NameNoneDisplay);


            thisFig=this.Container.ROILabelFigure;
            this.ROILabelSetDisplay=ROILabelSetDisplay(thisFig,this.InstanceName);

            thisFig=this.Container.SignalNavFigure;
            this.SignalNavigationDisplay=BrowserPanelDisplay(thisFig);



            this.ROILabelSetDisplay.Fig.UserData='ImageLabeler';

            thisFig=this.Container.FrameLabelFigure;
            this.FrameLabelSetDisplay=FrameLabelSetDisplay(thisFig,this.InstanceName);

            thisFig=this.Container.InstructionFigure;
            this.InstructionsSetDisplay=InstructionsSetDisplay(thisFig);

            thisFig=this.Container.AttribSublabelFigure;
            this.AttributesSublabelsDisplay=AttributesSublabelsDisplay(thisFig);

            thisFig=this.Container.OverviewFigure;
            this.OverviewDisplay=OverviewDisplay(thisFig);
            this.addOverviewListeners();

            thisFig=this.Container.MetadataFigure;
            this.MetadataDisplay=MetadataDisplay(thisFig);


            this.updateFigureCloseListener();
        end

        function makeSureToolbarVisible(this)
            changeToolbarVisibility(this,true);
        end


        function imDisplay=getImageDisplay(this)
            imDisplay=[];
            if this.DisplayManager.NumDisplays>1
                imDisplay=this.DisplayManager.getDisplayFromIdNoCheck(2);
            end
        end

        function out=getImageAxesLimits(this)
            imDisplay=getImageDisplay(this);
            out=imDisplay.getAxesLimits;
        end







        function restoreSignalAfterAutomation(this)
            restoreAllImages(this);
        end


        function signalNavigationKeyPress(this,src)
            doBrowserKeyPress(this,src);
        end


        function resetNavigationControls(this)
            if useAppContainer()
                deleteImageBrowser(this);
            else
                reset(this.BrowserPanelObj);
            end
            this.BrowserPanelObj=[];
        end

        function resetOverviewDisplay(this)
            reset(this.OverviewDisplay);
        end

        function resetViewForCleanSession(this)


            this.LabelTab.enableLoadImagesDatastore(true);
            this.LabelTab.enableShowOverviewListItem(false);
            this.LabelTab.setShowOverviewListItem(false);


            this.resetOverviewDisplay();


            this.Container.makeOverviewInvisible();
        end

        function closeUifigureDialogs(this)
            this.DialogManager.clear();
        end

        function deleteImageBrowser(this)
            if useAppContainer()&&~isempty(this.BrowserPanelObj)
                this.BrowserPanelObj.deleteBrowser();
            end
        end


        function drawImage(this,idx,forceRedraw)
            if~hasImages(this.Session)
                return;
            end

            [data,exceptions]=this.Session.readData(idx);

            if~isempty(exceptions)
                hFig=this.Container.getDefaultFig;
                msg=sprintf('%s\n',exceptions(:).message);
                errorMessage=vision.getMessage('vision:imageLabeler:ReadDataError',msg);
                dialogName=vision.getMessage('vision:imageLabeler:ReadDataErrorTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
            end



            useProgressBar=this.IsDataBlockedImage&&this.ShowDrawProgressBar;

            if useProgressBar
                currIdx=this.getCurrentIndex();
                if currIdx>=this.Session.getNumImages()

                    positions=[];
                else
                    positions=this.Session.queryROILabelAnnotationByReaderId(1,currIdx);
                end

                numLabelsCurrentImage=numel(positions);
                numLabelsNewImage=numel(data.Positions);

                if numLabelsNewImage>400||numLabelsCurrentImage>400
                    hFig=getDefaultFig(this.Container);

                    progressDlgTitle=vision.getMessage('vision:labeler:DrawingImageTitle');
                    pleaseWaitMsg=vision.getMessage('vision:labeler:StartDrawing');
                    waitBarObj=vision.internal.labeler.tool.ProgressDialog(hFig,...
                    progressDlgTitle,pleaseWaitMsg);

                    drawingROIsMessage=vision.getMessage('vision:labeler:DrawingImage');
                    waitBarObj.setParams(0.5,drawingROIsMessage);

                    closeWaitbar=onCleanup(@()close(waitBarObj));
                end
            end

            data.ForceRedraw=forceRedraw;

            drawImageWithInteractiveROIs(this,data);


            if this.ShowOverviewTab
                this.OverviewDisplay.draw(data,idx);
            end

...
...
...
...
...
...
...
...
...
...

            if(this.StopAlgRun)
                imgDisplay=getSelectedDisplay(this);
                currentROIs=imgDisplay.getCurrentROIs();
                imgDisplay.updateUndoOnLabelChange(idx,currentROIs);
            end

        end

        function resetMetadataDisplay(this)
            reset(this.MetadataDisplay);
        end
    end

    methods(Access=private)

        function createTabsSetActive(this)


            this.LabelTab=vision.internal.imageLabeler.tool.LabelTab(this);


            this.SemanticTab=vision.internal.labeler.tool.SemanticTab(this);

            this.AlgorithmTabImage=vision.internal.imageLabeler.tool.AlgorithmTab(this);
            this.AlgorithmTab=this.AlgorithmTabImage;




            this.AlgorithmTabBlockedImage=vision.internal.imageLabeler.tool.BlockedImageAlgorithmTab(this);
            this.AlgorithmTabBlockedImage.hide();


            this.ActiveTab=this.LabelTab;
        end













...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...


        function modifyLabelNameParent(this,roiLabelNew,oldLabelName)

            newLabelName=roiLabelNew.Label;

            modifyLabelSelection(this,oldLabelName,newLabelName);

            modifyLabelName(this,oldLabelName,newLabelName);

            modifyLabelNameInLeftPanel(this,oldLabelName,newLabelName);

            modifyLabelNameInCurrentROIs(this,oldLabelName,newLabelName);
        end


        function loadImages(this,imageData)

            dispName=getFirstdisplayTitle(this,imageData);

            if this.IsDataBlockedImage
                dispType=displayType.BlockedImageMixedSize;
            else
                dispType=displayType.ImageMixedSize;
            end

            addDisplayIfNone(this,dispName,dispType);

            loadImages(this.BrowserPanelObj,imageData);

        end


        function appendImage(this,imageData)

            imDisplay=getImageDisplay(this);
            if~isempty(imDisplay)

                appendImage(imDisplay);
                appendImage(this.BrowserPanelObj,imageData);

            end
        end


        function restoreAllImages(this)

            imDisplay=getImageDisplay(this);
            if~isempty(imDisplay)


                restoreAllImages(this.BrowserPanelObj);


                selectedImageIdx=getSelectedImageIdx(this.Session);



                selectImageByIndex(this,selectedImageIdx);

            end
        end


        function TF=canRespondToKeyPress(this,imDisplay)

            TF=~(this.BrowserPanelObj.hasImages()&&getUserIsDrawing(imDisplay));
        end


        function doBrowserKeyPress(this,src)
            imDisplay=getImageDisplay(this);
            if~isempty(imDisplay)
                if canRespondToKeyPress(this,imDisplay)
                    this.BrowserPanelObj.doKeyPress(src);
                end
            end
        end


        function filterSelectedImages(this)

            imDisplay=getImageDisplay(this);
            if~isempty(imDisplay)

                filterSelectedImages(this.BrowserPanelObj);

                if~useAppContainer()
                    indices=this.BrowserPanelObj.SelectedItemIndex;



                    firsImageIdx=indices(1);
                    this.selectImageByIndex(firsImageIdx);
                end



                imDisplay.wipeROIs();

                if~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay)
                    updateVisualSummaryInAlgorithmMode(this);
                end
            end
        end


        function selectImageByIndex(this,idx)
            imDisplay=getImageDisplay(this);
            if~isempty(imDisplay)

                updateDisplayIndex(imDisplay,idx);


                selectImageByIndex(this.BrowserPanelObj,idx);
            end
        end


        function createAndSetBrowserPanel(this,~)
            this.BrowserPanelObj=vision.internal.imageLabeler.tool.BrowserPanel(...
            this.SignalNavigationDisplay.getLabeledVideoContainer(),...
            this.IsDataBlockedImage);
            attachBrowserPanelListeners(this);
            imageLabelUIContainer=this.SignalNavigationDisplay.getLabeledVideoContainer();
            imageLabelUIContainer.setBrowserPanel(this.BrowserPanelObj);

            this.SignalNavigationDisplay.resizeFigure();


            this.BrowserPanelObj.setTempOverviewDirectory(this.OverviewDisplay.OverviewDir);
        end


        function attachBrowserPanelListeners(this)
            addlistener(this.BrowserPanelObj,'ImageSelectedInBrowser',@this.doImageSelectedInBrowser);
            addlistener(this.BrowserPanelObj,'ImageRemovedInBrowser',@this.doImageRemovedInBrowser);
            addlistener(this.BrowserPanelObj,'ImageRotateInBrowser',@this.doImageRotateInBrowser);

            addlistener(this.BrowserPanelObj,'PlacingThumbnailsStarted',@(~,~)this.openProgressDialog);
            addlistener(this.BrowserPanelObj,'PlacingThumbnailsFinished',@(~,~)this.closeProgressDialog);

            addlistener(this.BrowserPanelObj,'GeneratingOverviewImage',...
            @(~,evt)this.doUpdateProgressDlg(evt.ImageName,evt.ImageSize));
            addlistener(this.BrowserPanelObj,'OverviewBlockedImageGenerated',...
            @(~,evt)this.doWriteOverviewImage(evt.BlockedImage,evt.ImageNum));
        end


        function hideBrowserPanelContent(this)
            hideContent(this.BrowserPanelObj);
        end


        function createAndSetImageBrowser(this,~)
            this.BrowserPanelObj=vision.internal.imageLabeler.tool.HorizontalImageBrowser(...
            this.SignalNavigationDisplay.getLabeledVideoContainer(),...
            this.IsDataBlockedImage);
            attachImageBrowserListeners(this);
        end


        function attachImageBrowserListeners(this)
            addlistener(this.BrowserPanelObj,'ImageSelectedInBrowser',@this.doImageSelectedInBrowser);
            addlistener(this.BrowserPanelObj,'ImageRemovedInBrowser',@this.doImageRemovedInBrowser);
            addlistener(this.BrowserPanelObj,'ImageRotateInBrowser',@this.doImageRotateInBrowser);
        end


        function showBrowserPanelContent(this)
            showContent(this.BrowserPanelObj);
        end

        function reconfigureToolstripTabs(this)

            if this.IsDataBlockedImage
                this.SemanticTab.hide();

                this.AlgorithmTabImage.hide();
                this.AlgorithmTab=this.AlgorithmTabBlockedImage;
            else

                this.AlgorithmTabBlockedImage.hide();
                this.AlgorithmTab=this.AlgorithmTabImage;
            end

            drawnow();

        end

    end




    methods

        function configureNewDisplayHelper(this,newDisplay)
            configureImageBrowserDisplay(newDisplay,...
            @(varargin)this.protectOnDelete(@this.doImageSelected,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doImageRemoved,varargin{:}),...
            @(varargin)this.protectOnDelete(@this.doImageRotate,varargin{:}));
        end

    end


    methods




        function datamode=get.DataMode(this)

            if this.Session.hasDatastore()
                datamode="datastore";
            elseif this.Session.hasImages()
                if this.IsDataBlockedImage
                    datamode="blockedimage";
                else
                    datamode="image";
                end
            else
                datamode="empty";
            end
        end




        function IsDataBlockedImage=get.IsDataBlockedImage(this)
            IsDataBlockedImage=this.Session.IsDataBlockedImage;
        end

        function set.IsDataBlockedImage(this,IsDataBlockedImage)
            this.Session.IsDataBlockedImage=IsDataBlockedImage;


            if IsDataBlockedImage

                this.SupportedROILabelTypes=[labelType.Rectangle...
                ,labelType.Line,labelType.Polygon,labelType.ProjectedCuboid];



                this.LabelTab.setAlgorithmSectionBlockedImageLabelingMode(true);


                this.LabelTab.enableLoadImagesDatastore(false);


                helperTxt=vision.getMessage('vision:labeler:ROIBlockedImageHelperText');
                this.ROILabelSetDisplay.updateHelperText(helperTxt);

            else
                this.SupportedROILabelTypes=[labelType.Rectangle...
                ,labelType.Line,labelType.PixelLabel...
                ,labelType.Polygon,labelType.ProjectedCuboid];





                helperTxt=vision.getMessage('vision:labeler:ROIHelperText');
                this.ROILabelSetDisplay.updateHelperText(helperTxt);

            end

            setTitleBar(this,this.ToolName);
            this.reconfigureToolstripTabs();
        end




        function foldername=setTempDirectory(this)

            [~,name]=fileparts(tempname);
            foldername=[tempdir,'Labeler_',name];

            status=mkdir(foldername);
            if~status
                toolCenter=this.Container.getLocation();
                dlg=this.DialogManager.MandatoryDirectoryDialog(toolCenter,name);
                foldername=dlg.Directory;
            end

            setTempDirectory(this.Session,foldername);
            this.setTempOverviewDirectory();
        end

        function setTempOverviewDirectory(this)

            overviewDir=fullfile(this.Session.TempDirectory,this.OverviewDirName);
            if exist(overviewDir,'dir')
                return
            end

            status=mkdir(overviewDir);
            if~status
                disp('Cannot create overview folder under tempdir');
            end

            this.OverviewDisplay.OverviewDir=overviewDir;

        end

    end

    methods

        function freezeSignalNavInteractions(this)
            freeze(this.BrowserPanelObj);






            setDisplayFigHandleVis(this,'off');
        end


        function unfreezeSignalNavInteractions(this)


            setDisplayFigHandleVis(this,'callback');

            unfreeze(this.BrowserPanelObj);
        end





    end




    methods(Access=protected)


        function saveLayoutToSessionInLabelMode(~)
        end


        function reactToAppInFocus(this)

            if~isvalid(this)
                return
            end

            if~isempty(this.Session)&&...
                this.Session.HasROILabels&&this.Session.hasImages()
                imDisplay=getImageDisplay(this);
                if~isempty(imDisplay)
                    if strcmp(imDisplay.getModeSelection,'ROI')&&~getTearAwayVisibility(this.SemanticTab)
                        drawnow;

                        enableDrawing(imDisplay);
                    end
                end
            end
        end


        function reactToAppFocusLost(this)

            if~isvalid(this)
                return
            end
            if this.Session.HasROILabels&&this.Session.hasImages()
                imDisplay=getImageDisplay(this);
                if~isempty(imDisplay)

                    if strcmp(imDisplay.getModeSelection,'ROI')&&~getTearAwayVisibility(this.SemanticTab)
                        drawnow;
                        imDisplay.disableDrawing();
                    end
                end
            end
        end


        function reset(this)
            [data,~]=this.Session.readData(getCurrentIndex(this));
            imDisplay=getImageDisplay(this);
            if~isa(imDisplay,'vision.internal.labeler.tool.display.BlockedImageDisplay')
                resetPixelLabeler(imDisplay,data);
            end
        end

    end




    methods(Access=protected)

        function doImageSelected(this,varargin)


            finalize(this);

            evtData=varargin{2};


            if~isempty(evtData.Index)&&numel(evtData.Index)==1
                this.drawImage(evtData.Index,false);

                setSelectedImageIdx(this.Session,evtData.Index);

                isVisualSummaryOpen=~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay);

                if isVisualSummaryOpen
                    updateVisualSummarySlider(this,[],[]);
                end
            end
        end


        function doImageSelectedInBrowser(this,varargin)
            doImageSelected(this,varargin{:})

            data=varargin{2};
            if~isempty(data.Index)
                setModeROIorNone(this);

                imgIdx=data.Index(1);
                imDisplay=getSelectedDisplay(this);
                updateDisplayIndex(imDisplay,imgIdx);
            end




            if this.IsDataBlockedImage&&this.Session.NumROILabels>0
                numLevels=zeros(length(data.Index),1);
                counter=1;
                for imageId=data.Index
                    numLevels(counter)=getNumResLevels(this.Session,imageId);
                    counter=counter+1;
                end

                automateEnableFlag=size(unique(numLevels(:)),1)==1;

                this.LabelTab.setAlgorithmSectionAutomateButton(automateEnableFlag);


                if isa(this.ActiveTab,'vision.internal.imageLabeler.tool.BlockedImageAlgorithmTab')
                    imgIdx=data.Index(1);
                    resLevelSizes=getLevelSizes(this.Session,imgIdx);
                    this.MetadataDisplay.updateMetadataProperties(resLevelSizes);
                end

            end

        end


        function doImageRemoved(this,varargin)

            wait(this.Container);


            finalize(this);

            evtData=varargin{2};
            removedImageIndices=evtData.Index;

            if~isempty(removedImageIndices)
                removeImagesFromSession(this.Session,removedImageIndices);
                removeImage(this.OverviewDisplay,removedImageIndices);





                newIdx=min(max(removedImageIndices),getNumImages(this.Session));
                if newIdx>0

                    imageDisplay=this.getImageDisplay();
                    imageDisplay.resetUndoRedoBuffer();
                    drawImage(this,newIdx,true);
                else


                    deleteComponenDestroyListener(this);
                    selectedDisplay=getSelectedDisplay(this);
                    selectedDisplayname=selectedDisplay.Name;
                    removeDisplayPlus(this,getDisplayFig(this.DisplayManager,...
                    selectedDisplayname),false);

                    clearAfterLastSignalRemoved(this);

                    this.undoRedoQABCallback();
                    updateFigureCloseListener(this);
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
                end

                updateToolstrip(this);
            end

            resume(this.Container);
        end


        function doImageRemovedInBrowser(this,varargin)
            doImageRemoved(this,varargin{:})

            data=varargin{2};
            tf=~isempty(data.Index);

            if tf
                setModeROIorNone(this);drawnow();






            end

        end


        function doImageRotate(this,varargin)



            finalize(this);

            evtData=varargin{2};
            imagesToBeRotatedIdx=evtData.Index;
            rotationType=evtData.RotationType;





            newRotatedIdx=[];
            for idx=imagesToBeRotatedIdx
                filename=this.Session.ImageFilenames{idx};
                if~isdicom(filename)
                    newRotatedIdx=[newRotatedIdx,idx];%#ok<AGROW> 
                end
            end
            imagesToBeRotatedIdx=newRotatedIdx;


            displayMessage=vision.getMessage('vision:imageLabeler:RotateImageWarning');
            dialogName=vision.getMessage('vision:imageLabeler:RotateImage');
            yes=vision.getMessage('MATLAB:uistring:popupdialogs:Yes');
            no=vision.getMessage('MATLAB:uistring:popupdialogs:No');
            hFig=this.Container.getDefaultFig;

            selection=vision.internal.labeler.handleAlert(hFig,'questionWithWaitDlg',displayMessage,dialogName,...
            this.Tool,yes,no,yes);

            if~isempty(imagesToBeRotatedIdx)

                if strcmpi(selection,yes)

                    wait(this.Container);
                    resetWait=onCleanup(@()resume(this.Container));

                    currentImageIdx=imagesToBeRotatedIdx(1);
                    [rotatedImages,imageSizes]=rotateImages(this.Session,imagesToBeRotatedIdx,rotationType);

                    if~isempty(find(rotatedImages==currentImageIdx,1))
                        imDisplay=getImageDisplay(this);

                        imDisplay.resetUndoRedoBuffer;
                        clearImage(imDisplay);
                        drawImage(this,currentImageIdx,true);
                        rotateCurrentViewROI(this.OverviewDisplay,imagesToBeRotatedIdx,imageSizes,rotationType);
                    end

                    numRotateImg=numel(rotatedImages);
                    numImgToBeRotated=numel(imagesToBeRotatedIdx);

                    resume(this.Container);
                    if(numRotateImg>0)&&numRotateImg<numImgToBeRotated
                        errorMessage=vision.getMessage('vision:imageLabeler:RotateImageErrorSome');
                        dialogName=vision.getMessage('vision:imageLabeler:RotateImage');
                        vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                        this.Tool);
                    elseif numRotateImg==0
                        errorMessage=vision.getMessage('vision:imageLabeler:RotateImageErrorAll');
                        dialogName=vision.getMessage('vision:imageLabeler:RotateImage');
                        vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                        this.Tool);
                    end
                end
            end
        end


        function doImageRotateInBrowser(this,varargin)
            doImageRotate(this,varargin{:})

            data=varargin{2};
            idx=data.Index;

            if~isempty(idx)
                setModeROIorNone(this);drawnow();




            end

        end


        function idx=getCurrentIndex(this,varargin)
            imDisplay=getImageDisplay(this);
            if~isempty(imDisplay)
                idx=getCurrentDisplayIndex(imDisplay);
            else
                idx=[];
            end
        end


        function addDisplayIfNone(this,dispName,dispType)






            grabFocus(this.DisplayManager);
            dispName=string(dispName);

            if this.DisplayManager.NumDisplays==1

                addNewDisplayAsTab(this,dispType,dispName);
                this.AreSignalsLoaded=true;

                if this.DisplayManager.NumDisplays>1
                    noneDisplay=this.DisplayManager.getDisplayFromIdNoCheck(1);
                    if isPanelVisible(noneDisplay)
                        drawnow()
                        makeNonDisplayInvisible(this.Container);
                    end


                    this.OverviewDisplay.initialize(dispType);
                    this.LabelTab.enableShowOverviewListItem(true);

                    if this.IsDataBlockedImage&&~this.ShowOverviewTab


                        this.ShowOverviewTab=true;
                        this.LabelTab.setShowOverviewListItem(true);

                        makeOverviewVisible(this.Container);drawnow()

                    end

                    if isempty(this.BrowserPanelObj)


                        imageThumbnailInfo=[];
                        if useAppContainer()



                            adjustFigurePanelWidth(this.Container);

                            createAndSetImageBrowser(this,imageThumbnailInfo);
                        else
                            createAndSetBrowserPanel(this,imageThumbnailInfo);
                            hideBrowserPanelContent(this);
                        end

                        this.ShowNavControlTab=true;


                        makeSignalNavVisible(this.Container);drawnow()
                        createXMLandGenerateLayout(this,1,1);

                        if~useAppContainer()
                            showBrowserPanelContent(this);
                        else


                            adjustFigurePanelWidth(this.Container);
                        end

                    end

                end


                imDisplay=this.getImageDisplay();
                addlistener(imDisplay,'AxesLimitsChanged',@(~,evt)this.displayLimitsChanged(evt.XLim,evt.YLim));


            end
        end
    end

    methods
        function hasException=handleException(~)


            hasException=false;
        end
    end




    methods

        function undo(this,~,~)
            selectedDisplay=getImageDisplay(this);
            signalName=getSignalName(this);
            currentIndex=getCurrentIndex(this);

            undoHelper(this,signalName,selectedDisplay,currentIndex);
        end


        function redo(this,~,~)
            selectedDisplay=getImageDisplay(this);
            signalName=getSignalName(this);
            currentIndex=getCurrentIndex(this);

            redoHelper(this,signalName,selectedDisplay,currentIndex);
        end


        function currentIndex=getCurrentFrameIndex(this,~)
            currentIndex=getCurrentIndex(this);
        end
    end




    methods


        function updateFrameLabelData(this,data,addOrDelete)

            if~useAppContainer()
                indices=this.BrowserPanelObj.SelectedItemIndex;
            else
                indices=this.BrowserPanelObj.BrowserObj.Selected;
            end

            signalName='';

            for i=1:numel(indices)
                switch addOrDelete
                case 'add'
                    addFrameLabelAnnotation(this.Session,signalName,indices(i),data.LabelName);
                    checkFrameLabel(this.FrameLabelSetDisplay,data.ItemId);

                case 'delete'
                    deleteFrameLabelAnnotation(this.Session,signalName,indices(i),data.LabelName);
                    uncheckFrameLabel(this.FrameLabelSetDisplay,data.ItemId);
                end
            end



...
...
...


            value=strcmpi(addOrDelete,'add');
            updateVisualSummarySceneCount(this,signalName,data.LabelName,indices,value);
        end

...
...
...
...
...
...


        function[currentFrame,currentFrameIndex]=getCurrentFrameAndFrameidx(this,~)

            currentFrameIndex=this.getCurrentIndex();
            [data,~]=this.Session.readData(currentFrameIndex);
            currentFrame=data.Image;

        end

        function name=getConvertedSignalName(~,~)
            name='';
        end

    end




    methods

...
...
...
...
...
...
...




        function setModeInDisplay(this,mode)

            setMode(this,mode);

            resetFocus(this);
        end


        function setLabelingMode(this,mode)

            imDisplay=getImageDisplay(this);
            setLabelingMode(imDisplay,mode);
            if mode==labelType.PixelLabel
                setROIIcon(this.LabelTab,'pixel');
                setROIIcon(this.SemanticTab,'pixel');
                showContextualSemanticTab(this);
                this.TabGroup.SelectedTab=getTab(this.SemanticTab);
            else
                setROIIcon(this.LabelTab,'roi');
                setROIIcon(this.SemanticTab,'roi');
                hideContextualSemanticTab(this);
            end
        end







        function doModeChange(this,~,data)

            mode=data.Mode;
            this.ActiveTab.reactToModeChange(mode);


            if~this.Session.HasROILabels&&strcmpi(mode,'ROI')
                mode='none';
            end

            setModeInDisplay(this,mode);
        end
    end




    methods

        function exportLabelAnnotationsToWS(this)

            wait(this.Container);

            resetWait=onCleanup(@()resume(this.Container));

            finalize(this);

            variableName='gTruth';

            if hasPixelLabels(this.Session)
                dlgTitle=vision.getMessage('vision:uitools:ExportTitle');
                toFile=false;
                exportDlg=vision.internal.labeler.tool.ExportPixelLabelDlg(...
                this.Tool,variableName,dlgTitle,this.Session.getPixelLabelDataPath,toFile);
                wait(exportDlg);
                if~exportDlg.IsCanceled
                    this.Session.setPixelLabelDataPath(exportDlg.VarPath);
                    TF=exportPixelLabelData(this.Session,exportDlg.CreatedDirectory);
                    if~TF
                        hFig=this.Container.getDefaultFig;
                        errorMessage=getString(message('vision:labeler:UnableToExportDlgMessage'));
                        dialogName=getString(message('vision:labeler:UnableToExportDlgName'));
                        vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                        this.Tool);
                        return;
                    end
                end

                format='groundTruth';
            else
                allowTableFormatChoice=~this.Session.hasSceneLabels()&&~this.Session.hasDatastore();
                exportDlg=vision.internal.imageLabeler.tool.ExportDlg(this.Tool,variableName,allowTableFormatChoice);
                wait(exportDlg);
                format=exportDlg.VarFormat;
            end

            if~exportDlg.IsCanceled
                varName=exportDlg.VarName;
                this.setStatusText(vision.getMessage('vision:labeler:ExportToWsStatus',varName));


                signalName='';
                if strcmpi(format,'groundTruth')
                    labels=exportLabelAnnotations(this.Session,signalName);
                    if hasPixelLabels(this.Session)
                        refreshPixelLabelAnnotation(this.Session);
                    end
                    saveVariableToWs(this,varName,labels);
                else

                    labels=exportLabelAnnotations(this.Session,signalName);
                    tbl=table(labels.DataSource.Source,'VariableNames',{'imageFilename'});
                    tbl=[tbl,labels.LabelData];

                    saveVariableToWs(this,varName,tbl);
                end
                this.setStatusText('');
            end
            drawnow;


        end

    end




    methods(Access=private)

        function deletePixelLabelsForBlockedImages(this)

            this.hideContextualSemanticTab();

            indices=this.ROILabelSetDisplay.getLabelIDsByLabelType(labelType.PixelLabel);
            for i=numel(indices):-1:1
                this.ROILabelSetDisplay.deleteItemWithID(indices(i));
            end
            this.Session.ROILabelSet.removeLabelsByLabelType(labelType.PixelLabel);

        end

        function[isCandidateForBlockedImage,errored]=checkIfCandidateForBlockedImage(this,fileNames)







            isCandidateForBlockedImage=false;
            errored=false;
            s=settings;
            blockedImageMinSize=s.vision.imageLabeler.BlockedImageMinSize.ActiveValue;

            warnStruct=warning('off');
            resetWarnings=onCleanup(@()warning(warnStruct));

            try
                for idx=1:numel(fileNames)

                    filename=fileNames{idx};
                    if isdicom(filename)


                        df=images.internal.dicom.DICOMFile(filename);
                        info.Width=df.getAttribute(0x0028,0x0011);
                        info.Height=df.getAttribute(0x0028,0x0010);


                        if isempty(info.Width)||isempty(info.Height)||...
                            (info.Width==0)||(info.Height==0)
                            error(message("vision:imageLabeler:NoImageInDicom"));
                        end
                    else
                        info=imfinfo(filename);
                    end

                    isCandidateForBlockedImage=numel(info)>1||...
                    info.Width>=blockedImageMinSize(2)||info.Height>=blockedImageMinSize(1);

                    if isCandidateForBlockedImage
                        return
                    end
                end

            catch ME

                errored=true;

                hFig=this.Container.getDefaultFig;
                errorMessage=vision.getMessage('vision:imageLabeler:ReadDataError',ME.message);
                dialogName=vision.getMessage('vision:imageLabeler:ReadDataErrorTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                return
            end

        end

        function[importAs,canceled]=importDataAsBlockedImageDialog(this)

            wait(this.Container);
            resetWait=onCleanup(@()resume(this.Container));

            toolCenter=this.Container.getLocation();
            hasPixelLabels=this.Session.hasPixelLabels();
            dlg=this.DialogManager.ImportImageAsDlg(toolCenter,hasPixelLabels);

            importAs=dlg.ImportAs;
            canceled=dlg.Canceled;


            if hasPixelLabels&&~canceled&&importAs=="BlockedImage"
                this.deletePixelLabelsForBlockedImages();
            end

        end

        function isCancelled=checkForBlockedImage(this,fileNames)

            isCancelled=false;

            [isCandidateForBlockedImage,fileReadErrored]=this.checkIfCandidateForBlockedImage(fileNames);
            if fileReadErrored
                isCancelled=true;
                return
            end

            if isCandidateForBlockedImage
                [importAs,canceled]=this.importDataAsBlockedImageDialog();

                if canceled
                    isCancelled=true;
                    return
                end

                if importAs=="BlockedImage"

                    try
                        blockedImage(fileNames);

                    catch ME

                        hFig=this.Container.getDefaultFig;
                        msg=sprintf('%s\n',ME.message);
                        errorMessage=vision.getMessage('vision:imageLabeler:ReadDataError',msg);
                        dialogName=vision.getMessage('vision:imageLabeler:ReadDataErrorTitle');
                        vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                        this.Tool);

                        isCancelled=true;
                        return
                    end

                    this.IsDataBlockedImage=true;

                elseif importAs=="RegularImage"
                    this.IsDataBlockedImage=false;
                else
                    assert(false,'Should never be here as one of the radio buttons should be true');
                end
            end

        end

    end




    methods

        function loadImage(this)

            wait(this.Container);
            resetWait=onCleanup(@()resume(this.Container));


            if hasDatastore(this.Session)
                strReadFcn=func2str(this.Session.Datastore.ReadFcn);
                message=vision.getMessage('vision:imageLabeler:AddImageDatastoreExistsError',strReadFcn);
                dialogName=vision.getMessage('vision:imageLabeler:AddImageTitle');
                hFig=this.Container.getDefaultFig;

                vision.internal.labeler.handleAlert(hFig,'messageDialog',message,dialogName,...
                this.Tool);
                return;
            end


            [fileNames,isUserCanceled]=imgetfile('MultiSelect',true);
            if isUserCanceled||isempty(fileNames)
                return;
            end

            if~useAppContainer()
                unsupportedFileName=hasXMLUnsupportedChar(fileNames);
                if~isempty(unsupportedFileName)
                    message=vision.getMessage('vision:imageLabeler:XMLUnsupportedCharInFilename',unsupportedFileName);
                    dialogName=vision.getMessage('vision:imageLabeler:AddImageTitle');
                    hFig=this.Container.getDefaultFig;

                    vision.internal.labeler.handleAlert(hFig,'messageDialog',message,dialogName,...
                    this.Tool);
                    return;
                end
            end

            fileNames=splitMultiFrameDICOMImages(this,fileNames);

            isCanceled=doLoadDataAs(this,fileNames);
            if isCanceled
                return
            end

        end





        function fileNamesOut=splitMultiFrameDICOMImages(this,fileNamesIn)

            fileNamesOut=fileNamesIn;


            idxOut=1;
            for idxIn=1:numel(fileNamesIn)

                filename=fileNamesIn{idxIn};
                if isdicom(filename)
                    if isMultiFrameDICOM
                        askForBaseFolder;
                        if~isempty(this.BaseFolderForDicomSplit)
                            rewriteToIndividualFrames;
                        else

                            fileNamesOut(idxOut)=[];
                        end
                    else
                        fileNamesOut{idxOut}=filename;
                        idxOut=idxOut+1;
                    end
                else
                    fileNamesOut{idxOut}=filename;
                    idxOut=idxOut+1;
                end
            end


            function flag=isMultiFrameDICOM


                df=images.internal.dicom.DICOMFile(filename);
                numFrames=df.getAttribute(0x0028,0x0008);
                flag=~isempty(numFrames)&&(numFrames>1);
            end


            function askForBaseFolder


                if isempty(this.BaseFolderForDicomSplit)

                    splittingFolderDlg=vision.internal.imageLabeler.tool.dialogs.SplitDicomFolderDlg(...
                    this.Tool,this.BaseFolderForDicomSplit);

                    wait(splittingFolderDlg);

                    if~splittingFolderDlg.IsSkipped
                        this.BaseFolderForDicomSplit=splittingFolderDlg.FolderPath;
                    else
                        this.BaseFolderForDicomSplit=[];
                    end
                end

            end




            function rewriteToIndividualFrames

                inputFname=filename;
                [multiFrame,map]=dicomread(inputFname);

                [~,outBaseFileName,~]=fileparts(inputFname);
                baseFolder=this.BaseFolderForDicomSplit;


                outFolder=fullfile(baseFolder,outBaseFileName);

                if~isfolder(outFolder)


                    mkdir(outFolder);
                end


                outBaseFileName=fullfile(outFolder,outBaseFileName);

                if~isempty(map)
                    dicomwrite(multiFrame,map,outBaseFileName+".dcm",'MultiframeSingleFile',false)
                else
                    dicomwrite(multiFrame,outBaseFileName+".dcm",'MultiframeSingleFile',false)
                end
                outFiles=dir(outBaseFileName+"*.dcm");

                for i=1:numel(outFiles)
                    fileNamesOut{idxOut}=fullfile(outFiles(i).folder,outFiles(i).name);
                    idxOut=idxOut+1;
                end

            end

        end


        function loadImageFromDataStore(this)


            variableTypes={'matlab.io.datastore.ImageDatastore'};
            variableDisp={'imageDatastore'};
            [imds,~,isCanceled]=vision.internal.uitools.getVariablesFromWS(variableTypes,variableDisp);

            if isCanceled
                return
            end

            isCanceled=doLoadDataAs(this,imds);
            if isCanceled
                return
            end

        end

        function isCanceled=doLoadDataAs(this,imageData)




























            wait(this.Container);
            resetWait=onCleanup(@()resume(this.Container));

            isDatastore=isa(imageData,'matlab.io.datastore.FileBasedDatastore');
            isCanceled=false;
            hFig=this.Container.getDefaultFig;

            switch this.DataMode

            case "empty"
                if isDatastore
                    if~isempty(imageData.Files)
                        doLoadDatastore(this,imageData);
                    end
                else
                    isCanceled=checkForBlockedImage(this,imageData);
                    if isCanceled
                        return
                    end
                    doLoadImages(this,imageData);
                end

                setTitleBar(this,this.ToolName);
                this.reconfigureToolstripTabs();

            case "image"
                if isDatastore
                    if isReadFcnDefault(this,imageData)
                        doLoadImages(this,imageData.Files);
                    else
                        message=vision.getMessage('vision:imageLabeler:AddImageDatastoreError');
                        dialogName=vision.getMessage('vision:imageLabeler:AddImageTitle');
                        vision.internal.labeler.handleAlert(hFig,'messageDialog',message,dialogName,...
                        this.Tool);
                        isCanceled=true;
                        return;
                    end
                else
                    [isCandidateForBlockedImage,fileReadErrored]=this.checkIfCandidateForBlockedImage(imageData);
                    if fileReadErrored
                        isCanceled=true;
                        return
                    end

                    if isCandidateForBlockedImage
                        toolCenter=this.Container.getLocation();
                        dlg=this.DialogManager.MergeLargeDataDlg(toolCenter);
                        if~isempty(dlg)&&dlg.Canceled
                            isCanceled=true;
                            return;
                        end
                    end
                    doLoadImages(this,imageData);
                end

            case "blockedimage"
                if isDatastore
                    assert(true,'Should never reach here as AddFromDatastore should be disabled');
                else
                    doLoadImages(this,imageData);
                end

            case "datastore"
                if isDatastore
                    if strcmp(func2str(this.Session.Datastore.ReadFcn),func2str(imageData.ReadFcn))
                        doLoadImages(this,imageData.Files);
                    else
                        strReadFcn=func2str(this.Session.Datastore.ReadFcn);
                        message=vision.getMessage('vision:imageLabeler:AddImageDatastoreExistsError',strReadFcn);
                        dialogName=vision.getMessage('vision:imageLabeler:AddImageTitle');
                        vision.internal.labeler.handleAlert(hFig,'messageDialog',message,dialogName,...
                        this.Tool);
                        isCanceled=true;
                        return
                    end
                else
                    message=vision.getMessage('vision:imageLabeler:AddImageDatastoreError');
                    dialogName=vision.getMessage('vision:imageLabeler:AddImageTitle');
                    vision.internal.labeler.handleAlert(hFig,'messageDialog',message,dialogName,...
                    this.Tool);
                    isCanceled=true;
                    return;
                end

            end

        end

        function doLoadImageAs(this,imageData,IsDataBlockedImage)

            if isempty(imageData)
                return
            end

            this.IsDataBlockedImage=IsDataBlockedImage;

            doLoadImages(this,imageData);

        end

    end




    methods

        function doLoadImages(this,imageData)

            wait(this.Container);
            turnOffWaiting=onCleanup(@()resume(this.Container));

            if iscellstr(imageData)%#ok<*ISCLSTR>
                imageData=setdiff(unique(...
                [this.Session.ImageFilenames;reshape(imageData,[],1)],'stable'),...
                this.Session.ImageFilenames,'stable');

                if isempty(imageData)
                    return
                end
            end

            this.setStatusText(vision.getMessage('vision:imageLabeler:LoadImageStatus'));

            numImagesBeforeAdd=getNumImages(this.Session);

            if this.IsDataBlockedImage
                dispType=displayType.BlockedImageMixedSize;


                if isempty(this.Session.TempDirectory)
                    this.setTempDirectory();
                end

            else
                dispType=displayType.ImageMixedSize;
            end


            dispName=getFirstdisplayTitle(this,imageData);

            addDisplayIfNone(this,dispName,dispType);

            signalName=getSignalName(this);
            addImagesToSession(this.Session,signalName,imageData);

            if this.IsDataBlockedImage
                newImageIdx=numImagesBeforeAdd+1;
                resizeFirstBlockedImageAndOpenProgressDialog(this,imageData(1),newImageIdx);
            end

            numImagesAfterAdd=getNumImages(this.Session);


            if numImagesAfterAdd>numImagesBeforeAdd

                if iscellstr(imageData)
                    imageFiles.Filenames=imageData;
                    appendImage(this,imageFiles);
                else
                    appendImage(this,imageData);
                end
                imgIdx=numImagesBeforeAdd+1;
                selectImageByIndex(this,imgIdx);
            end

            updateROIModeAndAttribs(this);
            this.updateFigureCloseListener();

            this.updateToolstrip();
            updateVisualSummary(this);

            if this.IsDataBlockedImage
                closeProgressDialog(this)
                removeRotation(this.BrowserPanelObj);
            end

            this.setStatusText('');
        end

        function doLoadDatastore(this,ds)

            if isReadFcnDefault(this,ds)
                doLoadImages(this,ds.Files);
            else
                doLoadImages(this,ds);


                disableRotation(this.BrowserPanelObj);
            end

        end

        function doLoadBlockedImagesFromWksp(this,blockedImageData)

            if isempty(blockedImageData)
                return
            end

            this.IsDataBlockedImage=true;

            doLoadImages(this,blockedImageData);

        end



    end




    methods

        function doLoadLabels(this,gTruth,currentDefinitions)

            if isImageDatastore(gTruth.DataSource)
                images=gTruth.DataSource.Source.Files;
            else
                images=gTruth.DataSource.Source;
            end

            isPixelLabelType=gTruth.LabelDefinitions.Type==labelType.PixelLabel;
            hasPixelLabels=any(isPixelLabelType);
            currentSessionHasPixelLabels=this.Session.hasPixelLabels;

            currentImages=this.Session.ImageFilenames;
            labelData=gTruth.LabelData;



            [overlap,currentIndices,imageIdx]=intersect(currentImages,images,'stable');


            currentPixDef=currentDefinitions(...
            currentDefinitions.Type==labelType.PixelLabel,:);
            pixDefinitions=gTruth.LabelDefinitions(isPixelLabelType,:);




            if hasPixelLabels&&currentSessionHasPixelLabels

                if~isempty(overlap)

                    replace=vision.getMessage('vision:labeler:ImportReplaceButtonPixelLabel');
                    keep=vision.getMessage('vision:labeler:ImportKeepButtonPixelLabel');
                    cancel=vision.getMessage('MATLAB:uistring:popupdialogs:Cancel');
                    dlgMessage=vision.getMessage('vision:labeler:ImportReplaceOrKeepPixelLabel');
                    dlgTitle=vision.getMessage('vision:labeler:ImportReplaceOrKeepPixelLabelTitle');
                    hFig=this.Container.getDefaultFig;
                    selection=vision.internal.labeler.handleAlert(hFig,'question',dlgMessage,dlgTitle,...
                    replace,keep,cancel,replace);

                    if isempty(selection)
                        selection=cancel;
                    end

                    switch selection
                    case replace





                        if~any(strcmp(pixDefinitions.Properties.VariableNames,'LabelColor'))
                            pixDefinitions.LabelColor=cell(height(pixDefinitions),1);

                        end

                        if~iscell(pixDefinitions.LabelColor)
                            pixDefinitions.LabelColor=num2cell(pixDefinitions.LabelColor,2);
                        end
                        idx=find(~ismember(reshape([currentPixDef.LabelColor{:}]',3,[])',...
                        reshape([pixDefinitions.LabelColor{:}]',3,[])','rows'));


                        for i=1:numel(idx)


                            if~isempty(pixDefinitions.LabelColor{idx(i)})
                                modifyLabelColor(this,currentPixDef.Name{idx(i)},pixDefinitions.LabelColor{idx(i)})
                            end
                        end


                        this.updatePixelColorLookup();
                    case keep


                        labelData{imageIdx,'PixelLabelData'}={''};

                    case cancel

                        return;
                    end
                end

            end





            isRectOrScene=(gTruth.LabelDefinitions.Type==labelType.Rectangle)...
            |(gTruth.LabelDefinitions.Type==labelType.Line)...
            |(gTruth.LabelDefinitions.Type==labelType.ProjectedCuboid)...
            |(gTruth.LabelDefinitions.Type==labelType.Scene);

            currentRectDef=currentDefinitions(...
            currentDefinitions.Type==labelType.Rectangle...
            |currentDefinitions.Type==labelType.Line...
            |currentDefinitions.Type==labelType.ProjectedCuboid...
            |currentDefinitions.Type==labelType.Scene,:);

            rectOrSceneDefinitions=gTruth.LabelDefinitions(isRectOrScene,:);
            [~,idx]=setdiff(rectOrSceneDefinitions.Name,currentRectDef.Name);
            newDefinitions=rectOrSceneDefinitions(idx,:);

            if~isempty(newDefinitions)

                addLabelsDefinitions(this.Session,newDefinitions);
            end


            [newImages,newIdx]=setdiff(images,currentImages,'stable');

            newIndices=[];
            newData=[];
            if~isempty(newImages)



                newIndices=getNumImages(this.Session)+(1:numel(newImages));
                signalName=getSignalName(this);
                addImagesToSession(this.Session,signalName,newImages);
                newData=labelData(newIdx,:);

            end

            labelDataForExistingImages=[];
            if~isempty(currentIndices)

                labelDataForExistingImages=labelData(imageIdx,:);

            end


            if~isempty(newIndices)
                labelData=[labelDataForExistingImages;newData];
                indices=[currentIndices;newIndices];
            else
                labelData=labelDataForExistingImages;
                indices=currentIndices;
            end

            signalName=getSignalName(this);
            addLabelData(this.Session,signalName,gTruth.LabelDefinitions,...
            labelData,indices,gTruth.getPolygonOrder);


            [~,idx]=setdiff(pixDefinitions.Name,currentPixDef.Name);
            newPixelDefinitions=pixDefinitions(idx,:);

            if~isempty(newPixelDefinitions)

                addLabelsDefinitions(this.Session,newPixelDefinitions);
                if hasPixelLabels

                    this.updatePixelColorLookup();
                end
            end

            drawImage(this,this.getCurrentIndex(),true);
        end

        function importLabelAnnotations(this,source)

            wait(this.Container);

            this.setStatusText(vision.getMessage('vision:labeler:ImportLabelAnnotationsStatus'));

            setWaitingToFalseAtExit=onCleanup(@()resume(this.Container));

            if isa(source,'groundTruth')

                gTruth=source;
            else

                [success,gTruth]=importLabelAnnotationsPreWork(this,source);
                if~success||isempty(gTruth)
                    return;
                end
            end


            notValid=~isscalar(gTruth)||~hasValidDataSource(gTruth)||...
            ~(isImageCollection(gTruth.DataSource)||isImageDatastore(gTruth.DataSource));

            hFig=this.Container.getDefaultFig;
            if notValid
                errorMessage=vision.getMessage('vision:imageLabeler:ImportLabelsInvalidGroundTruthSrc');
                dialogName=vision.getMessage('vision:labeler:ImportError');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                return;
            end



            polyOrder=getPolygonOrder(gTruth);
            [gTruth,~]=vision.internal.labeler.splitCustomGroundTruth(gTruth);
            setPolygonOrder(gTruth,polyOrder);






            currentDefinitions=exportLabelDefinitions(this.Session);

            canImportLabels=importPixelLabelHelper(this,gTruth,currentDefinitions);

            if~canImportLabels
                return
            end

            assert(canImportLabels,'Internal Error');



            isVisualSummaryOpen=~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay);
            if isVisualSummaryOpen
                isVisualSummaryDocked=isDocked(this.VisualSummaryDisplay);
            else
                isVisualSummaryDocked=false;
            end

            reopenVisualSummary=getReopenVisualSummaryFlag(this);

            numImagesBeforeAdd=getNumImages(this.Session);










            switch(this.DataMode)

            case "empty"

                ds=gTruth.DataSource.Source;

                checkForBlockedImageFlag=true;
                if this.gTruthHasPixelLabels(gTruth)
                    checkForBlockedImageFlag=false;
                end

                if checkForBlockedImageFlag
                    if isImageDatastore(gTruth.DataSource)
                        if isReadFcnDefault(this,ds)
                            images=ds.Files;
                            isCanceled=checkForBlockedImage(this,images);
                            if isCanceled
                                return
                            end
                        end
                    else
                        images=gTruth.DataSource.Source;
                        isCanceled=checkForBlockedImage(this,images);
                        if isCanceled
                            return
                        end
                    end
                end

                this.Session.loadLabelAnnotations(gTruth);

            case "image"


                if isImageDatastore(gTruth.DataSource)
                    if isReadFcnDefault(this,gTruth.DataSource.Source)


                    else
                        msg=vision.getMessage('vision:imageLabeler:AddImageDatastoreError');
                        dialogName=vision.getMessage('vision:imageLabeler:AddImageTitle');
                        vision.internal.labeler.handleAlert(hFig,'messageDialog',msg,dialogName,...
                        this.Tool);
                        return;
                    end

                else
                    images=gTruth.DataSource.Source;
                    [isCandidateForBlockedImage,fileReadErrored]=this.checkIfCandidateForBlockedImage(images);
                    if fileReadErrored
                        return
                    end

                    if isCandidateForBlockedImage
                        toolCenter=this.Container.getLocation();
                        dlg=this.DialogManager.MergeLargeDataDlg(toolCenter);
                        if~isempty(dlg)&&dlg.Canceled
                            return;
                        end
                    end
                end

                doLoadLabels(this,gTruth,currentDefinitions)

            case "blockedimage"


                if this.gTruthHasPixelLabels(gTruth)
                    errorMessage=vision.getMessage('vision:imageLabeler:LoadPixelLabelsBlockedImageError');
                    dialogName=vision.getMessage('vision:labeler:UnableToLoadAnnotationsDlgName');
                    vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                    this.Tool);
                    return
                end

                if isImageDatastore(gTruth.DataSource)
                    if isReadFcnDefault(this,gTruth.DataSource.Source)


                    else
                        msg=vision.getMessage('vision:imageLabeler:AddImageDatastoreError');
                        dialogName=vision.getMessage('vision:imageLabeler:AddImageTitle');
                        vision.internal.labeler.handleAlert(hFig,'messageDialog',msg,dialogName,...
                        this.Tool);
                        return;
                    end

                else


                end

                doLoadLabels(this,gTruth,currentDefinitions)

            case "datastore"

                if isImageDatastore(gTruth.DataSource)
                    ds=gTruth.DataSource.Source;
                    if strcmp(func2str(this.Session.Datastore.ReadFcn),func2str(ds.ReadFcn))

                    else
                        strReadFcn=func2str(this.Session.Datastore.ReadFcn);
                        msg=vision.getMessage('vision:imageLabeler:AddImageDatastoreExistsError',strReadFcn);
                        dialogName=vision.getMessage('vision:imageLabeler:AddImageTitle');
                        vision.internal.labeler.handleAlert(hFig,'messageDialog',msg,dialogName,...
                        this.Tool);
                        return;
                    end
                else
                    strReadFcn=func2str(this.Session.Datastore.ReadFcn);
                    msg=vision.getMessage('vision:imageLabeler:AddImageDatastoreExistsError',strReadFcn);
                    dialogName=vision.getMessage('vision:imageLabeler:AddImageTitle');
                    vision.internal.labeler.handleAlert(hFig,'messageDialog',msg,dialogName,...
                    this.Tool);
                    return;
                end

                doLoadLabels(this,gTruth,currentDefinitions)

            end

            this.ShowDrawProgressBar=false;

            numImagesAfterAdd=getNumImages(this.Session);
            if numImagesBeforeAdd==numImagesAfterAdd




                reconfigureUI(this);
            else
                newImageIdx=numImagesBeforeAdd+1;
                reconfigureUI(this,newImageIdx);
            end

            this.ShowDrawProgressBar=true;

            doReopenVisualSummary(this,reopenVisualSummary,isVisualSummaryDocked);

            this.setStatusText('');

        end

        function reconfigureUI(this,newImageIdx)

            if hasImages(this.Session)

                isNewBlockedImageLoaded=this.IsDataBlockedImage&&nargin>1;

                prevSelectedIdx=getSelectedImageIdx(this.Session);
                this.reconfigureToolstripTabs();

                if hasDatastore(this.Session)
                    imageData=this.Session.Datastore;
                else
                    imageData=this.Session.ImageFilenames;
                end

                dispName=getFirstdisplayTitle(this,imageData);

                if this.IsDataBlockedImage
                    dispType=displayType.BlockedImageMixedSize;


                    if isempty(this.Session.TempDirectory)
                        this.setTempDirectory();
                    end
                else
                    dispType=displayType.ImageMixedSize;
                end

                addDisplayIfNone(this,dispName,dispType);

                if isNewBlockedImageLoaded

                    filename=this.Session.ImageFilenames{newImageIdx};
                    this.resizeFirstBlockedImageAndOpenProgressDialog(filename,newImageIdx);
                end

                try
                    if useAppContainer()
                        appendImage(this.BrowserPanelObj,imageData);
                    else
                        loadImages(this.BrowserPanelObj,imageData);
                    end

                    if hasDatastore(this.Session)
                        disableRotation(this.BrowserPanelObj);
                    elseif this.IsDataBlockedImage

                        removeRotation(this.BrowserPanelObj);
                    end
                catch ME

                    if~this.IsAppClosing
                        rethrow(ME)
                    end
                end

                selectImageByIndex(this,prevSelectedIdx)
            end

            reconfigureLabelPanelsAndToolstrip(this);

        end

        function reconfigureLabelPanelsAndToolstrip(this)
            try

                reconfigureROILabelSetDisplay(this);

                reconfigureFrameLabelSetDisplay(this);

                this.updateToolstrip();
            catch ME

                if~this.IsAppClosing
                    rethrow(ME)
                end
            end
        end


        function TF=isReadFcnDefault(~,ds)
            TF=vision.internal.isDefaultImdsReadFcn(ds);
        end

        function resizeFirstBlockedImageAndOpenProgressDialog(this,imageData,newImageIdx)






            if isa(imageData,'blockedImage')
                bim=imageData;
            else
                bim=blockedImage(imageData);
            end

            if useAppContainer()
                resume(this.Container);
            end
            this.openProgressDialog();

            [~,name,ext]=fileparts(char(bim.Source));
            this.doUpdateProgressDlg([name,ext],bim.Size(1,[1,2]));

            resizedBim=vision.internal.imageLabeler.tool.blockedImage.resize(bim,this.OverviewDisplay.OverviewImageSize);
            this.doWriteOverviewImage(resizedBim,newImageIdx)




        end

    end




    methods

        function doLoadSession(this,pathName,fileName,varargin)


            wait(this.Container);
            resetWait=onCleanup(@()resume(this.Container));

            hFig=this.Container.getDefaultFig;


            loadedSession=this.SessionManager.loadSession(pathName,fileName,hFig);

            if isempty(loadedSession)
                resume(this.Container);
                return;
            end



            isVisualSummaryOpen=~isempty(this.VisualSummaryDisplay)&&isvalid(this.VisualSummaryDisplay);

            if isVisualSummaryOpen
                isVisualSummaryDocked=isDocked(this.VisualSummaryDisplay);
            else
                isVisualSummaryDocked=false;
            end

            reopenVisualSummary=getReopenVisualSummaryFlag(this);








            this.cleanSession();

            this.Session=loadedSession;


            this.LabelVisibleInternal=loadedSession.ShowROILabelMode;
            this.LabelTab.changeLabelDisplayOption(loadedSession.ShowROILabelMode);

            this.IsDataBlockedImage=this.Session.IsDataBlockedImage;

            updateSignalModel(this.Session,[]);



            if hasPixelLabels(this.Session)||this.IsDataBlockedImage
                this.setTempDirectory();
            end





            if this.IsDataBlockedImage
                dispType=displayType.BlockedImageMixedSize;
            else
                dispType=displayType.ImageMixedSize;
            end
            this.OverviewDisplay.initialize(dispType);
            this.OverviewDisplay.loadCurrentViewPosFromSession(this.Session.getCurrentViewPosition());


            TF=importPixelLabelData(this.Session);



            if~TF
                oldDirectory=this.Session.TempDirectory;
                [~,name]=fileparts(tempname);
                foldername=vision.internal.labeler.tool.selectDirectoryDialog(name);
                setTempDirectory(this.Session,foldername);
                importPixelLabelData(this.Session);
                if isfolder(oldDirectory)
                    rmdir(oldDirectory,'s');
                end
            end

            this.ShowDrawProgressBar=false;

            newImageIdx=1;
            reconfigureUI(this,newImageIdx);
            this.ShowDrawProgressBar=true;


            if hasPixelLabels(this.Session)
                resetDrawingTools(this.SemanticTab);

                this.updatePixelColorLookup();

                this.DisplayManager.updatePixelLabelColorInCurrentFrame()
            end




            [~,fileName]=fileparts(fileName);
            titleStr=getString(message(...
            'vision:labeler:ToolTitleWithSession',this.ToolName,fileName));
            setTitleBar(this.Container,titleStr);

            doReopenVisualSummary(this,reopenVisualSummary,isVisualSummaryDocked);
        end

    end




    methods

        function setupSucceeded=setupAlgorithm(this)

            wait(this.Container);

            cleanupObj=onCleanup(@()cleanPostSetupAlg(this));

            try

                algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;


                selections=getSelectedLabelDefinitions(this);
                setSelectedLabelDefinitions(algorithm,selections);


                setupSucceeded=verifyAlgorithmSetup(algorithm);
            catch ME


                dlgTitle=vision.getMessage('vision:labeler:CantVerifyAlgorithmTitle');
                showExceptionDialog(this,ME,dlgTitle);

                setupSucceeded=false;
                return;
            end



            if~setupSucceeded

                hFig=this.Container.getDefaultFig;
                errorMessage=vision.getMessage('vision:labeler:IncompleteAlgorithmSetupMessage');
                dialogName=vision.getMessage('vision:labeler:IncompleteAlgorithmSetupTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                return;
            end
        end


        function runAlgorithm(this)




            finalize(this);

            closeExceptionDialogs(this);

            algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;



            deselectROIInstances(this);
            freezePanelsWhileRunningAlgorithm(this);



            onDone=onCleanup(@this.cleanupPostAlgorithmRun);

            this.StopAlgRun=false;

            imDisplay=getImageDisplay(this);

            freezeSignalNavInteractions(this);


            freezeDrawingTools(imDisplay);


            imageIndices=getVisibleImageIndices(this);


            firstImageIndex=imageIndices(1);
            selectImageByIndex(this,firstImageIndex);


            success=initializeAlgorithm(this,firstImageIndex);

            if~success
                return;
            end




            if~useAppContainer()


                this.BrowserPanelObj.setTimerToZero;
                teardown=onCleanup(@()this.BrowserPanelObj.resetTimer());
            end


            enableSliderCallback(this,false);

            for idx=imageIndices

                if this.StopAlgRun

                    break;
                end

                selectImageByIndex(this,idx);


                data=this.Session.readData(idx);
                I=data.Image;
                if this.IsDataBlockedImage
                    imSize=[I.Size(1,1),I.Size(1,2)];
                    level=getLevel(algorithm);
                    worldStart=I.WorldStart(1,1:2);
                    worldEnd=I.WorldEnd(1,1:2);
                    maskSize=[I.Size(level,1),I.Size(level,2)];
                else
                    imSize=[size(I,1),size(I,2)];
                    worldStart=[0.5,0.5];
                    worldEnd=worldStart+imSize;
                    maskSize=imSize;
                end

                if this.isBlockedImageAutomation()
                    updateWorldLimits(algorithm,worldStart,worldEnd);
                    updateMaskSize(algorithm,maskSize);
                    this.AlgorithmTab.setBlockedAutomationRegionForRun(I);
                end


                try
                    [labels,isValid]=doRun(algorithm,I);
                    labels=checkUserLabels(this,labels,isValid,imSize);
                    labels=restructPositionAndAddUID(this,labels);
                catch ME
                    dlgTitle=vision.getMessage('vision:labeler:CantRunAlgorithmTitle');
                    showExceptionDialog(this,ME,dlgTitle);
                    updateVisualSummary(this);
                    enableSliderCallback(this,true);
                    return;
                end


                signalName='';
                tNow=idx;
                this.Session.addAlgorithmLabels(signalName,tNow,idx,labels);


                reset(this);
                drawImage(this,idx,true);
                drawnow('limitrate')
            end

            updateVisualSummary(this);

            enableSliderCallback(this,true);




            try
                terminate(algorithm);
            catch ME
                dlgTitle=vision.getMessage('vision:labeler:CantTerminateAlgorithmTitle');
                showExceptionDialog(this,ME,dlgTitle);
                return;
            end

        end


        function userCanceled=undorunAlgorithm(this)

            userCanceled=showUndoRunDialog(this);

            if~userCanceled

                closeExceptionDialogs(this);
                finalize(this);

                wait(this.Container);

                imageIndices=getVisibleImageIndices(this);
                signalName=getSignalName(this);
                replaceAnnotationsForUndo(this.Session,signalName,imageIndices);

                if hasPixelLabels(this.Session)
                    replacePixelLabels(this.Session,imageIndices);
                end

                if this.isBlockedImageAutomation()

                    this.AlgorithmTab.resetAutomationRegionMode();
                end

                reset(this);


                selectImageByIndex(this,imageIndices(1));
                if~useAppContainer()
                    selectedImageIndex=this.BrowserPanelObj.SelectedItemIndex;
                else
                    selectedImageIndex=this.BrowserPanelObj.selectedItem;
                end



                if(length(imageIndices)==1||selectedImageIndex==1)
                    drawImage(this,imageIndices(1),false);
                end

                updateVisualSummary(this);

                resume(this.Container);
            end
        end


        function acceptAlgorithm(this)

            closeExceptionDialogs(this);
            finalize(this);


            imageIndices=getVisibleImageIndices(this);

            signalName=getSignalName(this);
            mergeAnnotations(this.Session,signalName,imageIndices);

            if isPixelLabelingAlgorithm(this.AlgorithmSetupHelper)
                mergePixelLabels(this.Session,imageIndices);
            end

            removeInstructionsPanel(this);


            removeCustomAutomationPolygons(this);


            removeMetadataPanel(this);

            endAutomation(this);

            updateVisualSummary(this);
            updateAttributesSublabelsPanelIfNeeded(this);
        end


        function cancelAlgorithm(this)


            wait(this.Container);


            removeCustomAutomationPolygons(this);


            cancelAlgorithm@vision.internal.labeler.tool.LabelerTool(this,getSignalName(this));


            removeMetadataPanel(this);


            resume(this.Container);
        end

        function removeCustomAutomationPolygons(this)
            if this.isBlockedImageAutomation()
                imDisplay=getImageDisplay(this);
                imDisplay.deleteAllAutomationPolygonROIs();
            end
        end

        function removeMetadataPanel(this)
            if this.IsDataBlockedImage
                makeMetadataInvisible(this.Container);
                makeFigureInvisible(this.MetadataDisplay);
                createXMLandGenerateLayout(this,1,1);


                imDisplay=getImageDisplay(this);
                imDisplay.setGridButtonVisibility(true);
            end
        end

    end

    methods




        function startAutomation(this)



            this.AlgorithmInstanceFlag=true;


            startAutomation@vision.internal.labeler.tool.LabelerTool(this);

            updateAttributesSublabelsPanel(this);

            if this.AlgorithmInstanceFlag
                if this.isBlockedImageAutomation()



                    imDisplay=getImageDisplay(this);
                    imDisplay.initializePolygonToolAutomationRegion();
                    imDisplay.configureAutomationPolygonDeleteCallback(@this.deleteAutomationPolygonROI);
                    this.addBlockedAutomationListeners();


                    if this.ShowBlockedAutomationTutorial
                        createBlockedAutomationTutorialDialog(this);
                    end
                end



















            end


        end


        function success=tryToSetupAlgorithm(this)










            closeExceptionDialogs(this);


            wait(this.Container);

            oCU=onCleanup(@()resume(this.Container));

            success=false;
            hFig=this.Container.getDefaultFig;


            if~this.LabelTab.isAlgorithmSelected
                errorMessage=vision.getMessage('vision:labeler:SelectAlgorithmFirst');
                dialogName=vision.getMessage('vision:labeler:SelectAlgorithmFirstTitle');
                vision.internal.labeler.handleAlert(hFig,'errorWithWaitDlg',errorMessage,dialogName,...
                this.Tool);
                return;
            end

            try


                if~isAlgorithmOnPath(this.AlgorithmSetupHelper)
                    return;
                end


                if~isAlgorithmValid(this.AlgorithmSetupHelper)
                    return;
                end



                if~algorithmInstanceFromSession(this.AlgorithmSetupHelper,this.Session)
                    this.AlgorithmInstanceFlag=false;
                    return;
                end

            catch ME

                dlgTitle=vision.getMessage('vision:labeler:CantSetupAlgorithmTitle');
                showExceptionDialog(this,ME,dlgTitle);

                return;
            end




            if~this.IsDataBlockedImage
                if this.isBlockedImageAutomation()

                    this.AlgorithmTabImage.hide();
                    this.AlgorithmTab=this.AlgorithmTabBlockedImage;
                else

                    this.AlgorithmTabBlockedImage.hide();
                    this.AlgorithmTab=this.AlgorithmTabImage;
                end
            end

            if this.isBlockedImageAutomation()

                this.AlgorithmTab.resetAutomationRegionMode();



                val='1024';
                this.AlgorithmTab.resetBlockSizeRowColumnValue(val);



                numImages=getNumImagesAutomation(this);
                if numImages>1
                    this.AlgorithmTab.disableAutomationRegionCustom();
                end




                if numImages==1
                    this.AlgorithmTab.disableStopButton();
                end


                if~matlab.internal.parallel.isPCTInstalled()
                    this.AlgorithmTab.disableUseParallelButton();
                end
            end


            if this.IsDataBlockedImage

                numLevels=getNumResLevels(this.Session);
                this.AlgorithmTab.populateBlockedParameterResLevelList(numLevels);


                imDisplay=getImageDisplay(this);
                imDisplay.setGridButtonVisibility(false);




                makeMetadataVisible(this.Container);
                createXMLandGenerateLayout(this,1,1);
                resLevelSizes=getLevelSizes(this.Session);
                this.MetadataDisplay.updateMetadataProperties(resLevelSizes);
            end


            finalize(this);
            signalName=getSignalName(this);
            gTruth=exportLabelAnnotations(this.Session,signalName);
            setAlgorithmLabelData(this.AlgorithmSetupHelper,gTruth);



            [roiLabelDefs,frameLabelDefs]=getLabelDefinitions(this.Session);
            if~checkValidLabels(this.AlgorithmSetupHelper,roiLabelDefs,frameLabelDefs,vision.labeler.loading.SignalType.Image,hFig)
                return;
            end


            if hasPixelLabels(this.Session)
                newdir=fullfile(this.Session.TempDirectory,'Automation');
                status=mkdir(newdir);
                if status
                    setTempDirectory(this.Session,newdir)
                else
                    return;
                end
            end



            success=true;


            reset(this);


            filterSelectedImages(this);

            disableSublabelDefItems(this);



            freezeLabelPanelsWhenStartingAutomation(this);


            signalName=getSignalName(this);
            cacheAnnotations(this.Session,signalName);


            readjustDrawingModeInAutomation(this);



            imageIndices=getVisibleImageIndices(this);
            validFrameLabels=this.AlgorithmSetupHelper.ValidFrameLabelNames;
            replaceROIAnnotations(this.Session,signalName,imageIndices);
            replaceFrameAnnotationsAllSignals(this.Session,signalName,imageIndices,validFrameLabels);


            selectImageByIndex(this,imageIndices(1));


            [~,~,labelIDs]=this.Session.queryFrameLabelAnnotationByReaderId(1,imageIndices(1));
            updateFrameLabelStatus(this.FrameLabelSetDisplay,labelIDs);
...
...
...
        end

        function addBlockedAutomationListeners(this)
            imDisplay=getImageDisplay(this);
            addlistener(imDisplay,'AutomationPolygonROIsChanged',...
            @(~,evt)this.doAutomationPolygonROIsChanged(evt));
            addlistener(imDisplay,'AutomationPolygonROIsDeleted',...
            @(~,evt)this.doAutomationPolygonROIsChanged(evt));
        end

        function previousSelectionIndex=freezeActiveLabelDefinitionItems(this)




            [~,labelIndices]=getLabelNames(this.ROILabelSetDisplay);
            previousSelectionIndex=this.ROILabelSetDisplay.CurrentSelection;
            this.ROILabelSetDisplay.unselectToBeDisabledItems(labelIndices);
            for idx=labelIndices
                this.ROILabelSetDisplay.disableItem(idx);
            end
        end

        function unfreezeActiveLabelDefinitionItems(this,previousLabelSelectionIndex)



            invalidROILabelIdx=this.AlgorithmSetupHelper.InvalidROILabelIndices;

            [~,labelIndices]=getLabelNames(this.ROILabelSetDisplay);
            invalidROILabelIdx=labelIndices(invalidROILabelIdx);
            validROILabelIdx=setdiff(labelIndices,invalidROILabelIdx);
            for idx=validROILabelIdx
                this.ROILabelSetDisplay.enableItem(idx);
            end

            this.ROILabelSetDisplay.selectItem(previousLabelSelectionIndex);
        end

        function doAutomationPolygonROIsChanged(this,evt)




            numPolygons=length(evt.Source.PolygonToolAutomationRegion.CurrentROIs);


            currentAutomationRegionMode=this.AlgorithmTab.getCurrentAutomationRegionMode();
            if strcmp(currentAutomationRegionMode,'CustomRegion')
                if numPolygons>0
                    this.AlgorithmTab.setRunButtonMode(true);
                else
                    this.AlgorithmTab.setRunButtonMode(false);
                end
            end


            this.AlgorithmTab.updateNumCustomPolygons(numPolygons);


            roiPos=cell(numPolygons,1);
            if~isempty(roiPos)
                for id=1:numPolygons
                    roiPos{id}=evt.Source.PolygonToolAutomationRegion.CurrentROIs{id}.Position;
                end
            end
            this.AlgorithmTab.updatePolygonPositions(roiPos);
            this.freezeActiveLabelDefinitionItems();

        end

        function tf=isBlockedImageAutomation(this)
            alg=this.AlgorithmSetupHelper.AlgorithmInstance;
            metaClass=metaclass(alg);
            metaSuperclass=metaClass.SuperclassList;
            superclasses={metaSuperclass.Name};
            expectedClass='vision.labeler.mixin.BlockedImageAutomation';
            tf=ismember(expectedClass,superclasses);
        end


        function num=getNumImagesAutomation(this)
            if useAppContainer()
                num=length(this.BrowserPanelObj.BrowserObj.Selected);
            else
                num=length(this.BrowserPanelObj.VisibleItemIndex);
            end
        end



        function deleteAutomationPolygonROI(this,varargin)


            selectedDisplay=getSelectedDisplay(this);

            selectedDisplay.deleteAutomationPolygonSelectedROIs();
            this.Session.IsChanged=true;
        end



        function cleanupPostAlgorithmRun(this)


            this.StopAlgRun=true;

            imDisplay=getImageDisplay(this);

            unfreezeSignalNavInteractions(imDisplay);


            unfreezeDrawingTools(imDisplay);
            unfreezePanelsAfterRunningAlgorithm(this);
        end


        function userCanceled=showUndoRunDialog(this)


            s=settings;
            showUndoRun=s.vision.imageLabeler.ShowUndoRunDialog.ActiveValue;

            if~showUndoRun
                userCanceled=false;
                return;
            end

            userCanceled=vision.internal.labeler.tool.undoRunDialog(this.Tool,this.InstanceName);
        end


        function success=initializeAlgorithm(this,imageIndex)

            success=true;

            wait(this.Container);

            data=this.Session.readData(imageIndex);
            I=data.Image;

            algorithm=this.AlgorithmSetupHelper.AlgorithmInstance;

            try
                doInitialize(algorithm,I);
            catch ME
                success=false;

                dlgTitle=vision.getMessage('vision:labeler:CantInitializeAlgorithmTitle');
                showExceptionDialog(this,ME,dlgTitle);
                return;
            end

            resume(this.Container);
        end


        function endAutomation(this)



            endAutomation@vision.internal.labeler.tool.LabelerTool(this);

            updateAttributesSublabelsPanel(this);



            reset(this);
            restoreAllImages(this);
            drawImage(this,this.getCurrentIndex(),false);

            setSemanticTabForAutomation(this);
        end


    end




    methods

        function toggleOverviewAndSetLayout(this,TF)

            this.toggleOverviewDisplay(TF);
            createXMLandGenerateLayout(this,1,1);

        end

        function toggleOverviewDisplay(this,TF)





            this.ShowOverviewTab=TF;

            if TF



                makeOverviewVisible(this.Container);

                idx=this.getCurrentIndex;
                if~isempty(idx)
                    data=this.Session.readData(idx);
                    this.OverviewDisplay.draw(data,idx);
                end

            else
                makeOverviewInvisible(this.Container);
            end

            this.OverviewDisplay.Enabled=TF;

        end

    end




    methods

        function addOverviewListeners(this)
            addlistener(this.OverviewDisplay,'CurrentViewChanged',...
            @(~,evtData)this.changeDisplayLimits(evtData.CurrentPosition,evtData.Index));

            addlistener(this.OverviewDisplay,'OverviewBlockedImWrittenToDisk',...
            @(~,evtData)this.Session.mergeGeneratedOverviewLevel(evtData.BlockedImage,evtData.ImageNum));
        end

        function doWriteOverviewImage(this,bim,imageNum)
            this.OverviewDisplay.writeOverviewBlockedImage(bim,imageNum);
        end

        function changeDisplayLimits(this,currentViewPostion,roiIndex)

            xLim=[currentViewPostion(1),currentViewPostion(1)+currentViewPostion(3)]+[-0.5,0.5];
            yLim=[currentViewPostion(2),currentViewPostion(2)+currentViewPostion(4)]+[-0.5,0.5];

            imDisplay=this.getImageDisplay();
            imDisplay.setAxesLimits(xLim,yLim);

            this.Session.setCurrentViewPosition(currentViewPostion,roiIndex)

        end

        function displayLimitsChanged(this,xLim,yLim)


            idx=this.getCurrentIndex();
            xLim=xLim+[0.5,-0.5];
            yLim=yLim+[0.5,-0.5];
            pos=[xLim(1),yLim(1),xLim(2)-xLim(1),yLim(2)-yLim(1)];
            this.OverviewDisplay.setROIPosition(idx,pos);
        end

        function openProgressDialog(this)
            if~this.IsDataBlockedImage
                return
            end

            this.HasOverviewGenerated=false;

            this.freezePanelsWhileGeneratingThumbnails();

            if~useAppContainer()
                toolCenter=this.Container.getLocation();
                this.DialogManager.openGeneratingOverviewAndThumbnailsDlg(toolCenter);
            else
                imDisplay=this.getImageDisplay();
                this.DialogManager.openGeneratingOverviewAndThumbnailsDlgUIFig(imDisplay.Fig);
            end
        end

        function closeProgressDialog(this)
            if~this.IsDataBlockedImage
                return
            end

            this.unfreezePanelsAfterGeneratingThumbnails();

            if~useAppContainer()
                this.DialogManager.hideGeneratingOverviewAndThumbnailsDlg();
            else
                this.DialogManager.hideGeneratingOverviewAndThumbnailsDlgUIFig();
            end

            this.HasOverviewGenerated=true;
        end

        function doUpdateProgressDlg(this,imageName,imageSize)
            if~this.IsDataBlockedImage
                return
            end

            msg{1}=['Image: ',char(imageName)];
            msg{2}=['Image Size: ',num2str(imageSize)];
            this.DialogManager.updateProgressDlgMsg(msg);
        end

        function freezePanelsWhileGeneratingThumbnails(this)




            visible=false;
            changeToolbarVisibility(this,visible);


            freeze(this.ROILabelSetDisplay);
            disableAllItems(this.ROILabelSetDisplay);


            freeze(this.FrameLabelSetDisplay);
            disableAllItems(this.FrameLabelSetDisplay);
            freezeOptionPanel(this.FrameLabelSetDisplay);


            disableAllControls(this.LabelTab);
            hide(this.SemanticTab);


            this.OverviewDisplay.Enabled=false;

        end

        function unfreezePanelsAfterGeneratingThumbnails(this)


            visible=true;
            changeToolbarVisibility(this,visible);


            if this.Session.HasROILabels
                enableAllItems(this.ROILabelSetDisplay);
            end

            unfreeze(this.ROILabelSetDisplay);

            selectedItemInfo=getSelectedItemInfo(this);
            if selectedItemInfo.isAnyItemSelected
                if selectedItemInfo.isPixelLabelItemSelected
                    this.ROILabelSetDisplay.disableSublabelDefCreateButton();
                    this.ROILabelSetDisplay.disableAttributeDefCreateButton();
                    show(this.SemanticTab);

                elseif~selectedItemInfo.isLabelSelected
                    this.ROILabelSetDisplay.disableSublabelDefCreateButton();
                end
            else
                this.ROILabelSetDisplay.disableSublabelDefCreateButton();
                this.ROILabelSetDisplay.disableAttributeDefCreateButton();
            end


            unfreeze(this.FrameLabelSetDisplay);
            if this.Session.HasFrameLabels&&this.FrameLabelSetDisplay.isValidItemSelected()
                this.FrameLabelSetDisplay.unfreezeOptionPanel();
            end
            enableAllItems(this.FrameLabelSetDisplay);


            anyROIOrFrameLabels=this.Session.HasROILabels||this.Session.HasFrameLabels;
            enableControls(this.LabelTab);
            this.LabelTab.enableAlgorithmSection(anyROIOrFrameLabels);
            this.LabelTab.enableExportSection(anyROIOrFrameLabels);
            this.LabelTab.enablePolygonOpacitySlider(this.Session.hasShapeLabels);
            this.LabelTab.enablePixelOpacitySlider(this.Session.hasPixelLabels);


            onlyOneImage=(getNumImages(this.Session)==1);
            updateVisualSummaryButton(this,~onlyOneImage);


            this.OverviewDisplay.Enabled=true;

        end

    end





    methods



        function updateOnSliderMove(this,~,data)

            sliderValue=data.Data;
            diff=abs(sliderValue-round(sliderValue));

            if diff<0.03
                this.SliderUpdate=true;
            else
                this.SliderUpdate=false;
                selectImageByIndex(this,round(sliderValue));
                updateSliderLine(this.VisualSummaryDisplay,round(sliderValue));
            end
        end

        function updateOnSliderRelease(~,~,~)
        end


        function updateFrameAndSlider(this,~,jumpIndex)
            selectImageByIndex(this,jumpIndex);
            updateSliderLine(this.VisualSummaryDisplay,jumpIndex);
        end
    end




    methods
        function frameIdx=getLastReadFrameIdx(this,~)
            frameIdx=getCurrentIndex(this);
        end

        function tf=isSignalRangeValid(~,~)
            tf=true;
        end

        function tf=gTruthHasPixelLabels(~,gTruth)
            tf=any(gTruth.LabelDefinitions.Type==labelType.PixelLabel);
        end

    end

    methods(Hidden)


        function currentVal=getCurrentValueForSlider(this)

            currentVal=getCurrentIndex(this);
        end


        function startIndex=getStartIndex(this,varargin)


            if~useAppContainer
                startIndex=this.BrowserPanelObj.VisibleItemIndex(1);
            else
                startIndex=this.BrowserPanelObj.BrowserObj.Selected;
            end
        end


        function endIndex=getEndIndex(this,varargin)

            endIndex=getNumImages(this.Session);
        end


        function imageIndices=getXAxisForSummary(this,varargin)

            imageIndices=1:getEndIndex(this);
        end


        function annotationInfo=getAnnotationInfoForSummary(this,signalName,varargin)

            imageIndices=getVisibleImageIndices(this);


            roiLabelDefs.Names={this.Session.ROILabelSet.DefinitionStruct.Name};
            roiLabelDefs.Colors={this.Session.ROILabelSet.DefinitionStruct.Color};
            roiLabelDefs.Type={this.Session.ROILabelSet.DefinitionStruct.Type};
            sceneLabelDefs.Names={this.Session.FrameLabelSet.DefinitionStruct.Name};
            sceneLabelDefs.Colors={this.Session.FrameLabelSet.DefinitionStruct.Color};



            numROIAnnotations=this.Session.queryROISummary(signalName,roiLabelDefs.Names,imageIndices);

            numSceneAnnotations=this.Session.querySceneSummary(signalName,sceneLabelDefs.Names,imageIndices);

            annotationInfo.ROILabelDefs=roiLabelDefs;
            annotationInfo.SceneLabelDefs=sceneLabelDefs;
            annotationInfo.TimeVector=imageIndices;
            annotationInfo.NumROIAnnotations=numROIAnnotations;
            annotationInfo.NumSceneAnnotations=numSceneAnnotations;
        end


        function updateDone=sliderUpdateDone(this)
            updateDone=this.SliderUpdate;
        end


        function pos=getModelDialogPos(this,dlgSize)

            if~useAppContainer()
                pos=imageslib.internal.apputil.ScreenUtilities.getModalDialogPos(this.Container.App.Name,dlgSize);
            else
                pos=imageslib.internal.app.utilities.ScreenUtilities.getModalDialogPos(this.Container.App,dlgSize);
            end

        end


        function createBlockedAutomationTutorialDialog(this)


            if this.isBlockedImageAutomation()




                this.ShowBlockedAutomationTutorial=true;

                s=settings;

                messageStrings={getString(message('vision:imageLabeler:BlockedAutomationTutorial1'))};

                titleString=getString(message('vision:imageLabeler:BlockedAutomationTutorialTitle'));

                basePath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+images');
                imagePaths={fullfile(basePath,'BlockedAutomationTutorial.png')};

                flag=s.vision.labeler.OpenWithAppContainer.ActiveValue;

                getBlockedAutomationDialog(this,imagePaths,messageStrings,titleString,s,flag);
            end

        end


        function getBlockedAutomationDialog(this,imagePaths,messageStrings,titleString,settings,flag)%#ok<INUSL> 
            images.internal.app.TutorialDialog(imagePaths,...
            messageStrings,titleString,...
            settings.vision.imageLabeler.ShowBlockedAutomationTutorialDialog,...
            flag);
        end
    end






    methods(Access=private)

        function dispName=getFirstdisplayTitle(this,imageData)
            if iscell(imageData)&&(numel(imageData)>0)
                [~,dispName,~]=fileparts(imageData{1});
            elseif isa(imageData,'matlab.io.datastore.ImageDatastore')
                [~,dispName,~]=fileparts(imageData.Files{1});
            elseif isa(imageData,'blockedImage')
                [~,dispName,~]=fileparts(imageData(1).Source);
            else
                dispName=[this.NameNoneDisplay,'s'];
            end
        end


        function name=getSignalName(this)
            imDisplay=getImageDisplay(this);
            if isempty(imDisplay)
                name='Image';
            else
                name=imDisplay.Name;
            end
        end


        function updateFigureTitle(this,imDisplay)


            idx=getCurrentDisplayIndex(imDisplay);
            [~,name]=fileparts(this.BrowserPanelObj.imageNameByIndex(idx));
            oldName=imDisplay.Name;
            updateDisplayAndTabName(this,string(oldName),string(name));
        end


        function drawImageWithInteractiveROIs(this,data)

            assert(ischar(data.ImageFilename));

            imDisplay=getImageDisplay(this);


            if isfield(data,'ImageIndex')

                updateDisplayIndex(imDisplay,data.ImageIndex)
            end

            imDisplay.drawImageWithInteractiveROIs(data);

            imDisplay.installContextMenu(this.isInAlgoMode(),this.Session.getNumPixelLabels);

            imDisplay.updateSuperpixelState();

            if imDisplay.pastePixelFlag()
                enablePixPasteFlag='on';
            else
                enablePixPasteFlag='off';
            end

            if this.Session.getNumPixelLabels>0
                visiblePixPasteFlag='on';
            else
                visiblePixPasteFlag='off';
            end
            setPixPasteMenuState(imDisplay,enablePixPasteFlag,visiblePixPasteFlag);


            updateFrameLabelStatus(this.FrameLabelSetDisplay,data.SceneLabelIds);

            updateFigureTitle(this,imDisplay);
        end

    end

    methods(Access=private)

        function setDisplayFigHandleVis(this,status)
            imDisplay=getImageDisplay(this);
            setDisplayFigHandleVis(imDisplay,status);
        end


        function idx=getVisibleImageIndices(this)
            if~useAppContainer
                idx=this.BrowserPanelObj.VisibleItemIndex;
            else
                idx=this.BrowserPanelObj.BrowserObj.Selected;
            end
        end
    end





    methods(Access=protected)

        function setTitleBar(this,titleStr)
            if this.IsDataBlockedImage

                c=strsplit(titleStr,'-');
                if numel(c)==1

                    titleStr=[titleStr,' (BlockedImage)'];
                else
                    titleStr=[c{1},'(BlockedImage) -',strjoin(c(2:end))];
                end

            end

            setTitleBar(this.Container,titleStr);
        end

    end




    methods(Static)

        function deleteAllTools()
            imageslib.internal.apputil.manageToolInstances('deleteAll',...
            'imageLabeler');
        end
    end
end


function unsupportedFilename=hasXMLUnsupportedChar(fileNames)










    unsupportedFilename=[];
    for i=1:numel(fileNames)



        fileName=fileNames{i};
        hasUnsupportedChar=any(double(char(fileName))==8211);
        if hasUnsupportedChar
            unsupportedFilename=fileName;
            return;
        end
    end

end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('useAppContainer');
end
