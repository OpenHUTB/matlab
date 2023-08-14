classdef LCCView<handle







    properties

        AppContainer;
        TabGroup;
        CalibrationTab;

        DataBrowserAccepted;
        DataBrowserRejected;
        DataBrowserItemClickCb=[];


        DataFigureGroup;
        ImageFigureDocument;
        PointcloudFigureDocument;
        ImageFigureHandle;
        PointcloudFigureHandle;
        PointcloudPlaneCornerPoints=[];

        CurrentItemIndex;
        CurrentItemSelectedPoints;
        HasValidPCFeatures;

        StatusBar;
        StatusLabel;

        CuboidObj=[];
        CuboidPosition=[-10,-10,-2,10,10,5];
        EditROITab;
        ROIBeforeEdit=[];
        SnapToROIFlag=false;
        EditROIMode=false;
        UndoStack={};
        RedoStack={};
        StackDepth=3;


        roiMovedListener;

        SelectCheckerboardTab;
        SelectCheckerboardMode=false;
        InitialSelectedPoints;

        ErrorGroup;
        TranslationError;
        RotationError;
        ReprojectionError;
        Outliers;

        DefaultLayoutJSON=[];
    end

    properties(Access='private')

        AppTag='lccApp';
        AppTitle=[];

        TabGroupTag='tabGroupLCC';


        FigureDocumentGroupTag="figures";
        FigureDocumentGroupTitle=[];

        ImageFigureDocumentTag="imageFig";
        ImageFigureDocumentTitle=[];

        PointcloudFigureDocumentTag="ptcFig";
        PointcloudFigureDocumentTitle=[];


        ErrorDocumentGroupTag="errors";
        ErrorDocumentGroupTitle=[];

        TErrorFigureDocumentTag="translationErrors";
        TErrorFigureDocumentTitle=[];

        RErrorFigureDocumentTag="rotationErrors";
        RErrorFigureDocumentTitle=[];

        RpErrorFigureDocumentTag="reprojectionErrors";
        RpErrorFigureDocumentTitle=[];

        StatusBarTag="statusbar";





        QabHelpBtnTag="qabHelpBtn";
    end

    methods

        function this=LCCView()
            import matlab.ui.internal.toolstrip.*
            import lidar.internal.calibration.tool.*;

            setTitles(this);

            createApp(this);

            this.TabGroup=TabGroup();
            this.TabGroup.Tag=this.TabGroupTag;

            this.CalibrationTab=CalibrationTab;

            this.TabGroup.add(this.CalibrationTab.Tab);

            this.EditROITab=EditROITab;

            this.SelectCheckerboardTab=SelectCheckerboardTab;


            this.AppContainer.add(this.TabGroup);

            addDataFigureGroup(this);
            addDataFigureDocuments(this);

            hideApp(this);
        end

        function setTitles(this)
            this.AppTitle=string(message('lidar:lidarCameraCalibrator:appTitle'));
            this.FigureDocumentGroupTitle=string(message('lidar:lidarCameraCalibrator:dataFigureGroupTitle'));
            this.ImageFigureDocumentTitle=string(message('lidar:lidarCameraCalibrator:imageFigureTitle'));
            this.PointcloudFigureDocumentTitle=string(message('lidar:lidarCameraCalibrator:pointCloudFigureTitle'));
            this.ErrorDocumentGroupTitle=string(message('lidar:lidarCameraCalibrator:errorFigureGroupTitle'));
            this.TErrorFigureDocumentTitle=string(message('lidar:lidarCameraCalibrator:translationErrorFigureTitle'));
            this.RErrorFigureDocumentTitle=string(message('lidar:lidarCameraCalibrator:rotationErrorFigureTitle'));
            this.RpErrorFigureDocumentTitle=string(message('lidar:lidarCameraCalibrator:reprojectionErrorFigureTitle'));
        end

        function setInitialValues(this,removeGround,clusterThr,dimensionTolerance,cuboidPosition)
            this.CuboidPosition=cuboidPosition;
            this.CalibrationTab.DetectSection.setDefaults(removeGround,clusterThr,dimensionTolerance);

            this.SnapToROIFlag=true;
        end

        function initializeState(this)
            cleanState(this);
            setBgColor(this);
            setEnabledState(this,false);
            setImportEnabledState(this,true);
            useDefaultLayout(this);
        end

        function useDefaultLayout(this)
            if(isempty(this.DefaultLayoutJSON))
                this.DefaultLayoutJSON=fileread(fullfile(toolboxdir('lidar'),...
                'lidar','+lidar','+internal','+calibration','+tool',...
                'beforeCalibrationLayout.json'));
            end
            if(~isempty(this.DefaultLayoutJSON))
                setAppLayout(this,this.DefaultLayoutJSON);
            end
        end
        function cleanState(this)


            this.AppContainer.Title=this.AppTitle;


            removeThumbnails(this);


            resetDataFigureDocuments(this);


            removeErrorDocuments(this);
        end

    end

    methods

        function appTag=makeAppTag(this)
            appTag=this.AppTag+"_"+matlab.lang.internal.uuid;
        end

        function createApp(this)

            appOptions.Tag=makeAppTag(this);
            appOptions.Title=this.AppTitle;
            this.AppContainer=matlab.ui.container.internal.AppContainer(appOptions);
            screenSize=get(0,"ScreenSize");
            appWindowBounds=[0.1*screenSize(3),...
            0.1*screenSize(4),...
            0.8*screenSize(3),...
            0.85*screenSize(4)];
            this.AppContainer.WindowBounds=appWindowBounds;
            this.AppContainer.WindowMaximized=true;


            this.StatusBar=matlab.ui.internal.statusbar.StatusBar;
            this.StatusBar.Tag=this.StatusBarTag;
            this.StatusLabel=matlab.ui.internal.statusbar.StatusLabel;
            this.StatusLabel.Text=string(message('lidar:lidarCameraCalibrator:sbNewSession'));
            this.StatusBar.add(this.StatusLabel);

            this.AppContainer.add(this.StatusBar);


            qabHelpBtn=matlab.ui.internal.toolstrip.qab.QABHelpButton();

            qabHelpBtn.DocName='lidarCameraCalibrator';
            qabHelpBtn.Tag=this.QabHelpBtnTag;

            this.AppContainer.add(qabHelpBtn);
        end

        function appContainer=getAppContainer(this)

            appContainer=this.AppContainer;
        end

        function showApp(this)
            this.AppContainer.Visible=true;
            this.AppContainer.WindowMaximized=true;
        end
        function setFocus(this)
            this.setBusy(false);
            this.AppContainer.bringToFront();
        end

        function hideApp(this)
            this.AppContainer.Visible=false;
        end

        function closeApp(this)


            this.AppContainer.delete();
        end

        function setBgColor(this)
            color=[1,1,1];
            setBgColor(this.DataBrowserAccepted,color);
            setBgColor(this.DataBrowserRejected,color);
            this.ImageFigureDocument.Figure.Color=color;
            this.PointcloudFigureDocument.Figure.Color=color;

        end

        function appendStringToAppTitle(this,value)
            this.AppContainer.Title=this.AppTitle+" - "+string(value);
        end

        function value=isImportBtnEnabled(this)
            value=this.CalibrationTab.FileSection.ImportDataListItem.Enabled;
        end

        function setImportEnabledState(this,value)
            if(value)
                this.CalibrationTab.FileSection.ImportDataListItem.Enabled=true;
                this.CalibrationTab.FileSection.AddDataListItem.Enabled=false;
            else
                this.CalibrationTab.FileSection.ImportDataListItem.Enabled=false;
                this.CalibrationTab.FileSection.AddDataListItem.Enabled=true;
            end
        end

        function setEnabledState(this,value)
            this.CalibrationTab.FileSection.setEnableState(value);
            this.CalibrationTab.IntrinsicsSection.setEnableState(value);
            this.CalibrationTab.DetectSection.setEnableState(value);
            this.CalibrationTab.CalibrateSection.setEnableState(value);
            this.CalibrationTab.DisplayOptionsSection.setEnableState(value);
            this.CalibrationTab.LayoutSection.setEnableState(true);
            this.CalibrationTab.ExportSection.setEnableState(value);
        end

        function setCalibrateSectionEnableState(this,value)
            this.CalibrationTab.CalibrateSection.setEnableState(value);
        end

        function setExportSectionEnableState(this,value)
            this.CalibrationTab.ExportSection.setEnableState(value);
        end


        function updateStatusText(this,text)
            this.StatusLabel.Text=char(text);
        end

        function appendStatusText(this,text)
            this.StatusLabel.Text=[this.StatusLabel.Text,' ',char(text)];
        end

        function setBusy(this,flag)
            this.AppContainer.Busy=flag;
        end

        function value=isBusy(this)
            value=this.AppContainer.Busy;
        end

        function value=isEditROIMode(this)
            value=this.EditROIMode;
        end
    end

    methods

        function addDataFigureGroup(this)


            this.DataFigureGroup=matlab.ui.internal.FigureDocumentGroup();
            this.DataFigureGroup.Title=this.FigureDocumentGroupTitle;
            this.DataFigureGroup.Tag=this.FigureDocumentGroupTag;
            this.AppContainer.add(this.DataFigureGroup);
        end

        function addDataFigureDocuments(this)
            addImageFigureDocument(this);
            addPointcloudFigureDocument(this);
            setDocumentLayout(this,false);
        end

        function addImageFigureDocument(this)
            documentOptions.Title=this.ImageFigureDocumentTitle;
            documentOptions.Tag=this.ImageFigureDocumentTag;


            documentOptions.DocumentGroupTag=this.DataFigureGroup.Tag;
            this.ImageFigureDocument=matlab.ui.internal.FigureDocument(documentOptions);
            this.ImageFigureDocument.Closable=false;
            this.ImageFigureDocument.Figure.AutoResizeChildren='off';
            this.AppContainer.add(this.ImageFigureDocument);
        end

        function addPointcloudFigureDocument(this)
            documentOptions.Title=this.PointcloudFigureDocumentTitle;
            documentOptions.Tag=this.PointcloudFigureDocumentTag;


            documentOptions.DocumentGroupTag=this.DataFigureGroup.Tag;
            this.PointcloudFigureDocument=matlab.ui.internal.FigureDocument(documentOptions);
            this.PointcloudFigureDocument.Closable=false;
            this.AppContainer.add(this.PointcloudFigureDocument);
        end

        function resetDataFigureDocuments(this)
            if(isvalid(this.ImageFigureDocument))

                this.ImageFigureDocument.Title=this.ImageFigureDocumentTitle;
                if(~isempty(this.ImageFigureHandle))
                    delete(this.ImageFigureHandle);
                end
            end

            if(isvalid(this.PointcloudFigureDocument))

                this.PointcloudFigureDocument.Title=this.PointcloudFigureDocumentTitle;
                if(~isempty(this.PointcloudFigureHandle))
                    this.CuboidObj=[];
                    delete(this.PointcloudFigureHandle.Parent);




                    removePointcloudFigureDocument(this);
                    addPointcloudFigureDocument(this);
                end
            end
        end

        function removeImageFigureDocument(this)
            this.AppContainer.closeDocument(this.FigureDocumentGroupTag,...
            this.ImageFigureDocumentTag);
            this.ImageFigureHandle=[];
        end

        function removePointcloudFigureDocument(this)
            this.AppContainer.closeDocument(this.FigureDocumentGroupTag,...
            this.PointcloudFigureDocumentTag);
            this.PointcloudFigureHandle=[];
        end

        function addCuboidObj(this)
            if(isempty(this.CuboidObj))
                this.CuboidObj=images.roi.Cuboid('Parent',this.PointcloudFigureHandle.Parent,...
                'Deletable',false,...
                'Color',[1.0,1.0,0.0]);
                this.CuboidObj.Position=this.CuboidPosition;
                this.CuboidObj.InteractionsAllowed='none';
                this.CuboidObj.Visible=false;
                addlistener(this.CuboidObj,'MovingROI',@(a,b)cbCuboidChanging(this,1));


                deleteCuboidMenu=findobj(this.CuboidObj.ContextMenu.Children,'Tag','IPTROIContextMenuDelete');
                delete(deleteCuboidMenu);
            end
        end

        function saveROIPositionValues(this)

            cuboidPos=this.CuboidObj.Position;
            endIdx=min(numel(this.UndoStack),this.StackDepth);
            if isempty(this.UndoStack)||~(isempty(this.UndoStack)||isequal(cuboidPos,this.UndoStack{1}))
                this.UndoStack=[cuboidPos,this.UndoStack(1:endIdx)];
            end
        end

        function cbCuboidChanging(this,clearRedoStackFlag)
            if(~isempty(this.CuboidObj))

                this.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbCuboidROI',string(mat2str(this.CuboidObj.Position,2)))));

                minBoxDims=[2,2,2];
                minPoints=0.2*length(this.PointcloudFigureHandle.XData);

                if(this.CuboidObj.Position(4)<minBoxDims(1)||this.CuboidObj.Position(5)<minBoxDims(2)||this.CuboidObj.Position(6)<minBoxDims(3))

                    this.EditROITab.CloseSection.ApplyBtn.Enabled=false;
                else
                    hasPointsInROI=this.CuboidObj.inROI(this.PointcloudFigureHandle.XData,...
                    this.PointcloudFigureHandle.YData,...
                    this.PointcloudFigureHandle.ZData);

                    if(sum(hasPointsInROI)<minPoints)

                        this.EditROITab.CloseSection.ApplyBtn.Enabled=false;
                    else
                        this.EditROITab.CloseSection.ApplyBtn.Enabled=true;
                    end
                end

                this.EditROITab.ActionSection.SnapToROIBtn.Enabled=this.EditROITab.CloseSection.ApplyBtn.Enabled;

                if(~this.EditROITab.CloseSection.ApplyBtn.Enabled)
                    this.appendStatusText(string(message('lidar:lidarCameraCalibrator:cuboidROINotEnoughSize')));
                    this.CuboidObj.Label=string(message('lidar:lidarCameraCalibrator:cuboidROINotEnoughSize'));
                    this.CuboidObj.LabelTextColor=[0.9,0,0];
                else
                    this.CuboidObj.Label='';
                end

                if clearRedoStackFlag


                    this.RedoStack={};
                end
            end

        end

        function updateImageData(this,img,title)





            if(isvalid(this.ImageFigureDocument))
                if(isempty(this.ImageFigureHandle)||~isvalid(this.ImageFigureHandle))
                    this.ImageFigureHandle=uiimage(this.ImageFigureDocument.Figure,'ImageSource',img,'ScaleMethod','fit');
                    this.ImageFigureHandle.BackgroundColor='black';
                    cbImageResize(this);
                    this.ImageFigureDocument.Figure.SizeChangedFcn=@(~,~)cbImageResize(this);
                else
                    this.ImageFigureHandle.ImageSource=img;
                end

                this.ImageFigureDocument.Title=title;
            end

        end

        function updatePointcloudFigureColorData(this,ptCloud)
            color=reshape(ptCloud.Color,[],3);
            if this.SelectCheckerboardMode||~(isempty(this.HasValidPCFeatures)||this.HasValidPCFeatures||isempty(this.CurrentItemSelectedPoints)||this.SnapToROIFlag)



                color(this.CurrentItemSelectedPoints,:)=uint8(ones(numel(find(this.CurrentItemSelectedPoints)),3)+[255,0,0]);
            end
            this.PointcloudFigureHandle.CData=color;
        end

        function updatePointcloudFigureData(this,ptCloud)
            if~(isempty(this.PointcloudFigureHandle)||isempty(ptCloud))
                this.PointcloudFigureHandle.PointCloud=ptCloud;
                this.PointcloudFigureHandle.XData=reshape(ptCloud.Location(:,1),[],1);
                this.PointcloudFigureHandle.YData=reshape(ptCloud.Location(:,2),[],1);
                this.PointcloudFigureHandle.ZData=reshape(ptCloud.Location(:,3),[],1);
                this.updatePointcloudFigureColorData(ptCloud);
                adjustPointcloudViewAxes(this);
            end
        end

        function adjustPointcloudViewAxes(this)

            if(isempty(this.PointcloudFigureHandle.XData)||...
                isempty(this.PointcloudFigureHandle.YData)||...
                isempty(this.PointcloudFigureHandle.ZData))
                return;
            end

            if(~this.CuboidObj.Visible)
                lim=[min(this.PointcloudFigureHandle.XData),max(this.PointcloudFigureHandle.XData)];
                this.PointcloudFigureHandle.Parent.XLim=lim;

                lim=[min(this.PointcloudFigureHandle.YData),max(this.PointcloudFigureHandle.YData)];
                this.PointcloudFigureHandle.Parent.YLim=lim;

                lim=[min(this.PointcloudFigureHandle.ZData),max(this.PointcloudFigureHandle.ZData)];
                this.PointcloudFigureHandle.Parent.ZLim=lim;
            else
                padding=0.01;
                cPos=this.CuboidObj.Position;
                lim=[min(this.PointcloudFigureHandle.XData),max(this.PointcloudFigureHandle.XData)];
                if(lim(1)>cPos(1))||lim(2)<cPos(1)+cPos(4)
                    lim(1)=min(lim(1),cPos(1))-padding;
                    lim(2)=max(lim(2),cPos(1)+cPos(4))+padding;
                    this.PointcloudFigureHandle.Parent.XLim=lim;
                end

                lim=[min(this.PointcloudFigureHandle.YData),max(this.PointcloudFigureHandle.YData)];
                if(lim(1)>cPos(2))||lim(2)<cPos(2)+cPos(5)
                    lim(1)=min(lim(1),cPos(2))-padding;
                    lim(2)=max(lim(2),cPos(2)+cPos(5))+padding;
                    this.PointcloudFigureHandle.Parent.YLim=lim;
                end

                lim=[min(this.PointcloudFigureHandle.ZData),max(this.PointcloudFigureHandle.ZData)];
                if(lim(1)>cPos(3))||lim(2)<cPos(3)+cPos(6)
                    lim(1)=min(lim(1),cPos(3))-padding;
                    lim(2)=max(lim(2),cPos(3)+cPos(6))+padding;
                    this.PointcloudFigureHandle.Parent.ZLim=lim;
                end
            end
            drawnow;
        end

        function updatePointcloudData(this,model,ptCloud,title)



            if(isvalid(this.PointcloudFigureDocument))
                ptCloud=this.snapToROI(ptCloud,true);
                if(isempty(this.PointcloudFigureHandle)||~isvalid(this.PointcloudFigureHandle))
                    this.PointcloudFigureHandle=pcshow(ptCloud,...
                    Parent=axes(this.PointcloudFigureDocument.Figure),...
                    Markersize=3,Projection="orthographic").Children;
                    this.PointcloudFigureHandle.Parent.Toolbar=axtoolbar(this.PointcloudFigureHandle.Parent,{'brush','zoomin','zoomout','pan','rotate','restoreview'});


                    this.PointcloudFigureHandle.Parent.Toolbar.Children(6).ButtonPushedFcn=@(e,d)restorePointcloudView(this);


                    this.PointcloudFigureHandle.Parent.Toolbar.Children(1).Visible=0;
                else
                    updatePointcloudFigureData(this,ptCloud);
                end

                this.setPostCallbackFcn(model,ptCloud);

                this.PointcloudFigureDocument.Title=title;


                addCuboidObj(this);
            end
        end

        function cbSelectionChangedFcn(this)



            this.SelectCheckerboardTab.SelectSection.SelectCheckerboardBtn.Value=...
            logical(this.PointcloudFigureHandle.Parent.Toolbar.Children(1).Value);
        end

        function setPostCallbackFcn(this,model,ptCloud)
            if~this.SelectCheckerboardMode
                return
            end
            hBrush=brush(this.PointcloudFigureHandle);
            hBrush.ActionPostCallback=@(hEvent,hSource)saveBrushedData(this,model,ptCloud);
        end

        function saveBrushedData(this,model,ptCloud)



            ptsSelected=logical(this.PointcloudFigureHandle.BrushData.');
            color=ptCloud.Color;
            color(ptsSelected,:)=uint8(ones(numel(find(ptsSelected)),3)+[255,0,0]);
            if~isempty(find(ptsSelected,1))
                updateSelectedPointsByIndex(model,this.CurrentItemIndex,ptsSelected);
                this.CurrentItemSelectedPoints=ptsSelected;
                this.PointcloudFigureHandle.CData=color;
            end


            set(this.PointcloudFigureHandle,'BrushData',[]);
        end

        function clearBrushedData(this,model,ptCloud)



            brushData=this.PointcloudFigureHandle.BrushData;

            newBrushData=zeros(size(brushData),'uint8');


            set(this.PointcloudFigureHandle,'BrushData',newBrushData);
            ptsSelected=logical(this.PointcloudFigureHandle.BrushData.');

            color=ptCloud.Color;
            color(ptsSelected,:)=ones(numel(find(ptsSelected)),3,'uint8')+uint8([255,0,0]);




            updateSelectedPointsByIndex(model,this.CurrentItemIndex,[]);
            this.CurrentItemSelectedPoints=ptsSelected;
            this.PointcloudFigureHandle.CData=color;
        end

    end

    methods
        function addErrorPanel(this)

            if isempty(this.ErrorGroup)

                this.ErrorGroup=matlab.ui.internal.FigureDocumentGroup;
                this.ErrorGroup.Title=this.ErrorDocumentGroupTitle;
                this.ErrorGroup.Tag=this.ErrorDocumentGroupTag;
                this.ErrorGroup.DefaultRegion="bottom";
                this.ErrorGroup.ConstrainToSubContainer=true;
                this.ErrorGroup.SubGridDimensions=[3,1];
                this.AppContainer.add(this.ErrorGroup);
            end

            addErrorDocuments(this);
            this.AppContainer.DocumentRowWeights=[0.6,0.4];
        end

        function removeErrorDocuments(this)
            if(~isempty(this.TranslationError)&&...
                this.AppContainer.hasDocument(this.ErrorDocumentGroupTag,this.TErrorFigureDocumentTag))
                removeDocument(this.TranslationError,this.AppContainer);
            end
            if(~isempty(this.RotationError)&&...
                this.AppContainer.hasDocument(this.ErrorDocumentGroupTag,this.RErrorFigureDocumentTag))
                removeDocument(this.RotationError,this.AppContainer);
            end
            if~isempty(this.ReprojectionError)&&...
                this.AppContainer.hasDocument(this.ErrorDocumentGroupTag,this.RpErrorFigureDocumentTag)
                removeDocument(this.ReprojectionError,this.AppContainer);
            end
        end

        function addErrorDocuments(this)
            if(~this.AppContainer.hasDocument(this.ErrorDocumentGroupTag,this.TErrorFigureDocumentTag))
                this.TranslationError=lidar.internal.calibration.tool.LCCErrorDocument(...
                this,this.TErrorFigureDocumentTitle,this.TErrorFigureDocumentTag,this.ErrorDocumentGroupTag);
                this.AppContainer.addDocument(this.TranslationError.ErrorDocument);
                pause(1);
            end
            if(~this.AppContainer.hasDocument(this.ErrorDocumentGroupTag,this.RErrorFigureDocumentTag))
                this.RotationError=lidar.internal.calibration.tool.LCCErrorDocument(...
                this,this.RErrorFigureDocumentTitle,this.RErrorFigureDocumentTag,this.ErrorDocumentGroupTag);
                this.AppContainer.addDocument(this.RotationError.ErrorDocument);
                pause(1);
            end
            if(~this.AppContainer.hasDocument(this.ErrorDocumentGroupTag,this.RpErrorFigureDocumentTag))
                this.ReprojectionError=lidar.internal.calibration.tool.LCCErrorDocument(...
                this,this.RpErrorFigureDocumentTitle,this.RpErrorFigureDocumentTag,this.ErrorDocumentGroupTag);
                this.AppContainer.addDocument(this.ReprojectionError.ErrorDocument);
                pause(1);
            end
            if~isempty(this.ErrorGroup)
                this.ErrorGroup.SubGridDimensions=[this.ErrorGroup.DocumentCount,1];
                pause(1);
            end
        end

        function addErrorPlots(this,model)
            plotError(this.TranslationError,model.CalibrationErrors.TranslationError,...
            string(message('lidar:lidarCameraCalibrator:TransErrorYLabel')));
            plotError(this.RotationError,model.CalibrationErrors.RotationError,...
            string(message('lidar:lidarCameraCalibrator:RotErrorYLabel')));
            plotError(this.ReprojectionError,model.CalibrationErrors.ReprojectionError,...
            string(message('lidar:lidarCameraCalibrator:ReproErrorYLabel')));
            drawnow;
        end

        function addSliders(this)
            createSlider(this.TranslationError);
            createSlider(this.RotationError);
            createSlider(this.ReprojectionError);
            drawnow;
        end

        function updateSelection(this,highlightBars,errorType)
            if(~isempty(this.ErrorGroup)&&this.ErrorGroup.DocumentCount<=0)
                return;
            end

            hBar=errorType.ErrorBar;
            hBar.FaceColor='flat';
            this.Outliers=this.TranslationError.OutlierIdx|this.RotationError.OutlierIdx|this.ReprojectionError.OutlierIdx;
            if all(~this.Outliers)


                updateFigureData(this);
                return;
            end

            resetThumbnailHighlight(this,1,1);
            for i=1:length(this.Outliers)
                if this.Outliers(i)
                    Highlight(this.DataBrowserAccepted,i);
                else
                    resetThumbnail(this.DataBrowserAccepted.Thumbnails(i));
                end
            end
            idx=find(this.Outliers~=0,1,'first');
            updateFigures(this.DataBrowserAccepted,idx);
            Scroll(this.DataBrowserAccepted,idx);
            for i=1:length(highlightBars)
                if highlightBars(i)

                    hBar.CData(i,:)=[0.066,0.443,0.745];
                else

                    hBar.CData(i,:)=[0.705,0.870,1];
                end
            end
        end

        function updateErrorPanel(this,model)
            if(model.isCalibrationDone)
                addErrorPanel(this);
                addErrorPlots(this,model);
                addSliders(this);
            end
        end

        function resetErrorPlots(this)
            if(~isempty(this.TranslationError)&&...
                this.AppContainer.hasDocument(...
                this.ErrorDocumentGroupTag,...
                this.TErrorFigureDocumentTag))
                resetState(this.TranslationError);
            end

            if(~isempty(this.RotationError)&&...
                this.AppContainer.hasDocument(...
                this.ErrorDocumentGroupTag,...
                this.RErrorFigureDocumentTag))
                resetState(this.RotationError);
            end

            if(~isempty(this.ReprojectionError)&&...
                this.AppContainer.hasDocument(...
                this.ErrorDocumentGroupTag,...
                this.RpErrorFigureDocumentTag))
                resetState(this.ReprojectionError);
            end
        end

        function highlightErrorBars(this,idx,tf)
            if(~isempty(this.TranslationError)&&...
                this.AppContainer.hasDocument(...
                this.ErrorDocumentGroupTag,...
                this.TErrorFigureDocumentTag))
                highlightBar(this.TranslationError,idx,tf);
            end

            if(~isempty(this.RotationError)&&...
                this.AppContainer.hasDocument(...
                this.ErrorDocumentGroupTag,...
                this.RErrorFigureDocumentTag))
                highlightBar(this.RotationError,idx,tf);
            end

            if(~isempty(this.ReprojectionError)&&...
                this.AppContainer.hasDocument(...
                this.ErrorDocumentGroupTag,...
                this.RpErrorFigureDocumentTag))
                highlightBar(this.ReprojectionError,idx,tf);
            end
        end

        function lineState=getThresholdLineState(this)


            lineState=[];
            if(~isempty(this.TranslationError)&&...
                this.AppContainer.hasDocument(...
                this.ErrorDocumentGroupTag,...
                this.TErrorFigureDocumentTag))
                [lineLoc,isLine]=getState(this.TranslationError.ErrorSlider);
                isAtDefaultLoc=(lineLoc==this.TranslationError.MaxPosition);
                lineState=[lineState,lineLoc,isLine,isAtDefaultLoc];
            end
            if(~isempty(this.RotationError)&&...
                this.AppContainer.hasDocument(...
                this.ErrorDocumentGroupTag,...
                this.RErrorFigureDocumentTag))
                [lineLoc,isLine]=getState(this.RotationError.ErrorSlider);
                isAtDefaultLoc=(lineLoc==this.RotationError.MaxPosition);
                lineState=[lineState,lineLoc,isLine,isAtDefaultLoc];
            end

            if(~isempty(this.ReprojectionError)&&...
                this.AppContainer.hasDocument(...
                this.ErrorDocumentGroupTag,...
                this.RpErrorFigureDocumentTag))
                [lineLoc,isLine]=getState(this.ReprojectionError.ErrorSlider);
                isAtDefaultLoc=(lineLoc==this.ReprojectionError.MaxPosition);
                lineState=[lineState,lineLoc,isLine,isAtDefaultLoc];
            end

        end
    end

    methods
        function addDataBrowser(this,model)
            this.DataBrowserAccepted=lidar.internal.calibration.tool.LCCDataBrowser(...
            this,model,string(message('lidar:lidarCameraCalibrator:AcceptedDataBrowserName')),...
            string(message('lidar:lidarCameraCalibrator:AcceptedDataBrowserTitle')),0.6);
            this.DataBrowserRejected=lidar.internal.calibration.tool.LCCDataBrowser(...
            this,model,string(message('lidar:lidarCameraCalibrator:RejectedDataBrowserName')),...
            string(message('lidar:lidarCameraCalibrator:RejectedDataBrowserTitle')),0.4);

            addToAppContainer(this.DataBrowserAccepted,this.AppContainer);
            addToAppContainer(this.DataBrowserRejected,this.AppContainer);
            createStartupText(this.DataBrowserAccepted);
        end

        function removeThumbnails(this)
            removeAllThumbnails(this.DataBrowserAccepted);
            removeAllThumbnails(this.DataBrowserRejected);

            this.AppContainer.getPanel("panel1").Title=...
            string(message('lidar:lidarCameraCalibrator:AcceptedDataBrowserTitle'));
            this.AppContainer.getPanel("panel2").Title=...
            string(message('lidar:lidarCameraCalibrator:RejectedDataBrowserTitle'));
        end

        function resetThumbnailHighlight(this,accFlag,rejFlag)
            if accFlag
                resetThumbnails(this.DataBrowserAccepted);
            end
            if rejFlag
                resetThumbnails(this.DataBrowserRejected);
            end
        end

        function addThumbnailsToDataBrowser(this,model)
            if(length(this.DataBrowserAccepted.Thumbnails)+length(this.DataBrowserRejected.Thumbnails)...
                ==model.NumDatapairs)

                return;
            end
            isAccepted=model.Datapairs.hasValidFeatures();

            populateDataBrowser(this.DataBrowserAccepted,isAccepted);
            populateDataBrowser(this.DataBrowserRejected,~isAccepted);

            makeThumbnailsVisible(this.DataBrowserAccepted);
            makeThumbnailsVisible(this.DataBrowserRejected);
            updateLabels(this.DataBrowserAccepted);
            updateLabels(this.DataBrowserRejected);
            updateDataBrowserTitle(this);
        end

        function updateDataBrowserTitle(this)

            n=length(this.DataBrowserAccepted.Thumbnails);
            this.AppContainer.getPanel("panel1").Title=...
            string(message('lidar:lidarCameraCalibrator:AcceptedDataPanelTitle',n));
            n=length(this.DataBrowserRejected.Thumbnails);
            this.AppContainer.getPanel("panel2").Title=...
            string(message('lidar:lidarCameraCalibrator:RejectedDataPanelTitle',n));
        end

        function updateDataBrowser(this,model)



            n=length(this.DataBrowserAccepted.Thumbnails);
            flag=0;
            if(isequal([this.DataBrowserAccepted.Thumbnails.OrgIndex],find(model.Datapairs.hasValidFeatures))...
                &&isequal([this.DataBrowserRejected.Thumbnails.OrgIndex],find(~model.Datapairs.hasValidFeatures)))
                return
            end
            for i=n:-1:1
                ind=this.DataBrowserAccepted.Thumbnails(i).OrgIndex;
                if~(model.Datapairs(ind).hasValidFeatures())

                    flag=1;
                    moveThumbnail(this.DataBrowserAccepted,i,this.DataBrowserRejected);
                end
            end

            n=length(this.DataBrowserRejected.Thumbnails);

            for i=n:-1:1
                ind=this.DataBrowserRejected.Thumbnails(i).OrgIndex;
                if(model.Datapairs(ind).hasValidFeatures())

                    flag=1;
                    moveThumbnail(this.DataBrowserRejected,i,this.DataBrowserAccepted);
                end
            end
            if flag==1
                updateLabels(this.DataBrowserAccepted);
                toggleCollapse(this.DataBrowserAccepted);
                updateLabels(this.DataBrowserRejected);
                toggleCollapse(this.DataBrowserRejected);
            end
        end

        function[hDataBrowser,idx]=getSelectedThumbnailOnDataBrowser(this)
            hDataBrowser=[];
            if~isempty(this.DataBrowserRejected.Thumbnails)&&...
                ~isempty(this.DataBrowserRejected.HilightedIdx)
                hDataBrowser=this.DataBrowserRejected;
            else
                if~isempty(this.DataBrowserAccepted.Thumbnails)&&...
                    ~isempty(this.DataBrowserAccepted.HilightedIdx)
                    hDataBrowser=this.DataBrowserAccepted;
                end
            end
            if isempty(hDataBrowser)
                if~isempty(this.DataBrowserAccepted.Thumbnails)
                    hDataBrowser=this.DataBrowserAccepted;
                else
                    hDataBrowser=this.DataBrowserRejected;
                end
            end
            idx=min(hDataBrowser.HilightedIdx);
            if isempty(idx)
                idx=1;
            end
        end

        function updateFigureData(this)
            [hDataBrowser,idx]=getSelectedThumbnailOnDataBrowser(this);
            if length(hDataBrowser.Thumbnails)>=1
                try
                    Scroll(hDataBrowser,idx);
                    cbDataBrowserItemClicked(this,hDataBrowser.Thumbnails(idx).Himage,...
                    [],hDataBrowser);
                catch
                    idx=1;
                    Scroll(hDataBrowser,idx);
                    cbDataBrowserItemClicked(this,hDataBrowser.Thumbnails(idx).Himage,...
                    [],hDataBrowser);
                end
            else
                resetDataFigureDocuments(this);
                setBgColor(this);
            end
        end
    end

    methods
        function setCuboidVisibility(this,flag)
            if(~isempty(this.CuboidObj))
                this.CuboidObj.Visible=flag;
                this.adjustPointcloudViewAxes();
            end
        end

        function value=isCuboidVisible(this)
            value=false;
            if(~isempty(this.CuboidObj))
                value=this.CuboidObj.Visible;
            end
        end

        function setSnapToROIFlag(this,flag)
            if(isempty(this.CuboidObj))
                return;
            end
            if(this.SnapToROIFlag~=flag)
                this.SnapToROIFlag=flag;
                ptCloud=this.snapToROI([],false);
                updatePointcloudFigureData(this,ptCloud);
            end
        end

        function hideImageFigure(this)

            this.ImageFigureDocument.Phantom=true;
        end

        function showDataFigures(this)

            this.ImageFigureDocument.Phantom=false;
            this.ImageFigureDocument.Index=1;
            this.PointcloudFigureDocument.Index=2;
        end

        function saveToolbarBtnState(this)



            pcViewState.ToolbarStateButton.Rotate3d=this.PointcloudFigureHandle.Parent.Toolbar.Children(2).Value;
            pcViewState.ToolbarStateButton.Pan=this.PointcloudFigureHandle.Parent.Toolbar.Children(3).Value;
            pcViewState.ToolbarStateButton.ZoomIn='off';
            pcViewState.ToolbarStateButton.ZoomOut='off';

            zh=zoom(this.PointcloudFigureHandle.Parent);
            if(~isempty(zh))
                if(strcmp(zh.Direction,'in'))
                    pcViewState.ToolbarStateButton.ZoomIn=zh.Enable;
                elseif(strcmp(zh.Direction,'out'))
                    pcViewState.ToolbarStateButton.ZoomOut=zh.Enable;
                end
            end

            this.PointcloudFigureHandle.UserData=pcViewState;
        end

        function restoreToolbarBtnState(this)



            if(~isempty(this.PointcloudFigureHandle.UserData))

                pcViewState=this.PointcloudFigureHandle.UserData;


                rotate3d(this.PointcloudFigureHandle.Parent,pcViewState.ToolbarStateButton.Rotate3d);
                pan(this.PointcloudFigureHandle.Parent,pcViewState.ToolbarStateButton.Pan);

                zh=zoom(this.PointcloudFigureHandle.Parent);
                if(~isempty(zh))
                    if(strcmp(pcViewState.ToolbarStateButton.ZoomIn,'on'))
                        zh.Direction='in';
                        zh.Enable=pcViewState.ToolbarStateButton.ZoomIn;
                    elseif(strcmp(pcViewState.ToolbarStateButton.ZoomOut,'on'))
                        zh.Direction='out';
                        zh.Enable=pcViewState.ToolbarStateButton.ZoomOut;
                    else
                        zh.Direction='in';
                        zh.Enable='off';
                        zh.Direction='out';
                        zh.Enable='off';
                    end
                end

                drawnow;
                this.PointcloudFigureHandle.UserData=[];
            end
        end

        function setPreActionCallback(this,hAction)
            hAction.ActionPreCallback=@(hSource,hEvent)setKeyPressListener(this,hSource,hEvent);
        end

        function setActionEnableState(this,hFig,state)
            rotate3d(hFig,state);
            pan(hFig,state);
            zoom(hFig,state);
        end

        function setActionCallbacks(this)
            hAction=rotate3d(this.PointcloudFigureHandle.Parent);
            this.setPreActionCallback(hAction);
            hAction.Enable='off';

            hAction=pan(this.PointcloudFigureDocument.Figure);
            this.setPreActionCallback(hAction);
            hAction.Enable='off';

            hAction=zoom(this.PointcloudFigureDocument.Figure);
            this.setPreActionCallback(hAction);
            hAction.Enable='off';
        end

        function setKeyPressListener(this,hSource,hEvent)
            hManager=uigetmodemanager(hSource);
            [hManager.WindowListenerHandles.Enabled]=deal(false);
            set(hSource,'WindowKeyPressFcn',[]);
            set(hSource,'KeyPressFcn',@(src,evt)keyPressedFcn(this,src,evt));
        end

        function keyPressedFcn(this,hSource,hEvent)
            if~this.EditROIMode
                return
            end
            if numel(hEvent.Modifier)>1


                return;
            end
            if strcmp(hEvent.Key,'escape')
                this.setActionEnableState(hSource,'off');
            end
            if~isempty(hEvent.Modifier)&&...
                (strcmp(hEvent.Modifier,'control')||strcmp(hEvent.Modifier,'command'))&&...
                strcmp(hEvent.Key,'z')&&~this.SnapToROIFlag

                if numel(this.UndoStack)>=2
                    endIdx=min(numel(this.RedoStack),2);
                    currentCuboidPos=this.UndoStack{1};
                    newCuboidPos=this.UndoStack{2};
                    this.RedoStack=[currentCuboidPos,this.RedoStack(1:endIdx)];

                    endIdx=min(numel(this.UndoStack),this.StackDepth+1);
                    this.UndoStack=this.UndoStack(2:endIdx);
                    this.CuboidObj.Position=newCuboidPos;
                    this.cbCuboidChanging(0);
                end

            end
            if~isempty(hEvent.Modifier)&&...
                (strcmp(hEvent.Modifier,'control')||strcmp(hEvent.Modifier,'command'))&&...
                strcmp(hEvent.Key,'y')&&~this.SnapToROIFlag

                if numel(this.RedoStack)>=1
                    endIdx=min(numel(this.UndoStack),this.StackDepth);
                    newCuboidPos=this.RedoStack{1};
                    this.UndoStack=[newCuboidPos,this.UndoStack(1:endIdx)];
                    endIdx=min(numel(this.RedoStack),this.StackDepth);
                    this.RedoStack=this.RedoStack(2:endIdx);
                    this.CuboidObj.Position=newCuboidPos;
                    this.cbCuboidChanging(0);
                end
            end
        end

        function editROIBegin(this)
            this.updateStatusText(string(message('lidar:lidarCameraCalibrator:sbEditROIMode')));


            this.saveToolbarBtnState();

            this.EditROIMode=true;
            this.EditROITab.ActionSection.SnapToROIBtn.Value=false;
            this.EditROITab.CloseSection.ApplyBtn.Enabled=true;
            this.ROIBeforeEdit=this.CuboidObj.Position;
            this.TabGroup.remove(this.CalibrationTab.Tab);
            this.TabGroup.add(this.EditROITab.Tab);


            this.hideImageFigure();
            this.removeErrorDocuments();


            this.DataBrowserAccepted.setContextMenuEnabledState('off');
            this.DataBrowserRejected.setContextMenuEnabledState('off');


            this.setCuboidVisibility(true);

            if(this.SnapToROIFlag)

                setSnapToROIFlag(this,false);
            end

            this.CuboidObj.InteractionsAllowed='all';

            this.setActionEnableState(this.PointcloudFigureHandle.Parent,'off');

            updateFigureData(this);


            restorePointcloudView(this);


            this.PointcloudFigureDocument.Figure.KeyPressFcn=@(src,evt)keyPressedFcn(this,src,evt);
            this.setActionCallbacks();


            this.UndoStack={this.CuboidObj.Position};

            this.RedoStack={};
            this.roiMovedListener=addlistener(this.CuboidObj,'ROIMoved',@(a,b)saveROIPositionValues(this));

            drawnow;
        end

        function editROIEnd(this,useNewROIFlag,model)

            this.setBusy(true);

            this.CuboidPosition=this.CuboidObj.Position;
            if(~useNewROIFlag)

                this.CuboidPosition=this.ROIBeforeEdit;
            end


            this.EditROIMode=false;
            this.TabGroup.remove(this.EditROITab.Tab);

            this.TabGroup.add(this.CalibrationTab.Tab);
            this.CuboidObj.Position=this.CuboidPosition;
            this.SnapToROIFlag=this.CalibrationTab.DisplayOptionsSection.SnapToROIBtn.Value;
            this.showDataFigures();
            this.updateErrorPanel(model);


            this.DataBrowserAccepted.setContextMenuEnabledState('on');
            this.DataBrowserRejected.setContextMenuEnabledState('on');

            this.CuboidObj.InteractionsAllowed='none';
            this.CuboidObj.Label='';

            this.restoreToolbarBtnState();

            delete(this.roiMovedListener);
            this.CuboidObj.Visible=this.CalibrationTab.DisplayOptionsSection.HideROIBtn.Enabled&&~this.CalibrationTab.DisplayOptionsSection.HideROIBtn.Value;
            restorePointcloudView(this);
            cbRestoreDefaultLayout(this,model);
            updateFigureData(this);
            this.setBusy(false);
        end

        function ptCloudOut=snapToROI(this,ptCloud,ptCloudUpdateFlag)
            persistent ptCloudOrig;
            ptCloudOut=[];
            if(isempty(ptCloudOrig)||ptCloudUpdateFlag)
                ptCloudOrig=ptCloud;
            end

            if(isempty(ptCloudOrig))
                return;
            end

            if(this.SnapToROIFlag)
                roi=this.CuboidPosition;
                if(~isempty(this.CuboidObj)&&isvalid(this.CuboidObj))
                    roi=this.CuboidObj.Position;
                end
                if(~isempty(roi))
                    roi(4)=roi(1)+roi(4);
                    roi(5)=roi(2)+roi(5);
                    roi(6)=roi(3)+roi(6);
                    roi=[roi(1),roi(4),roi(2),roi(5),roi(3),roi(6)];
                    ptCloudOut=ptCloudOrig.select(ptCloudOrig.findPointsInROI(roi));
                else

                    ptCloudOut=ptCloudOrig;
                end
            else
                ptCloudOut=ptCloudOrig;
            end
        end

    end

    methods

        function selectCheckerboardBegin(this)
            this.TabGroup.remove(this.CalibrationTab.Tab);
            this.TabGroup.add(this.SelectCheckerboardTab.Tab);

            this.SelectCheckerboardMode=true;

            this.SelectCheckerboardTab.SelectSection.SelectCheckerboardBtn.Value=false;


            this.hideImageFigure();
            this.removeErrorDocuments();

            this.setCuboidVisibility(false);
            if(this.SnapToROIFlag)

                setSnapToROIFlag(this,false);
            end


            this.DataBrowserAccepted.setContextMenuEnabledState('off');
            this.DataBrowserRejected.setContextMenuEnabledState('off');


            this.setActionEnableState(this.PointcloudFigureHandle.Parent,'off');


            this.PointcloudFigureHandle.Parent.Toolbar.Children(1).Visible=1;
            this.setBrushMode('off');

            this.PointcloudFigureHandle.Parent.Toolbar.SelectionChangedFcn=@(hSource,hEvent)cbSelectionChangedFcn(this);

            updateFigureData(this);

            restorePointcloudView(this);
            drawnow;
        end

        function selectCheckerboardEnd(this,model,applyFlag)
            this.setBusy(true);

            if~applyFlag

                model.updateSelectedPoints(this.InitialSelectedPoints);
            end

            this.TabGroup.remove(this.SelectCheckerboardTab.Tab);
            this.TabGroup.add(this.CalibrationTab.Tab);
            this.SnapToROIFlag=this.CalibrationTab.DisplayOptionsSection.SnapToROIBtn.Value;

            this.SelectCheckerboardMode=false;


            this.PointcloudFigureHandle.Parent.Toolbar.Children(1).Visible=0;

            set(this.PointcloudFigureHandle,'BrushData',zeros(size(this.PointcloudFigureHandle.BrushData)));

            this.setBrushMode('off');

            this.PointcloudFigureHandle.Parent.Toolbar.SelectionChangedFcn='';

            this.showDataFigures();
            this.updateErrorPanel(model);

            this.CuboidObj.Visible=this.CalibrationTab.DisplayOptionsSection.HideROIBtn.Enabled&&~this.CalibrationTab.DisplayOptionsSection.HideROIBtn.Value;


            this.DataBrowserAccepted.setContextMenuEnabledState('on');
            this.DataBrowserRejected.setContextMenuEnabledState('on');


            cbRestoreDefaultLayout(this,model);
            restorePointcloudView(this);
            updateFigureData(this);
            this.setBusy(false);
        end

        function setBrushMode(this,value)
            brush(this.PointcloudFigureHandle.Parent,value);
        end

    end

    methods

        function cbImageResize(this)
            if(~isempty(this.ImageFigureHandle)&&isvalid(this.ImageFigureHandle))
                matlab.ui.internal.databrowser.resizeChildWidget(this.ImageFigureDocument.Figure,this.ImageFigureHandle);
            end
        end

        function flag=isCtrlClickValid(this,hDataBrowserFig,dataBrowser,lastThumbnail)


            flag=(~isempty(hDataBrowserFig)&&...
            ~isempty(hDataBrowserFig.SelectionType)&&...
            strcmp(hDataBrowserFig.SelectionType,'alt'));


            if flag&&~isempty(lastThumbnail)
                flag=(strcmp(dataBrowser.Name,lastThumbnail.Parent.Name));
            end
        end

        function flag=rightClickHighlightedTh(this,hFig,dataBrowser,idx)
            flag=false;
            if isprop(hFig,'SelectionType')&&strcmp(hFig.SelectionType,'alt')
                if find(dataBrowser.HilightedIdx==idx)


                    flag=true;
                end
            end
        end

        function cbDataBrowserItemClicked(this,hSource,hEvent,dataBrowser)
            if isempty(hSource)
                idx=1;
            else
                if~isempty(hSource.UserData)

                    idx=hSource.UserData;
                    hFig=hSource.Parent.Parent.Parent;
                else


                    idx=hSource.Children(1).UserData;
                    hFig=hSource.Parent;
                end
                if this.rightClickHighlightedTh(hFig,dataBrowser,idx)
                    return
                end
            end


            persistent lastThumbnail;

            if~isempty(hSource)&&this.isCtrlClickValid(hSource.Parent.Parent.Parent,dataBrowser,lastThumbnail)



                this.Outliers(idx)=1;
            else





                if(~isempty(lastThumbnail)&&isvalid(lastThumbnail)&&...
                    strcmp(lastThumbnail.Parent.View.AppContainer.Tag,...
                    this.AppContainer.Tag))
                    resetThumbnail(lastThumbnail);
                end

                resetThumbnailHighlight(this,1,1);
                dataBrowser.SelectedThumbnails=[];
                this.Outliers=[];


                resetErrorPlots(this);
                updateFigures(dataBrowser,idx);
            end

            dataBrowser.AnchorTh=idx;
            lastThumbnail=dataBrowser.Thumbnails(idx);
            if isequal(dataBrowser,this.DataBrowserAccepted)
                highlightErrorBars(this,idx,1);
            end
            Highlight(dataBrowser,idx);
        end

        function cbRestoreDefaultLayout(this,model)
            this.setDocumentLayout(model.isCalibrationDone());
            layoutJSON=getAppLayout(this,model.isCalibrationDone());
            setAppLayout(this,layoutJSON);
            this.AppContainer.LeftWidth=0.18;

            pause(1);
            toggleCollapse(this.DataBrowserAccepted);
            pause(1);
            toggleCollapse(this.DataBrowserRejected);
            pause(1);
        end

        function setAppLayout(this,layoutJSON)
            if(~isempty(layoutJSON))
                this.AppContainer.LayoutJSON=jsonencode(layoutJSON);
                drawnow;
            end
        end

        function layoutJSON=getAppLayout(this,isCalibrated)
            if~isCalibrated
                layoutJSON=fileread(fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','beforeCalibrationLayout.json'));
            else
                layoutJSON=fileread(fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+calibration','+tool','afterCalibrationLayout.json'));
            end
        end

        function setDocumentLayout(this,isCalibrated)
            layoutJSON=getAppLayout(this,isCalibrated);
            this.AppContainer.DocumentLayoutJSON=jsonencode(jsondecode(layoutJSON).documentLayout);
        end

        function restorePointcloudView(this)
            if(~isempty(this.PointcloudFigureHandle))


                matlab.graphics.controls.internal.resetHelper(this.PointcloudFigureHandle.Parent,~false);
                adjustPointcloudViewAxes(this);
                drawnow;
            end
        end
    end

    methods(Hidden)

        function sessionData=makeSessionData(this)

            sessionData=struct('CalibrationTabState',struct('RemoveGroundBtnValue',this.CalibrationTab.DetectSection.RemoveGroundBtn.Value,...
            'ClusterThrSpnrValue',this.CalibrationTab.DetectSection.ClusterThrSpnr.Value,...
            'DimensionToleranceSpnrValue',this.CalibrationTab.DetectSection.DimensionToleranceSpnr.Value,...
            'DetectBtnEnabled',this.CalibrationTab.DetectSection.DetectBtn.Enabled,...
            'SnapToROIBtnValue',this.CalibrationTab.DisplayOptionsSection.SnapToROIBtn.Value,...
            'HideROIBtnEnabled',this.CalibrationTab.DisplayOptionsSection.HideROIBtn.Enabled,...
            'HideROIBtnValue',this.CalibrationTab.DisplayOptionsSection.HideROIBtn.Value,...
            'CuboidPosition',this.CuboidPosition)...
            );
        end

        function validSession=loadSession(this,sessionData)
            validSession=false;
            if(isempty(sessionData))
                return;
            end

            try
                this.CuboidPosition=sessionData.CalibrationTabState.CuboidPosition;
                this.CalibrationTab.DetectSection.RemoveGroundBtn.Value=sessionData.CalibrationTabState.RemoveGroundBtnValue;
                this.CalibrationTab.DetectSection.ClusterThrSpnr.Value=sessionData.CalibrationTabState.ClusterThrSpnrValue;
                this.CalibrationTab.DetectSection.DimensionToleranceSpnr.Value=sessionData.CalibrationTabState.DimensionToleranceSpnrValue;
                this.CalibrationTab.DetectSection.DetectBtn.Enabled=sessionData.CalibrationTabState.DetectBtnEnabled;

                this.CalibrationTab.DisplayOptionsSection.SnapToROIBtn.Value=sessionData.CalibrationTabState.SnapToROIBtnValue;
                this.CalibrationTab.DisplayOptionsSection.HideROIBtn.Enabled=sessionData.CalibrationTabState.HideROIBtnEnabled;
                this.CalibrationTab.DisplayOptionsSection.HideROIBtn.Value=sessionData.CalibrationTabState.HideROIBtnValue;
            catch
                validSession=false;
                return;
            end
            this.CuboidObj.Position=this.CuboidPosition;
            if(~this.CalibrationTab.DisplayOptionsSection.SnapToROIBtn.Value)
                setSnapToROIFlag(this,false);
                this.setCuboidVisibility(~this.CalibrationTab.DisplayOptionsSection.HideROIBtn.Value);
            else
                ptCloud=this.snapToROI([],false);
                updatePointcloudFigureData(this,ptCloud);
            end
            restorePointcloudView(this);
            validSession=true;
        end
    end

    methods

        function update(this,model)



            setBusy(this,true);
            if(model.isNewSession())
                this.initializeState();
                createStartupText(this.DataBrowserAccepted);
                setBusy(this,false);
                return;
            end


            addThumbnailsToDataBrowser(this,model);

            updateDataBrowser(this,model);
            updateDataBrowserTitle(this);
            updateLabels(this.DataBrowserAccepted);
            updateLabels(this.DataBrowserRejected);

            updateCntxtMenu(this.DataBrowserAccepted,model.areFeaturesDetected()&&model.isCalibrationDone());
            updateCntxtMenu(this.DataBrowserRejected,model.areFeaturesDetected()&&model.isCalibrationDone());


            if(model.isCalibrationDone())
                updateErrorPanel(this,model);
            else
                removeErrorDocuments(this);
                this.Outliers=[];
            end

            if isempty(this.DataBrowserRejected.Thumbnails)
                createStartupText(this.DataBrowserAccepted);
            end


            setCalibrateSectionEnableState(this,model.areFeaturesDetected());
            setExportSectionEnableState(this,model.isCalibrationDone());


            updateFigureData(this);
            this.cbRestoreDefaultLayout(model);

            drawnow;

            setBusy(this,false);
        end
    end
end
