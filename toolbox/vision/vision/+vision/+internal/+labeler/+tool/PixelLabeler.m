
classdef PixelLabeler<vision.internal.labeler.tool.ROILabeler



    properties(Dependent)
LabelMatrix
Colormap
MarkerSize
Mode
Alpha
    end

    properties(Access=private)
        ShowTutorial=true;
    end

    properties(Access=protected)

Polygon
LabelMatrixInternal





LabelMatrixChange

ColormapInternal
        MarkerSizeInternal=0.5;
        ModeInternal='polygon';
        AlphaInternal=0.5;

GrabCut
GrabCutPolygon
BackgroundInd
ForegroundInd
hForeLine
hBackLine

Freehand

Image
ImageSize
ImageFilename
LabelMatrixFilename
ImageIndex
        ImageChange=true
        IncludeList=1:255;

PaintBrushLayout
SuperpixelLabel
SuperpixelLabelMatrix
SuperpixelBoundaryMask
        SuperpixelCount=400;
        SuperpixelState=false;
    end

    properties
ColorLookupTable


        LabelVisibility(255,1)logical=true(255,1)
    end

    events


PolygonStarted
PolygonFinished


AppWaitStarted
AppWaitFinished


GrabCutEditEnabled
GrabCutEditDisabled



TempPixelUpdate
    end

    methods

        function this=PixelLabeler()
            this.ColorLookupTable=single(squeeze(vision.internal.labeler.getColorMap('pixel')));
        end




        function I=preprocessImageData(this,data)

            if isempty(this.Image)



                I=im2single(data.Image);
            else
                I=this.Image;
            end



            localColorLookUpTable=this.getColorLookupTable();

            if~isempty(this.LabelMatrix)&&max(this.LabelMatrix(:))>0&&ismatrix(this.LabelMatrix)
                I=images.internal.labeloverlayalgo(I,double(this.LabelMatrix),localColorLookUpTable,this.Alpha,this.IncludeList);
            end

        end

        function info=getLabelAndColorData(this,data)

            if isempty(this.Image)



                I=data.Image;
            else
                I=this.Image;
            end



            cmap=this.getColorLookupTable();
            info.cmap=[cmap(1,:);cmap];
            info.label=getVisibleLabelMatrix(this,this.LabelMatrix);
            info.alpha=this.Alpha;
            info.I=I;
        end




        function finalize(this)



            commitPolygon(this);
            commitFreehand(this);
            commitGrabCut(this);
            clearGrabCutLines(this);
            commitSuperpixel(this);

            if~isempty(this.LabelMatrix)


                labelData.Label=this.LabelMatrix;
                labelData.Color=[];
                labelData.Position=this.LabelMatrixFilename;
                labelData.Shape=labelType.PixelLabel;
                labelData.Index=this.ImageIndex;




                evtData=vision.internal.labeler.tool.PixelLabelEventData(labelData,false);

                notify(this,'LabelIsChanged',evtData);
            end

        end




        function reset(this,data)

            delete(this.Polygon)
            this.Polygon=[];


            delete(this.GrabCutPolygon)
            this.GrabCutPolygon=[];
            this.GrabCut=[];
            clearGrabCutLines(this);
            this.Image=vision.internal.labeler.normalizeImageData(data.Image);

            this.ImageSize=size(data.Image);
            this.attachPaintBrushLayout();
            this.LabelMatrix=data.LabelMatrix;
            this.Colormap=single(squeeze(vision.internal.labeler.getColorMap('pixel')));
            this.ImageFilename=data.ImageFilename;
            this.LabelMatrixFilename=data.LabelMatrixFilename;
            this.ImageIndex=data.ImageIndex;
            this.ImageChange=true;
        end

        function setLabelMatrixFilename(this,fullfilename)
            this.LabelMatrixFilename=fullfilename;
        end

        function setHandles(this,hFig,hAx,hIm)

            this.ImageHandle=hIm;
            this.AxesHandle=hAx;
            this.Figure=hFig;

        end




        function addPolygon(this,labelVal,color)


            images.roi.internal.setROIPointer(this.Figure,'crosshair');

            prepareToDraw(this);

            selectedROI=images.roi.Polygon(...
            'Parent',this.AxesHandle,...
            'MinimumNumberOfPoints',3,...
            'Color',color,...
            'Tag',this.SelectedLabel.Label,...
            'UserData',labelVal,...
            'DrawingArea',[0.5,0.5,this.ImageHandle.XData(2),this.ImageHandle.YData(2)],...
            'FaceSelectable',false,...
            'FaceAlpha',0);

            notify(this,'PolygonStarted');

            cp=this.AxesHandle.CurrentPoint;
            selectedROI.beginDrawingFromPoint([cp(1,1),cp(1,2)]);

            if~isvalid(this)||~isvalid(this.Figure)
                return;
            end
            notify(this,'PolygonFinished');



            if this.checkROIValidity(selectedROI)

                wirePolygonListeners(this,selectedROI);
                commitPreviousROI(this);
                this.Polygon=selectedROI;
                this.updateSemanticView()
            else



                delete(selectedROI);
                displayPreviousROI(this);
            end




            if isvalid(this.Figure)
                setPointer(this);
            end

        end




        function addAssistedFreehand(this,labelVal,color)


            images.roi.internal.setROIPointer(this.Figure,'crosshair');

            prepareToDraw(this);

            selectedROI=images.roi.AssistedFreehand(...
            'Parent',this.AxesHandle,...
            'Image',this.ImageHandle,...
            'Color',color,...
            'Tag',this.SelectedLabel.Label,...
            'UserData',labelVal,...
            'FaceSelectable',false,...
            'FaceAlpha',0);

            notify(this,'PolygonStarted');

            cp=this.AxesHandle.CurrentPoint;
            selectedROI.beginDrawingFromPoint([cp(1,1),cp(1,2)]);

            if~isvalid(this)||~isvalid(this.Figure)
                return;
            end
            notify(this,'PolygonFinished');



            if this.checkROIValidity(selectedROI)

                wireFreehandListeners(this,selectedROI);
                commitPreviousROI(this);
                this.Freehand=selectedROI;
                this.updateSemanticView()

            else



                delete(selectedROI);
                displayPreviousROI(this);
            end




            if isvalid(this.Figure)
                setPointer(this);
            end

        end




        function addGrabCutPolygon(this,labelVal,color)


            images.roi.internal.setROIPointer(this.Figure,'crosshair');

            prepareToDraw(this);

            selectedROI=images.roi.Polygon(...
            'Parent',this.AxesHandle,...
            'MinimumNumberOfPoints',3,...
            'Color',color,...
            'StripeColor',[1,1,1],...
            'Tag',this.SelectedLabel.Label,...
            'UserData',labelVal,...
            'DrawingArea',[0.5,0.5,this.ImageHandle.XData(2),this.ImageHandle.YData(2)],...
            'FaceSelectable',false,...
            'FaceAlpha',0);

            notify(this,'PolygonStarted');

            cp=this.AxesHandle.CurrentPoint;
            selectedROI.beginDrawingFromPoint([cp(1,1),cp(1,2)]);

            if~isvalid(this)
                return;
            end
            notify(this,'PolygonFinished');



            if this.checkROIValidity(selectedROI)

                wireGrabCutPolygonListeners(this,selectedROI);
                commitPreviousROI(this);
                this.GrabCutPolygon=selectedROI;
                this.setGrabCutPolygon(true);

            else



                delete(selectedROI);
                displayPreviousROI(this);
            end

            updateGrabCutEditor(this);




            if isvalid(this.Figure)
                setPointer(this);
            end

        end




        function addPaintBrush(this,labelVal,color)

            prepareToDraw(this);

            set(this.PaintBrushLayout,'Color',color);
            set(this.PaintBrushLayout,'UserData',labelVal);
            set(this.PaintBrushLayout,'BrushSize',this.MarkerSize);

            this.PaintBrushLayout.beginDrawing();
            this.commitMaskToLabelMatrix(this.PaintBrushLayout);

            this.updateSemanticView()
            clear(this.PaintBrushLayout);


            setPointer(this);
        end




        function addFloodFill(this,labelVal,color)

            prepareToDraw(this);

            selectedROI=images.internal.drawingTools.PaintBrush(this.AxesHandle,this.ImageSize);
            selectedROI.Color=color;
            selectedROI.Label=this.SelectedLabel.Label;
            selectedROI.UserData=labelVal;

            point=round(this.AxesHandle.CurrentPoint);
            row=max(min(point(1,2),size(this.Image,1)),1);
            col=max(min(point(1,1),size(this.Image,2)),1);

            im=sum((this.Image-this.Image(row,col,:)).^2,3);
            im=mat2gray(im);

            tol=0.05;

            selectedROI.Mask=grayconnected(im,row,col,tol);
            this.commitMaskToLabelMatrix(selectedROI);

            this.updateSemanticView()

        end

        function addSuperpixelGrid(this,labelVal,color)

            this.LabelMatrixInternal=this.SuperpixelLabelMatrix;

            prepareToDraw(this);

            set(this.PaintBrushLayout,'Color',color);
            set(this.PaintBrushLayout,'UserData',labelVal);

            this.PaintBrushLayout.beginDrawing();

            this.commitMaskToLabelMatrix(this.PaintBrushLayout);

            this.updateSemanticView()
            clear(this.PaintBrushLayout);

            this.SuperpixelLabelMatrix=this.LabelMatrixInternal;

            L=this.LabelMatrixInternal;
            L(this.SuperpixelBoundaryMask)=this.PaintBrushLayout.UserData;
            this.LabelMatrixInternal=L;

            this.updateSemanticViewTemp();
        end

        function attachPaintBrushLayout(this)
            if isempty(this.PaintBrushLayout)
                this.PaintBrushLayout=images.roi.internal.PaintBrush;
            end

            if~isempty(this.Image)
                set(this.PaintBrushLayout,'Parent',this.AxesHandle,...
                'BrushSize',this.MarkerSize,...
                'ImageSize',size(this.Image,1:2));
            end
        end

        function updateSuperpixelState(this)
            if this.SuperpixelState
                updateSuperpixelGrid(this,this.SuperpixelCount,false);
            end
        end

        function updateSuperpixelLayoutState(this,state)
            this.SuperpixelState=state;
            if~state
                this.updateSemanticViewTemp();
            end
        end

        function setSuperpixelParams(this,superpixCount)
            this.SuperpixelCount=superpixCount;
        end

        function resetSuperPixelLayout(this)
            commitSuperpixel(this);
            updateSuperpixelGrid(this,0,true);
        end

        function updateSuperpixelGrid(this,superpixCount,disableGrid)
            if disableGrid
                if~(strcmp(this.Mode,'draw')...
                    ||strcmp(this.Mode,'erase'))
                    disableBrushOutline(this);
                end

                this.SuperpixelState=false;
                if isempty(this.SuperpixelLabelMatrix)
                    return;
                end
                this.LabelMatrixInternal=this.SuperpixelLabelMatrix;
                this.updateSemanticViewTemp();
                if superpixCount==0
                    this.SuperpixelLabelMatrix=[];
                    return;
                end
            end

            selectedROI=images.internal.drawingTools.PaintBrush(this.AxesHandle,this.ImageSize);
            selectedROI.Color=this.SelectedLabel.Color;
            selectedROI.Label=this.SelectedLabel.Label;
            selectedROI.UserData=this.SelectedLabel.PixelLabelID;

            if this.SuperpixelCount~=superpixCount||...
                any(this.ImageSize(1:2)~=size(this.SuperpixelLabel))||...
                this.ImageChange

                notify(this,'AppWaitStarted');



                maxRange=numel(this.Image(:,:,1))/16;
                conversionFactor=1000/log(maxRange);

                [L,~]=superpixels(this.Image,round(exp(superpixCount/conversionFactor))+1);
                this.SuperpixelLabel=L;

                if isempty(this.PaintBrushLayout)
                    this.PaintBrushLayout=images.roi.internal.PaintBrush;
                end

                set(this.PaintBrushLayout,'ImageSize',size(this.SuperpixelLabel));

                this.SuperpixelBoundaryMask=boundarymask(this.SuperpixelLabel,4);
                this.ImageChange=false;
            end
            set(this.PaintBrushLayout,'Parent',this.AxesHandle,...
            'Superpixels',this.SuperpixelLabel,'OutlineVisible',true);

            selectedROI.Mask=this.SuperpixelBoundaryMask;
            this.SuperpixelLabelMatrix=this.LabelMatrixInternal;

            L=this.LabelMatrixInternal;
            mask=selectedROI.Mask;
            L(mask)=selectedROI.UserData;
            this.LabelMatrixInternal=L;

            this.SuperpixelState=true;
            this.updateSemanticViewTemp();

            notify(this,'AppWaitFinished');
            this.SuperpixelCount=superpixCount;
        end

        function updateBrushOutline(this,color)
            if strcmp(this.Mode,'draw')...
                ||strcmp(this.Mode,'superpixel')
                state=true;
            elseif strcmp(this.Mode,'erase')
                color=[1,1,1];
                state=true;
            else
                state=false;
            end

            if~isempty(this.PaintBrushLayout)
                set(this.PaintBrushLayout,'Color',color);
                set(this.PaintBrushLayout,'OutlineVisible',state,...
                'ImageSize',size(this.Image,1:2),...
                'BrushSize',this.MarkerSize);

                if~strcmp(this.Mode,'superpixel')
                    set(this.PaintBrushLayout,'Superpixels',[]);
                end
            end
        end

        function disableBrushOutline(this)
            if~isempty(this.PaintBrushLayout)
                set(this.PaintBrushLayout,'OutlineVisible',false);
            end
        end

        function addGrabCutEdit(this,editmode)

            markerSize=1+round(mean(this.ImageSize)/100);

            point=round(this.AxesHandle.CurrentPoint(1,1:2));

            hAx=this.AxesHandle;
            hFig=this.Figure;

            isPointOutsideROI=this.isROIValid(this.GrabCutPolygon)&&~this.GrabCutPolygon.inROI(point(1),point(2));

            isForeOrBack=strcmpi(editmode,'fore')||strcmpi(editmode,'back');

            if isPointOutsideROI&&isForeOrBack
                point=[NaN,NaN];
            end

            switch editmode
            case 'fore'
                if isempty(this.hForeLine)
                    createForegroundLine(this);
                    this.hForeLine.XData=point(1);
                    this.hForeLine.YData=point(2);
                    set(this.hForeLine,'Visible','on');
                else
                    this.hForeLine.XData(end+1)=NaN;
                    this.hForeLine.YData(end+1)=NaN;
                end
            case 'back'
                if isempty(this.hBackLine)
                    createBackgroundLine(this);
                    this.hBackLine.XData=point(1);
                    this.hBackLine.YData=point(2);
                    set(this.hBackLine,'Visible','on');
                else
                    this.hBackLine.XData(end+1)=NaN;
                    this.hBackLine.YData(end+1)=NaN;
                end
            end

            if~isempty(this.hForeLine)
                uistack(this.hForeLine,'top');
            end

            scribbleDrag();
            oldMotionFcn=hFig.WindowButtonMotionFcn;
            hFig.WindowButtonMotionFcn=@scribbleDrag;
            hFig.WindowButtonUpFcn=@scribbleUp;

            function scribbleDrag(~,~)

                point=hAx.CurrentPoint;
                point=round(point(1,1:2));
                axesPosition=[1,1,this.ImageSize(2)-1,this.ImageSize(1)-1];

                if(isClickOutsideAxes(point,axesPosition))
                    return;
                end

                isPointOutsideROI=this.isROIValid(this.GrabCutPolygon)&&~this.GrabCutPolygon.inROI(point(1),point(2));

                isForeOrBack=strcmpi(editmode,'fore')||strcmpi(editmode,'back');
                if isPointOutsideROI&&isForeOrBack
                    point=[NaN,NaN];
                end

                switch editmode
                case 'fore'
                    if~isempty(this.hForeLine)
                        this.hForeLine.XData(end+1)=point(1);
                        this.hForeLine.YData(end+1)=point(2);
                    end
                case 'back'
                    if~isempty(this.hBackLine)
                        this.hBackLine.XData(end+1)=point(1);
                        this.hBackLine.YData(end+1)=point(2);
                    end
                case 'erase'
                    XMin=point(1)-markerSize;
                    XMax=point(1)+markerSize;
                    YMin=point(2)-markerSize;
                    YMax=point(2)+markerSize;

                    if~isempty(this.hForeLine)
                        QueryForeData=(this.hForeLine.XData>XMin)&...
                        (this.hForeLine.XData<XMax)&...
                        (this.hForeLine.YData>YMin)&...
                        (this.hForeLine.YData<YMax);

                        this.hForeLine.XData(QueryForeData)=NaN;
                        this.hForeLine.YData(QueryForeData)=NaN;
                    end

                    if~isempty(this.hBackLine)
                        QueryBackData=(this.hBackLine.XData>XMin)&...
                        (this.hBackLine.XData<XMax)&...
                        (this.hBackLine.YData>YMin)&...
                        (this.hBackLine.YData<YMax);

                        this.hBackLine.XData(QueryBackData)=NaN;
                        this.hBackLine.YData(QueryBackData)=NaN;
                    end
                end

            end

            function scribbleUp(~,~)

                scribbleDrag();
                hFig.WindowButtonMotionFcn=oldMotionFcn;
                hFig.WindowButtonUpFcn=[];

                emptyLinesBeforeDraw=isempty(this.ForegroundInd)&&isempty(this.BackgroundInd);

                if~isempty(this.hForeLine)
                    cleanXData=this.hForeLine.XData(~isnan(this.hForeLine.XData));
                    cleanYData=this.hForeLine.YData(~isnan(this.hForeLine.YData));
                    this.ForegroundInd=unique(sub2ind(this.ImageSize,cleanYData,cleanXData));
                end

                if~isempty(this.hBackLine)
                    cleanXData=this.hBackLine.XData(~isnan(this.hBackLine.XData));
                    cleanYData=this.hBackLine.YData(~isnan(this.hBackLine.YData));
                    this.BackgroundInd=unique(sub2ind(this.ImageSize,cleanYData,cleanXData));
                end

                emptyLinesAfterDraw=isempty(this.ForegroundInd)&&isempty(this.BackgroundInd);
                noMarksAdded=emptyLinesBeforeDraw&&emptyLinesAfterDraw;

                if noMarksAdded


                    return;
                end

                this.addMarksToGrabCut();

            end

        end




        function rois=getSelectedROIsForCopy(this)

            rois=[];
            if this.isROIValid(this.Polygon)
                copiedData=this.getCopiedData(this.Polygon);
                copiedData.shape='pixel';
                rois=copiedData;
            end
        end




        function pasteSelectedROIs(this,copiedData)

            if isempty(copiedData)
                return;
            end

            commitPolygon(this);

            this.Polygon=images.roi.Polygon(...
            'Parent',this.AxesHandle,...
            'UserData',copiedData.UserData,...
            'Tag',copiedData.Tag,...
            'Color',copiedData.Color,...
            'MinimumNumberOfPoints',3,...
            'Visible',copiedData.Visible,...
            'DrawingArea',[0.5,0.5,this.ImageHandle.XData(2),this.ImageHandle.YData(2)],...
            'Position',copiedData.Position,...
            'FaceSelectable',false,...
            'FaceAlpha',0);

            wirePolygonListeners(this,this.Polygon);
        end

        function pasteSelectedFreehand(this,copiedData)

            if isempty(copiedData)
                return;
            end

            commitFreehand(this);

            this.Freehand=images.roi.AssistedFreehand(...
            'Parent',this.AxesHandle,...
            'Image',this.ImageHandle,...
            'UserData',copiedData.UserData,...
            'Tag',copiedData.Tag,...
            'Color',copiedData.Color,...
            'Position',copiedData.Position,...
            'Visible',copiedData.Visible,...
            'Waypoints',copiedData.Waypoints,...
            'FaceSelectable',false,...
            'FaceAlpha',0);

            wireFreehandListeners(this,this.Freehand);
        end




        function commitPolygon(this)

            if this.isROIValid(this.Polygon)
                oldROI=this.Polygon;
                this.commitPolygonToLabelMatrix(oldROI);
                delete(oldROI)
                this.Polygon=[];
            end
        end




        function commitFreehand(this)

            if this.isROIValid(this.Freehand)
                oldROI=this.Freehand;
                this.commitPolygonToLabelMatrix(oldROI);
                delete(oldROI)
                this.Freehand=[];
            end
        end




        function commitGrabCut(this)

            if this.isROIValid(this.GrabCutPolygon)
                oldROI=this.GrabCutPolygon;
                this.commitGrabCutToLabelMatrix(oldROI);
                delete(oldROI)
                this.GrabCutPolygon=[];
                clearGrabCutLines(this);
                updateGrabCutEditor(this);
            end
        end




        function commitSuperpixel(this)
            if~isempty(this.SuperpixelLabelMatrix)
                this.LabelMatrixInternal=this.SuperpixelLabelMatrix;
                this.SuperpixelLabelMatrix=[];
            end
        end




        function deletePolygon(this)
            if this.isROIValid(this.Polygon)
                oldROI=this.Polygon;
                delete(oldROI)
                this.Polygon=[];
                this.updateSemanticView();
            end
        end


        function restoreGrabCutState(this,copiedData)

            this.GrabCutPolygon=images.roi.Polygon('Parent',this.AxesHandle,...
            'MinimumNumberOfPoints',3,...
            'Color',copiedData.GrabCutPolygon.Color,...
            'Tag',copiedData.GrabCutPolygon.Label,...
            'UserData',copiedData.GrabCutPolygon.UserData,...
            'Visible',copiedData.GrabCutPolygon.Visible,...
            'StripeColor',[1,1,1],...
            'DrawingArea',[0.5,0.5,this.ImageHandle.XData(2),this.ImageHandle.YData(2)],...
            'Position',copiedData.GrabCutPolygon.Position,...
            'FaceSelectable',false,...
            'FaceAlpha',0);

            wireGrabCutPolygonListeners(this,this.GrabCutPolygon);

            this.ForegroundInd=copiedData.ForegroundInd;
            this.BackgroundInd=copiedData.BackgroundInd;

            hasMarks=~isempty(copiedData.ForegroundInd)||~isempty(copiedData.BackgroundInd);

            if hasMarks

                if~isempty(copiedData.hForeLine.XData)
                    createForegroundLine(this);
                    set(this.hForeLine,'XData',copiedData.hForeLine.XData,'YData',copiedData.hForeLine.YData,...
                    'Visible','on');
                end

                if~isempty(copiedData.hBackLine.XData)
                    createBackgroundLine(this);
                    set(this.hBackLine,'XData',copiedData.hBackLine.XData,'YData',copiedData.hBackLine.YData,...
                    'Visible','on');
                end

                this.setGrabCutPolygon(false);
                this.addMarksToGrabCut();
            else
                this.setGrabCutPolygon(false);
            end

        end


        function deletePixelLabelData(this,pixelID)
            L=this.LabelMatrixInternal;
            L(L==pixelID)=0;
            this.LabelMatrix=L;
            this.updateSemanticView();
        end


        function updateGrabCutEditor(this)
            if this.isROIValid(this.GrabCutPolygon)&&this.GrabCutPolygon.Visible
                notify(this,'GrabCutEditEnabled');
            else
                notify(this,'GrabCutEditDisabled');
            end
        end


        function setPointer(this)
            switch this.ModeInternal
            case{'polygon','grabcutpolygon','grabcutauto','assistedfreehand'}

                images.roi.internal.setROIPointer(this.Figure,'crosshair');
            case 'floodfill'

                myPointer=this.paintBucketPointer;
                set(this.Figure,'Pointer','custom','PointerShapeCData',myPointer,'PointerShapeHotSpot',[16,16]);
            case{'draw','grabcutforeground','grabcutbackground'}

                myPointer=this.pencilPointer;
                set(this.Figure,'Pointer','custom','PointerShapeCData',myPointer,'PointerShapeHotSpot',[16,1]);
            case{'erase','grabcuterase'}

                myPointer=transpose(this.pencilPointer);
                set(this.Figure,'Pointer','custom','PointerShapeCData',myPointer,'PointerShapeHotSpot',[16,1]);
            otherwise
                set(this.Figure,'Pointer','arrow');
            end
        end


        function deletePixelROIs(this)

            commitPreviousROI(this);
            switch this.Mode
            case{'polygon'}
                this.Polygon=[];
            case{'grabcutpolygon'}
                this.GrabCutPolygon=[];
            case{'assistedfreehand'}
                this.Freehand=[];
            end
            this.setLabelMatrixInternal(zeros(size(this.LabelMatrixInternal),'uint8'));
            this.updateSemanticView();

            if this.SuperpixelState
                this.updateSuperpixelState();
            else
                this.updateSemanticViewTemp();
            end
        end


        function clipboard=copyPixelROIs(this)




            if this.isROIValid(this.Polygon)
                clipboard.CopyMode='polygon';
                clipboard.ActiveROIs=getUndoPlaceholder(this);
            elseif this.isROIValid(this.GrabCutPolygon)
                clipboard.CopyMode='grabcutpolygon';
                clipboard.ActiveROIs=getUndoPlaceholder(this);
            elseif this.isROIValid(this.Freehand)
                clipboard.CopyMode='assistedfreehand';
                clipboard.ActiveROIs=getUndoPlaceholder(this);
            else
                clipboard.ActiveROIs=[];
            end

            if this.SuperpixelState
                clipboard.Mask=this.SuperpixelLabelMatrix;
            else
                clipboard.Mask=this.LabelMatrixInternal;
            end
        end


        function pastePixelROIs(this,PixelClipboard)



            [y_extent,x_extent]=size(this.LabelMatrix);



            LabelMatrixChangeTemp=this.LabelMatrixInternal;

            commitPreviousROI(this);
            if~isempty(PixelClipboard.ActiveROIs)
                if strcmp(PixelClipboard.CopyMode,'grabcutpolygon')
                    polyPts=PixelClipboard.ActiveROIs.GrabCutPolygon.Position;
                else
                    polyPts=PixelClipboard.ActiveROIs.Position;
                end

                if((max(polyPts(:,1))<x_extent)&&(max(polyPts(:,2))<y_extent))
                    switch(PixelClipboard.CopyMode)
                    case{'grabcutpolygon'}
                        this.restoreGrabCutState(PixelClipboard.ActiveROIs)
                    case{'polygon'}
                        this.pasteSelectedROIs(PixelClipboard.ActiveROIs);
                    case{'assistedfreehand'}
                        this.pasteSelectedFreehand(PixelClipboard.ActiveROIs);
                    end
                end
            end

            clipboardMask=PixelClipboard.Mask;

            [newMaskRows,newMaskCols]=size(this.LabelMatrix);
            [clipboardRow,clipboardCol]=size(clipboardMask);
            padCols=0;padRows=0;
            if clipboardCol<x_extent
                padCols=x_extent-clipboardCol;
            elseif clipboardCol>x_extent
                newMaskCols=x_extent-1;
            end

            if clipboardRow<y_extent
                padRows=y_extent-clipboardRow;
            elseif clipboardRow>y_extent
                newMaskRows=y_extent-1;
            end

            clipboardMask=padarray(clipboardMask,[padRows,padCols],0,'post');
            clipboardMask=imcrop(clipboardMask,[1,1,newMaskCols,newMaskRows]);





            if this.SuperpixelState
                LabelMatrixInternalTemp=(this.SuperpixelLabelMatrix-...
                this.SuperpixelLabelMatrix.*uint8(clipboardMask>0));
            else
                LabelMatrixInternalTemp=(this.LabelMatrixInternal-...
                this.LabelMatrixInternal.*uint8(clipboardMask>0));
            end

            LabelMatrixInternalTemp=clipboardMask+LabelMatrixInternalTemp;

            this.setLabelMatrixInternal(LabelMatrixInternalTemp);


            this.LabelMatrixChange=int16(this.LabelMatrixInternal)-...
            int16(LabelMatrixChangeTemp);

            if this.SuperpixelState
                this.updateSuperpixelState();
            end
            this.updateSemanticView();
        end
    end

    methods(Access=protected)

        function onButtonDown(this,varargin)

            try




                mouseClickType=get(this.Figure,'SelectionType');
                labelVal=this.SelectedLabel.PixelLabelID;
                color=this.SelectedLabel.Color;

                if~ismatrix(this.LabelMatrix)
                    return
                end

                switch mouseClickType
                case 'normal'
                    switch this.ModeInternal
                    case 'polygon'
                        addPolygon(this,labelVal,color);
                    case 'assistedfreehand'
                        addAssistedFreehand(this,labelVal,color);
                    case 'floodfill'
                        addFloodFill(this,labelVal,color);
                    case 'draw'
                        addPaintBrush(this,labelVal,color);
                    case 'erase'
                        addPaintBrush(this,0,[1,1,1]);
                    case{'grabcutpolygon','grabcutauto'}
                        addGrabCutPolygon(this,labelVal,color);
                    case 'grabcutforeground'
                        addGrabCutEdit(this,'fore');
                    case 'grabcutbackground'
                        addGrabCutEdit(this,'back');
                    case 'grabcuterase'
                        addGrabCutEdit(this,'erase');
                    case 'superpixel'
                        addSuperpixelGrid(this,labelVal,color);
                    end
                case 'extend'
                    if~any(strcmp(this.ModeInternal,{'grabcutforeground','grabcutbackground','grabcuterase'}))
                        fillUnlabeledRegions(this,labelVal);
                    end
                otherwise
                    return;
                end
            catch

            end
        end


        function undoData=getUndoPlaceholder(this)
            if this.isROIValid(this.Polygon)

                undoData=this.getCopiedData(this.Polygon);

            elseif this.isROIValid(this.Freehand)

                undoData=this.getCopiedData(this.Freehand);

            elseif this.isROIValid(this.GrabCutPolygon)

                undoData.GrabCutPolygon=this.getCopiedData(this.GrabCutPolygon);
                undoData.ForegroundInd=this.ForegroundInd;
                undoData.BackgroundInd=this.BackgroundInd;
                if~isempty(this.hForeLine)
                    undoData.hForeLine.XData=this.hForeLine.XData;
                    undoData.hForeLine.YData=this.hForeLine.YData;
                else
                    undoData.hForeLine.XData=[];
                    undoData.hForeLine.YData=[];
                end
                if~isempty(this.hBackLine)
                    undoData.hBackLine.XData=this.hBackLine.XData;
                    undoData.hBackLine.YData=this.hBackLine.YData;
                else
                    undoData.hBackLine.XData=[];
                    undoData.hBackLine.YData=[];
                end

            else
                undoData=[];
            end
        end


        function prepareToDraw(this)


            if this.isROIValid(this.Polygon)
                this.Polygon.Visible='off';
            end


            if this.isROIValid(this.Freehand)
                this.Freehand.Visible='off';
            end


            showGrabCutLines(this,'off');

            if this.isROIValid(this.GrabCutPolygon)
                this.GrabCutPolygon.Visible='off';
            end

        end


        function L=createLabelMatrix(this)

            L=this.LabelMatrixInternal;

            if this.isROIValid(this.Polygon)&&strcmp(this.Polygon.Visible,'on')
                mask=this.Polygon.createMask(this.ImageSize(1),this.ImageSize(2));
                L(mask)=this.Polygon.UserData;
            end

            if this.isROIValid(this.Freehand)&&strcmp(this.Freehand.Visible,'on')
                mask=this.Freehand.createMask(this.ImageSize(1),this.ImageSize(2));
                L(mask)=this.Freehand.UserData;
            end

            if this.isROIValid(this.GrabCutPolygon)&&strcmp(this.GrabCutPolygon.Visible,'on')
                mask=this.GrabCut.Mask;
                L(mask)=this.GrabCutPolygon.UserData;
            end
        end


        function commitPolygonToLabelMatrix(this,selectedROI)
            L=this.LabelMatrixInternal;
            mask=selectedROI.createMask(this.ImageSize(1),this.ImageSize(2));
            L(mask)=selectedROI.UserData;
            this.setLabelMatrixInternal(L);
        end


        function setGrabCutPolygon(this,toUpdateSemanticView)



            notify(this,'AppWaitStarted');
            if isempty(this.GrabCut)
                numSuperPixels=min(numel(this.Image),10000);
                [L,N]=superpixels(this.Image,numSuperPixels);
                this.GrabCut=images.graphcut.internal.grabcut(this.Image,L,N,8,5);
            end
            this.GrabCut=this.GrabCut.addBoundingBox(this.GrabCutPolygon.Position);
            notify(this,'AppWaitFinished');
            if toUpdateSemanticView
                this.updateSemanticView();
            end
        end


        function setGrabCutPolygonPassThrough(this)




            this.LabelMatrixChange=zeros(size(this.LabelMatrixInternal),'int16');
            this.setGrabCutPolygon(true);
        end


        function addMarksToGrabCut(this)
            this.GrabCut=this.GrabCut.addHardConstraints(this.ForegroundInd,this.BackgroundInd);
            this.GrabCut=this.GrabCut.segment();
            if(isempty(this.ForegroundInd)&&isempty(this.BackgroundInd))&&max(this.GrabCut.Mask(:))==0



                this.GrabCut=this.GrabCut.addBoundingBox(this.GrabCutPolygon.Position);
            end
            this.updateSemanticView();
        end

        function createForegroundLine(this)
            colorSpec=[0.467,.675,0.188];
            this.hForeLine=line('Parent',this.AxesHandle,'Color',colorSpec,'Visible','off',...
            'LineWidth',2,'HitTest','off','tag','scribbleLine',...
            'PickableParts','none','HandleVisibility','off',...
            'Marker','.','MarkerSize',10,'MarkerEdgeColor',colorSpec,...
            'MarkerFaceColor',colorSpec);
        end

        function createBackgroundLine(this)
            colorSpec=[0.635,0.078,0.184];
            this.hBackLine=line('Parent',this.AxesHandle,'Color',colorSpec,'Visible','off',...
            'LineWidth',2,'HitTest','off','tag','scribbleLine',...
            'PickableParts','none','HandleVisibility','off',...
            'Marker','.','MarkerSize',10,'MarkerEdgeColor',colorSpec,...
            'MarkerFaceColor',colorSpec);
        end


        function clearGrabCutLines(this)
            this.BackgroundInd=[];
            this.ForegroundInd=[];
            delete(this.hForeLine);
            delete(this.hBackLine);
            this.hForeLine=[];
            this.hBackLine=[];
        end

        function showGrabCutLines(this,vis)

            if~isempty(this.hForeLine)
                set(this.hForeLine,'Visible',vis);
            end

            if~isempty(this.hBackLine)
                set(this.hBackLine,'Visible',vis);
            end

        end


        function commitMaskToLabelMatrix(this,selectedROI)





            LMTemp=this.LabelMatrixInternal;

            if this.isROIValid(this.Polygon)
                commitPolygon(this);
            elseif this.isROIValid(this.GrabCutPolygon)
                commitGrabCut(this);
            elseif this.isROIValid(this.Freehand)
                commitFreehand(this);
            end

            L=this.LabelMatrixInternal;

            mask=selectedROI.Mask;
            L(mask)=selectedROI.UserData;
            this.setLabelMatrixInternal(L);






            this.LabelMatrixChange=int16(L)-int16(LMTemp);
        end


        function commitGrabCutToLabelMatrix(this,selectedROI)
            L=this.LabelMatrixInternal;
            mask=this.GrabCut.Mask;
            L(mask)=selectedROI.UserData;
            this.setLabelMatrixInternal(L);
        end


        function updateSemanticView(this)
            data.Image=this.Image;
            data.ImageFilename=this.ImageFilename;
            data.Position=this.LabelMatrixFilename;
            data.Index=this.ImageIndex;
            data.ForceRedraw=true;
            data.Label=this.LabelMatrix;

            evtData=vision.internal.labeler.tool.PixelLabelEventData(data);

            notify(this,'ImageIsChanged',evtData);

        end


        function updateSemanticViewTemp(this)




            data.Image=this.Image;
            data.ImageFilename=this.ImageFilename;
            data.Position=this.LabelMatrixFilename;
            data.Index=this.ImageIndex;
            data.ForceRedraw=true;
            data.Label=this.LabelMatrix;

            evtData=vision.internal.labeler.tool.PixelLabelEventData(data);

            notify(this,'TempPixelUpdate',evtData);

        end


        function updateSemanticViewPassThrough(this)




            this.LabelMatrixChange=zeros(size(this.LabelMatrixInternal),'int16');
            this.updateSemanticView();
        end


        function prepareToDelete(this)

            this.Polygon=images.roi.Polygon();
            deleteROI(this);

        end


        function prepareToDeleteFreehand(this)

            this.Freehand=images.roi.AssistedFreehand();
            deleteROI(this);

        end


        function deleteROI(this)
            if~isvalid(this)
                return;
            end
            this.LabelMatrixChange=...
            zeros(size(this.LabelMatrixInternal),'int16');
            this.updateSemanticView();
        end


        function deleteGrabCut(this)

            if~isvalid(this)
                return;
            end

            removePreviousROI(this);

            updateGrabCutEditor(this);
            deleteROI(this);

            notify(this,'GrabCutEditDisabled');
        end


        function fillUnlabeledRegions(this,labelVal)
            if~isvalid(this)
                return;
            end

            finalize(this);
            L=this.LabelMatrixInternal;
            L(this.LabelMatrix==0)=labelVal;
            this.setLabelMatrixInternal(L);
            this.updateSemanticView()
        end


        function wirePolygonListeners(this,selectedROI)
            addlistener(selectedROI,'VertexAdded',@(~,~)this.updateSemanticViewPassThrough());
            addlistener(selectedROI,'VertexDeleted',@(~,~)this.updateSemanticViewPassThrough());
            addlistener(selectedROI,'DeletingROI',@(~,~)this.prepareToDelete());
            addlistener(selectedROI,'ROIMoved',@(~,~)this.updateSemanticViewPassThrough());
            addlistener(selectedROI,'MovingROI',@(~,~)this.updateSemanticViewTemp());
        end


        function wireFreehandListeners(this,selectedROI)
            addlistener(selectedROI,'WaypointAdded',@(~,~)this.updateSemanticViewPassThrough());
            addlistener(selectedROI,'WaypointRemoved',@(~,~)this.updateSemanticViewPassThrough());
            addlistener(selectedROI,'DeletingROI',@(~,~)this.prepareToDeleteFreehand());
            addlistener(selectedROI,'ROIMoved',@(~,~)this.updateSemanticViewPassThrough());
            addlistener(selectedROI,'MovingROI',@(~,~)this.updateSemanticViewTemp());
        end

        function wireGrabCutPolygonListeners(this,selectedROI)
            addlistener(selectedROI,'VertexAdded',@(~,~)this.setGrabCutPolygonPassThrough());
            addlistener(selectedROI,'VertexDeleted',@(~,~)this.setGrabCutPolygonPassThrough());
            addlistener(selectedROI,'DeletingROI',@(~,~)this.deleteGrabCut());
            addlistener(selectedROI,'ROIMoved',@(~,~)this.setGrabCutPolygonPassThrough());
        end


        function wirePaintBrushListeners(this,selectedROI)
            addlistener(selectedROI,'MaskEdited',@(~,~)this.updateSemanticView());
        end

        function removePreviousROI(this)

            if this.isROIValid(this.Polygon)


                oldROI=this.Polygon;
                delete(oldROI)
                this.Polygon=[];

            elseif this.isROIValid(this.GrabCutPolygon)

                oldROI=this.GrabCutPolygon;
                delete(oldROI)
                this.GrabCutPolygon=[];
                clearGrabCutLines(this);

            elseif this.isROIValid(this.Freehand)


                oldROI=this.Freehand;
                delete(oldROI)
                this.Freehand=[];
            end

        end

        function commitPreviousROI(this)



            if this.isROIValid(this.Polygon)
                oldROI=this.Polygon;
                this.commitPolygonToLabelMatrix(oldROI);
                delete(oldROI)
            elseif this.isROIValid(this.GrabCutPolygon)
                oldROI=this.GrabCutPolygon;
                this.commitGrabCutToLabelMatrix(oldROI);
                delete(oldROI)
                this.GrabCutPolygon=[];
                clearGrabCutLines(this);
            elseif this.isROIValid(this.Freehand)
                oldROI=this.Freehand;
                this.commitPolygonToLabelMatrix(oldROI);
                delete(oldROI)
            else




                this.LabelMatrixChange=...
                zeros(size(this.LabelMatrixInternal),'int16');
            end
        end

        function displayPreviousROI(this)

            if this.isROIValid(this.Polygon)
                this.Polygon.Visible='on';
            elseif this.isROIValid(this.GrabCutPolygon)
                this.GrabCutPolygon.Visible='on';
                showGrabCutLines(this,'on');
            elseif this.isROIValid(this.Freehand)
                this.Freehand.Visible='on';
            end

        end

        function TF=isROIValid(this,roi)




            TF=~isempty(roi)&&this.checkROIValidity(roi);

        end

    end

    methods



        function set.LabelMatrix(this,L)

            this.LabelMatrixChange=[];
            this.setLabelMatrixInternal(L);
        end


        function L=get.LabelMatrix(this)
            L=createLabelMatrix(this);
        end



        function set.Colormap(this,cmap)
            assert(size(cmap,2)==3,'Invalid Colormap');
            this.ColormapInternal=cmap;
        end

        function cmap=get.Colormap(this)
            cmap=this.ColormapInternal;
        end



        function set.Mode(this,str)
            if any(strcmp(str,{'polygon','draw','erase','floodfill','assistedfreehand',...
                'grabcutpolygon','grabcutauto','grabcutforeground','grabcutbackground','grabcuterase','superpixel'}))
                this.ModeInternal=str;
                setPointer(this);

                if this.ShowTutorial&&strcmp(str,'grabcutpolygon')
                    this.createTutorialDialog();
                end
            end
        end

        function setMode(this,str,showTutorial)
            this.ShowTutorial=showTutorial;
            this.Mode=str;

            color=[1,1,1];
            if~isempty(this.SelectedLabel)
                color=this.SelectedLabel.Color;
            end
            updateBrushOutline(this,color);
        end

        function str=get.Mode(this)
            str=this.ModeInternal;
        end



        function set.Alpha(this,val)
            assert(val>=0&&val<=100,'Invalid Alpha');
            this.AlphaInternal=val/100;
            updateSemanticView(this);
        end

        function val=get.Alpha(this)
            val=this.AlphaInternal;
        end



        function set.MarkerSize(this,val)

            assert(val>=0&&val<=100,'Invalid MarkerSize');
            this.MarkerSizeInternal=val/100;

            if~isempty(this.PaintBrushLayout)
                this.PaintBrushLayout.BrushSize=this.MarkerSize;
            end
        end

        function val=get.MarkerSize(this)
            minSize=min(this.ImageSize(1:2));




            val=round(this.MarkerSizeInternal*minSize*0.1)+1;
        end


        function showBrushMarker(this,color)
            if isempty(this.PaintBrushLayout)
                this.PaintBrushLayout=images.roi.internal.PaintBrush;
                set(this.PaintBrushLayout,'BrushSize',this.MarkerSize);
            end

            if~isempty(this.Image)
                set(this.PaintBrushLayout,'Parent',this.AxesHandle,...
                'ImageSize',size(this.Image,1:2),...
                'Color',color,'Superpixels',[],...
                'OutlineVisible',true);
            end
        end


        function updatePixelLabelerLookup(this,color,pixelID)
            this.ColorLookupTable(pixelID,:)=color;
        end


        function updateActivePolygonColorInCurrentFrame(this,labelName,color)

            switch this.ModeInternal
            case 'polygon'
                if~isempty(this.Polygon)&&strcmp(this.Polygon.Tag,labelName)
                    this.Polygon.Color=color;
                end
            case 'assistedfreehand'
                if~isempty(this.Freehand)&&strcmp(this.Freehand.Tag,labelName)
                    this.Freehand.Color=color;
                end
            case{'grabcutpolygon'}
                if~isempty(this.GrabCutPolygon)&&strcmp(this.GrabCutPolygon.Tag,labelName)
                    this.GrabCutPolygon.Color=color;
                end
            case{'superpixel','draw'}
                if~isempty(this.PaintBrushLayout)
                    this.PaintBrushLayout.Color=color;
                end
            end
        end


        function updateActivePolygonNameInCurrentFrame(this,oldName,newName)

            switch this.ModeInternal
            case 'polygon'
                if~isempty(this.Polygon)&&strcmp(this.Polygon.Tag,oldName)
                    this.Polygon.Tag=newName;
                end
            case 'assistedfreehand'
                if~isempty(this.Freehand)&&strcmp(this.Freehand.Tag,oldName)
                    this.Freehand.Tag=newName;
                end
            case{'grabcutpolygon'}
                if~isempty(this.GrabCutPolygon)&&strcmp(this.GrabCutPolygon.Tag,oldName)
                    this.GrabCutPolygon.Tag=newName;
                end
            end
        end


        function updateActivePolygonVisibility(this,selectedLabelData,selectedItemInfo)

            labelName=selectedLabelData.Label;
            this.LabelVisibility(selectedLabelData.PixelLabelID,1)=...
            ~this.LabelVisibility(selectedLabelData.PixelLabelID,1);


            if this.isROIValid(this.Polygon)&&strcmp(this.Polygon.Tag,labelName)
                this.Polygon.Visible=~this.Polygon.Visible;
            end
            if this.isROIValid(this.Freehand)&&strcmp(this.Freehand.Tag,labelName)
                this.Freehand.Visible=~this.Freehand.Visible;
            end
            if this.isROIValid(this.GrabCutPolygon)&&strcmp(this.GrabCutPolygon.Tag,labelName)
                this.GrabCutPolygon.Visible=~this.GrabCutPolygon.Visible;
            end


            if strcmp(this.ModeInternal,'draw')||strcmp(this.ModeInternal,'erase')...
                ||strcmp(this.ModeInternal,'superpixel')
                if strcmp(labelName,selectedItemInfo.Label)
                    if~selectedLabelData.ROIVisibility
                        disableBrushOutline(this);
                        if strcmp(this.ModeInternal,'superpixel')
                            updateSuperpixelGrid(this,0,true);
                        end
                    else
                        updateBrushOutline(this,selectedLabelData.Color)
                        if strcmp(this.ModeInternal,'superpixel')
                            updateSuperpixelGrid(this,this.SuperpixelCount,false);
                        end
                    end
                end
            end

            this.updateSemanticViewTemp();
        end


        function retVar=getColorLookupTable(this)
            retVar=this.ColorLookupTable;
        end


        function setColorLookupTable(this,updatedLookupTable)


            this.ColorLookupTable=updatedLookupTable;
        end


        function setLabelVisibility(this,pixelLabelVisibility)


            this.LabelVisibility=pixelLabelVisibility;
        end


        function setLabelMatrixInternal(this,L)


            if isempty(this.LabelMatrixChange)
                this.LabelMatrixChange=int16(L);
            else
                this.LabelMatrixChange=...
                int16(L)-int16(this.LabelMatrixInternal);
            end
            this.LabelMatrixInternal=L;
        end


        function fileName=getImageFilename(this)

            fileName=this.ImageFilename;
        end


        function labelMatrix=getVisibleLabelMatrix(this,labelMatrix)


            if~any(labelMatrix)
                return;
            end

            for i=1:size(labelMatrix,1)
                for j=1:size(labelMatrix,2)
                    if labelMatrix(i,j)>0&&~this.LabelVisibility(labelMatrix(i,j))
                        labelMatrix(i,j)=0;
                    end
                end
            end
        end
    end




    methods
        function L=getEmptyLabelMatrix(this)

            if isempty(this.LabelMatrixInternal)
                L=[];
                return;
            end


            L=zeros(size(this.LabelMatrixInternal),'int16');


            L=reduceLabelMatrixForUndoStack(this,L);
        end


        function L=getLabelMatrixInternal(this)

            if isempty(this.LabelMatrixInternal)
                L=[];
                return;
            end




            L=this.LabelMatrixChange;


            L=this.reduceLabelMatrixForUndoStack(L);
        end


        function P=reduceLabelMatrixForUndoStack(this,L)

            [labelMatrixROC,BBox]=this.extractRegionOfChange(L);


            LCompressed=this.applyRLECompression(labelMatrixROC);

            P=struct('LabelMatrix',LCompressed,'BoundingBox',BBox);
        end


        function U=getUndoPlaceHolder(this)
            U=this.getUndoPlaceholder();
        end


        function wipeROIs(this)

            this.commitPreviousROI();
            L=zeros(size(this.LabelMatrixInternal),'uint8');
            this.LabelMatrixInternal=L;
        end


        function drawROIs(this,data)

            L=data.LabelMatrix;
            this.setLabelMatrixInternal(L);

            if this.SuperpixelState
                updateSuperpixelGrid(this,this.SuperpixelCount,false);
            end


            if~isempty(data.Placeholder)
                copiedData=data.Placeholder;
                if isfield(copiedData,'GrabCutPolygon')
                    this.restoreGrabCutState(copiedData);
                elseif isfield(copiedData,'Waypoints')
                    this.pasteSelectedFreehand(copiedData);
                else
                    this.pasteSelectedROIs(copiedData);
                end
            end
        end


        function L=createLabelMatrixFromUndoStack(this,undoLMStruct)









            L=zeros(size(this.LabelMatrixInternal),'int16');
            extract=int16(eval(undoLMStruct.LabelMatrix));
            rowMin=undoLMStruct.BoundingBox(1);
            colMin=undoLMStruct.BoundingBox(2);
            rowMax=rowMin+undoLMStruct.BoundingBox(3);
            colMax=colMin+undoLMStruct.BoundingBox(4);
            L(rowMin:rowMax,colMin:colMax)=extract;
        end


        function resetURPixelOnLabDefDel(this)


            this.LabelMatrixChange=this.LabelMatrixInternal;
        end
    end

    methods(Static,Access=private)


        function[labelMatrixROC,bBox]=extractRegionOfChange(L)




            [row,col]=find(L~=0);
            if isempty(row)
                labelMatrixROC=L;
                bBox=[1,1,size(L,1)-1,size(L,2)-1];
            else
                rowMin=min(row);
                rowMax=max(row);
                colMin=min(col);
                colMax=max(col);


                labelMatrixROC=L(rowMin:rowMax,colMin:colMax);




                bBox=[rowMin,colMin,rowMax-rowMin,colMax-colMin];
            end
        end


        function evalSTR=applyRLECompression(L)







            orgDim=size(L);

            vec=L(:)';

            diffvec=diff(vec);
            [~,idx]=find(diffvec~=0);
            idx=[0,idx,size(vec,2)];
            compressSTR='[';
            for repDATA=1:size(idx,2)-1

                idxBegin=idx(repDATA)+1;
                idxEnd=idx(repDATA+1);

                repEnd=vec(idxEnd);

                if idxBegin==idxEnd

                    compressSTR=[compressSTR,num2str(repEnd)];
                else

                    compressSTR=[compressSTR,'[',num2str(1),':',num2str(idxEnd-idxBegin+1),']*0+',num2str(repEnd)];
                end

                if repDATA~=size(idx,2)-1
                    compressSTR=[compressSTR,','];
                end

                if mod(repDATA,15)==0

                    compressSTR=[compressSTR,''',...',newline,''''];
                end

            end
            compressSTR=[compressSTR,']'];
            evalSTR=['reshape(eval([''',compressSTR,''']),[',num2str(orgDim),'])'];
        end


        function myPointer=pencilPointer
            myPointer=[NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,1,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,2,1,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,1,2,2,1,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,1,2,1,2,1,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,1,2,2,2,1,2,1,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,NaN,1,2,2,2,2,2,1,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,1,1,2,2,2,2,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,NaN,1,2,1,2,2,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,1,2,2,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            NaN,1,2,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            1,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN;
            1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN];
        end

        function myPointer=paintBucketPointer

            myPointer=[NaN,NaN,NaN,NaN,NaN,1,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,NaN,1,NaN,NaN,NaN,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,NaN,1,NaN,NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,NaN,1,NaN,1,2,1,1,NaN,NaN,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,NaN,1,1,2,2,1,2,1,1,NaN,NaN,NaN,NaN
            NaN,NaN,NaN,NaN,1,2,2,2,1,2,2,1,1,1,NaN,NaN
            NaN,NaN,NaN,1,2,2,2,1,2,1,2,2,1,1,1,NaN
            NaN,NaN,1,2,2,2,2,2,1,2,2,2,2,1,1,1
            NaN,1,2,2,2,2,2,2,2,2,2,2,1,1,1,1
            1,2,2,2,2,2,2,2,2,2,2,1,NaN,1,1,1
            NaN,1,2,2,2,2,2,2,2,2,1,NaN,NaN,1,1,1
            NaN,NaN,1,2,2,2,2,2,2,1,NaN,NaN,NaN,1,1,1
            NaN,NaN,NaN,1,2,2,2,2,1,NaN,NaN,NaN,NaN,1,1,1
            NaN,NaN,NaN,NaN,1,2,2,1,NaN,NaN,NaN,NaN,NaN,1,1,NaN
            NaN,NaN,NaN,NaN,NaN,1,1,NaN,NaN,NaN,NaN,NaN,NaN,1,NaN,NaN
            NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN];

        end

        function createTutorialDialog()

            s=settings;

            messageStrings={getString(message('vision:labeler:GrabCutTutorial1')),...
            getString(message('vision:labeler:GrabCutTutorial2')),...
            getString(message('vision:labeler:GrabCutTutorial3'))};

            titleString=getString(message('vision:labeler:GrabCutTutorialTitle'));

            imagePaths={fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+images','ImageLabeler_GrabCutTutorial1.png'),...
            fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+images','ImageLabeler_GrabCutTutorial2.png'),...
            fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+images','ImageLabeler_GrabCutTutorial3.png')};

            images.internal.app.TutorialDialog(imagePaths,messageStrings,titleString,s.vision.imageLabeler.ShowGrabCutTutorialDialog,...
            s.vision.labeler.OpenWithAppContainer.ActiveValue);

        end

    end
end

function TF=isClickOutsideAxes(clickLocation,axesPosition)
    TF=(clickLocation(1)<axesPosition(1))||...
    (clickLocation(1)>(axesPosition(1)+axesPosition(3)))||...
    (clickLocation(2)<axesPosition(2))||...
    (clickLocation(2)>(axesPosition(2)+axesPosition(4)));
end
