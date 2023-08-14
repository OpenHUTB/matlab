classdef ROI<handle&matlab.mixin.SetGet




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


    properties(Dependent)


NumberInUse


Editable

BrushSize

BrushOutline

BrushColor

    end


    properties(Dependent,SetAccess=protected)

ImageSize

    end


    properties(Access={?images.internal.app.segmenter.volume.View,...
        ?medical.internal.app.labeler.view.roi.ROIVolume,...
        ?medical.internal.app.labeler.view.roi.ROIImage})

        ClickPosition(1,2)double=[0,0];

        ReassignmentMask logical=logical.empty;

MeanSuperpixelValues

    end


    properties(SetAccess=private,GetAccess=...
        {?images.internal.app.segmenter.volume.View,...
        ?medical.internal.app.labeler.view.roi.ROIVolume,...
        ?medical.internal.app.labeler.view.roi.ROIImage})

        SelectAll(1,1)logical=false;

        IsUserDrawing(1,1)logical=false;

    end


    properties(Access=protected,Hidden,Transient)


        NumberInUseInternal(1,1)double=0;

        BrushSizeInternal(1,1)double=0.5;

        ByPassSelectionStateUpdate(1,1)logical=false;

        FloodFillSensitivity(1,1)double=0.05;

        FloodFillSize(1,1)double=0.5;

Slice
ImageData

        CurrentIndex(1,1)double=1;

        SelectedPart='marker';


        InteractionsAllowedInternal char='all';

        Connectivity(1,1)double=4;


        ContextMenu matlab.ui.container.ContextMenu
        CutMenu matlab.ui.container.Menu
        CopyMenu matlab.ui.container.Menu
        PasteMenu matlab.ui.container.Menu
        SelectAllMenu matlab.ui.container.Menu
        ReassignMenu matlab.ui.container.Menu
        DeleteMenu matlab.ui.container.Menu
        AddWaypointMenu matlab.ui.container.Menu

        ImageContextMenu matlab.ui.container.ContextMenu
        ImageCutMenu matlab.ui.container.Menu
        ImageCopyMenu matlab.ui.container.Menu
        ImagePasteMenu matlab.ui.container.Menu
        ImageSelectAllMenu matlab.ui.container.Menu
        ImageReassignMenu matlab.ui.container.Menu
        ImageDeleteMenu matlab.ui.container.Menu

        ImageHandle matlab.graphics.primitive.Image

        Rotate images.internal.app.utilities.Rotate

    end


    properties(GetAccess={?images.uitest.factory.Tester,...
        ?uitest.factory.Tester,...
        ?medical.internal.app.labeler.view.roi.ROI},...
        SetAccess=private,Transient)

        Freehand images.roi.Freehand
        AssistedFreehand images.roi.AssistedFreehand
        Polygon images.roi.Polygon
        Brush images.roi.internal.PaintBrush
        Rectangle images.roi.Rectangle



AxesHandle

        Tag="ROIs"
    end


    methods




        function self=ROI()

            self.Rotate=images.internal.app.utilities.Rotate();

        end




        function draw(self,val,color)

            self.ByPassSelectionStateUpdate=true;
            deselectAll(self);
            self.ByPassSelectionStateUpdate=false;

            roi=getNextAvailableROI(self);

            set(roi,'Color',color,'UserData',val,'FaceAlpha',0.2,'DrawingArea','unlimited');

            beginDrawingFromPoint(roi,self.ClickPosition);

            if~isvalid(roi)
                return;
            end

            if isROIValid(self,roi)
                set(roi,'FaceAlpha',0,'Selected',true);
                updateSelectionState(self);
            else
                deselect(self,roi);
            end

        end




        function drawAssisted(self,val,color)

            self.ByPassSelectionStateUpdate=true;
            deselectAll(self);
            self.ByPassSelectionStateUpdate=false;

            set(self.AssistedFreehand,'Color',color,'UserData',val,'FaceAlpha',0.2,...
            'Image',self.ImageHandle,'Parent',self.AxesHandle);

            beginDrawingFromPoint(self.AssistedFreehand,self.ClickPosition);

            if~isvalid(self.AssistedFreehand)
                return;
            end

            set(self.AssistedFreehand,'FaceAlpha',0,'Selected',true);

            if isROIValid(self,self.AssistedFreehand)

                roi=getNextAvailableROI(self);

                set(roi,'FaceAlpha',0,'Selected',true,'Color',color,'UserData',val,...
                'Position',self.AssistedFreehand.Position,...
                'Waypoints',self.AssistedFreehand.Waypoints);

                updateSelectionState(self);

            end

            deselect(self,self.AssistedFreehand);

        end




        function drawPolygon(self,val,color)

            self.ByPassSelectionStateUpdate=true;
            deselectAll(self);
            self.ByPassSelectionStateUpdate=false;

            set(self.Polygon,'Color',color,'UserData',val,'FaceAlpha',0.2,...
            'Parent',self.AxesHandle,'DrawingArea','unlimited');

            beginDrawingFromPoint(self.Polygon,self.ClickPosition);

            if~isvalid(self.Polygon)
                return;
            end

            set(self.Polygon,'FaceAlpha',0,'Selected',true);

            if isROIValid(self,self.Polygon)

                roi=getNextAvailableROI(self);

                set(roi,'FaceAlpha',0,'Selected',true,'Color',color,'UserData',val,...
                'Position',self.Polygon.Position,...
                'Waypoints',true([size(self.Polygon.Position,1),1]));

                updateSelectionState(self);

            end

            deselect(self,self.Polygon);

        end




        function paint(self,val,color)

            deselectAll(self);

            priorColor=self.Brush.Color;

            set(self.Brush,'ImageSize',self.ImageSize,...
            'Color',color,'UserData',val,'BrushSize',self.BrushSize);

            beginDrawing(self.Brush);

            set(self.Brush,'Color',priorColor);

            mask=applyBackward(self.Rotate,self.Brush.Mask);

            if any(mask,"all")

                notify(self,'SetPriorMask',images.internal.app.segmenter.volume.events.PriorMaskEventData(false(size(mask)),logical.empty,uint8.empty));

                notify(self,'ROIUpdated',images.internal.app.segmenter.volume.events.ROIEventData(...
                mask,...
                self.Brush.UserData,...
                logical.empty,...
                0));

            end

        end




        function fill(self,val,~)

            deselectAll(self);

            mask=false(self.ImageSize);
            click=round(self.ClickPosition);

            mask(click(2),click(1))=true;

            mask=applyBackward(self.Rotate,mask);

            notify(self,'SetPriorMask',images.internal.app.segmenter.volume.events.PriorMaskEventData(false(size(mask)),logical.empty,uint8.empty));

            notify(self,'FillRegion',images.internal.app.segmenter.volume.events.ROIEventData(...
            mask,...
            val,...
            logical.empty,...
            0));

        end




        function floodFill(self,val)

            deselectAll(self);

            mask=false(self.ImageSize);
            click=round(self.ClickPosition);

            mask(click(2),click(1))=true;

            mask=applyBackward(self.Rotate,mask);

            if isempty(self.MeanSuperpixelValues)
                generateMeanSuperpixels(self);
            end

            notify(self,'SetPriorMask',images.internal.app.segmenter.volume.events.PriorMaskEventData(false(size(mask)),logical.empty,uint8.empty));

            notify(self,'FloodFillRegion',images.internal.app.segmenter.volume.events.FloodFillEventData(...
            mask,...
            val,...
            self.MeanSuperpixelValues,...
            self.FloodFillSensitivity));

        end




        function preload(self,img)

            self.ImageHandle=img;
            self.AxesHandle=img.Parent;

            createContextMenu(self,ancestor(self.AxesHandle,'figure'));



            create(self,100);

            self.AssistedFreehand=images.roi.AssistedFreehand(...
            'InteractionsAllowed',self.InteractionsAllowedInternal,...
            'FaceSelectable',false,...
            'Deletable',false,...
            'ContextMenu',self.ContextMenu);

            addlistener(self.AssistedFreehand,'ROIClicked',@(roi,evt)ROIIsClicked(self,roi,evt));
            addlistener(self.AssistedFreehand,'ROIMoved',@(roi,evt)labelMoved(self,roi,evt));
            addlistener(self.AssistedFreehand,'DrawingStarted',@(~,~)drawingHasStarted(self));
            addlistener(self.AssistedFreehand,'DrawingFinished',@(roi,~)drawingHasFinished(self,roi));

            addprop(self.AssistedFreehand,'Copied');
            self.AssistedFreehand.Copied=false;

            addprop(self.AssistedFreehand,'Pasted');
            self.AssistedFreehand.Pasted=false;

            addprop(self.AssistedFreehand,'CheckForHoles');
            self.AssistedFreehand.CheckForHoles=false;

            self.Polygon=images.roi.Polygon(...
            'InteractionsAllowed',self.InteractionsAllowedInternal,...
            'FaceSelectable',false,...
            'Deletable',false,...
            'ContextMenu',self.ContextMenu);

            addlistener(self.Polygon,'DrawingStarted',@(~,~)drawingHasStarted(self));
            addlistener(self.Polygon,'DrawingFinished',@(roi,~)drawingHasFinished(self,roi));

            addprop(self.Polygon,'Copied');
            self.Polygon.Copied=false;

            addprop(self.Polygon,'Pasted');
            self.Polygon.Pasted=false;

            addprop(self.Polygon,'CheckForHoles');
            self.Polygon.CheckForHoles=false;

            self.Brush=images.roi.internal.PaintBrush;
            self.Brush.Parent=self.AxesHandle;

            self.Rectangle=images.roi.Rectangle('FaceAlpha',0,...
            'Color',[0.5,0.5,0.5],'InteractionsAllowed','none',...
            'FaceSelectable',false,'LineWidth',1,'DrawingArea','unlimited');

        end




        function select(self,slice,cmap)

            slice=applyForward(self.Rotate,slice);

            click=round(self.ClickPosition);

            labelval=slice(click(2),click(1));

            if labelval>0


                BW=bwselect(slice==labelval,...
                click(1),click(2),self.Connectivity);

                pos=images.internal.builtins.bwborders(double(BW),self.Connectivity);

                data=fliplr(pos{1});

                roi=getNextAvailableROI(self);
                set(roi,'Position',data(1:end-1,:),'Color',cmap(labelval+1,:),'UserData',labelval,'Selected',true);

                BW=applyBackward(self.Rotate,BW);
                slice=applyBackward(self.Rotate,slice);

                notify(self,'SetPriorMask',images.internal.app.segmenter.volume.events.PriorMaskEventData(imfill(BW,self.Connectivity,'holes'),getHoleMask(self,BW,slice),getParentMask(self,BW,slice)));

            end

            updateSelectionState(self);

        end




        function selectWindow(self,slice,color)

            self.ByPassSelectionStateUpdate=true;
            deselectAll(self);
            self.ByPassSelectionStateUpdate=false;

            set(self.Rectangle,'Parent',self.AxesHandle)
            beginDrawingFromPoint(self.Rectangle,self.ClickPosition);

            set(self.Rectangle,'Parent',[]);



            if self.Rectangle.Position(3)>10||self.Rectangle.Position(4)>10
                selectAllInWindow(self,slice,color,self.Rectangle.Position);
            else
                select(self,slice,color);
            end

        end




        function selectAll(self,slice,cmap)

            self.SelectAll=false;

            self.ByPassSelectionStateUpdate=true;
            deselectAll(self);
            self.ByPassSelectionStateUpdate=false;

            self.Slice=slice;
            slice=applyForward(self.Rotate,slice);

            maxval=max(slice(:));

            for labelval=1:maxval




                pos=images.internal.builtins.bwborders(bwlabel(slice==labelval,self.Connectivity),self.Connectivity);

                for idx=1:numel(pos)

                    data=fliplr(pos{idx});

                    roi=getNextAvailableROI(self);
                    set(roi,'Position',data(1:end-1,:),'Color',cmap(labelval+1,:),'UserData',labelval,'Selected',true,'CheckForHoles',true);

                end

                updateSelectionState(self);

            end

            notify(self,'SetPriorMask',images.internal.app.segmenter.volume.events.PriorMaskEventData(applyBackward(self.Rotate,slice>0),logical.empty,uint8.empty));

        end




        function selectAllInWindow(self,slice,cmap,window)

            if window(3)==0||window(4)==0
                return;
            end

            self.Slice=slice;


            slice=applyForward(self.Rotate,slice);
            sz=size(slice);
            xCrop=[max(window(1),0.5),min(window(1)+window(3),sz(2)+0.5)];
            yCrop=[max(window(2),0.5),min(window(2)+window(4),sz(1)+0.5)];


            croppedSlice=zeros(size(slice));
            priorMask=false(size(slice));

            slice=slice(round(yCrop(1)+0.5):round(yCrop(2)-0.5),round(xCrop(1)+0.5):round(xCrop(2)-0.5));

            anySelected=false;

            maxval=max(slice(:));

            for labelval=1:maxval




                croppedSlice(round(yCrop(1)+0.5):round(yCrop(2)-0.5),round(xCrop(1)+0.5):round(xCrop(2)-0.5))=imclearborder(slice==labelval,self.Connectivity);
                priorMask=priorMask|croppedSlice;
                pos=images.internal.builtins.bwborders(bwlabel(croppedSlice,self.Connectivity),self.Connectivity);

                for idx=1:numel(pos)

                    data=fliplr(pos{idx});

                    roi=getNextAvailableROI(self);
                    set(roi,'Position',data(1:end-1,:),'Color',cmap(labelval+1,:),'UserData',labelval,'Selected',true,'CheckForHoles',true);
                    anySelected=true;

                end

            end

            updateSelectionState(self);

            if anySelected
                notify(self,'SetPriorMask',images.internal.app.segmenter.volume.events.PriorMaskEventData(applyBackward(self.Rotate,priorMask),logical.empty,uint8.empty));
            end

        end




        function deselectAll(self)
            deselect(self,self.Freehand);
        end




        function copy(self)


            set(self.Freehand,'Copied',false);


            idx=getSelectedROIs(self);

            if any(idx)
                set(self.Freehand(idx),'Copied',true,'Index',self.CurrentIndex);
            end

        end




        function cut(self)

            copy(self);
            deselectAll(self);

            idx=getCopiedROIs(self);

            if any(idx)
                cutROIs=self.Freehand(idx);

                mask=zeros(size(self.ImageHandle.CData,[1,2]),'logical');

                for i=1:numel(cutROIs)

                    mask=mask|createMask(cutROIs(i),self.ImageHandle);

                end

                mask=applyBackward(self.Rotate,mask);

                notify(self,'ROIUpdated',images.internal.app.segmenter.volume.events.ROIEventData(...
                mask,...
                0,...
                logical.empty,...
                0));

            end

        end




        function deleteSelected(self)

            idx=getSelectedROIs(self);

            if any(idx)
                selectedROIs=self.Freehand(idx);

                mask=zeros(size(self.ImageHandle.CData,[1,2]),'logical');

                for i=1:numel(selectedROIs)

                    mask=mask|createMask(selectedROIs(i),self.ImageHandle);

                end

                mask=applyBackward(self.Rotate,mask);

                deselectAll(self);

                notify(self,'ROIUpdated',images.internal.app.segmenter.volume.events.ROIEventData(...
                mask,...
                0,...
                logical.empty,...
                0));

            end

        end




        function paste(self)

            self.ByPassSelectionStateUpdate=true;
            deselectAll(self);
            self.ByPassSelectionStateUpdate=false;


            idx=getCopiedROIs(self);

            if any(idx)

                copiedROIs=self.Freehand(idx);

                pasteMask=zeros(size(self.ImageHandle.CData,[1,2]),'uint8');

                TF=numel(copiedROIs)>1;

                for i=1:numel(copiedROIs)

                    roi=getNextAvailableROI(self);
                    set(roi,'Position',copiedROIs(i).Position,'Color',copiedROIs(i).Color,...
                    'UserData',copiedROIs(i).UserData,'Selected',true,'Parent',self.AxesHandle,...
                    'Copied',false,'CheckForHoles',TF,'Pasted',TF,'Index',copiedROIs(i).Index);

                    mask=createMask(copiedROIs(i),self.ImageHandle);
                    pasteMask(mask)=copiedROIs(i).UserData;

                end

                pasteMask=applyBackward(self.Rotate,pasteMask);

                updateSelectionState(self);

                notify(self,'SetPriorMask',images.internal.app.segmenter.volume.events.PriorMaskEventData(false(size(pasteMask)),logical.empty,uint8.empty));

                notify(self,'ROIPasted',images.internal.app.segmenter.volume.events.ROIEventData(...
                pasteMask,...
                [],...
                logical.empty,...
                0));

            else
                updateSelectionState(self);
            end

        end




        function clear(self)

            set(self.Freehand,'Copied',false);
            deselectAll(self);
            clear(self.Rotate);
        end




        function clearBrush(self)
            clear(self.Brush);
        end




        function updateBrushOutline(self)
            self.Brush.BrushSize=self.BrushSize;
        end




        function updateContextMenu(self)

            n=sum(getSelectedROIs(self));

            if n>0
                self.CutMenu.Enable='on';
                self.CopyMenu.Enable='on';
                self.DeleteMenu.Enable='on';
                self.ReassignMenu.Enable='on';
                self.ImageCutMenu.Enable='on';
                self.ImageCopyMenu.Enable='on';
                self.ImageDeleteMenu.Enable='on';
                self.ImageReassignMenu.Enable='on';
            else
                self.CutMenu.Enable='off';
                self.CopyMenu.Enable='off';
                self.DeleteMenu.Enable='off';
                self.ReassignMenu.Enable='off';
                self.ImageCutMenu.Enable='off';
                self.ImageCopyMenu.Enable='off';
                self.ImageDeleteMenu.Enable='off';
                self.ImageReassignMenu.Enable='off';
            end

            if n==1
                self.AddWaypointMenu.Enable='on';
            else
                self.AddWaypointMenu.Enable='off';
            end

            if any(getCopiedROIs(self))
                self.PasteMenu.Enable='on';
                self.ImagePasteMenu.Enable='on';
            else
                self.PasteMenu.Enable='off';
                self.ImagePasteMenu.Enable='off';
            end

        end




        function clearClipboard(self)

            deselectAll(self);
            removeCopy(self);

        end




        function updateRGBA(self,cmap)

            idx=getSelectedROIs(self)|getCopiedROIs(self);

            if any(idx)

                selectedROIs=self.Freehand(idx);

                for i=1:numel(selectedROIs)

                    set(selectedROIs(i),'Color',cmap(selectedROIs(i).UserData+1,:));

                end

            end

        end




        function[roi,val,mask]=getSelection(self)

            idx=getSelectedROIs(self);

            if any(idx)

                selectedROIs=self.Freehand(idx);



                if numel(selectedROIs)>1
                    roi=[];
                    val=[];
                    mask=logical.empty;
                else
                    mask=createMask(selectedROIs(1),self.ImageHandle);
                    mask=applyBackward(self.Rotate,mask);
                    pos=images.internal.builtins.bwborders(double(mask),self.Connectivity);

                    roi=fliplr(pos{1});
                    roi=roi(1:end-1,:);

                    val=selectedROIs(1).UserData;
                end

            else

                roi=[];
                val=[];
                mask=logical.empty;

            end

        end




        function rotate(self,val)
            rotate(self.Rotate,val);
        end




        function updateSlice(self,img,slice)
            self.Slice=slice;
            self.ImageData=img;
        end




        function updateSliceIndex(self,idx)
            self.CurrentIndex=idx;
        end




        function idx=getSliceIndex(self)
            idx=self.CurrentIndex;
        end




        function L=generateSuperpixels(self,sz)

            if isempty(sz)
                L=[];
                self.MeanSuperpixelValues=[];
            else

                imSize=size(self.ImageData);
                self.Brush.ImageSize=imSize(1:2);
                L=superpixels(self.ImageData,round((((imSize(1)*imSize(2))/100)*((1-sz)))+100));
            end

            self.Brush.Superpixels=L;

        end




        function generateMeanSuperpixels(self)


            imSize=size(self.ImageData);
            sz=self.FloodFillSize;

            nRequested=round((((imSize(1)*imSize(2))/100)*((1-sz)))+100);
            nChannels=size(self.ImageData,3);

            if nChannels==3
                im=rgb2lab(self.ImageData);
                [L,n]=superpixels(im,nRequested,'IsInputLab',true);
                meanFeatures=images.internal.builtins.meanSuperpixelFeatures(im,L,n,nChannels);

                R=zeros(size(L),'like',L);
                G=zeros(size(L),'like',L);
                B=zeros(size(L),'like',L);
                for labelVal=1:n
                    R(L==labelVal)=meanFeatures(labelVal,1);
                    G(L==labelVal)=meanFeatures(labelVal,2);
                    B(L==labelVal)=meanFeatures(labelVal,3);
                end

                val(:,:,1)=R;
                val(:,:,2)=G;
                val(:,:,3)=B;

            else
                im=im2double(self.ImageData);
                [L,n]=superpixels(self.ImageData,nRequested);
                meanFeatures=images.internal.builtins.meanSuperpixelFeatures(im,L,n,nChannels);

                val=zeros(size(L),'like',L);
                for labelVal=1:n
                    val(L==labelVal)=meanFeatures(labelVal,1);
                end

            end

            self.MeanSuperpixelValues=val;

        end




        function setFloodFillSettings(self,sz,tol)

            self.FloodFillSensitivity=tol;
            self.FloodFillSize=sz;
            self.MeanSuperpixelValues=[];

        end

    end


    methods(Access=protected)


        function labelDrawn(self,roi)

            mask=createMask(roi,self.ImageHandle);

            if~any(mask)
                deselect(self,roi);
            else

                mask=applyBackward(self.Rotate,mask);

                notify(self,'SetPriorMask',images.internal.app.segmenter.volume.events.PriorMaskEventData(false(size(mask)),logical.empty,uint8.empty));

                notify(self,'ROIUpdated',images.internal.app.segmenter.volume.events.ROIEventData(...
                mask,...
                roi.UserData,...
                logical.empty,...
                0));

            end

        end


        function reassignSelected(self)

            idx=getSelectedROIs(self);

            if any(idx)

                selectedROIs=self.Freehand(idx);

                mask=zeros(size(self.ImageHandle.CData,[1,2]),'logical');

                for i=1:numel(selectedROIs)

                    mask=mask|createMask(selectedROIs(i),self.ImageHandle);

                end

                mask=applyBackward(self.Rotate,mask);

                self.ReassignmentMask=mask;
                deselectAll(self);

                notify(self,'ROIReassigned');

            end

        end


        function deselect(self,roi)

            set(roi,'Selected',false,'CheckForHoles',false,'Pasted',false);
            set(roi,'Parent',gobjects(0));

            updateSelectionState(self);

        end


        function deselectOtherROIs(self,roi)


            idx=roi~=self.Freehand;


            deselect(self,self.Freehand(idx));

        end


        function create(self,n)


            for idx=1:n

                h=images.roi.Freehand(...
                'InteractionsAllowed',self.InteractionsAllowedInternal,...
                'Multiclick',true,...
                'FaceSelectable',false,...
                'Deletable',false,...
                'ContextMenu',self.ContextMenu,...
                'Smoothing',0);

                addlistener(h,'ROIClicked',@(roi,evt)ROIIsClicked(self,roi,evt));
                addlistener(h,'ROIMoved',@(roi,evt)labelMoved(self,roi,evt));
                addlistener(h,'DrawingStarted',@(~,~)drawingHasStarted(self));
                addlistener(h,'DrawingFinished',@(roi,~)drawingHasFinished(self,roi));

                addprop(h,'Copied');
                h.Copied=false;

                addprop(h,'Pasted');
                h.Pasted=false;

                addprop(h,'Index');

                addprop(h,'CheckForHoles');
                h.CheckForHoles=false;

                self.Freehand=[self.Freehand;h];

            end

        end


        function removeCopy(self)

            set(self.Freehand,'Copied',false);

        end


        function updateSelectionState(self)

            if~self.ByPassSelectionStateUpdate

                val=sum(getSelectedROIs(self));

                notify(self,'ROISelected',images.internal.app.segmenter.volume.events.ROISelectedEventData(val));
                notify(self,'CopyPasteUpdated',images.internal.app.segmenter.volume.events.CopyPasteUpdatedEventData(val>0,sum(getCopiedROIs(self))>0));

            end

        end


        function idx=getParentedROIs(self)
            idx=cellfun(@(x)~isempty(x),get(self.Freehand,'Parent'));
        end


        function idx=getSelectedROIs(self)
            idx=cellfun(@(x)logical(x),get(self.Freehand,'Selected'));
        end


        function idx=getCopiedROIs(self)
            idx=cellfun(@(x)logical(x),get(self.Freehand,'Copied'));
        end


        function roi=getNextAvailableROI(self)



            idx=find(~getCopiedROIs(self)&~getSelectedROIs(self),1);

            if isempty(idx)

                create(self,1);
                roi=self.Freehand(end);
            else
                roi=self.Freehand(idx);
            end


            roi.Parent=self.AxesHandle;

        end


        function TF=isROIValid(~,roi)


            TF=isvalid(roi)&&~isempty(roi.Position)&&size(roi.Position,1)>=3;
        end


        function ROIIsClicked(self,roi,evt)

            switch evt.SelectionType
            case 'ctrl'

                deselect(self,roi);
            case 'right'


            otherwise

                deselectOtherROIs(self,roi);

                if roi.CheckForHoles

                    slice=applyForward(self.Rotate,self.Slice);
                    BW=createMask(roi,slice);


                    mask=bwperim(BW);

                    border=slice(mask);

                    if~isempty(border)&&all(border==border(1))
                        [row,col]=find(mask,1);
                        BW=bwselect(slice==border(1),col,row,self.Connectivity);
                    end

                    BW=applyBackward(self.Rotate,BW);
                    slice=applyBackward(self.Rotate,slice);

                    priorMask=imfill(BW,self.Connectivity,'holes');
                    holeMask=getHoleMask(self,BW,slice);
                    parentMask=getParentMask(self,BW,slice);

                    if roi.Pasted
                        if roi.Index==self.CurrentIndex








                            parentMask=uint8.empty;
                            priorMask=false(size(priorMask));
                        else


                            priorMask=logical.empty;
                        end
                    end

                    roi.Pasted=false;
                    roi.CheckForHoles=false;
                    notify(self,'SetPriorMask',images.internal.app.segmenter.volume.events.PriorMaskEventData(priorMask,holeMask,parentMask));

                end
            end

            self.SelectedPart=evt.SelectedPart;

        end


        function selectAllFromContextMenu(self)

            self.SelectAll=true;

            notify(self,'AllROIsSelected')

        end


        function labelMoved(self,roi,evt)

            if~self.IsUserDrawing



                [m,n,~]=size(self.ImageHandle.CData);


                mask=createMask(roi,m,n);


                xData=self.ImageHandle.XData;
                yData=self.ImageHandle.YData;

                xROI=axes2pix(n,xData,evt.PreviousPosition(:,1));
                yROI=axes2pix(m,yData,evt.PreviousPosition(:,2));

                if strcmp(self.SelectedPart,'marker')
                    offset=[0,0];
                else
                    offset=applyOffsetBackward(self.Rotate,evt.CurrentPosition(1,:)-evt.PreviousPosition(1,:));
                end

                previousMask=poly2mask(xROI,yROI,m,n);

                mask=applyBackward(self.Rotate,mask);
                previousMask=applyBackward(self.Rotate,previousMask);

                notify(self,'ROIUpdated',images.internal.app.segmenter.volume.events.ROIEventData(...
                mask,...
                roi.UserData,...
                previousMask,...
                offset));
            end

        end


        function drawingHasStarted(self)

            self.IsUserDrawing=true;

            notify(self,'DrawingStarted');

        end


        function drawingHasFinished(self,roi)

            self.IsUserDrawing=false;

            notify(self,'DrawingFinished');

            if isROIValid(self,roi)
                labelDrawn(self,roi);
            else
                deselect(self,roi);
                notify(self,'DrawingAborted');
            end

        end


        function mask=getParentMask(self,BW,slice)




            BW=imfill(BW,'holes');
            mask=imdilate(BW,ones(3,3))&~BW;

            border=slice(mask);

            if~isempty(border)&&all(border==border(1))
                [row,col]=find(mask,1);

                mask=bwselect(slice==border(1),col,row,self.Connectivity)|BW;
                mask=uint8(mask).*border(1);
            else

                mask=uint8.empty;
            end

        end


        function mask=getHoleMask(self,BW,~)



            L=getHoles(self,BW);

            if all(L==0)
                mask=logical.empty;
            else
                mask=L>0;
            end

        end


        function L=getHoles(self,BW)



            if(self.Connectivity==4)
                backgroundConn=8;
            else
                backgroundConn=4;
            end


            BWcomplement=imcomplement(BW);


            BWholes=imclearborder(BWcomplement,backgroundConn);


            L=bwlabel(BWholes,backgroundConn);

        end


        function addWaypoint(self)

            idx=getSelectedROIs(self);

            if sum(idx)==1
                onLineClickAddWaypoint(self.Freehand(idx));
            end

        end


        function createContextMenu(self,fig)


            cmenu=uicontextmenu(fig);

            self.AddWaypointMenu=uimenu(cmenu,'Label',getString(message('images:imroi:addWaypoint')),'MenuSelectedFcn',@(~,~)addWaypoint(self),'Tag','AddWaypoint');
            self.CutMenu=uimenu(cmenu,'Label',getString(message('images:segmenter:cut')),'MenuSelectedFcn',@(~,~)cut(self),'Tag','Cut','Accelerator','X','Separator','on');
            self.CopyMenu=uimenu(cmenu,'Label',getString(message('images:segmenter:copy')),'MenuSelectedFcn',@(~,~)copy(self),'Tag','Copy','Accelerator','C');
            self.PasteMenu=uimenu(cmenu,'Label',getString(message('images:segmenter:paste')),'MenuSelectedFcn',@(~,~)paste(self),'Tag','Paste','Accelerator','V');
            self.SelectAllMenu=uimenu(cmenu,'Label',getString(message('images:segmenter:selectAll')),'MenuSelectedFcn',@(~,~)selectAllFromContextMenu(self),'Tag','SelectAll','Accelerator','A');
            self.ReassignMenu=uimenu(cmenu,'Label',getString(message('images:segmenter:reassign')),'MenuSelectedFcn',@(~,~)reassignSelected(self),'Tag','Reassign','Separator','on');
            self.DeleteMenu=uimenu(cmenu,'Label',getString(message('images:segmenter:delete')),'MenuSelectedFcn',@(~,~)deleteSelected(self),'Tag','Delete');

            immenu=uicontextmenu(fig,'ContextMenuOpeningFcn',@(~,~)updateContextMenu(self));

            self.ImageCutMenu=uimenu(immenu,'Label',getString(message('images:segmenter:cut')),'MenuSelectedFcn',@(~,~)cut(self),'Tag','Cut','Accelerator','X');
            self.ImageCopyMenu=uimenu(immenu,'Label',getString(message('images:segmenter:copy')),'MenuSelectedFcn',@(~,~)copy(self),'Tag','Copy','Accelerator','C');
            self.ImagePasteMenu=uimenu(immenu,'Label',getString(message('images:segmenter:paste')),'MenuSelectedFcn',@(~,~)paste(self),'Tag','Paste','Accelerator','V');
            self.ImageSelectAllMenu=uimenu(immenu,'Label',getString(message('images:segmenter:selectAll')),'MenuSelectedFcn',@(~,~)selectAllFromContextMenu(self),'Tag','SelectAll','Accelerator','A');
            self.ImageReassignMenu=uimenu(immenu,'Label',getString(message('images:segmenter:reassign')),'MenuSelectedFcn',@(~,~)reassignSelected(self),'Tag','Reassign','Separator','on');
            self.ImageDeleteMenu=uimenu(immenu,'Label',getString(message('images:segmenter:delete')),'MenuSelectedFcn',@(~,~)deleteSelected(self),'Tag','Delete');

            self.ImageHandle.UIContextMenu=immenu;

            self.ContextMenu=cmenu;

        end

    end

    methods




        function set.Editable(self,TF)





            if TF
                self.InteractionsAllowedInternal='all';
            else
                self.InteractionsAllowedInternal='none';
            end
            set(self.Freehand,'InteractionsAllowed',self.InteractionsAllowedInternal);

        end

        function TF=get.Editable(self)

            TF=strcmp(self.InteractionsAllowedInternal,'all');

        end




        function set.BrushSize(self,val)

            if val<0
                val=0;
            elseif val>1
                val=1;
            end
            self.BrushSizeInternal=val;
            self.Brush.BrushSize=self.BrushSize;
        end

        function val=get.BrushSize(self)
            minSize=min(self.ImageSize(1:2));




            val=round(self.BrushSizeInternal*minSize*0.1)+1;
        end




        function val=get.ImageSize(self)

            val=[0,0];
            if~isempty(self.ImageHandle.CData)
                val=[self.ImageHandle.YData(2),self.ImageHandle.XData(2)];
            end

        end




        function set.BrushColor(self,color)
            self.Brush.Color=color;
        end

        function color=get.BrushColor(self)
            color=self.Brush.Color;
        end




        function set.BrushOutline(self,TF)
            self.Brush.OutlineVisible=TF;
        end

        function TF=get.BrushOutline(self)
            TF=self.Brush.OutlineVisible;
        end

    end

    methods(Access=?uitest.factory.Tester)
        function setClickPosition(self,value)

            self.ClickPosition=value;
        end
    end


end