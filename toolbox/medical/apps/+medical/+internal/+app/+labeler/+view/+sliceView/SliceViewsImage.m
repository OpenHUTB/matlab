classdef SliceViewsImage<handle




    properties

        Slice medical.internal.app.labeler.view.sliceView.ScrollableSliceView

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

        function self=SliceViewsImage(sliceFig)

            self.wireupSlice(sliceFig);

            self.resize(sliceFig.Position);

        end


        function sliceIm=getImageHandles(self)
            sliceIm=self.Slice.getImageHandle();
        end


        function disableForDrawing(self)
            self.Slice.disableForDrawing();
        end


        function enableForDrawing(self)
            self.Slice.enableForDrawing();
        end


        function clear(self)
            self.Slice.clear();
        end


        function initialize(self,numSlices,pixelSpacing,dataLimits)

            wlMotionScale=computeWLMotionScale(dataLimits);

            self.ContrastLimitsInternal=dataLimits;
            self.Slice.ContrastLimits=dataLimits;

            self.Slice.initialize(numSlices,pixelSpacing(1,:),wlMotionScale);

            self.Slice.SliderVisible=numSlices>1;
            self.Slice.SummaryVisible=numSlices>1;

        end


        function redraw(self)


            self.Slice.redraw();
        end


        function refresh(self)


            self.Slice.refresh();
        end


        function refreshWithoutLabels(self)


            self.Slice.refreshWithoutLabels();
        end


        function setDisplayConvention(self,displayConvention)
































        end


        function updateSlice(self,slice,label,labelColormap,labelVisible,currentIdx,~)
            self.Slice.updateSlice(slice,label,labelColormap,labelVisible,self.ContrastLimitsInternal,currentIdx);
        end


        function updateContrastLimits(self,contrastLimits)
            self.ContrastLimits=contrastLimits;
        end


        function previousSlice(self,~)
            self.Slice.previousSlice();
        end


        function nextSlice(self,~)
            self.Slice.nextSlice();
        end


        function sliceImg=getScreenshot(self)
            sliceImg=self.Slice.getScreenshot();
        end


        function showOrientationMarkers(self,TF)
            self.Slice.showOrientationMarkers(TF);
        end


        function showScaleBar(self,TF)
            self.Slice.showScaleBar(TF);
        end


        function resize(self,sliceFigPos)
            self.Slice.resize(sliceFigPos);
        end


        function enableVoxelInfoListeners(self,TF)
            self.Slice.enableVoxelInfo(TF);
        end


        function startWindowLevel(self)
            self.Slice.startWindowLevel();
        end


        function zoomIn(self)
            self.Slice.zoomIn();
        end


        function zoomOut(self)
            self.Slice.zoomOut();
        end


        function pan(self,str)
            self.Slice.pan(str);
        end


        function scroll(self,scrollCount,~)
            self.Slice.scroll(scrollCount);
        end


        function deselectAxesInteraction(self)
            self.Slice.deselectAxesInteraction();
        end


        function rotate(self,val,~)
            self.Slice.rotate(val);
        end


        function displaySliceNumber(self,currentSlice,maxSlice,~)
            self.Slice.displaySliceNumber(currentSlice,maxSlice);
        end


        function displayLabelColor(self,color)
            self.Slice.displayLabelColor(color);
        end


        function displayMode(self,mode)
            self.Slice.displayMode(mode);
        end


        function updateThumbnailDisplay(self,img,label,cmap,idx,maxIdx,~)
            self.Slice.updateThumbnailDisplay(img,label,cmap,self.ContrastLimitsInternal);
        end


        function hideThumbnail(self)
            self.Slice.hideThumbnail();
        end


        function setSuperpixelOverlay(self,L,~)
            self.Slice.SuperpixelOverlay=L;
        end


        function L=getSuperpixelOverlay(self,~)
            L=self.Slice.SuperpixelOverlay;
        end


        function updateSummary(self,data,color,~)
            self.Slice.updateSummary(data,color);
        end


        function pixSize=getPixelSize(self,~)
            pixSize=self.Slice.PixelSize;
        end

    end


    methods


        function set.Visible(self,TF)
            self.Slice.Visible=TF;
        end


        function set.Enabled(self,TF)
            self.Slice.Enabled=TF;
        end


        function set.ContrastLimits(self,cLim)

            self.Slice.ContrastLimits=cLim;

            self.ContrastLimitsInternal=cLim;
            self.refresh();

        end

        function cLim=get.ContrastLimits(self)
            cLim=self.ContrastLimitsInternal;
        end


        function set.LabelOpacity(self,opacity)

            self.Slice.LabelOpacity=opacity;
            self.redraw();

        end


        function set.Empty(self,TF)
            self.Slice.Empty=TF;

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
            self.Slice.SuperpixelsVisible=TF;
        end

        function TF=get.SuperpixelsVisible(self)
            TF=self.Slice.SuperpixelsVisible;
        end


        function set.LastActiveSliceDirection(self,~)

            self.Slice.setAsActiveSlice(true);%#ok<MCSUP> 

            self.LastActiveSliceDirection=medical.internal.app.labeler.enums.SliceDirection.Unknown;

        end


        function set.EnableWindowLevel(self,TF)
            self.Slice.EnableWindowLevel=TF;
        end

        function TF=get.EnableWindowLevel(self)
            TF=self.Slice.EnableWindowLevel;
        end

    end


    methods(Access=private)


        function wireupSlice(self,sliceFig)

            sliceDir=medical.internal.app.labeler.enums.SliceDirection.Unknown;
            self.Slice=medical.internal.app.labeler.view.sliceView.ScrollableSliceView(sliceFig,sliceDir);
            self.Slice.setTags("TransverseSlicePanel","TransverseSummary");

            addlistener(self.Slice,'SliceAtIndexRequested',@(src,evt)self.notify('SliceAtIndexRequested',evt));
            addlistener(self.Slice,'SliceChanged',@(src,evt)self.notify('SliceChanged',evt));
            addlistener(self.Slice,'RefreshSlice',@(src,evt)self.notify('RefreshSlice',evt));
            addlistener(self.Slice,'RefreshSliceWithoutLabels',@(src,evt)self.notify('RefreshSliceWithoutLabels',evt));
            addlistener(self.Slice,'InteractionModeChanged',@(src,evt)self.notify('InteractionModeChanged',evt));
            addlistener(self.Slice,'ImageClicked',@(src,evt)self.notify('ImageClicked',evt));
            addlistener(self.Slice,'VoxelInfoRequested',@(src,evt)self.notify('VoxelInfoRequested',evt));
            addlistener(self.Slice,'ClearVoxelInfo',@(src,evt)self.notify('ClearVoxelInfo'));
            addlistener(self.Slice,'ContrastLimitsChanged',@(~,evt)self.reactToWindowLevelChanged(evt));

            self.LastActiveSliceDirection=sliceDir;

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
