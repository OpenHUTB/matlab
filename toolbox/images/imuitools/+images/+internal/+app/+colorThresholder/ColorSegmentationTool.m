classdef ColorSegmentationTool<handle




    properties(Hidden=true,SetAccess=private)





FigureHandles


hFigCurrent


mask
sliderMask
clusterMask


imRGB


hAxes


hMaskOpacitySlider


ImagePreviewDisplay


hPolyROIs


hInvertMaskButton
hHidePointCloud





normalizedDoubleData
massageNansInfs

    end

    properties(Access=private)


hToolGroup


hTabGroup
ThresholdTab
ImageCaptureTab


hImagePanel


LoadImageSection
ThresholdControlsSection
ChooseProjectionSection
ColorSpacesSection
ManualSelectionSection
ViewSegmentationSection
ExportSection


hColorSpacesButton
hShowBinaryButton
hOverlayColorButton
hPointCloudBackgroundSlider
isLiveUpdate



hChangeUIComponentHandles
lassoSensitiveComponentHandles



currentOpacity



ClientActionListener





colorspaceSelectedListener




binaryButonStateChangedListener
invertMaskItemStateChangedListener
sliderMovedListener
pointCloudSliderMovedListener



hColorSpaceMontageView
hColorSpaceProjectionView


hFreehandROIs
freehandManager
polyManager


hFreehandListener
hPolyMovedListener
hSliderMovedListener
hPolyListener
hFreehandMovedListener

preLassoToolstripState


imSize


isProjectionApplied


pointCloudColor
maskColor


isFreehandApplied
isManualDelete
is3DView
isFigClicked


LoadImageIcon
newColorspaceIcon
hidePointCloudIcon
liveUpdateIcon
invertMaskIcon
resetButtonIcon
showBinaryIcon
createMaskIcon
freeIcon
polyIcon
rotateIcon
rotatePointer

    end


    methods

        function self=ColorSegmentationTool(varargin)

            self.hToolGroup=matlab.ui.internal.desktop.ToolGroup(getString(message('images:colorSegmentor:appName')));
            self.hTabGroup=matlab.ui.internal.toolstrip.TabGroup();


            images.internal.app.utilities.addDDUXLogging(self.hToolGroup,'Image Processing Toolbox','Color Thresholder');


            self.ThresholdTab=self.hTabGroup.addTab(getString(message('images:colorSegmentor:thresholdTab')));
            self.ThresholdTab.Tag=getString(message('images:colorSegmentor:ThresholdTabName'));
            self.hTabGroup.SelectedTab=self.ThresholdTab;


            self.ImagePreviewDisplay=[];


            self.removeViewTab();


            self.removeQuickAccessBar()





            self.disableInteractiveTiling();


            self.LoadImageSection=self.ThresholdTab.addSection(getString(message('images:colorSegmentor:loadImage')));
            self.LoadImageSection.Tag='LoadImage';
            self.ColorSpacesSection=self.ThresholdTab.addSection(getString(message('images:colorSegmentor:colorSpaces')));
            self.ColorSpacesSection.Tag='ColorSection';
            self.ThresholdControlsSection=self.ThresholdTab.addSection(getString(message('images:colorSegmentor:thresholdControls')));
            self.ThresholdControlsSection.Tag='ThresholdControlsSection';
            self.ViewSegmentationSection=self.ThresholdTab.addSection(getString(message('images:colorSegmentor:viewSegmentation')));
            self.ViewSegmentationSection.Tag='ViewSegmentationSection';
            self.ManualSelectionSection=self.ThresholdTab.addSection(getString(message('images:colorSegmentor:colorSelection')));
            self.ManualSelectionSection.Tag='ManualSelectionSection';
            self.ChooseProjectionSection=self.ThresholdTab.addSection(getString(message('images:colorSegmentor:pointCloud')));
            self.ChooseProjectionSection.Tag='ChooseProjection';
            self.ExportSection=self.ThresholdTab.addSection(getString(message('images:colorSegmentor:export')));
            self.ExportSection.Tag='Export';


            self.loadAppIcons();
            self.layoutLoadImageSection();
            self.layoutColorSpacesSection();
            self.layoutManualSelectionSection();
            self.layoutThresholdControlsSection();
            self.layoutViewSegmentationSection();
            self.layoutExportSection();
            self.layoutChooseProjectionSection();

            self.hToolGroup.addTabGroup(self.hTabGroup);


            self.pointCloudColor=1-repmat(self.hPointCloudBackgroundSlider.Value,1,3)/100;
            self.maskColor=[0,0,0];


            self.setControlsEnabled(false);
            self.hPointCloudBackgroundSlider.Enabled=false;


            g=self.hToolGroup.Peer.getWrappedComponent;
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.PERMIT_DOCUMENT_BAR_HIDE,false);

            disableDragDropOnToolGroup(self);


            [x,y,width,height]=imageslib.internal.apputil.ScreenUtilities.getInitialToolPosition();
            self.hToolGroup.setPosition(x,y,width,height);
            self.hToolGroup.disableDataBrowser();
            self.hToolGroup.open();

            imageslib.internal.apputil.manageToolInstances('add','colorThresholder',self.hToolGroup);

            self.isProjectionApplied=false;
            self.isFreehandApplied=false;
            self.isManualDelete=true;





            addlistener(self.hToolGroup,'GroupAction',...
            @(~,ed)doClosingSession(self,ed));


            if nargin>0
                im=varargin{1};
                self.importImageData(im);
            else
                self.hColorSpacesButton.Enabled=false;
            end



            drawnow;


            self.ClientActionListener=addlistener(self.hToolGroup,...
            'ClientAction',@(hobj,evt)clientActionCB(self,hobj,evt));

        end

    end

    methods

        function[h3DPoly,h2DPoly,h2DRotate]=getPointCloudButtonHandles(self)



            h3DPoly=findobj(self.hFigCurrent,'Tag','ProjectButton');
            h2DPoly=findobj(self.hFigCurrent,'Tag','PolyButton');
            h2DRotate=findobj(self.hFigCurrent,'Tag','RotateButton');

        end

        function hButton=getMontageViewButtonHandle(self,csname)


            if self.hasCurrentValidMontageInstance()
                hButton=self.hColorSpaceMontageView.getButtonHandle(csname);
            else
                hButton=[];
            end

        end

    end

    methods


        function initializeAppWithRGBImage(self,im)


            self.imRGB=im;


            self.mask=true(size(im,1),size(im,2));


            self.hColorSpacesButton.Enabled=true;

        end


    end


    methods(Access=private)

        function[self,im]=normalizeDoubleDataDlg(self,im)

            self.normalizedDoubleData=false;
            self.massageNansInfs=false;


            finiteIdx=isfinite(im(:));
            hasNansInfs=~all(finiteIdx);


            isOutsideRange=any(im(finiteIdx)>1)||any(im(finiteIdx)<0);



            if isOutsideRange||hasNansInfs

                buttonname=questdlg(getString(message('images:colorSegmentor:normalizeDataDlgMessage')),...
                getString(message('images:colorSegmentor:normalizeDataDlgTitle')),...
                getString(message('images:colorSegmentor:normalizeData')),...
                getString(message('images:commonUIString:cancel')),...
                getString(message('images:colorSegmentor:normalizeData')));

                if strcmp(buttonname,getString(message('images:colorSegmentor:normalizeData')))


                    if hasNansInfs

                        im(isnan(im))=0;


                        im(im==Inf)=1;


                        im(im==-Inf)=0;

                        self.massageNansInfs=true;
                    end


                    if isOutsideRange
                        im=mat2gray(im);
                        self.normalizedDoubleData=true;
                    end

                else
                    im=[];
                end

            end
        end

        function cdata=computeColorspaceRepresentation(self,csname)

            switch(csname)

            case 'RGB'
                cdata=self.imRGB;
            case 'HSV'
                cdata=rgb2hsv(self.imRGB);
            case 'YCbCr'
                cdata=rgb2ycbcr(self.imRGB);
            case 'L*a*b*'
                cdata=rgb2lab(self.imRGB);

            otherwise
                assert(false,'Unknown colorspace name specified.');
            end

        end

        function doClosingSession(self,evt)
            if strcmp(evt.EventData.EventType,'CLOSING')


                drawnow;

                if isCameraPreviewInApp(self)

                    drawnow;
                    self.ImageCaptureTab.closePreviewWindowCallback;
                end

                if~isempty(self.hColorSpaceMontageView)
                    self.hColorSpaceMontageView.delete()
                end
                imageslib.internal.apputil.manageToolInstances('remove','colorThresholder',self.hToolGroup);
                delete(self.hToolGroup)
                delete(self);
            end
        end


        function clientActionCB(self,~,evt)

            hFig=evt.EventData.Client;

            if strcmpi(evt.EventData.EventType,'ACTIVATED')

                self.manageROIButtonStates()


                clientTitle=evt.EventData.ClientTitle;
                existingTabs=self.hToolGroup.TabNames;


                if strcmp(clientTitle,getString(message('images:colorSegmentor:chooseColorspace')))
                    self.hColorSpacesButton.Enabled=false;
                    self.setControlsEnabled(false);
                    self.hPointCloudBackgroundSlider.Enabled=true;
                elseif strcmp(clientTitle,getString(message('images:colorSegmentor:MainPreviewFigure')))
                    self.hColorSpacesButton.Enabled=false;
                    self.setControlsEnabled(false);
                    self.hPointCloudBackgroundSlider.Enabled=false;
                elseif self.validColorspaceFiguresInApp()
                    self.setControlsEnabled(true);
                    self.hColorSpacesButton.Enabled=true;
                    if self.hHidePointCloud.Value
                        self.hPointCloudBackgroundSlider.Enabled=false;
                    else
                        self.hPointCloudBackgroundSlider.Enabled=true;
                    end
                end


                if strcmpi(clientTitle,getString(message('images:colorSegmentor:MainPreviewFigure')))


                    if~any(strcmpi(existingTabs,getString(message('images:colorSegmentor:ImageCaptureTabName'))))
                        add(self.hTabGroup,getToolTab(self.ImageCaptureTab),2);
                    end

                    self.hTabGroup.SelectedTab=getToolTab(self.ImageCaptureTab);

                    self.hFigCurrent=hFig;
                elseif self.validColorspaceFiguresInApp()




                    hLeftPanel=findobj(hFig,'tag','LeftPanel');

                    if~isempty(hLeftPanel)
                        layoutScrollpanel(self,hLeftPanel);




                        hRightPanel=findobj(hFig,'tag','RightPanel');
                        histHandles=getappdata(hRightPanel,'HistPanelHandles');
                        hProjectionView=getappdata(hRightPanel,'ProjectionView');
                        self.hColorSpaceProjectionView=hProjectionView;


                        self.hFigCurrent=hFig;
                        cData=getappdata(hRightPanel,'ColorspaceCData');
                        self.updateMask(cData,histHandles{:});
                        hPanel3D=findobj(hRightPanel,'tag','proj3dpanel');


                        if strcmp(get(hPanel3D,'Visible'),'on')
                            self.is3DView=true;
                        else
                            self.is3DView=false;
                        end


                        if~self.hHidePointCloud.Value
                            self.applyClusterROIs();
                        end

                        self.hideOtherROIs()

                    end


                    if any(strcmp(existingTabs,getString(message('images:colorSegmentor:ImageCaptureTabName'))))
                        remove(self.hTabGroup,getToolTab(self.ImageCaptureTab));
                    end
                    self.hToolGroup.SelectedTab=self.ThresholdTab.Tag;
                else

                    if any(strcmp(existingTabs,getString(message('images:colorSegmentor:ImageCaptureTabName'))))
                        remove(self.hTabGroup,getToolTab(self.ImageCaptureTab));
                    end
                    self.hToolGroup.SelectedTab=self.ThresholdTab.Tag;
                end

            end



            if strcmpi(evt.EventData.EventType,'CLOSED')
                appDeleted=~isvalid(self)||~isvalid(self.hToolGroup);
                if~appDeleted
                    self.manageROIButtonStates()
                    if~self.validColorspaceFiguresInApp()
                        self.setControlsEnabled(false);
                        if self.hToolGroup.isClientShowing(getString(message('images:colorSegmentor:chooseColorspace')))
                            self.hPointCloudBackgroundSlider.Enabled=true;
                            self.hColorSpacesButton.Enabled=false;
                        elseif self.hToolGroup.isClientShowing(getString(message('images:colorSegmentor:MainPreviewFigure')))
                            self.hPointCloudBackgroundSlider.Enabled=false;
                            self.hColorSpacesButton.Enabled=false;
                        else
                            self.hColorSpacesButton.Enabled=true;
                            self.hPointCloudBackgroundSlider.Enabled=false;
                        end
                    end
                end
            end

        end


        function manageROIButtonStates(self)

            if~isvalid(self)||~isvalid(self.hToolGroup)
                return
            end


            if~isempty(self.freehandManager)
                self.resetLassoTool()
                self.freehandManager=[];
                set(findobj(self.hImagePanel,'Tag','SelectButton'),'Value',0);
            end

            if~isempty(self.polyManager)
                self.disablePolyRegion()
                self.polyManager=[];

                validHandles=self.FigureHandles(ishandle(self.FigureHandles));
                arrayfun(@(h)set(findobj(h,'Tag','PolyButton'),'Value',0),validHandles);
            end

        end


        function updateMask(self,cData,hChan1Hist,hChan2Hist,hChan3Hist)




            channel1Lim=hChan1Hist.currentSelection;
            channel2Lim=hChan2Hist.currentSelection;
            channel3Lim=hChan3Hist.currentSelection;

            firstPlane=cData(:,:,1);
            secondPlane=cData(:,:,2);
            thirdPlane=cData(:,:,3);




            if isa(hChan1Hist,'images.internal.app.colorThresholder.InteractiveHistogramHue')&&(channel1Lim(1)>=channel1Lim(2))
                BW=bsxfun(@ge,firstPlane,channel1Lim(1))|bsxfun(@le,firstPlane,channel1Lim(2));
            else
                BW=bsxfun(@ge,firstPlane,channel1Lim(1))&bsxfun(@le,firstPlane,channel1Lim(2));
            end

            BW=BW&bsxfun(@ge,secondPlane,channel2Lim(1))&bsxfun(@le,secondPlane,channel2Lim(2));
            BW=BW&bsxfun(@ge,thirdPlane,channel3Lim(1))&bsxfun(@le,thirdPlane,channel3Lim(2));

            self.sliderMask=BW;


            self.updateMasterMask();

        end


        function updateClusterMask(self,varargin)




            switch nargin
            case 1

                self.clusterMask=true([size(self.imRGB,1),size(self.imRGB,2)]);
            case 2
                self.clusterMask=varargin{1};
            end


            self.updateMasterMask();

        end


        function updateMasterMask(self)



            BW=self.sliderMask&self.clusterMask;

            if self.hInvertMaskButton.Value
                self.mask=~BW;
            else
                self.mask=BW;
            end


            self.updateMaskOverlayGraphics();

        end


        function updatePointCloud(self,varargin)





            hPanel=findobj(self.hFigCurrent,'tag','RightPanel');
            hScat=findobj(hPanel,'Tag','ScatterPlot');


            hScat.Parent.XLimMode='Manual';
            hScat.Parent.YLimMode='Manual';


            BW=self.sliderMask(:);
            im=getappdata(hPanel,'TransformedCDataForCluster');
            xData=im(:,1);
            yData=im(:,2);


            if nargin>1
                hScat.Parent.XLim=varargin{1};
                hScat.Parent.YLim=varargin{2};
            end


            xData=xData(BW);
            yData=yData(BW);



            cData1=self.imRGB(:,:,1);
            cData2=self.imRGB(:,:,2);
            cData3=self.imRGB(:,:,3);
            cData1=cData1(self.sliderMask);
            cData2=cData2(self.sliderMask);
            cData3=cData3(self.sliderMask);
            cData=[cData1,cData2,cData3];

            set(hScat,'XData',xData,'YData',yData,'CData',cData);

        end

        function hidePointCloud(self)

            if self.hHidePointCloud.Value
                self.hPointCloudBackgroundSlider.Enabled=false;

                validHandles=self.FigureHandles(ishandle(self.FigureHandles));


                for ii=1:numel(validHandles)
                    hRightPanel=findobj(validHandles(ii),'tag','RightPanel');
                    if~isempty(hRightPanel)
                        if strcmp(hRightPanel.Parent.Tag,'HSV')
                            handleH=findobj(hRightPanel,'tag','H');
                            handleS=findobj(hRightPanel,'tag','S');
                            handleV=findobj(hRightPanel,'tag','V');
                            layoutPosition=getappdata(hRightPanel,'layoutPosition');

                            set(handleH,'Position',layoutPosition{4});

                            set(handleS,'Position',layoutPosition{5});

                            set(handleV,'Position',layoutPosition{6});
                        else
                            histHandles=findobj(hRightPanel,'tag','SlidersContainer');
                            arrayfun(@(h)set(h,'Position',[0,0,1,1]),histHandles);
                        end

                        projHandles=findobj(hRightPanel,'tag','ColorProj','-or','tag','proj3dpanel');
                        arrayfun(@(h)set(h,'Visible','off'),projHandles);
                    end
                end
                self.updateClusterMask()
            else
                self.hPointCloudBackgroundSlider.Enabled=true;

                validHandles=self.FigureHandles(ishandle(self.FigureHandles));


                for ii=1:numel(validHandles)
                    hRightPanel=findobj(validHandles(ii),'tag','RightPanel');
                    if~isempty(hRightPanel)
                        if strcmp(hRightPanel.Parent.Tag,'HSV')
                            handleH=findobj(hRightPanel,'tag','H');
                            handleS=findobj(hRightPanel,'tag','S');
                            handleV=findobj(hRightPanel,'tag','V');
                            layoutPosition=getappdata(hRightPanel,'layoutPosition');

                            set(handleH,'Position',layoutPosition{1});

                            set(handleS,'Position',layoutPosition{2});

                            set(handleV,'Position',layoutPosition{3});
                        else
                            histHandles=findobj(hRightPanel,'tag','SlidersContainer');
                            arrayfun(@(h)set(h,'Position',[0,0.6,1,0.4]),histHandles);
                        end

                        if images.internal.app.colorThresholder.hasValidROIs(validHandles(ii),self.hPolyROIs)
                            projHandles=findobj(hRightPanel,'tag','ColorProj');
                        else
                            projHandles=findobj(hRightPanel,'tag','proj3dpanel');
                        end
                        set(projHandles,'Visible','on');
                    end
                end

                if images.internal.app.colorThresholder.hasValidROIs(self.hFigCurrent,self.hPolyROIs)
                    self.is3DView=false;
                else
                    self.is3DView=true;
                end

                self.updatePointCloud();
                self.applyClusterROIs();
            end


        end


        function updateMaskOverlayGraphics(self)

            hIm=findobj(self.hImagePanel,'type','image');
            if self.hShowBinaryButton.Value
                set(hIm,'CData',self.mask);
            else
                alphaData=ones(size(self.mask,1),size(self.mask,2));
                alphaData(~self.mask)=1-self.hMaskOpacitySlider.Value/100;
                set(hIm,'AlphaData',alphaData);
            end

        end


        function self=setTSButtonIconFromImage(self,ButtonObj,im)





            iconImage=im2uint8(im);
            icon=matlab.ui.internal.toolstrip.Icon(iconImage);
            ButtonObj.Icon=icon;

        end


        function manageControlsOnNewColorspace(self)



            self.hShowBinaryButton.Value=false;
            self.hInvertMaskButton.Value=false;
            self.hMaskOpacitySlider.Value=100;

        end


        function manageControlsOnImageLoad(self)






            self.binaryButonStateChangedListener.Enabled=false;
            self.invertMaskItemStateChangedListener.Enabled=false;
            self.sliderMovedListener.Enabled=false;

            self.manageControlsOnNewColorspace();



            drawnow;


            self.binaryButonStateChangedListener.Enabled=true;
            self.invertMaskItemStateChangedListener.Enabled=true;
            self.sliderMovedListener.Enabled=true;

        end


        function setControlsEnabled(self,TF)



            for i=1:length(self.hChangeUIComponentHandles)
                self.hChangeUIComponentHandles{i}.Enabled=TF;
            end

        end


    end


    methods(Access=public)

        function importImageData(self,im)

            if isfloat(im)
                [self,im]=normalizeDoubleDataDlg(self,im);
                if isempty(im)
                    return;
                end
            end



            if self.hasCurrentValidMontageInstance()
                self.hColorSpaceMontageView.delete();
            end

            self.initializeAppWithRGBImage(im);

            [m,n,~]=size(im);
            self.imSize=m*n;


            if self.imSize>1e6
                self.isLiveUpdate.Value=false;
            else
                self.isLiveUpdate.Value=true;
            end


            self.compareColorSpaces();

        end

        function TF=hasCurrentValidMontageInstance(self)
            TF=isa(self.hColorSpaceMontageView,'images.internal.app.colorThresholder.ColorSpaceMontageView')&&...
            isvalid(self.hColorSpaceMontageView);
        end

        function TF=validColorspaceFiguresInApp(self)

            TF=self.hToolGroup.isClientShowing('RGB')||...
            self.hToolGroup.isClientShowing('HSV')||...
            self.hToolGroup.isClientShowing('YCbCr')||...
            self.hToolGroup.isClientShowing('L*a*b*');

        end

        function TF=isCameraPreviewInApp(self)
            TF=self.hToolGroup.isClientShowing(getString(message('images:colorSegmentor:MainPreviewFigure')));
        end

        function toolGroup=getToolGroup(self)
            toolGroup=self.hToolGroup;
        end

        function tabGroup=getTabGroup(self)
            tabGroup=self.hTabGroup;
        end



        function user_canceled=showImportingDataWillCauseDataLossDlg(self,msg,msgTitle)

            user_canceled=false;

            if self.validColorspaceFiguresInApp()

                buttonName=questdlg(msg,msgTitle,...
                getString(message('images:commonUIString:yes')),...
                getString(message('images:commonUIString:cancel')),...
                getString(message('images:commonUIString:cancel')));

                if strcmp(buttonName,getString(message('images:commonUIString:yes')))




                    self.manageControlsOnImageLoad();
                    self.hColorSpacesButton.Enabled=false;

                    validFigHandles=ishandle(self.FigureHandles);
                    if ismember(getString(message('images:colorSegmentor:MainPreviewFigure')),get(self.FigureHandles(validFigHandles),'Name'))


                        validFigHandles(1)=0;
                        close(self.FigureHandles(validFigHandles));
                        self.FigureHandles=self.FigureHandles(1);
                    else
                        close(self.FigureHandles(validFigHandles));
                        self.FigureHandles=[];
                    end
                    if self.hasCurrentValidMontageInstance()
                        self.hColorSpaceMontageView.delete();
                    end
                else
                    user_canceled=true;
                end

            end
        end

    end

    methods(Access=private)


        function hFig=createColorspaceSegmentationView(self,im,csname,tMat,camPosition,camVector)





            self.ClientActionListener.Enabled=false;

            if isempty(im)
                if isempty(self.ImagePreviewDisplay)||~isvalid(self.ImagePreviewDisplay.Fig)
                    self.ImagePreviewDisplay=...
                    images.internal.app.colorThresholder.ImagePreview;
                    self.FigureHandles(end+1)=self.ImagePreviewDisplay.Fig;
                    self.hToolGroup.addFigure(self.ImagePreviewDisplay.Fig);
                end
                hFig=self.ImagePreviewDisplay.Fig;
            else

                tabName=self.getFigName(csname);

                hFig=figure('NumberTitle','off',...
                'Name',tabName,'Colormap',gray(2),...
                'IntegerHandle','off','Tag',csname);





                hFig.WindowKeyPressFcn=@(~,~)[];
                hFig.WindowButtonDownFcn=@(~,~)self.buttonClicked(true);
                hFig.WindowButtonUpFcn=@(~,~)self.buttonClicked(false);

                self.FigureHandles(end+1)=hFig;
                self.hToolGroup.addFigure(hFig);
            end



            self.hToolGroup.getFiguresDropTargetHandler.unregisterInterest(hFig);

            iptPointerManager(hFig);

            if~isempty(im)
                hLeftPanel=uipanel('Parent',hFig,'Position',[0,0,0.6,1],'BorderType','none','tag','LeftPanel');
                hRightPanel=uipanel('Parent',hFig,'Position',[0.6,0,0.4,1],'BorderType','none','tag','RightPanel');

                layoutInteractiveColorProjection(self,hRightPanel,im,csname,tMat);
                layoutScrollpanel(self,hLeftPanel);

                layoutInteractiveHistograms(self,hRightPanel,im,csname);

                histHandles=getappdata(hRightPanel,'HistPanelHandles');


                [m,n,~]=size(im);
                self.sliderMask=true([m,n]);
                self.clusterMask=true([m,n]);
                self.updateMask(im,histHandles{:});
                self.updateClusterMask();



                set(hFig,'HandleVisibility','callback');




                self.ClientActionListener.Enabled=true;

                self.hFigCurrent=hFig;

                self.getClusterProjection(camPosition,camVector)

                if self.hHidePointCloud.Value
                    self.hidePointCloud()
                end

            else


                set(hFig,'HandleVisibility','callback');




                self.ClientActionListener.Enabled=true;

                self.hFigCurrent=hFig;

            end

            hAx=findobj(self.hImagePanel,'type','axes');
            if isvalid(hAx)
                images.internal.utils.customAxesInteraction(hAx);
            end

        end

        function layoutScrollpanel(self,hLeftPanel)

            if isempty(self.hImagePanel)||~ishandle(self.hImagePanel)

                self.hImagePanel=uipanel('Parent',hLeftPanel,...
                'Units','normalized',...
                'Position',[0,0,1,1],...
                'Tag','ImagePanel',...
                'SizeChangedFcn',@(~,~)self.reactToAppResize());

                hAx=axes('Parent',self.hImagePanel,...
                'Units','pixels');




                warnState=warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
                imshow(self.imRGB,'Parent',hAx);
                warning(warnState);

                images.internal.utils.customAxesInteraction(hAx);


                set(hAx,'Visible','on');


                set(hAx,'Color',self.maskColor);


                set(hAx,'XTick',[],'YTick',[]);


                set(hAx,'XColor','none','YColor','none');

                uicontrol('Style','togglebutton','Parent',self.hImagePanel,'Units','Normalized','Position',[0.01,0.945,0.04,0.045],...
                'Tag','SelectButton','Callback',@(~,~)self.lassoRegion(),'CData',self.freeIcon,...
                'TooltipString',getString(message('images:colorSegmentor:addRegionTooltip')));

                self.hAxes=hAx;
            else



                set(self.hImagePanel,'Parent',hLeftPanel);
            end

        end

        function[hChan1Hist,hChan2Hist,hChan3Hist]=layoutInteractiveHistograms(self,hPanel,im,csname)

            import images.internal.app.colorThresholder.InteractiveHistogram;
            import images.internal.app.colorThresholder.InteractiveHistogramHue;

            margin=5;
            hFigFlowSliders=uiflowcontainer('v0',...
            'Parent',hPanel,...
            'FlowDirection','TopDown',...
            'Position',[0,0.6,1,0.4],...
            'Margin',margin,...
            'Tag','SlidersContainer');

            switch csname

            case 'RGB'
                hChan1Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,1),'ramp',{[0,0,0],[1,0,0]},'R');
                hChan2Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,2),'ramp',{[0,0,0],[0,1,0]},'G');
                hChan3Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,3),'ramp',{[0,0,0],[0,0,1]},'B');

            case 'HSV'
                ratios=[1,0.5,0.5];
                drawnow;drawnow;drawnow
                [hPanelTop,hPanelMiddle,hPanelBottom,layoutPosition]=images.internal.app.colorThresholder.createThreePanels(hPanel,ratios,margin);
                setappdata(hPanel,'layoutPosition',layoutPosition);
                hChan1Hist=InteractiveHistogramHue(hPanelTop,im(:,:,1));
                hChan2Hist=InteractiveHistogram(hPanelMiddle,im(:,:,2),'saturation');
                hChan3Hist=InteractiveHistogram(hPanelBottom,im(:,:,3),'BlackToWhite','V');

            case 'L*a*b*'
                hChan1Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,1),'LStar','L*');
                hChan2Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,2),'aStar');
                hChan3Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,3),'bStar');

            case 'YCbCr'
                hChan1Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,1),'BlackToWhite','Y');
                hChan2Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,2),'Cb');
                hChan3Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,3),'Cr');

            otherwise
                hChan1Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,1));
                hChan2Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,2));
                hChan3Hist=InteractiveHistogram(hFigFlowSliders,im(:,:,3));

            end

            addlistener(hChan1Hist,'currentSelection','PostSet',...
            @(~,~)updateClusterDuringSliderDrag(self,im,hChan1Hist,hChan2Hist,hChan3Hist));

            addlistener([hChan2Hist,hChan3Hist],'currentSelection','PostSet',...
            @(~,~)updateClusterDuringSliderDrag(self,im,hChan1Hist,hChan2Hist,hChan3Hist));

            histograms={hChan1Hist,hChan2Hist,hChan3Hist};

            setappdata(hPanel,'HistPanelHandles',histograms);
            setappdata(hPanel,'ColorspaceCData',im);

        end

        function resetSliders(self)


            self.clearFreehands()


            hRightPanel=findobj(self.hFigCurrent,'tag','RightPanel');
            histHandles=getappdata(hRightPanel,'HistPanelHandles');



            for ii=1:3
                histHandles{ii}.currentSelection=histHandles{ii}.histRange;
                histHandles{ii}.updateHistogram()
            end

            im=getappdata(hRightPanel,'ColorspaceCData');
            updateClusterAfterSliderDrag(self,[],[],im,histHandles{1:3});

        end

        function updateClusterDuringSliderDrag(self,im,hChan1Hist,hChan2Hist,hChan3Hist)






            if self.isLiveUpdate.Value
                self.updateCluster(im,hChan1Hist,hChan2Hist,hChan3Hist)
            elseif isempty(self.hSliderMovedListener)
                self.hSliderMovedListener=addlistener(self.hFigCurrent,'WindowMouseRelease',@(hObj,evt)self.updateClusterAfterSliderDrag(hObj,evt,im,hChan1Hist,hChan2Hist,hChan3Hist));
            end

        end

        function updateClusterAfterSliderDrag(self,~,~,im,hChan1Hist,hChan2Hist,hChan3Hist)


            delete(self.hSliderMovedListener);
            self.hSliderMovedListener=[];
            self.updateCluster(im,hChan1Hist,hChan2Hist,hChan3Hist)

        end

        function updateCluster(self,im,hChan1Hist,hChan2Hist,hChan3Hist)

            if~self.isFreehandApplied
                self.clearFreehands()
            end
            self.updateMask(im,hChan1Hist,hChan2Hist,hChan3Hist);
            if self.hHidePointCloud.Value
                return;
            end

            if self.is3DView
                self.hColorSpaceProjectionView.updatePointCloud(self.sliderMask);
            else
                self.updatePointCloud();
            end

        end

        function hColorProj=layoutInteractiveColorProjection(self,hPanel,im,csname,tMat)

            RGB=self.imRGB;

            m=size(RGB,1);
            n=size(RGB,2);


            im=reshape(im,[m*n,3]);
            RGB=reshape(RGB,[m*n,3]);

            im=double(im);


            switch(csname)
            case 'HSV'
                Xcoord=im(:,2).*im(:,3).*cos(2*pi*im(:,1));
                Ycoord=im(:,2).*im(:,3).*sin(2*pi*im(:,1));
                im(:,1)=Xcoord;
                im(:,2)=Ycoord;
            case{'L*a*b*','YCbCr'}
                temp=im(:,1);
                im(:,1)=im(:,2);
                im(:,2)=im(:,3);
                im(:,3)=temp;
            end





            shiftVec=mean(im,1);
            im=bsxfun(@minus,im,shiftVec);

            setappdata(hPanel,'ColorspaceCDataForCluster',im);
            setappdata(hPanel,'TransformationMat',tMat);
            setappdata(hPanel,'ShiftVector',shiftVec);

            tMat=tMat(1:2,:);
            im=[im,ones(size(im,1),1)]';
            colorDataPCA=(tMat*im)';

            setappdata(hPanel,'TransformedCDataForCluster',colorDataPCA);

            hColorProj=uipanel('Parent',hPanel,'BorderType','none','Units','Normalized','Position',[0,0,1,0.6],'Tag','ColorProj');
            set(hColorProj,'Visible','off','BackgroundColor',self.pointCloudColor);
            hAx=axes('Parent',hColorProj);
            scatter(hAx,colorDataPCA(:,1),colorDataPCA(:,2),6,im2double(RGB),'.','Tag','ScatterPlot');
            set(hAx,'XTick',[],'YTick',[],'ZTick',[]);
            set(hAx,'Color',self.pointCloudColor,'Box','off','Units','normalized','Position',[0.01,0.01,0.98,0.98]);
            set(hAx,'XColor',self.pointCloudColor,'YColor',self.pointCloudColor,'ZColor',self.pointCloudColor);
            set(hAx,'Visible','on');

            uicontrol('Style','togglebutton','Parent',hColorProj,'Units','Normalized','Position',[0.01,0.915,0.06,0.075],...
            'Tag','PolyButton','Callback',@(hobj,evt)self.polyRegionForClusters(hobj,evt),'CData',self.polyIcon,...
            'TooltipString',getString(message('images:colorSegmentor:polygonButtonTooltip')));

            uicontrol('Style','pushbutton','Parent',hColorProj,'Units','Normalized','Position',[0.07,0.915,0.06,0.075],...
            'Tag','RotateButton','Callback',@(~,~)self.show3DViewState(),'CData',self.rotateIcon,...
            'TooltipString',getString(message('images:colorSegmentor:rotateButtonTooltip')));

            self.showStatusBar();

        end


    end


    methods(Access=private)

        function loadAppIcons(self)

            self.LoadImageIcon=matlab.ui.internal.toolstrip.Icon.IMPORT_24;
            self.newColorspaceIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/NewColorSpace_24.png'));
            self.hidePointCloudIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/HidePointCloud_16.png'));
            self.liveUpdateIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/LiveUpdate_24.png'));
            self.invertMaskIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/InvertMask_24px.png'));
            self.resetButtonIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/Reset_24.png'));
            self.showBinaryIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/ShowBinary_24px.png'));
            self.createMaskIcon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/CreateMask_24px.png'));
            self.freeIcon=setUIControlIcon(fullfile(matlabroot,'/toolbox/images/icons/DrawFreehand_16.png'));
            self.polyIcon=setUIControlIcon(fullfile(matlabroot,'/toolbox/images/icons/DrawPolygon_16.png'));
            self.rotateIcon=setUIControlIcon(fullfile(matlabroot,'/toolbox/images/icons/Rotate3D_16.png'));

            mousePointer=load(fullfile(matlabroot,'/toolbox/images/icons/rotatePointer.mat'));
            self.rotatePointer=mousePointer.rotatePointer;

        end

        function layoutLoadImageSection(self)


            loadImageButton=matlab.ui.internal.toolstrip.SplitButton(getString(message('images:colorSegmentor:loadImageSplitButtonTitle')),...
            self.LoadImageIcon);
            loadImageButton.Tag='btnLoadImage';
            loadImageButton.Description=getString(message('images:colorSegmentor:loadImageTooltip'));


            sub_popup=matlab.ui.internal.toolstrip.PopupList();

            sub_item1=matlab.ui.internal.toolstrip.ListItem(getString(message('images:colorSegmentor:loadImageFromFile')));
            sub_item1.Icon=matlab.ui.internal.toolstrip.Icon.IMPORT_16;
            sub_item1.ShowDescription=false;
            addlistener(sub_item1,'ItemPushed',@self.loadImageFromFile);

            sub_item2=matlab.ui.internal.toolstrip.ListItem(getString(message('images:colorSegmentor:loadImageFromWorkspace')));
            sub_item2.Icon=matlab.ui.internal.toolstrip.Icon.IMPORT_16;
            sub_item2.ShowDescription=false;
            addlistener(sub_item2,'ItemPushed',@self.loadImageFromWorkspace);

            sub_item3=matlab.ui.internal.toolstrip.ListItem(getString(message('images:colorSegmentor:loadImageFromCamera')));
            sub_item3.Icon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(matlabroot,'toolbox','images','icons','color_thresholder_load_camera_16.png'));
            sub_item3.ShowDescription=false;
            addlistener(sub_item3,'ItemPushed',@self.loadImageFromCamera);

            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);
            sub_popup.add(sub_item3);

            loadImageButton.Popup=sub_popup;
            loadImageButton.Popup.Tag='Load Image Popup';
            addlistener(loadImageButton,'ButtonPushed',@self.loadImageFromFile);

            c=self.LoadImageSection.addColumn();
            c.add(loadImageButton);

            self.lassoSensitiveComponentHandles{end+1}=loadImageButton;

        end

        function layoutColorSpacesSection(self)

            self.hColorSpacesButton=matlab.ui.internal.toolstrip.Button(getString(message('images:colorSegmentor:newColorspace')),...
            self.newColorspaceIcon);
            self.hColorSpacesButton.Tag='btnChooseColorSpace';
            self.hColorSpacesButton.Description=getString(message('images:colorSegmentor:addNewColorspaceTooltip'));
            addlistener(self.hColorSpacesButton,'ButtonPushed',@(~,~)self.compareColorSpaces());

            c=self.ColorSpacesSection.addColumn();
            c.add(self.hColorSpacesButton);

            self.lassoSensitiveComponentHandles{end+1}=self.hColorSpacesButton;

        end

        function layoutChooseProjectionSection(self)

            self.hPointCloudBackgroundSlider=matlab.ui.internal.toolstrip.Slider([0,100],6);
            self.hPointCloudBackgroundSlider.Ticks=0;
            self.hPointCloudBackgroundSlider.Description=getString(message('images:colorSegmentor:pointCloudSliderTooltip'));
            self.pointCloudSliderMovedListener=addlistener(self.hPointCloudBackgroundSlider,'ValueChanged',@(hobj,evt)pointCloudSliderMoved(self,hobj,evt));
            self.hPointCloudBackgroundSlider.Tag='sliderPointCloudBackground';

            pointCloudColorLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:colorSegmentor:pointCloudSlider')));
            pointCloudColorLabel.Tag='labelPointCloudOpacity';

            self.hHidePointCloud=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:colorSegmentor:hidePointCloud')),self.hidePointCloudIcon);
            self.hHidePointCloud.Tag='btnHidePointCloud';
            self.hHidePointCloud.Description=getString(message('images:colorSegmentor:hidePointCloudTooltip'));
            addlistener(self.hHidePointCloud,'ValueChanged',@(~,~)self.hidePointCloud());

            c=self.ChooseProjectionSection.addColumn('HorizontalAlignment','center','Width',120);
            c.add(pointCloudColorLabel);
            c.add(self.hPointCloudBackgroundSlider);
            c2=self.ChooseProjectionSection.addColumn();
            c2.add(self.hHidePointCloud);

            self.hChangeUIComponentHandles{end+1}=self.hPointCloudBackgroundSlider;
            self.lassoSensitiveComponentHandles{end+1}=self.hHidePointCloud;
            self.hChangeUIComponentHandles{end+1}=self.hHidePointCloud;

        end

        function layoutManualSelectionSection(self)

            self.isLiveUpdate=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:colorSegmentor:liveUpdate')),self.liveUpdateIcon);
            self.isLiveUpdate.Description=getString(message('images:colorSegmentor:liveUpdateTooltip'));
            self.isLiveUpdate.Tag='btnLiveUpdate';

            c=self.ManualSelectionSection.addColumn();
            c.add(self.isLiveUpdate);

            self.hChangeUIComponentHandles{end+1}=self.isLiveUpdate;

        end

        function layoutThresholdControlsSection(self)

            self.hInvertMaskButton=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:colorSegmentor:invertMask')),...
            self.invertMaskIcon);
            self.hInvertMaskButton.Tag='btnInvertMask';
            self.hInvertMaskButton.Description=getString(message('images:colorSegmentor:invertMaskTooltip'));
            self.invertMaskItemStateChangedListener=addlistener(self.hInvertMaskButton,'ValueChanged',@self.invertMaskButtonPress);


            resetButton=matlab.ui.internal.toolstrip.Button(getString(message('images:colorSegmentor:resetButton')),self.resetButtonIcon);
            resetButton.Tag='btnResetSliders';
            resetButton.Description=getString(message('images:colorSegmentor:resetButtonTooltip'));
            addlistener(resetButton,'ButtonPushed',@(~,~)self.resetSliders());

            c=self.ThresholdControlsSection.addColumn();
            c.add(self.hInvertMaskButton);
            c2=self.ThresholdControlsSection.addColumn();
            c2.add(resetButton);

            self.hChangeUIComponentHandles{end+1}=self.hInvertMaskButton;
            self.hChangeUIComponentHandles{end+1}=resetButton;
            self.lassoSensitiveComponentHandles{end+1}=resetButton;

        end

        function layoutViewSegmentationSection(self)

            self.hShowBinaryButton=matlab.ui.internal.toolstrip.ToggleButton(getString(message('images:colorSegmentor:showBinary')),...
            self.showBinaryIcon);
            self.binaryButonStateChangedListener=addlistener(self.hShowBinaryButton,'ValueChanged',@self.showBinaryPress);
            self.hChangeUIComponentHandles{end+1}=self.hShowBinaryButton;
            self.hShowBinaryButton.Tag='btnShowBinary';
            self.hShowBinaryButton.Description=getString(message('images:colorSegmentor:viewBinaryTooltip'));

            self.hMaskOpacitySlider=matlab.ui.internal.toolstrip.Slider([0,100],100);
            self.hMaskOpacitySlider.Ticks=0;
            self.sliderMovedListener=addlistener(self.hMaskOpacitySlider,'ValueChanged',@self.opacitySliderMoved);
            self.hChangeUIComponentHandles{end+1}=self.hMaskOpacitySlider;
            self.hMaskOpacitySlider.Tag='sliderMaskOpacity';
            self.hMaskOpacitySlider.Description=getString(message('images:colorSegmentor:sliderTooltip'));

            overlayColorLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:colorSegmentor:backgroundColor')));
            overlayColorLabel.Tag='labelOverlayColor';
            overlayOpacityLabel=matlab.ui.internal.toolstrip.Label(getString(message('images:colorSegmentor:backgroundOpacity')));
            overlayOpacityLabel.Tag='labelOverlayOpacity';



            self.hOverlayColorButton=matlab.ui.internal.toolstrip.Button();
            self.setTSButtonIconFromImage(self.hOverlayColorButton,zeros(16,16,'uint8'));
            addlistener(self.hOverlayColorButton,'ButtonPushed',@self.chooseOverlayColor);
            self.hChangeUIComponentHandles{end+1}=self.hOverlayColorButton;
            self.hOverlayColorButton.Tag='btnOverlayColor';
            self.hOverlayColorButton.Description=getString(message('images:colorSegmentor:backgroundColorTooltip'));

            c=self.ViewSegmentationSection.addColumn('HorizontalAlignment','right');
            c.add(overlayColorLabel);
            c.add(overlayOpacityLabel);
            c2=self.ViewSegmentationSection.addColumn('Width',80);
            c2.add(self.hOverlayColorButton);
            c2.add(self.hMaskOpacitySlider);
            c3=self.ViewSegmentationSection.addColumn();
            c3.add(self.hShowBinaryButton);

        end

        function layoutExportSection(self)


            exportButton=matlab.ui.internal.toolstrip.SplitButton(getString(message('images:colorSegmentor:export')),...
            self.createMaskIcon);
            exportButton.Tag='btnExport';
            exportButton.Description=getString(message('images:colorSegmentor:exportButtonTooltip'));


            sub_popup=matlab.ui.internal.toolstrip.PopupList();

            sub_item1=matlab.ui.internal.toolstrip.ListItem(getString(message('images:colorSegmentor:exportImages')));
            sub_item1.Icon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/CreateMask_16px.png'));
            sub_item1.ShowDescription=false;
            addlistener(sub_item1,'ItemPushed',@(~,~)self.exportDataToWorkspace);

            sub_item2=matlab.ui.internal.toolstrip.ListItem(getString(message('images:colorSegmentor:exportFunction')));
            sub_item2.Icon=matlab.ui.internal.toolstrip.Icon(...
            fullfile(matlabroot,'/toolbox/images/icons/GenerateMATLABScript_Icon_16px.png'));
            sub_item2.ShowDescription=false;
            addlistener(sub_item2,'ItemPushed',@(~,~)images.internal.app.colorThresholder.generateColorSegmentationCode(self));

            sub_popup.add(sub_item1);
            sub_popup.add(sub_item2);

            exportButton.Popup=sub_popup;
            exportButton.Popup.Tag='Export Popup';
            addlistener(exportButton,'ButtonPushed',@(~,~)self.exportDataToWorkspace());


            c=self.ExportSection.addColumn();
            c.add(exportButton);

            self.hChangeUIComponentHandles{end+1}=exportButton;
            self.lassoSensitiveComponentHandles{end+1}=exportButton;

        end

    end


    methods(Access=private)


        function lassoRegion(self)



            if~isempty(self.freehandManager)
                return
            end


            if~isempty(self.polyManager)
                self.disablePolyRegion()
                self.polyManager=[];
                hPanel=findobj(self.hFigCurrent,'Tag','RightPanel');
                PolyButton=findobj(hPanel,'Tag','PolyButton');
                PolyButton.Value=0;
            end

            SelectButton=findobj(self.hImagePanel,'Tag','SelectButton');
            SelectButton.Value=1;



            self.preLassoToolstripState=self.getStateOfLassoSensitiveTools();
            self.disableLassoSensitiveTools()

            hAx=findobj(self.hImagePanel,'type','axes');
            self.freehandManager=iptui.internal.ImfreehandModeContainer(hAx);

            self.hFreehandListener=addlistener(self.freehandManager,'hROI','PostSet',...
            @(obj,evt)self.freehandedAdded(obj,evt));
            addlistener(self.freehandManager,'DrawingAborted',@(~,~)self.freehandDrawingAborted());

            self.freehandManager.enableInteractivePlacement();
        end

        function polyRegionForClusters(self,varargin)




            if~isempty(self.polyManager)
                return;
            end


            if~isempty(self.freehandManager)
                self.resetLassoTool()
                self.freehandManager=[];
                SelectButton=findobj(self.hImagePanel,'Tag','SelectButton');
                SelectButton.Value=0;
            end

            varargin{2}.Source.Value=1;



            self.preLassoToolstripState=self.getStateOfLassoSensitiveTools();
            self.disableLassoSensitiveTools()
            self.clearStatusBar();


            hScat=findobj(self.hFigCurrent,'Type','Scatter','Tag','ScatterPlot');
            hScat.Parent.XLimMode='Manual';
            hScat.Parent.YLimMode='Manual';
            self.polyManager=iptui.internal.ImpolyModeContainer(hScat.Parent);
            self.hPolyListener=addlistener(self.polyManager,'hROI','PostSet',@(obj,evt)self.polygonAddedForClusters(obj,evt));

            addlistener(self.polyManager,'DrawingAborted',@(~,~)self.polygonDrawingAborted());




            hAx=findobj(self.hColorSpaceProjectionView.hPanels,'type','axes');
            iptSetPointerBehavior(hAx,[]);

            self.polyManager.enableInteractivePlacement();

        end


        function freehandedAdded(self,~,~)


            SelectButton=findobj(self.hImagePanel,'Tag','SelectButton');
            SelectButton.Value=0;

            self.resetLassoTool()



            addlistener(self.freehandManager.hROI,'MovingROI',@(~,~)self.updateThresholdDuringROIDrag());

            hFree=self.freehandManager.hROI;
            self.freehandManager=[];

            self.addFreehandROIHandleToCollection(hFree)
            addlistener(hFree,'DeletingROI',@(obj,evt)newFreehandDeleteFcn(self,obj));

            self.applyROIs()

        end

        function polygonDrawingAborted(self)



            if isvalid(self)&&isvalid(self.hFigCurrent)
                hPanel=findobj(self.hFigCurrent,'Tag','RightPanel');
                PolyButton=findobj(hPanel,'Tag','PolyButton');
                PolyButton.Value=0;

                self.disablePolyRegion();
                self.polyManager=[];
            end
        end

        function freehandDrawingAborted(self)



            if isvalid(self)&&isvalid(self.hFigCurrent)

                self.resetLassoTool()
                self.freehandManager=[];
                SelectButton=findobj(self.hImagePanel,'Tag','SelectButton');
                SelectButton.Value=0;

            end
        end


        function polygonAddedForClusters(self,~,~)



            hPanel=findobj(self.hFigCurrent,'Tag','RightPanel');
            PolyButton=findobj(hPanel,'Tag','PolyButton');
            PolyButton.Value=0;

            self.disablePolyRegion()



            addlistener(self.polyManager.hROI,'MovingROI',@(~,~)self.updateClusterDuringROIDrag());

            hFree=self.polyManager.hROI;
            self.polyManager=[];

            if size(hFree.Position,1)>1
                self.addPolyROIHandleToCollection(hFree)
                addlistener(hFree,'DeletingROI',@(obj,evt)newPolyDeleteFcn(self,obj));
            else
                hFree.delete()
            end

            self.applyClusterROIs();

        end

        function updateClusterDuringROIDrag(self)



            if self.isLiveUpdate.Value||~self.isFigClicked
                self.applyClusterROIs()
            elseif isempty(self.hPolyMovedListener)


                self.hPolyMovedListener=addlistener(self.hFigCurrent,'WindowMouseRelease',@(~,~)self.updateClusterAfterROIDrag());
            end

        end

        function updateClusterAfterROIDrag(self)


            delete(self.hPolyMovedListener);
            self.hPolyMovedListener=[];
            self.applyClusterROIs();

        end

        function updateThresholdDuringROIDrag(self)



            if self.isLiveUpdate.Value
                self.applyROIs()
            elseif isempty(self.hFreehandMovedListener)


                self.hFreehandMovedListener=addlistener(self.hFigCurrent,'WindowMouseRelease',@(~,~)self.updateThresholdAfterROIDrag());
            end

        end

        function updateThresholdAfterROIDrag(self)


            delete(self.hFreehandMovedListener);
            self.hFreehandMovedListener=[];
            self.applyROIs();

        end


        function disablePolyRegion(self)

            self.enableLassoSensitiveTools(self.preLassoToolstripState)
            delete(self.hPolyListener);
            self.hPolyListener=[];

        end

        function resetLassoTool(self)

            self.enableLassoSensitiveTools(self.preLassoToolstripState)
            self.hFreehandListener=[];

        end


        function newFreehandDeleteFcn(self,obj)

            if~isvalid(self)

                return
            end



            figuresWithROIs=[self.hFreehandROIs{:,1}];
            idx=find(figuresWithROIs==self.hFigCurrent,1);
            if isempty(idx)
                return
            end


            if~isvalid(self.hFigCurrent)||strcmpi(self.hFigCurrent.Name,getString(message('images:colorSegmentor:MainPreviewFigure')))
                self.hFreehandROIs(idx,:)=[];
                return
            end
            currentROIs=self.hFreehandROIs{idx,2};
            currentROIs(currentROIs==obj)=[];
            obj.delete();
            self.hFreehandROIs{idx,2}=currentROIs;





            if self.isManualDelete
                self.applyROIs()
            end

        end


        function newPolyDeleteFcn(self,obj)


            if~isvalid(self)

                return
            end



            figuresWithROIs=[self.hPolyROIs{:,1}];
            idx=find(figuresWithROIs==self.hFigCurrent,1);
            if isempty(idx)
                return
            end


            if~isvalid(self.hFigCurrent)||strcmpi(self.hFigCurrent.Name,getString(message('images:colorSegmentor:MainPreviewFigure')))
                self.hPolyROIs(idx,:)=[];
                return
            end
            currentROIs=self.hPolyROIs{idx,2};


            idxArray=arrayfun(@(h)~isvalid(h),currentROIs);
            currentROIs(idxArray)=[];

            currentROIs(currentROIs==obj)=[];
            obj.delete();

            self.hPolyROIs{idx,2}=currentROIs;

            if isvalid(self.hFigCurrent)&&~self.isProjectionApplied
                self.applyClusterROIs()
            end

        end


        function addPolyROIHandleToCollection(self,newROIHandle)


            if isempty(self.hPolyROIs)
                self.hPolyROIs={self.hFigCurrent,newROIHandle};
                return
            end

            idx=images.internal.app.colorThresholder.findFigureIndexInCollection(self.hFigCurrent,self.hPolyROIs);
            if isempty(idx)
                self.hPolyROIs(end+1,:)={self.hFigCurrent,newROIHandle};
            else
                self.hPolyROIs{idx,2}=[self.hPolyROIs{idx,2},newROIHandle];
            end

        end


        function addFreehandROIHandleToCollection(self,newROIHandle)


            if isempty(self.hFreehandROIs)
                self.hFreehandROIs={self.hFigCurrent,newROIHandle};
                return
            end

            idx=images.internal.app.colorThresholder.findFigureIndexInCollection(self.hFigCurrent,self.hFreehandROIs);
            if isempty(idx)
                self.hFreehandROIs(end+1,:)={self.hFigCurrent,newROIHandle};
            else
                self.hFreehandROIs{idx,2}=[self.hFreehandROIs{idx,2},newROIHandle];
            end

        end


        function applyROIs(self)

            self.isFreehandApplied=true;


            hRightPanel=findobj(self.hFigCurrent,'tag','RightPanel');
            histHandles=getappdata(hRightPanel,'HistPanelHandles');

            if~images.internal.app.colorThresholder.hasValidROIs(self.hFigCurrent,self.hFreehandROIs)
                self.resetSliders()
                self.isFreehandApplied=false;
                return
            end


            cData=getappdata(hRightPanel,'ColorspaceCData');
            [lim1,lim2,lim3]=colorStats(self,cData);

            if(isempty(lim1)||isempty(lim2)||isempty(lim3))
                self.isFreehandApplied=false;
                return
            end


            histHandles{1}.currentSelection=lim1;
            histHandles{1}.updateHistogram();
            histHandles{2}.currentSelection=lim2;
            histHandles{2}.updateHistogram();
            histHandles{3}.currentSelection=lim3;
            histHandles{3}.updateHistogram();


            if~self.isLiveUpdate.Value
                delete(self.hSliderMovedListener);
                self.hSliderMovedListener=[];
                self.updateMask(cData,histHandles{:})
            end

            if~self.hHidePointCloud.Value
                self.applyClusterROIs();
            end

            self.isFreehandApplied=false;

        end


        function applyClusterROIs(self)




            hRightPanel=findobj(self.hFigCurrent,'tag','RightPanel');
            im=getappdata(hRightPanel,'TransformedCDataForCluster');


            if~images.internal.app.colorThresholder.hasValidROIs(self.hFigCurrent,self.hPolyROIs)
                self.updateClusterMask();
                if self.is3DView
                    self.hColorSpaceProjectionView.updatePointCloud(self.sliderMask);
                else
                    self.updatePointCloud();
                end
                return
            end


            hROIs=images.internal.app.colorThresholder.findROIs(self.hFigCurrent,self.hPolyROIs);

            imgSize=size(self.imRGB);
            bw=false(imgSize(1:2));


            for p=1:numel(hROIs)

                if isvalid(hROIs(p))
                    hPoints=hROIs(p).Position;

                    if size(hPoints,1)==1

                        delete(hROIs(p));
                        return
                    end

                    in=images.internal.inpoly(im(:,1),im(:,2),hPoints(:,1),hPoints(:,2));
                    in=reshape(in,size(bw));
                    bw=bw|in;
                end
            end


            self.updateClusterMask(bw);
            self.updatePointCloud();

        end


        function[lim1,lim2,lim3]=colorStats(self,cData)



            hROIs=images.internal.app.colorThresholder.findROIs(self.hFigCurrent,self.hFreehandROIs);

            imgSize=size(cData);
            bw=false(imgSize(1:2));

            for p=1:numel(hROIs)
                if isvalid(hROIs(p))
                    bw=bw|hROIs(p).createMask(cData);
                end
            end


            samplesInROI=samplesUnderMask(cData,bw);

            lim1=computeHLim(samplesInROI(:,1));
            lim2=[min(samplesInROI(:,2)),max(samplesInROI(:,2))];
            lim3=[min(samplesInROI(:,3)),max(samplesInROI(:,3))];

        end


        function hideOtherROIs(self)



            if~isempty(self.hFreehandROIs)
                figuresWithROIs=[self.hFreehandROIs{:,1}];
                idx=figuresWithROIs==self.hFigCurrent;
                hROIs=self.hFreehandROIs(~idx,2);
                for p=1:numel(hROIs)
                    tmp=hROIs{p};
                    for q=1:numel(tmp)
                        if isvalid(tmp(q))
                            set(tmp(q),'Visible','off')
                            set(tmp(q),'FaceSelectable',false)
                        end
                    end
                end
                hROIs=self.hFreehandROIs(idx,2);
                for p=1:numel(hROIs)
                    tmp=hROIs{p};
                    for q=1:numel(tmp)
                        if isvalid(tmp(q))
                            set(tmp(q),'Visible','on')
                            set(tmp(q),'FaceSelectable',false)
                        end
                    end
                end
            end

        end


        function stateVec=getStateOfLassoSensitiveTools(self)
            vecLength=numel(self.lassoSensitiveComponentHandles);
            stateVec=false(1,vecLength);

            for idx=1:vecLength
                stateVec(idx)=self.lassoSensitiveComponentHandles{idx}.Enabled;
            end
        end


        function disableLassoSensitiveTools(self)
            vecLength=numel(self.lassoSensitiveComponentHandles);

            for idx=1:vecLength
                self.lassoSensitiveComponentHandles{idx}.Enabled=false;
            end
        end


        function enableLassoSensitiveTools(self,stateVec)
            vecLength=numel(self.lassoSensitiveComponentHandles);

            for idx=1:vecLength
                self.lassoSensitiveComponentHandles{idx}.Enabled=stateVec(idx);
            end
        end
    end


    methods(Access=private)

        function loadImageFromFile(self,varargin)

            user_canceled_import=...
            self.showImportingDataWillCauseDataLossDlg(...
            getString(message('images:colorSegmentor:loadingNewImageMessage')),...
            getString(message('images:colorSegmentor:loadingNewImageTitle')));
            if~user_canceled_import


                if isCameraPreviewInApp(self)

                    self.ImageCaptureTab.closePreviewWindowCallback;
                end

                filename=imgetfile();
                if~isempty(filename)

                    im=imread(filename);
                    if~images.internal.app.colorThresholder.ColorSegmentationTool.isValidRGBImage(im)
                        hdlg=errordlg(getString(message('images:colorSegmentor:nonTruecolorErrorDlgText')),...
                        getString(message('images:colorSegmentor:nonTruecolorErrorDlgTitle')),'modal');



                        uiwait(hdlg);



drawnow
                        self.loadImageFromFile();
                        return;
                    end

                    self.importImageData(im);

                end
            end
        end

        function loadImageFromWorkspace(self,varargin)

            user_canceled_import=...
            self.showImportingDataWillCauseDataLossDlg(...
            getString(message('images:colorSegmentor:loadingNewImageMessage')),...
            getString(message('images:colorSegmentor:loadingNewImageTitle')));

            if~user_canceled_import


                if isCameraPreviewInApp(self)

                    self.ImageCaptureTab.closePreviewWindowCallback;
                end

                [im,~,~,~,user_canceled_dlg]=iptui.internal.imgetvar([],true);
                if~user_canceled_dlg
                    self.importImageData(im);
                end

            end

        end

        function loadImageFromCamera(self,varargin)

            if isCameraPreviewInApp(self)
                existingTabs=self.hToolGroup.TabNames;



                if~any(strcmp(existingTabs,getString(message('images:colorSegmentor:ImageCaptureTabName'))))

                    add(self.hTabGroup,getToolTab(self.ImageCaptureTab),2);
                end


                self.createColorspaceSegmentationView([],getString(message('images:colorSegmentor:MainPreviewFigure')));

                self.hTabGroup.SelectedTab=getToolTab(self.ImageCaptureTab);


                self.hFigCurrent=self.FigureHandles(1);

                return;
            end

            user_canceled_import=...
            self.showImportingDataWillCauseDataLossDlg(...
            getString(message('images:colorSegmentor:takingNewSnapshotMessage')),...
            getString(message('images:colorSegmentor:takeNewSnapshotTitle')));

            if~user_canceled_import
                existingTabs=self.hToolGroup.TabNames;



                if~any(strcmp(existingTabs,getString(message('images:colorSegmentor:ImageCaptureTabName'))))

                    self.ImageCaptureTab=images.internal.app.colorThresholder.ImageCaptureTab(self);
                    if(~self.ImageCaptureTab.LoadTab)
                        self.ImageCaptureTab=[];
                        return;
                    end

                    add(self.hTabGroup,getToolTab(self.ImageCaptureTab),2);
                end


                self.createColorspaceSegmentationView([],getString(message('images:colorSegmentor:MainPreviewFigure')));


                self.ImageCaptureTab.createDevice;

                self.hTabGroup.SelectedTab=getToolTab(self.ImageCaptureTab);


                self.ImagePreviewDisplay.makeFigureVisible();
            end
        end

        function compareColorSpaces(self)


            self.setControlsEnabled(false);
            self.hColorSpacesButton.Enabled=false;


            self.hPointCloudBackgroundSlider.Enabled=true;


            if self.hasCurrentValidMontageInstance()
                self.hColorSpaceMontageView.bringToFocusInSpecifiedPosition();
            else
                self.hColorSpaceMontageView=images.internal.app.colorThresholder.ColorSpaceMontageView(self.hToolGroup,self.imRGB,self.pointCloudColor,self.rotatePointer);




                self.colorspaceSelectedListener=event.proplistener(self.hColorSpaceMontageView,...
                self.hColorSpaceMontageView.findprop('SelectedColorSpace'),...
                'PostSet',@(hobj,evt)self.colorSpaceSelectedCallback(evt));
            end

        end

        function getClusterProjection(self,camPosition,camVector)


            csname=self.hFigCurrent.Tag;
            hPanel=findobj(self.hFigCurrent,'tag','RightPanel');
            isHidden=self.hHidePointCloud.Value;

            hProjectionView=images.internal.app.colorThresholder.ColorSpaceProjectionView(hPanel,self.hFigCurrent,self.imRGB,csname,camPosition,camVector,self.pointCloudColor,isHidden);

            uicontrol('Style','togglebutton','Parent',hProjectionView.hPanels,'Units','Normalized','Position',[0.01,0.915,0.06,0.075],...
            'Tag','ProjectButton','Callback',@(hobj,evt)self.applyTransformation(hobj,evt),'CData',self.polyIcon,...
            'TooltipString',getString(message('images:colorSegmentor:polygonButtonTooltip')));

            setappdata(hPanel,'ProjectionView',hProjectionView);
            self.hColorSpaceProjectionView=hProjectionView;


            hAx=findobj(hProjectionView.hPanels,'type','axes');

            iptSetPointerBehavior(hAx,@(hObj,evt)set(hObj,'Pointer','custom','PointerShapeCData',self.rotatePointer));

        end

        function changeViewState(self)


            hPanel=findobj(self.hFigCurrent,'Tag','ColorProj');
            if strcmp(get(hPanel,'Visible'),'off')
                set(hPanel,'Visible','on')
            else
                set(hPanel,'Visible','off')
            end


            self.hColorSpaceProjectionView.view3DPanel()

        end

        function colorSpaceSelectedCallback(self,evt)


            selectedColorSpace=evt.AffectedObject.SelectedColorSpace;
            tMat=evt.AffectedObject.tMat;
            camPosition=evt.AffectedObject.camPosition;
            camVector=evt.AffectedObject.camVector;

            self.is3DView=true;

            selectedColorspaceData=self.computeColorspaceRepresentation(selectedColorSpace);
            self.createColorspaceSegmentationView(selectedColorspaceData,selectedColorSpace,tMat,camPosition,camVector);


            self.setControlsEnabled(true);
            self.hColorSpacesButton.Enabled=true;
            self.hPointCloudBackgroundSlider.Enabled=~self.hHidePointCloud.Value;


            self.hideOtherROIs()

        end

        function invertMaskButtonPress(self,~,~)

            self.mask=~self.mask;


            self.updateMaskOverlayGraphics();

        end

        function showBinaryPress(self,hobj,~)

            hIm=findobj(self.hImagePanel,'type','image');
            if hobj.Value
                set(hIm,'AlphaData',1);
                self.updateMaskOverlayGraphics();
                self.hMaskOpacitySlider.Enabled=false;
            else
                set(hIm,'CData',self.imRGB);
                self.updateMaskOverlayGraphics();
                self.hMaskOpacitySlider.Enabled=true;
            end

        end

        function chooseOverlayColor(self,~,~)

            rgbColor=uisetcolor(getString(message('images:colorSegmentor:selectBackgroundColor')));

            colorSelectionCanceled=isequal(rgbColor,0);
            if~colorSelectionCanceled
                iconImage=zeros(16,16,3);
                iconImage(:,:,1)=rgbColor(1);
                iconImage(:,:,2)=rgbColor(2);
                iconImage(:,:,3)=rgbColor(3);
                iconImage=im2uint8(iconImage);

                self.setTSButtonIconFromImage(self.hOverlayColorButton,iconImage);


                set(findobj(self.hImagePanel,'type','axes'),'Color',rgbColor);
                self.maskColor=rgbColor;

            end

        end

        function pointCloudSliderMoved(self,~,~)

            self.pointCloudColor=1-repmat(self.hPointCloudBackgroundSlider.Value,1,3)/100;
            validHandles=self.FigureHandles(ishandle(self.FigureHandles));
            for ii=1:numel(validHandles)

                scatterPlots=findall(validHandles(ii),'Type','Scatter');
                arrayfun(@(h)set(h.Parent,'Color',self.pointCloudColor),scatterPlots);

                projHandles=findobj(validHandles(ii),'tag','ColorProj','-or','tag','proj3dpanel');
                arrayfun(@(h)set(h,'BackgroundColor',self.pointCloudColor),projHandles);
            end


            if self.hasCurrentValidMontageInstance
                self.hColorSpaceMontageView.updateScatterBackground(self.pointCloudColor)
            end

        end

        function opacitySliderMoved(self,varargin)
            self.updateMaskOverlayGraphics();
        end


        function exportDataToWorkspace(self)

            maskedRGBImage=self.imRGB;


            maskedRGBImage(repmat(~self.mask,[1,1,3]))=0;

            export2wsdlg({getString(message('images:colorSegmentor:binaryMask')),...
            getString(message('images:colorSegmentor:maskedRGBImage')),...
            getString(message('images:colorSegmentor:inputRGBImage'))},...
            {'BW','maskedRGBImage','inputImage'},{self.mask,maskedRGBImage,self.imRGB});

        end

        function reactToAppResize(self)
            if~isempty(self.hImagePanel)&&isvalid(self.hImagePanel)

                panelUnits=self.hImagePanel.Units;
                self.hImagePanel.Units='pixels';

                axToolbarHeight=20;
                border=10;
                panelSize=self.hImagePanel.Position([3,4]);

                axPos=[border,border,panelSize(1)-border,panelSize(2)-axToolbarHeight-border];
                self.hAxes.Position=axPos;

                self.hImagePanel.Units=panelUnits;
            end
        end

    end


    methods(Access=private)

        function disableInteractiveTiling(self)


            g=self.hToolGroup.Peer.getWrappedComponent;
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.PERMIT_USER_TILE,false);

        end


        function removeViewTab(self)

            group=self.hToolGroup.Peer.getWrappedComponent;

            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.ACCEPT_DEFAULT_VIEW_TAB,false);
        end


        function removeQuickAccessBar(self)


            group=self.hToolGroup.Peer.getWrappedComponent;
            filter=com.mathworks.toolbox.images.QuickAccessFilter.getFilter();
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.QUICK_ACCESS_TOOL_BAR_FILTER,filter)
        end


        function disableDragDropOnToolGroup(self)


            group=self.hToolGroup.Peer.getWrappedComponent;
            dropListener=com.mathworks.widgets.desk.DTGroupProperty.IGNORE_ALL_DROPS;
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.DROP_LISTENER,dropListener);
        end

    end

    methods(Static)

        function deleteAllTools
            imageslib.internal.apputil.manageToolInstances('deleteAll','colorThresholder');
        end

        function TF=isValidRGBImage(im)

            supportedDataType=isa(im,'uint8')||isa(im,'uint16')||isfloat(im);
            supportedAttributes=isreal(im)&&all(isfinite(im(:)))&&~issparse(im);
            supportedDimensionality=(ndims(im)==3)&&size(im,3)==3;

            TF=supportedDataType&&supportedAttributes&&supportedDimensionality;

        end

    end

    methods

        function tabName=getFigName(self,csname)

            validHandles=self.FigureHandles(ishandle(self.FigureHandles));
            names=arrayfun(@(h)get(h,'Name'),validHandles,'UniformOutput',false);

            idx=strcmpi(csname,names);

            if~any(idx)
                tabName=csname;
            else
                inc=2;
                while any(idx)
                    newname=[csname,' ',num2str(inc)];
                    idx=strcmpi(newname,names);
                    inc=inc+1;
                end
                tabName=newname;
            end

        end

        function applyTransformation(self,~,~)




            if~self.is3DView
                return
            end

            self.is3DView=false;

            hPanel=findobj(self.hFigCurrent,'Tag','RightPanel');
            PolyButton=findobj(hPanel,'Tag','PolyButton');
            PolyButton.Value=1;


            [tMat,xlim,ylim]=self.hColorSpaceProjectionView.customProjection();


            setappdata(hPanel,'TransformationMat',tMat);


            im=getappdata(hPanel,'ColorspaceCDataForCluster');
            tMat=tMat(1:2,:);
            im=[im,ones(size(im,1),1)]';
            im=(tMat*im)';

            setappdata(hPanel,'TransformedCDataForCluster',im);


            self.updatePointCloud(xlim,ylim);

            self.changeViewState()

            self.polyRegionForClusters()

        end

        function show3DViewState(self)

            if images.internal.app.colorThresholder.hasValidROIs(self.hFigCurrent,self.hPolyROIs)

                buttonName=questdlg(getString(message('images:colorSegmentor:rotateColorSpaceMessage')),...
                'Remove polygons?',...
                getString(message('images:commonUIString:yes')),...
                getString(message('images:commonUIString:cancel')),...
                getString(message('images:commonUIString:cancel')));

                if strcmp(buttonName,getString(message('images:commonUIString:yes')))
                    self.isProjectionApplied=true;

                    figuresWithROIs=[self.hPolyROIs{:,1}];
                    idx=find(figuresWithROIs==self.hFigCurrent,1);
                    currentROIs=self.hPolyROIs{idx,2};

                    currentROIs(1:end).delete();
                    self.isProjectionApplied=false;




                    hAx=findobj(self.hColorSpaceProjectionView.hPanels,'type','axes');
                    iptSetPointerBehavior(hAx,@(hObj,evt)set(hObj,'Pointer','custom','PointerShapeCData',self.rotatePointer));
                else
                    return
                end
            end

            self.is3DView=true;

            if~isempty(self.polyManager)
                self.disablePolyRegion()
                self.polyManager=[];
            end

            hPanel=findobj(self.hFigCurrent,'Tag','RightPanel');
            PolyButton=findobj(hPanel,'Tag','ProjectButton');
            PolyButton.Value=0;


            self.updateClusterMask()
            self.hColorSpaceProjectionView.updatePointCloud(self.sliderMask);
            self.changeViewState()

        end

        function showStatusBar(self)

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            f=md.getFrameContainingGroup(self.hToolGroup.Name);
            javaMethodEDT('setStatusText',f,getString(message('images:colorSegmentor:polygonHintMessage')));
        end

        function clearStatusBar(self)

            md=com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            f=md.getFrameContainingGroup(self.hToolGroup.Name);
            javaMethodEDT('setStatusText',f,'');
        end

        function clearFreehands(self)



            self.isManualDelete=false;
            if images.internal.app.colorThresholder.hasValidROIs(self.hFigCurrent,self.hFreehandROIs)
                figuresWithROIs=[self.hFreehandROIs{:,1}];
                idx=figuresWithROIs==self.hFigCurrent;
                hROIs=self.hFreehandROIs(idx,2);
                numFreehands=numel(hROIs);
                for p=1:numFreehands
                    hFree=hROIs{numFreehands-p+1};
                    hFree.delete();
                end
            end
            self.isManualDelete=true;

        end

        function buttonClicked(self,TF)
            self.isFigClicked=TF;
        end

    end

end


function triples=samplesUnderMask(img,mask)

    triples=zeros([nnz(mask),3],'like',img);

    for channel=1:3
        theChannel=img(:,:,channel);
        triples(:,channel)=theChannel(mask);
    end
end


function hLim=computeHLim(hValues)





    switch(class(hValues))
    case{'single','double'}
        lowerRegion=hValues(hValues<0.5);
        upperRegion=hValues(hValues>=0.5);

        if isempty(lowerRegion)||isempty(upperRegion)
            bimodal=false;
        elseif(min(lowerRegion)>0.04)||(max(upperRegion)<0.96)
            bimodal=false;
        elseif(min(upperRegion)-max(lowerRegion))>1/3
            bimodal=true;
        else
            bimodal=false;
        end

    case{'uint8'}
        lowerRegion=hValues(hValues<128);
        upperRegion=hValues(hValues>=128);

        if isempty(lowerRegion)||isempty(upperRegion)
            bimodal=false;
        elseif(min(lowerRegion)>10)||(max(upperRegion)<245)
            bimodal=false;
        elseif(min(upperRegion)-max(lowerRegion))>255/3
            bimodal=true;
        else
            bimodal=false;
        end

    case{'uint16'}
        lowerRegion=hValues(hValues<32896);
        upperRegion=hValues(hValues>=32896);

        if isempty(lowerRegion)||isempty(upperRegion)
            bimodal=false;
        elseif(min(lowerRegion)>2570)||(max(upperRegion)<62965)
            bimodal=false;
        elseif(min(upperRegion)-max(lowerRegion))>65535/3
            bimodal=true;
        else
            bimodal=false;
        end

    otherwise
        assert(false,'Data type not supported');
    end

    if(bimodal)
        hLim=[min(upperRegion),max(lowerRegion)];
    else
        hLim=[min(hValues),max(hValues)];
    end
end


function polyIcon=setUIControlIcon(filename)


    [polyIcon,~,transparency]=imread(filename);
    polyIcon=double(polyIcon)/255;
    transparency=double(transparency)/255;

    polyIcon(:,:,1)=polyIcon(:,:,1)+(0.94-polyIcon(:,:,1)).*(1-transparency);
    polyIcon(:,:,2)=polyIcon(:,:,2)+(0.94-polyIcon(:,:,2)).*(1-transparency);
    polyIcon(:,:,3)=polyIcon(:,:,3)+(0.94-polyIcon(:,:,3)).*(1-transparency);
    polyIcon(transparency==0)=NaN;

end
