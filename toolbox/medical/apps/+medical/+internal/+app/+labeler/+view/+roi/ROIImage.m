classdef ROIImage<handle&matlab.mixin.SetGet




    properties

        ROI medical.internal.app.labeler.view.roi.ROI

    end

    properties(Dependent)

Editable
    end

    events

DrawingStarted

DrawingFinished

DrawingAborted

ROIUpdated

ROIPasted

ROIReassigned

FillRegion

SetPriorMask

ROISelected

AllROIsSelected

CopyPasteUpdated

FloodFillRegion

    end

    methods


        function self=ROIImage()

            self.wireupROI();

        end


        function draw(self,val,color,~)
            self.ROI.draw(val,color)
        end


        function drawAssisted(self,val,color,~)
            self.ROI.drawAssisted(val,color);
        end


        function drawPolygon(self,val,color,~)
            self.ROI.drawPolygon(val,color);
        end


        function paint(self,val,color,~)
            self.ROI.paint(val,color);
        end


        function startLevelTrace(self,val,color)
            self.ROI.startLevelTrace(val,color);
        end


        function stopLevelTrace(self)
            self.ROI.stopLevelTrace();
        end


        function setLevelTraceThreshold(self,threshold)
            self.ROI.setLevelTraceThreshold(threshold);
        end


        function fill(self,val,color,~)
            self.ROI.fill(val,color);
        end


        function floodFill(self,val,~)
            self.ROI.floodFill(val);
        end


        function preload(self,sliceIm)
            self.ROI.preload(sliceIm);
        end


        function select(self,slice,cmap,~)
            self.ROI.select(slice,cmap);
        end


        function selectWindow(self,slice,color,~)
            self.ROI.selectWindow(slice,color);
        end


        function selectAll(self,slice,cmap,~)



            self.ROI.selectAll(slice,cmap);

        end


        function selectAllInWindow(self,slice,cmap,window,~)



            self.ROI.selectAllInWindow(slice,cmap,window);

        end


        function deselectAll(self,~)
            self.ROI.deselectAll();
        end


        function copy(self,~)
            self.ROI.copy();
        end


        function cut(self,~)
            self.ROI.cut();
        end


        function deleteSelected(self,~)
            self.ROI.deleteSelected();
        end


        function paste(self,~)
            self.ROI.paste();
        end


        function clear(self,~)
            self.ROI.clear();
        end


        function clearBrush(self)
            self.ROI.clearBrush();
        end


        function updateBrushOutline(self)
            self.ROI.updateBrushOutline();
        end


        function updateContextMenu(self)
            self.ROI.updateContextMenu();
        end


        function clearClipboard(self)
            self.ROI.clearClipboard();
        end


        function updateRGBA(self,cmap)



            self.ROI.updateRGBA(cmap);

        end


        function[roi,val,mask]=getSelection(self,~)
            [roi,val,mask]=self.ROI.getSelection();
        end


        function rotate(self,val,~)
            self.ROI.rotate(val);
        end


        function updateSlice(self,slice,labelSlice,~)
            self.ROI.updateSlice(slice,labelSlice);
        end


        function updateSliceIndex(self,idx,~)
            self.ROI.updateSliceIndex(idx);
        end


        function idx=getSliceIndex(self,~)
            idx=self.ROI.getSliceIndex();
        end


        function L=generateSuperpixels(self,sz,~)
            L=self.ROI.generateSuperpixels(sz);
        end


        function generateMeanSuperpixels(self,~)
            self.ROI.generateMeanSuperpixels();
        end


        function setFloodFillSettings(self,sz,tol)
            self.ROI.setFloodFillSettings(sz,tol);
        end


        function setClickPosition(self,pos,~)
            self.ROI.ClickPosition=pos;
        end


        function val=getMeanSuperpixelsValue(self,~)
            val=self.ROI.MeanSuperpixelValues;
        end

    end


    methods(Access=protected)


        function wireupROI(self)

            sliceDir=medical.internal.app.labeler.enums.SliceDirection.Transverse;
            self.ROI=medical.internal.app.labeler.view.roi.ROI();

            addlistener(self.ROI,'SetPriorMask',@(src,evt)self.reactToSetPriorMask(evt,self.ROI.getSliceIndex(),sliceDir));
            addlistener(self.ROI,'ROIUpdated',@(src,evt)self.reactToROIUpdated(evt,self.ROI.getSliceIndex(),sliceDir));
            addlistener(self.ROI,'ROIReassigned',@(src,evt)self.reactToROIReassigned(self.ROI.getSliceIndex(),sliceDir));
            addlistener(self.ROI,'ROIPasted',@(src,evt)self.reactToROIPasted(evt,self.ROI.getSliceIndex(),sliceDir));
            addlistener(self.ROI,'FillRegion',@(src,evt)self.reactToFillRegion(evt,self.ROI.getSliceIndex(),sliceDir));
            addlistener(self.ROI,'FloodFillRegion',@(src,evt)self.reactToFloodFillRegion(evt,self.ROI.getSliceIndex(),sliceDir));
            addlistener(self.ROI,'DrawingStarted',@(src,evt)notify(self,'DrawingStarted'));
            addlistener(self.ROI,'DrawingFinished',@(src,evt)notify(self,'DrawingFinished'));
            addlistener(self.ROI,'ROISelected',@(src,evt)notify(self,'ROISelected',evt));
            addlistener(self.ROI,'AllROIsSelected',@(src,evt)self.reactToAllROIsSelected(self.ROI.getSliceIndex(),sliceDir));
            addlistener(self.ROI,'DrawingAborted',@(src,evt)notify(self,'DrawingAborted'));
            addlistener(self.ROI,'CopyPasteUpdated',@(src,evt)notify(self,'CopyPasteUpdated',evt));

        end

    end


    methods(Access=protected)


        function reactToSetPriorMask(self,evt,idx,sliceDir)

            evt.SliceIdx=idx;
            evt.SliceDirection=sliceDir;
            notify(self,'SetPriorMask',evt)

        end


        function reactToROIUpdated(self,evt,idx,sliceDir)

            evt.SliceIdx=idx;
            evt.SliceDirection=sliceDir;
            notify(self,'ROIUpdated',evt)

        end


        function reactToROIReassigned(self,idx,sliceDir)

            evt=medical.internal.app.labeler.events.SliceEventData(idx,sliceDir);
            notify(self,'ROIReassigned',evt);

        end


        function reactToROIPasted(self,evt,idx,sliceDir)

            evt.SliceIdx=idx;
            evt.SliceDirection=sliceDir;
            notify(self,'ROIPasted',evt)

        end


        function reactToFillRegion(self,evt,idx,sliceDir)

            evt.SliceIdx=idx;
            evt.SliceDirection=sliceDir;
            notify(self,'FillRegion',evt)

        end


        function reactToFloodFillRegion(self,evt,idx,sliceDir)

            evt.SliceIdx=idx;
            evt.SliceDirection=sliceDir;
            notify(self,'FloodFillRegion',evt)

        end


        function reactToAllROIsSelected(self,idx,sliceDir)

            evt=medical.internal.app.labeler.events.SliceEventData(idx,sliceDir);
            notify(self,'AllROIsSelected',evt)

        end

    end


    methods


        function TF=getIsUserDrawing(self)
            TF=self.ROI.IsUserDrawing;
        end


        function setBrushColor(self,color)
            self.ROI.BrushColor=color;
        end

        function color=getBrushColor(self)
            color=self.ROI.BrushColor;
        end


        function setBrushOutline(self,TF)
            self.ROI.BrushOutline=TF;
        end

        function TF=getBrushOutline(self)
            TF=self.ROI.BrushOutline;
        end


        function setBrushSize(self,val)
            self.ROI.BrushSize=val;
        end

        function val=getBrushSize(self,~)
            val=self.ROI.BrushSize;
        end


        function setSelectAll(self,TF)
            self.ROI.SelectAll=TF;
        end

        function TF=getSelectAll(self,~)
            TF=self.ROI.SelectAll;
        end


        function mask=getReassignmentMask(self,~)
            mask=self.ROI.ReassignmentMask;
        end


        function set.Editable(self,TF)
            self.ROI.Editable=TF;
        end

        function TF=get.Editable(self)
            TF=self.ROI.Editable;
        end

    end

end