classdef SliceViewsVolume<handle




    properties

        Transverse medical.internal.app.labeler.view.sliceView.ScrollableSliceView

        Coronal medical.internal.app.labeler.view.sliceView.ScrollableSliceView

        Sagittal medical.internal.app.labeler.view.sliceView.ScrollableSliceView

        LastActiveSliceDirection medical.internal.app.labeler.enums.SliceDirection

    end

    properties(Dependent)

Visible

Enabled

Alpha

LabelOpacity

Empty

SuperpixelsVisible

ContrastLimits

EnableWindowLevel

    end

    properties(Access=private)
ContrastLimitsInternal
    end

    events

ImageClicked
InteractionModeChanged

SliceAtIndexRequested
SliceChanged

RefreshSlice
RefreshSliceWithoutLabels

VoxelInfoRequested
ClearVoxelInfo

ContrastLimitsChanged

    end

    methods

        function self=SliceViewsVolume(transverseFig,coronalFig,sagittalFig)

            self.wireupTransverse(transverseFig);
            self.wireupCoronal(coronalFig);
            self.wireupSagittal(sagittalFig);

            self.resize(transverseFig.Position,coronalFig.Position,sagittalFig.Position);

        end


        function[transverseIm,coronalIm,sagittalIm]=getImageHandles(self)
            transverseIm=self.Transverse.getImageHandle();
            coronalIm=self.Coronal.getImageHandle();
            sagittalIm=self.Sagittal.getImageHandle();
        end


        function disableForDrawing(self)
            self.Transverse.disableForDrawing();
            self.Coronal.disableForDrawing();
            self.Sagittal.disableForDrawing();
        end


        function enableForDrawing(self)
            self.Transverse.enableForDrawing();
            self.Coronal.enableForDrawing();
            self.Sagittal.enableForDrawing();
        end


        function clear(self)

            self.Transverse.clear();
            self.Coronal.clear();
            self.Sagittal.clear();

        end


        function initialize(self,numSlicesASC,pixelSpacingASC,dataLimits)

            wlMotionScale=computeWLMotionScale(dataLimits);

            self.ContrastLimitsInternal=dataLimits;
            self.Transverse.ContrastLimits=dataLimits;
            self.Coronal.ContrastLimits=dataLimits;
            self.Sagittal.ContrastLimits=dataLimits;

            self.Transverse.initialize(numSlicesASC(1),pixelSpacingASC(1,:),wlMotionScale);
            self.Coronal.initialize(numSlicesASC(3),pixelSpacingASC(3,:),wlMotionScale);
            self.Sagittal.initialize(numSlicesASC(2),pixelSpacingASC(2,:),wlMotionScale);

        end


        function redraw(self)



            self.Transverse.redraw();
            self.Coronal.redraw();
            self.Sagittal.redraw();

        end


        function refresh(self)



            self.Transverse.refresh();
            self.Coronal.refresh();
            self.Sagittal.refresh();

        end


        function refreshWithoutLabels(self)



            self.Transverse.refreshWithoutLabels();
            self.Coronal.refreshWithoutLabels();
            self.Sagittal.refreshWithoutLabels();

        end


        function setDisplayConvention(self,displayConvention)


            sliceDir=medical.internal.app.labeler.enums.SliceDirection.Transverse;
            [markerH1,markerH2,markerV1,markerV2]=medical.internal.app.labeler.utils.get2DOrientationMarkers(sliceDir);
            if displayConvention=="Neurological"

                [markerH1,markerH2]=deal(markerH2,markerH1);
                self.Transverse.setAxesXDir('reverse');
            else
                self.Transverse.setAxesXDir('normal');
            end
            self.Transverse.setOrientationMarkers(markerH1,markerH2,markerV1,markerV2);


            sliceDir=medical.internal.app.labeler.enums.SliceDirection.Coronal;
            [markerH1,markerH2,markerV1,markerV2]=medical.internal.app.labeler.utils.get2DOrientationMarkers(sliceDir);
            if displayConvention=="Neurological"

                [markerH1,markerH2]=deal(markerH2,markerH1);
                self.Coronal.setAxesXDir('reverse');
            else
                self.Coronal.setAxesXDir('normal');
            end
            self.Coronal.setOrientationMarkers(markerH1,markerH2,markerV1,markerV2);


            sliceDir=medical.internal.app.labeler.enums.SliceDirection.Sagittal;
            [markerH1,markerH2,markerV1,markerV2]=medical.internal.app.labeler.utils.get2DOrientationMarkers(sliceDir);
            self.Sagittal.setOrientationMarkers(markerH1,markerH2,markerV1,markerV2);

drawnow

        end


        function updateSlice(self,slice,label,labelColormap,labelVisible,currentIdx,sliceDir)

            switch sliceDir

            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.updateSlice(slice,label,labelColormap,labelVisible,self.ContrastLimitsInternal,currentIdx);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.updateSlice(slice,label,labelColormap,labelVisible,self.ContrastLimitsInternal,currentIdx);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.updateSlice(slice,label,labelColormap,labelVisible,self.ContrastLimitsInternal,currentIdx);
            end

        end


        function updateContrastLimits(self,contrastLimits)
            self.ContrastLimits=contrastLimits;
        end


        function previousSlice(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.previousSlice();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.previousSlice();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.previousSlice();
            end

        end


        function nextSlice(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.nextSlice();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.nextSlice();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.nextSlice();
            end

        end


        function[transverseImg,coronalImg,sagittalImg]=getScreenshot(self)

            transverseImg=self.Transverse.getScreenshot();
            coronalImg=self.Coronal.getScreenshot();
            sagittalImg=self.Sagittal.getScreenshot();

        end


        function showOrientationMarkers(self,TF)

            self.Transverse.showOrientationMarkers(TF);
            self.Coronal.showOrientationMarkers(TF);
            self.Sagittal.showOrientationMarkers(TF);

        end


        function showScaleBar(self,TF)

            self.Transverse.showScaleBar(TF);
            self.Coronal.showScaleBar(TF);
            self.Sagittal.showScaleBar(TF);

        end


        function resize(self,transverseFigPos,coronalFigPos,sagittalFigPos)

            self.Transverse.resize(transverseFigPos);
            self.Coronal.resize(coronalFigPos);
            self.Sagittal.resize(sagittalFigPos);

        end


        function enableVoxelInfoListeners(self,TF)

            self.Transverse.enableVoxelInfo(TF);
            self.Coronal.enableVoxelInfo(TF);
            self.Sagittal.enableVoxelInfo(TF);

        end


        function startWindowLevel(self)

            self.Transverse.startWindowLevel();
            self.Coronal.startWindowLevel();
            self.Sagittal.startWindowLevel();

        end


        function zoomIn(self)
            switch self.LastActiveSliceDirection
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.zoomIn();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.zoomIn();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.zoomIn();
            end
        end


        function zoomOut(self)
            switch self.LastActiveSliceDirection
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.zoomOut();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.zoomOut();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.zoomOut();
            end
        end


        function pan(self,str)
            switch self.LastActiveSliceDirection
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.pan(str);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.pan(str);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.pan(str);
            end
        end


        function scroll(self,scrollCount,sliceDir)
            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.scroll(scrollCount);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.scroll(scrollCount);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.scroll(scrollCount);
            end
        end


        function deselectAxesInteraction(self)
            self.Transverse.deselectAxesInteraction();
            self.Coronal.deselectAxesInteraction();
            self.Sagittal.deselectAxesInteraction();
        end


        function rotate(self,val,sliceDir)
            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.rotate(val);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.rotate(val);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.rotate(val);
            end
        end


        function displaySliceNumber(self,currentSlice,maxSlice,sliceDir)
            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.displaySliceNumber(currentSlice,maxSlice);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.displaySliceNumber(currentSlice,maxSlice);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.displaySliceNumber(currentSlice,maxSlice);
            end
        end


        function displayLabelColor(self,color)
            self.Transverse.displayLabelColor(color);
            self.Coronal.displayLabelColor(color);
            self.Sagittal.displayLabelColor(color);
        end


        function displayMode(self,mode)
            self.Transverse.displayMode(mode);
            self.Coronal.displayMode(mode);
            self.Sagittal.displayMode(mode)
        end


        function updateThumbnailDisplay(self,img,label,cmap,idx,maxIdx,sliceDir)
            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.updateThumbnailDisplay(img,label,cmap,self.ContrastLimitsInternal);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.updateThumbnailDisplay(img,label,cmap,self.ContrastLimitsInternal);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.updateThumbnailDisplay(img,label,cmap,self.ContrastLimitsInternal);
            end
        end


        function hideThumbnail(self)
            self.Transverse.hideThumbnail();
            self.Coronal.hideThumbnail();
            self.Sagittal.hideThumbnail();
        end


        function setSuperpixelOverlay(self,L,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.SuperpixelOverlay=L;

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.SuperpixelOverlay=L;

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.SuperpixelOverlay=L;
            end

        end


        function L=getSuperpixelOverlay(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                L=self.Transverse.SuperpixelOverlay;

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                L=self.Coronal.SuperpixelOverlay;

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                L=self.Sagittal.SuperpixelOverlay;
            end

        end


        function updateSummary(self,data,color,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.updateSummary(data,color);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Coronal.updateSummary(data,color);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Sagittal.updateSummary(data,color);
            end

        end


        function pixSize=getPixelSize(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                pixSize=self.Transverse.PixelSize;

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                pixSize=self.Coronal.PixelSize;

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                pixSize=self.Sagittal.PixelSize;
            end

        end

    end


    methods


        function set.Visible(self,TF)

            self.Transverse.Visible=TF;
            self.Coronal.Visible=TF;
            self.Sagittal.Visible=TF;

        end


        function set.Enabled(self,TF)

            self.Transverse.Enabled=TF;
            self.Coronal.Enabled=TF;
            self.Sagittal.Enabled=TF;

        end


        function set.ContrastLimits(self,cLim)

            self.Transverse.ContrastLimits=cLim;
            self.Coronal.ContrastLimits=cLim;
            self.Sagittal.ContrastLimits=cLim;

            self.ContrastLimitsInternal=cLim;
            self.refresh();

        end

        function cLim=get.ContrastLimits(self)
            cLim=self.ContrastLimitsInternal;
        end


        function set.LabelOpacity(self,opacity)

            self.Transverse.LabelOpacity=opacity;
            self.Coronal.LabelOpacity=opacity;
            self.Sagittal.LabelOpacity=opacity;

            self.refresh();

        end


        function set.Empty(self,TF)

            self.Transverse.Empty=TF;
            self.Coronal.Empty=TF;
            self.Sagittal.Empty=TF;

            if~TF

                s=settings;
                showOrientationMarkers=s.medical.apps.labeler.ShowOrientationMarkers2D.ActiveValue;
                self.showOrientationMarkers(showOrientationMarkers);

                showScaleBars=s.medical.apps.labeler.ShowScaleBars.ActiveValue;
                self.showScaleBar(showScaleBars);

                displayConvention=s.medical.apps.labeler.DisplayConvention.ActiveValue;
                self.setDisplayConvention(displayConvention);

            end

        end


        function set.SuperpixelsVisible(self,TF)

            self.Transverse.SuperpixelsVisible=TF;
            self.Coronal.SuperpixelsVisible=TF;
            self.Sagittal.SuperpixelsVisible=TF;

        end

        function TF=get.SuperpixelsVisible(self)
            TF=self.Transverse.SuperpixelsVisible;
        end


        function set.LastActiveSliceDirection(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.Transverse.setAsActiveSlice(true);%#ok<*MCSUP> 
                self.Coronal.setAsActiveSlice(false);
                self.Sagittal.setAsActiveSlice(false);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.Transverse.setAsActiveSlice(false);
                self.Coronal.setAsActiveSlice(true);
                self.Sagittal.setAsActiveSlice(false);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.Transverse.setAsActiveSlice(false);
                self.Coronal.setAsActiveSlice(false);
                self.Sagittal.setAsActiveSlice(true);
            end

            self.LastActiveSliceDirection=sliceDir;

        end


        function set.EnableWindowLevel(self,TF)

            self.Transverse.EnableWindowLevel=TF;
            self.Coronal.EnableWindowLevel=TF;
            self.Sagittal.EnableWindowLevel=TF;

        end

        function TF=get.EnableWindowLevel(self)
            TF=self.Transverse.EnableWindowLevel;
        end

    end


    methods(Access=private)


        function wireupTransverse(self,transverseFig)

            sliceDir=medical.internal.app.labeler.enums.SliceDirection.Transverse;
            self.Transverse=medical.internal.app.labeler.view.sliceView.ScrollableSliceView(transverseFig,sliceDir);
            self.Transverse.setTags("TransverseSlicePanel","TransverseSummary");

            addlistener(self.Transverse,'SliceAtIndexRequested',@(src,evt)self.notify('SliceAtIndexRequested',evt));
            addlistener(self.Transverse,'SliceChanged',@(src,evt)self.notify('SliceChanged',evt));
            addlistener(self.Transverse,'RefreshSlice',@(src,evt)self.notify('RefreshSlice',evt));
            addlistener(self.Transverse,'RefreshSliceWithoutLabels',@(src,evt)self.notify('RefreshSliceWithoutLabels',evt));
            addlistener(self.Transverse,'InteractionModeChanged',@(src,evt)self.notify('InteractionModeChanged',evt));
            addlistener(self.Transverse,'ImageClicked',@(src,evt)self.notify('ImageClicked',evt));
            addlistener(self.Transverse,'VoxelInfoRequested',@(src,evt)self.notify('VoxelInfoRequested',evt));
            addlistener(self.Transverse,'ClearVoxelInfo',@(src,evt)self.notify('ClearVoxelInfo'));
            addlistener(self.Transverse,'ContrastLimitsChanged',@(~,evt)self.reactToWindowLevelChanged(evt));

        end


        function wireupCoronal(self,coronalFig)

            sliceDir=medical.internal.app.labeler.enums.SliceDirection.Coronal;
            self.Coronal=medical.internal.app.labeler.view.sliceView.ScrollableSliceView(coronalFig,sliceDir);
            self.Coronal.setTags("CoronalSlicePanel","CoronalSummary");

            addlistener(self.Coronal,'SliceAtIndexRequested',@(src,evt)self.notify('SliceAtIndexRequested',evt));
            addlistener(self.Coronal,'SliceChanged',@(src,evt)self.notify('SliceChanged',evt));
            addlistener(self.Coronal,'RefreshSlice',@(src,evt)self.notify('RefreshSlice',evt));
            addlistener(self.Coronal,'RefreshSliceWithoutLabels',@(src,evt)self.notify('RefreshSliceWithoutLabels',evt));
            addlistener(self.Coronal,'InteractionModeChanged',@(src,evt)self.notify('InteractionModeChanged',evt));
            addlistener(self.Coronal,'ImageClicked',@(src,evt)self.notify('ImageClicked',evt));
            addlistener(self.Coronal,'VoxelInfoRequested',@(src,evt)self.notify('VoxelInfoRequested',evt));
            addlistener(self.Coronal,'ClearVoxelInfo',@(src,evt)self.notify('ClearVoxelInfo'));
            addlistener(self.Coronal,'ContrastLimitsChanged',@(~,evt)self.reactToWindowLevelChanged(evt));

        end


        function wireupSagittal(self,sagittalFig)

            sliceDir=medical.internal.app.labeler.enums.SliceDirection.Sagittal;

            self.Sagittal=medical.internal.app.labeler.view.sliceView.ScrollableSliceView(sagittalFig,sliceDir);
            self.Sagittal.setTags("SagittalSlicePanel","SagittalSummary");

            addlistener(self.Sagittal,'SliceAtIndexRequested',@(src,evt)self.notify('SliceAtIndexRequested',evt));
            addlistener(self.Sagittal,'SliceChanged',@(src,evt)self.notify('SliceChanged',evt));
            addlistener(self.Sagittal,'RefreshSlice',@(src,evt)self.notify('RefreshSlice',evt));
            addlistener(self.Sagittal,'RefreshSliceWithoutLabels',@(src,evt)self.notify('RefreshSliceWithoutLabels',evt));
            addlistener(self.Sagittal,'InteractionModeChanged',@(src,evt)self.notify('InteractionModeChanged',evt));
            addlistener(self.Sagittal,'ImageClicked',@(src,evt)self.notify('ImageClicked',evt));
            addlistener(self.Sagittal,'VoxelInfoRequested',@(src,evt)self.notify('VoxelInfoRequested',evt));
            addlistener(self.Sagittal,'ClearVoxelInfo',@(src,evt)self.notify('ClearVoxelInfo'));
            addlistener(self.Sagittal,'ContrastLimitsChanged',@(~,evt)self.reactToWindowLevelChanged(evt));

        end

    end


    methods(Access=protected)


        function reactToWindowLevelChanged(self,evt)

            drawnow('limitrate');

            self.updateContrastLimits(evt.Value);

            self.notify('ContrastLimitsChanged',evt);

        end

    end

end

function scale=computeWLMotionScale(dataLimits)

    switch(class(dataLimits))



    case{'int8','uint8'}
        scale=1;
    case{'int16','uint16'}
        scale=4;
    case{'int32','uint32'}
        scale=4;
    case{'single','double'}



        scale=1/255;
    otherwise
        scale=1/255;

    end

end
