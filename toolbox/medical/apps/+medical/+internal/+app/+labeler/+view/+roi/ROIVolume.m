classdef ROIVolume<handle&matlab.mixin.SetGet




    properties

        ROITransverse medical.internal.app.labeler.view.roi.ROI
        ROISagittal medical.internal.app.labeler.view.roi.ROI
        ROICoronal medical.internal.app.labeler.view.roi.ROI

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


        function self=ROIVolume()

            self.wireupROITransverse();
            self.wireupROICoronal();
            self.wireupROISagittal();

        end


        function draw(self,val,color,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.draw(val,color);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.draw(val,color);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.draw(val,color);
            end

        end


        function drawAssisted(self,val,color,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.drawAssisted(val,color);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.drawAssisted(val,color);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.drawAssisted(val,color);
            end

        end


        function drawPolygon(self,val,color,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.drawPolygon(val,color);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.drawPolygon(val,color);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.drawPolygon(val,color);
            end

        end


        function paint(self,val,color,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.paint(val,color);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.paint(val,color);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.paint(val,color);
            end

        end


        function startLevelTrace(self,val,color)

            self.ROITransverse.startLevelTrace(val,color);
            self.ROICoronal.startLevelTrace(val,color);
            self.ROISagittal.startLevelTrace(val,color);

        end


        function stopLevelTrace(self)

            self.ROITransverse.stopLevelTrace();
            self.ROICoronal.stopLevelTrace();
            self.ROISagittal.stopLevelTrace();

        end


        function setLevelTraceThreshold(self,threshold)

            self.ROITransverse.setLevelTraceThreshold(threshold);
            self.ROICoronal.setLevelTraceThreshold(threshold);
            self.ROISagittal.setLevelTraceThreshold(threshold);

        end


        function fill(self,val,color,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.fill(val,color);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.fill(val,color);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.fill(val,color);
            end

        end


        function floodFill(self,val,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.floodFill(val);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.floodFill(val);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.floodFill(val);
            end

        end


        function preload(self,transverseIm,coronalIm,sagittalIm)

            self.ROITransverse.preload(transverseIm);
            self.ROICoronal.preload(coronalIm);
            self.ROISagittal.preload(sagittalIm);

        end


        function select(self,slice,cmap,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.select(slice,cmap);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.select(slice,cmap);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.select(slice,cmap);
            end

        end


        function selectWindow(self,slice,color,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.selectWindow(slice,color);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.selectWindow(slice,color);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.selectWindow(slice,color);
            end

        end


        function selectAll(self,slice,cmap,sliceDir)




            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.selectAll(slice,cmap);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.selectAll(slice,cmap);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.selectAll(slice,cmap);
            end

        end


        function selectAllInWindow(self,slice,cmap,window,sliceDir)



            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.selectAllInWindow(slice,cmap,window);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.selectAllInWindow(slice,cmap,window);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.selectAllInWindow(slice,cmap,window);
            end

        end


        function deselectAll(self,sliceDir)

            if nargin==1

                self.ROITransverse.deselectAll();
                self.ROICoronal.deselectAll();
                self.ROISagittal.deselectAll();

            else

                switch sliceDir
                case medical.internal.app.labeler.enums.SliceDirection.Transverse
                    self.ROITransverse.deselectAll();

                case medical.internal.app.labeler.enums.SliceDirection.Coronal
                    self.ROICoronal.deselectAll();

                case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                    self.ROISagittal.deselectAll();
                end

            end

        end


        function copy(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.copy();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.copy();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.copy();
            end

        end


        function cut(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.cut();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.cut();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.cut();
            end

        end


        function deleteSelected(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.deleteSelected();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.deleteSelected();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.deleteSelected();
            end

        end


        function paste(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.paste();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.paste();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.paste();
            end

        end


        function clear(self,sliceDir)

            if nargin==1

                self.ROITransverse.clear();
                self.ROICoronal.clear();
                self.ROISagittal.clear();

            else

                switch sliceDir
                case medical.internal.app.labeler.enums.SliceDirection.Transverse
                    self.ROITransverse.clear();

                case medical.internal.app.labeler.enums.SliceDirection.Coronal
                    self.ROICoronal.clear();

                case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                    self.ROISagittal.clear();
                end

            end

        end


        function clearBrush(self)
            self.ROITransverse.clearBrush();
            self.ROICoronal.clearBrush();
            self.ROISagittal.clearBrush();
        end


        function updateBrushOutline(self)
            self.ROITransverse.updateBrushOutline();
            self.ROICoronal.updateBrushOutline();
            self.ROISagittal.updateBrushOutline();
        end


        function updateContextMenu(self)
            self.ROITransverse.updateContextMenu();
            self.ROICoronal.updateContextMenu();
            self.ROISagittal.updateContextMenu();
        end


        function clearClipboard(self)
            self.ROITransverse.clearClipboard();
            self.ROICoronal.clearClipboard();
            self.ROISagittal.clearClipboard();
        end


        function updateRGBA(self,cmap)




            self.ROITransverse.updateRGBA(cmap);
            self.ROICoronal.updateRGBA(cmap);
            self.ROISagittal.updateRGBA(cmap);

        end


        function[roi,val,mask]=getSelection(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                [roi,val,mask]=self.ROITransverse.getSelection();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                [roi,val,mask]=self.ROICoronal.getSelection();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                [roi,val,mask]=self.ROISagittal.getSelection();
            end

        end


        function rotate(self,val,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.rotate(val);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.rotate(val);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.rotate(val);
            end

        end


        function updateSlice(self,slice,labelSlice,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.updateSlice(slice,labelSlice);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.updateSlice(slice,labelSlice);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.updateSlice(slice,labelSlice);
            end

        end


        function updateSliceIndex(self,idx,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.updateSliceIndex(idx);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.updateSliceIndex(idx);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.updateSliceIndex(idx);
            end

        end


        function idx=getSliceIndex(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                idx=self.ROITransverse.getSliceIndex();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                idx=self.ROICoronal.getSliceIndex();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                idx=self.ROISagittal.getSliceIndex();
            end

        end


        function L=generateSuperpixels(self,sz,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                L=self.ROITransverse.generateSuperpixels(sz);

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                L=self.ROICoronal.generateSuperpixels(sz);

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                L=self.ROISagittal.generateSuperpixels(sz);
            end

        end


        function generateMeanSuperpixels(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.generateMeanSuperpixels();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.generateMeanSuperpixels();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.generateMeanSuperpixels();
            end

        end


        function setFloodFillSettings(self,sz,tol)
            self.ROITransverse.setFloodFillSettings(sz,tol);
            self.ROICoronal.setFloodFillSettings(sz,tol);
            self.ROISagittal.setFloodFillSettings(sz,tol);
        end


        function setClickPosition(self,pos,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROITransverse.ClickPosition=pos;

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROICoronal.ClickPosition=pos;

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROISagittal.ClickPosition=pos;
            end

        end


        function val=getMeanSuperpixelsValue(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                val=self.ROITransverse.MeanSuperpixelValues;

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                val=self.ROICoronal.MeanSuperpixelValues;

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                val=self.ROISagittal.MeanSuperpixelValues;
            end

        end

    end


    methods(Access=protected)


        function wireupROITransverse(self)

            sliceDir=medical.internal.app.labeler.enums.SliceDirection.Transverse;
            self.ROITransverse=medical.internal.app.labeler.view.roi.ROI();

            addlistener(self.ROITransverse,'SetPriorMask',@(src,evt)self.reactToSetPriorMask(evt,self.ROITransverse.getSliceIndex(),sliceDir));
            addlistener(self.ROITransverse,'ROIUpdated',@(src,evt)self.reactToROIUpdated(evt,self.ROITransverse.getSliceIndex(),sliceDir));
            addlistener(self.ROITransverse,'ROIReassigned',@(src,evt)self.reactToROIReassigned(self.ROITransverse.getSliceIndex(),sliceDir));
            addlistener(self.ROITransverse,'ROIPasted',@(src,evt)self.reactToROIPasted(evt,self.ROITransverse.getSliceIndex(),sliceDir));
            addlistener(self.ROITransverse,'FillRegion',@(src,evt)self.reactToFillRegion(evt,self.ROITransverse.getSliceIndex(),sliceDir));
            addlistener(self.ROITransverse,'FloodFillRegion',@(src,evt)self.reactToFloodFillRegion(evt,self.ROITransverse.getSliceIndex(),sliceDir));
            addlistener(self.ROITransverse,'DrawingStarted',@(src,evt)notify(self,'DrawingStarted'));
            addlistener(self.ROITransverse,'DrawingFinished',@(src,evt)notify(self,'DrawingFinished'));
            addlistener(self.ROITransverse,'ROISelected',@(src,evt)notify(self,'ROISelected',evt));
            addlistener(self.ROITransverse,'AllROIsSelected',@(src,evt)self.reactToAllROIsSelected(self.ROITransverse.getSliceIndex(),sliceDir));
            addlistener(self.ROITransverse,'DrawingAborted',@(src,evt)notify(self,'DrawingAborted'));
            addlistener(self.ROITransverse,'CopyPasteUpdated',@(src,evt)notify(self,'CopyPasteUpdated',evt));
            addlistener(self.ROITransverse,'LevelTraceOutlineRefreshed',@(src,evt)self.levelTraceOutlineRefreshed(sliceDir));

        end


        function wireupROICoronal(self)

            sliceDir=medical.internal.app.labeler.enums.SliceDirection.Coronal;
            self.ROICoronal=medical.internal.app.labeler.view.roi.ROI();

            addlistener(self.ROICoronal,'SetPriorMask',@(src,evt)self.reactToSetPriorMask(evt,self.ROICoronal.getSliceIndex(),sliceDir));
            addlistener(self.ROICoronal,'ROIUpdated',@(src,evt)self.reactToROIUpdated(evt,self.ROICoronal.getSliceIndex(),sliceDir));
            addlistener(self.ROICoronal,'ROIReassigned',@(src,evt)self.reactToROIReassigned(self.ROICoronal.getSliceIndex(),sliceDir));
            addlistener(self.ROICoronal,'ROIPasted',@(src,evt)self.reactToROIPasted(evt,self.ROICoronal.getSliceIndex(),sliceDir));
            addlistener(self.ROICoronal,'FillRegion',@(src,evt)self.reactToFillRegion(evt,self.ROICoronal.getSliceIndex(),sliceDir));
            addlistener(self.ROICoronal,'FloodFillRegion',@(src,evt)self.reactToFloodFillRegion(evt,self.ROICoronal.getSliceIndex(),sliceDir));
            addlistener(self.ROICoronal,'DrawingStarted',@(src,evt)notify(self,'DrawingStarted'));
            addlistener(self.ROICoronal,'DrawingFinished',@(src,evt)notify(self,'DrawingFinished'));
            addlistener(self.ROICoronal,'ROISelected',@(src,evt)notify(self,'ROISelected',evt));
            addlistener(self.ROICoronal,'AllROIsSelected',@(src,evt)self.reactToAllROIsSelected(self.ROICoronal.getSliceIndex(),sliceDir));
            addlistener(self.ROICoronal,'DrawingAborted',@(src,evt)notify(self,'DrawingAborted'));
            addlistener(self.ROICoronal,'CopyPasteUpdated',@(src,evt)notify(self,'CopyPasteUpdated',evt));
            addlistener(self.ROICoronal,'LevelTraceOutlineRefreshed',@(src,evt)self.levelTraceOutlineRefreshed(sliceDir));

        end


        function wireupROISagittal(self)

            sliceDir=medical.internal.app.labeler.enums.SliceDirection.Sagittal;
            self.ROISagittal=medical.internal.app.labeler.view.roi.ROI();

            addlistener(self.ROISagittal,'SetPriorMask',@(src,evt)self.reactToSetPriorMask(evt,self.ROISagittal.getSliceIndex(),sliceDir));
            addlistener(self.ROISagittal,'ROIUpdated',@(src,evt)self.reactToROIUpdated(evt,self.ROISagittal.getSliceIndex(),sliceDir));
            addlistener(self.ROISagittal,'ROIReassigned',@(src,evt)self.reactToROIReassigned(self.ROISagittal.getSliceIndex(),sliceDir));
            addlistener(self.ROISagittal,'ROIPasted',@(src,evt)self.reactToROIPasted(evt,self.ROISagittal.getSliceIndex(),sliceDir));
            addlistener(self.ROISagittal,'FillRegion',@(src,evt)self.reactToFillRegion(evt,self.ROISagittal.getSliceIndex(),sliceDir));
            addlistener(self.ROISagittal,'FloodFillRegion',@(src,evt)self.reactToFloodFillRegion(evt,self.ROISagittal.getSliceIndex(),sliceDir));
            addlistener(self.ROISagittal,'DrawingStarted',@(src,evt)notify(self,'DrawingStarted'));
            addlistener(self.ROISagittal,'DrawingFinished',@(src,evt)notify(self,'DrawingFinished'));
            addlistener(self.ROISagittal,'ROISelected',@(src,evt)notify(self,'ROISelected',evt));
            addlistener(self.ROISagittal,'AllROIsSelected',@(src,evt)self.reactToAllROIsSelected(self.ROISagittal.getSliceIndex(),sliceDir));
            addlistener(self.ROISagittal,'DrawingAborted',@(src,evt)notify(self,'DrawingAborted'));
            addlistener(self.ROISagittal,'CopyPasteUpdated',@(src,evt)notify(self,'CopyPasteUpdated',evt));
            addlistener(self.ROISagittal,'LevelTraceOutlineRefreshed',@(src,evt)self.levelTraceOutlineRefreshed(sliceDir));

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


        function levelTraceOutlineRefreshed(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                self.ROICoronal.clearLevelTrace();
                self.ROISagittal.clearLevelTrace();

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                self.ROITransverse.clearLevelTrace();
                self.ROISagittal.clearLevelTrace();

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                self.ROITransverse.clearLevelTrace();
                self.ROICoronal.clearLevelTrace();
            end

        end

    end


    methods


        function TF=getIsUserDrawing(self)
            TF=self.ROITransverse.IsUserDrawing||self.ROICoronal.IsUserDrawing||self.ROISagittal.IsUserDrawing;
        end


        function setBrushColor(self,color)
            self.ROITransverse.BrushColor=color;
            self.ROICoronal.BrushColor=color;
            self.ROISagittal.BrushColor=color;
        end

        function color=getBrushColor(self)
            color=self.ROITransverse.BrushColor;
        end


        function setBrushOutline(self,TF)
            self.ROITransverse.BrushOutline=TF;
            self.ROICoronal.BrushOutline=TF;
            self.ROISagittal.BrushOutline=TF;
        end

        function TF=getBrushOutline(self)
            TF=self.ROITransverse.BrushOutline;
        end


        function setBrushSize(self,val)
            self.ROITransverse.BrushSize=val;
            self.ROICoronal.BrushSize=val;
            self.ROISagittal.BrushSize=val;
        end

        function val=getBrushSize(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                val=self.ROITransverse.BrushSize;

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                val=self.ROICoronal.BrushSize;

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                val=self.ROISagittal.BrushSize;
            end

        end


        function setSelectAll(self,TF)
            self.ROITransverse.SelectAll=TF;
            self.ROICoronal.SelectAll=TF;
            self.ROISagittal.SelectAll=TF;
        end

        function TF=getSelectAll(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                TF=self.ROITransverse.SelectAll;

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                TF=self.ROICoronal.SelectAll;

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                TF=self.ROISagittal.SelectAll;
            end

        end


        function mask=getReassignmentMask(self,sliceDir)

            switch sliceDir
            case medical.internal.app.labeler.enums.SliceDirection.Transverse
                mask=self.ROITransverse.ReassignmentMask;

            case medical.internal.app.labeler.enums.SliceDirection.Coronal
                mask=self.ROICoronal.ReassignmentMask;

            case medical.internal.app.labeler.enums.SliceDirection.Sagittal
                mask=self.ROISagittal.ReassignmentMask;
            end

        end


        function set.Editable(self,TF)
            self.ROITransverse.Editable=TF;
            self.ROICoronal.Editable=TF;
            self.ROISagittal.Editable=TF;
        end

        function TF=get.Editable(self)
            TF=self.ROITransverse.Editable;
        end

    end

end