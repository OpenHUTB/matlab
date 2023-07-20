classdef ScrollableSliceView<handle




    properties
ContrastLimits
    end

    properties(GetAccess=?uitest.factory.Tester,SetAccess=protected)

        Slice medical.internal.app.labeler.view.sliceView.Slice

        Slider images.internal.app.segmenter.volume.display.Slider

        Summary images.internal.app.segmenter.volume.display.Summary

        SliceDirection medical.internal.app.labeler.enums.SliceDirection

    end

    properties(Dependent)
Enabled
LabelOpacity
Empty
SuperpixelsVisible
SuperpixelOverlay
SummaryVisible
SliderVisible
PixelSize
EnableWindowLevel
    end

    properties(Access=protected)

        WindowLevelEnabled(1,1)logical=false;
        WLMotionScale=1/255;
        WLSpeed=1;
LastMousePosition

VoxelInfoListener
WLMouseMotionListener
WLMouseReleaseListener

    end

    properties(Constant,Access=protected)
        SliderHeight=20;
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

        function self=ScrollableSliceView(hParent,sliceDirection)

            self.SliceDirection=sliceDirection;

            self.wireUpSlice(hParent);
            self.wireUpSlider(hParent);
            self.wireUpSummary(hParent);

            hFig=ancestor(hParent,'figure');

            self.VoxelInfoListener=addlistener(hFig,'WindowMouseMotion',@(src,evt)voxelInfoRequested(self,evt));
            self.VoxelInfoListener.Enabled=false;

            self.WLMouseMotionListener=addlistener(hFig,'WindowMouseMotion',@(src,evt)adjustCLim(self,src,evt));
            self.WLMouseMotionListener.Enabled=false;

            self.WLMouseReleaseListener=addlistener(hFig,'WindowMouseRelease',@(src,evt)reactToMouseRelease(self));
            self.WLMouseReleaseListener.Enabled=false;

        end


        function setTags(self,slicePanelTag,summaryPanelTag)
            self.Slice.setSlicePanelTag(slicePanelTag);
            self.Summary.setPanelTag(summaryPanelTag)
        end


        function initialize(self,numSlices,pixelSize,wlMotionScale)

            pixelSize=flip(pixelSize);
            self.Slice.PixelSize=pixelSize;

            currentSlice=floor(mean([1,numSlices]));
            self.Slider.update(currentSlice,numSlices);

            self.WLMotionScale=wlMotionScale;
            self.WLSpeed=1*self.WLMotionScale;

            self.Enabled=false;
            self.Slider.Enabled=true;
            self.Slice.Enabled=true;
            self.Summary.Enabled=true;


            self.reactToSliceRequested(self.Slider.Current);

        end


        function setAsActiveSlice(self,TF)

            if TF&&self.Slice.Empty
                return
            end
            self.SummaryVisible=TF;
            self.Slice.ColorIndicator.Visible=TF;
            self.Slice.ModeIndicator.Visible=TF;
        end


        function disableForDrawing(self)
            self.Slider.Enabled=false;
            self.Summary.Enabled=false;
        end


        function enableForDrawing(self)
            self.Slider.Enabled=true;
            self.Summary.Enabled=true;
        end


        function enableVoxelInfo(self,TF)
            self.VoxelInfoListener.Enabled=TF;
        end


        function imageHandle=getImageHandle(self)
            imageHandle=self.Slice.getImageHandle();
        end


        function showOrientationMarkers(self,TF)
            self.Slice.showOrientationMarkers(TF);
        end


        function setOrientationMarkers(self,markerH1,markerH2,markerV1,markerV2)
            self.Slice.setOrientationMarkers(markerH1,markerH2,markerV1,markerV2);
        end


        function showScaleBar(self,TF)
            self.Slice.showScaleBar(TF);
        end


        function resize(self,parentPos)

            slicePos=[1,(2*self.SliderHeight)+1,floor(parentPos(3)),floor(parentPos(4))-(2*self.SliderHeight)];
            slicePos(slicePos<1)=1;
            self.Slice.resize(slicePos);

            sliderPos=[1,1,floor(parentPos(3)),self.SliderHeight];
            sliderPos(sliderPos<1)=1;
            self.Slider.resize(sliderPos);

            summaryPos=[1,self.SliderHeight+1,floor(parentPos(3)),self.SliderHeight];
            summaryPos(summaryPos<1)=1;
            self.Summary.resize(summaryPos);

        end


        function setAxesXDir(self,dir)
            self.Slice.setAxesXDir(dir);
        end


        function updateSlice(self,img,label,labelCmap,labelVisible,contrastLimits,currentIdx)

            self.Slice.draw(img,label,labelCmap,im2single(contrastLimits),labelVisible);
            self.Slice.displaySliceNumber(currentIdx,self.Slider.Max);

            self.Slider.update(currentIdx,self.Slider.Max);

            self.Summary.drawIndicator(currentIdx,self.Slider.Max);

        end


        function redraw(self)
            self.reactToSliceRequested(self.Slider.Current)
        end


        function refresh(self)
            evt=medical.internal.app.labeler.events.SliceEventData(self.Slider.Current,self.SliceDirection);
            self.notify('RefreshSlice',evt);
        end


        function refreshWithoutLabels(self)
            evt=medical.internal.app.labeler.events.SliceEventData(self.Slider.Current,self.SliceDirection);
            self.notify('RefreshSliceWithoutLabels',evt);
        end


        function previousSlice(self)
            self.Slider.previous();
        end


        function nextSlice(self)
            self.Slider.next();
        end


        function reset(self,sz)
            self.Slider.reset(sz);
        end


        function clear(self)

            self.Slice.clear();
            self.Slider.clear();
            self.Summary.clear();

        end


        function zoomIn(self)
            self.Slice.zoomIn();
        end


        function zoomOut(self)
            self.Slice.zoomOut()
        end


        function pan(self,str)
            self.Slice.pan(str);
        end


        function scroll(self,scrollCount)
            self.Slice.scroll(scrollCount);
        end


        function deselectAxesInteraction(self)
            self.Slice.showVoxelInfo(false);
            self.Slice.deselectAxesInteraction();
        end


        function rotate(self,val)
            self.Slice.rotate(val);
        end


        function displayLabelColor(self,color)
            self.Slice.displayLabelColor(color);
        end


        function displayMode(self,mode)
            self.Slice.displayMode(mode);
        end


        function setImageColors(self,backgroundColor,boxColor)
            self.Slice.setImageColors(backgroundColor,boxColor);
        end


        function updateThumbnailDisplay(self,img,label,cmap,contrastLimits)
            self.Slice.updateThumbnailDisplay(img,label,cmap,im2single(contrastLimits));
        end


        function hideThumbnail(self)
            self.Slice.hideThumbnail();
        end


        function updateVoxelInfo(self,loc,val)
            self.Slice.updateVoxelInfo(loc,val);
        end


        function showVoxelInfo(self,TF)
            self.Slice.showVoxelInfo(TF);
        end


        function img=getScreenshot(self)
            img=self.Slice.getScreenshot();
        end


        function updateSummary(self,data,color)
            self.Summary.draw(data,color);
        end


        function startWindowLevel(self)
            self.startWindowLevelInteraction
        end

    end


    methods(Access=protected)


        function startWindowLevelInteraction(self,point)

            self.LastMousePosition=point;

            self.WLMouseMotionListener.Enabled=true;
            self.WLMouseReleaseListener.Enabled=true;

        end


        function adjustCLim(self,src,evt)

            if~isa(evt.HitObject,'matlab.graphics.primitive.Image')
                return
            end


            currentPos(1)=src.CurrentAxes.CurrentPoint(1,1);
            currentPos(2)=src.CurrentAxes.CurrentPoint(1,2);
            offset=currentPos-self.LastMousePosition;
            self.LastMousePosition=currentPos;


            cLim=self.ContrastLimits;
            windowWidth=cLim(2)-cLim(1);
            windowCenter=cLim(1)+windowWidth./2;


            windowWidth=windowWidth+self.WLSpeed*offset(1);
            windowCenter=windowCenter+self.WLSpeed*offset(2);

            windowWidth=max(windowWidth,self.WLMotionScale);
            newCLim=zeros(1,2);
            newCLim(1)=(windowCenter-windowWidth/2);
            newCLim(2)=newCLim(1)+windowWidth;



            if isequal(class(self.ContrastLimits),'single')||isequal(class(self.ContrastLimits),'double')
                newCLim(1)=max(newCLim(1),0);
                newCLim(2)=min(newCLim(2),1);
            end


            if newCLim(2)<=newCLim(1)
                newCLim=self.ContrastLimits;
            end
            self.ContrastLimits=cast(newCLim,class(self.ContrastLimits));

            evtData=medical.internal.app.labeler.events.ValueEventData(self.ContrastLimits);
            self.notify('ContrastLimitsChanged',evtData);

        end


        function reactToMouseRelease(self)

            self.WLMouseMotionListener.Enabled=false;
            self.WLMouseReleaseListener.Enabled=false;

        end

    end

    methods(Access=protected)


        function wireUpSlice(self,hParent)

            slicePos=[1,(2*self.SliderHeight)+1,floor(hParent.Position(3)),floor(hParent.Position(4))-(2*self.SliderHeight)];
            slicePos(slicePos<1)=1;

            self.Slice=medical.internal.app.labeler.view.sliceView.Slice(hParent,slicePos);
            setImageColors(self.Slice,[0,0,0],[0.5,0.5,0.5]);
            addSliceListeners(self);

            displayMode(self.Slice,'None');

        end


        function addSliceListeners(self)

            addlistener(self.Slice,'ImageClicked',@(src,evt)reactToImageClick(self,evt.IntersectionPoint,self.Slider.Current));
            addlistener(self.Slice,'InteractionModeChanged',@(src,evt)reactToModeChanged(self,evt));


        end


        function wireUpSlider(self,hParent)

            sliderPos=[1,1,floor(hParent.Position(3)),self.SliderHeight];
            sliderPos(sliderPos<1)=1;

            self.Slider=images.internal.app.segmenter.volume.display.Slider(hParent,sliderPos);
            addSliderListeners(self);

        end


        function addSliderListeners(self)

            addlistener(self.Slider,'NextPressed',@(src,evt)self.reactToNextPressed(evt.Index));
            addlistener(self.Slider,'PreviousPressed',@(src,evt)self.reactToPreviousPressed(evt.Index));
            addlistener(self.Slider,'SliderMoving',@(src,evt)self.reactToSliceRequested(evt.Index));
            addlistener(self.Slider,'SliderMoved',@(src,evt)self.reactToSliceChanged());

        end


        function wireUpSummary(self,hParent)

            pos=[1,self.SliderHeight+1,floor(hParent.Position(3)),self.SliderHeight];
            pos(pos<1)=1;

            self.Summary=images.internal.app.segmenter.volume.display.Summary(hParent,pos);
            addSummaryListeners(self);

        end


        function addSummaryListeners(self)

            addlistener(self.Summary,'SummaryClicked',@(src,evt)self.reactToSliceRequested(evt.Index));

        end

    end


    methods(Access=protected)


        function reactToImageClick(self,intersectionPoint,sliceIdx)

            if self.WindowLevelEnabled
                self.startWindowLevelInteraction(intersectionPoint(1:2));
            else
                evt=medical.internal.app.labeler.events.SliceClickedEventData(intersectionPoint,sliceIdx,self.SliceDirection);
                self.notify('ImageClicked',evt);
            end

        end


        function reactToModeChanged(self,evt)
            self.notify('InteractionModeChanged',evt);
        end


        function reactToNextPressed(self,idx)
            self.reactToSliceRequested(idx);
            self.reactToSliceChanged();
        end


        function reactToPreviousPressed(self,idx)
            self.reactToSliceRequested(idx);
            self.reactToSliceChanged();
        end


        function reactToSliceRequested(self,idx)

            evt=medical.internal.app.labeler.events.SliceEventData(idx,self.SliceDirection);
            self.notify('SliceAtIndexRequested',evt);

        end


        function reactToSliceChanged(self)
            evt=medical.internal.app.labeler.events.ValueEventData(self.SliceDirection);
            self.notify('SliceChanged',evt);
        end


        function voxelInfoRequested(self,evt)

            if evt.HitObject==self.Slice.Image.ImageHandle

                currentPos(1)=self.Slice.Image.AxesHandle.CurrentPoint(1,1);
                currentPos(2)=self.Slice.Image.AxesHandle.CurrentPoint(1,2);

                evt=medical.internal.app.labeler.events.VoxelIntensityEventData(currentPos,self.Slider.Current,self.SliceDirection);
                self.notify('VoxelInfoRequested',evt);

            else

                self.notify('ClearVoxelInfo')

            end

        end

    end


    methods




        function set.LabelOpacity(self,opacity)
            self.Slice.Alpha=opacity;
        end

        function opacity=get.LabelOpacity(self)
            opacity=self.Slice.Alpha;
        end




        function set.Empty(self,TF)
            self.Slice.Empty=TF;
            self.Slider.Enabled=~TF;
            self.Summary.Empty=TF;
        end




        function set.Enabled(self,TF)

            self.Slider.Enabled=TF;
            self.Slice.Enabled=TF;
            self.Summary.Enabled=TF;

        end




        function set.SuperpixelsVisible(self,TF)
            self.Slice.ShowOverlay=TF;
        end

        function TF=get.SuperpixelsVisible(self)
            TF=self.Slice.ShowOverlay;
        end




        function set.SuperpixelOverlay(self,L)
            self.Slice.SuperpixelOverlay=L;
        end

        function L=get.SuperpixelOverlay(self)
            L=self.Slice.SuperpixelOverlay;
        end




        function set.SummaryVisible(self,TF)
            self.Summary.SummaryVisible=TF;
        end




        function set.SliderVisible(self,TF)
            self.Slider.Visible=TF;
        end




        function pixSize=get.PixelSize(self)
            pixSize=self.Slice.PixelSize;
        end




        function set.EnableWindowLevel(self,TF)

            self.WindowLevelEnabled=TF;

        end

        function TF=get.EnableWindowLevel(self)
            TF=self.WindowLevelEnabled;
        end

    end

end
