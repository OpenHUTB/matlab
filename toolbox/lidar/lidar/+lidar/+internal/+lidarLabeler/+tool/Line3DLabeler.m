
classdef Line3DLabeler<lidar.internal.labeler.tool.ShapeLabeler




    properties(Access=protected)

ShapeSpec


        NumInUse=0;



ROI


        checkArray=[];

        SnapToPointInternal(1,1)logical=true;

MouseButtonDownListener
MouseButtonMotionListener
    end

    properties(Dependent)
SnapToPoint
    end

    methods

        function this=Line3DLabeler()
            this.ShapeSpec=labelType.Line;



            create(this,1,50);
        end


        function activate(this,fig,ax,imageHandle)

            this.attachToImage(fig,ax,imageHandle);
            if~isempty(this.MouseButtonDownListener)&&isvalid(this.MouseButtonDownListener)&&fig==this.MouseButtonDownListener.Source{:}
                this.MouseButtonDownListener.Enabled=true;
            else
                this.MouseButtonDownListener=event.listener(fig,'WindowMousePress',@(src,evt)onButtonDown(this,evt));
            end


            set(this.ImageHandle,'ButtonDownFcn',@this.onButtonDownWrapper);
        end


        function deactivate(this)
            if~isempty(this.MouseButtonDownListener)&&isvalid(this.MouseButtonDownListener)
                this.MouseButtonDownListener.Enabled=false;
            else
                delete(this.MouseButtonDownListener);
            end
        end

        function deparent(this,eroi)



            idx=find(this.ROI==eroi,1);
            this.checkArray(idx)=0;

            this.ROI(idx).Parent=gobjects(0);

            this.NumInUse=this.NumInUse-1;
        end

        function handleDeletedObj(this)


            idx=find(~isvalid(this.ROI),1);
            polyline3d=vision.roi.Polyline3D(...
            'Label','',...
            'Tag','',...
            'SelectedColor',[1,1,0],...
            'UserData',{'line','','',''});

            cMenu=polyline3d.UIContextMenu;
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuDelete');
            delete(defaultContextMenu);
            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCopy'),'Callback',@this.CopyCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCut'),'Callback',@this.CutCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('images:imroi:deletePolyline'),'Callback',@this.DeleteCallbackFcn);
            polyline3d.UIContextMenu=cMenu;


            this.addCallbacks(polyline3d);
            this.ROI(idx)=polyline3d;
        end


        function pasteSelectedROIs(this,CopiedLineROIs)

            numROIs=numel(CopiedLineROIs);

            if numROIs>0
                for i=1:numel(this.CurrentROIs)
                    if this.checkROIValidity(this.CurrentROIs{i})&&size(this.CurrentROIs{i}.Position,2)==3
                        this.CurrentROIs{i}.Selected=false;
                    end
                end
            else
                return;
            end

            numPastedROIs=0;
            for i=1:numROIs
                pos=CopiedLineROIs{i}.Position;

                if~isempty(pos)
                    eroi=makeEnhancedROI(this,pos,CopiedLineROIs{i}.Label,...
                    CopiedLineROIs{i}.parentName,CopiedLineROIs{i}.selfUID,...
                    CopiedLineROIs{i}.parentUID,CopiedLineROIs{i}.Color,CopiedLineROIs{i}.Visible);


                    eroi.Selected=true;
                    this.CurrentROIs{end+1}=eroi;
                    numPastedROIs=numPastedROIs+1;
                end
            end

            if numPastedROIs>0

                evtData=this.makeROIEventData(this.CurrentROIs);
                notify(this,'LabelIsChanged',evtData);
            end
        end


        function N=getNumSelectedROIsOfDefFamily(this,sublabelItemData)

            N=0;
            for i=1:numel(this.CurrentROIs)



                if this.CurrentROIs{i}.Selected

                    copiedData=this.getCopiedData(this.CurrentROIs{i});

                    hasMatch=this.CurrentROIs{i}.Selected&&...
                    (isParentROISelected(this,copiedData,sublabelItemData)||...
                    isSelfOrSiblingROISelected(this,copiedData,sublabelItemData))&&...
                    strcmpi(copiedData.UserData{1},'line');

                    N=N+double(hasMatch);

                end
            end
        end


        function updateProjectedView(this)
            evtData=this.makeROIEventData(this.CurrentROIs);
            notify(this,'LabelIsChanged',evtData)
        end
    end

    methods(Access=protected)





        function drawInteractiveROIs(this,roiPositions,labelNames,parentNames,...
            selfUIDs,parentUIDs,colors,shapes,roiVisibility)

            isShapeLine=(shapes==labelType.Line);
            numLines=nnz(isShapeLine);
            len=length(this.CurrentROIs);
            count=1;
            this.CurrentROIs(end+1:end+numLines)={[]};
            for n=1:numel(roiPositions)
                roiPos=roiPositions{n};
                if isShapeLine(n)
                    if~iscell(roiPos)
                        roiPos={roiPos};
                    end
                    for lineRoiInx=1:size(roiPos,1)

                        currColor=colors{n};
                        eroi=makeEnhancedROI(this,roiPos{lineRoiInx},labelNames{n},...
                        parentNames{n},selfUIDs{n},parentUIDs{n},currColor,roiVisibility{n});
                        this.CurrentROIs{len+count}=eroi;
                        count=count+1;
                    end
                end
            end

        end


        function eroi=makeEnhancedROI(this,rois,roiName,parentName,selfUID,parentUID,color,roiVisibility)
            eroi=createPolygon3D(this,roiName,parentName,selfUID,parentUID,color,roiVisibility);
            eroi.Position=rois;
        end


        function create(this,first,last)




            if isempty(this.ROI)&&first==1
                this.ROI=repmat(vision.roi.Polyline3D,[1,last]);
                this.checkArray=false(1,last);
            else
                this.ROI(first:last)=repmat(vision.roi.Polyline3D,[1,last-first+1]);
                this.checkArray(first:last)=false;
            end

            for idx=first:last

                polyline3d=vision.roi.Polyline3D(...
                'Label','',...
                'Tag','',...
                'SelectedColor',[1,1,0],...
                'LabelVisible',this.LabelVisibleInternal,...
                'UserData',{'line','','',''});

                cMenu=polyline3d.UIContextMenu;
                h1=findobj(cMenu,'Tag','IPTROIContextMenuDelete');
                delete(h1);

                uimenu('Parent',cMenu,'Label',vision.getMessage(...
                'vision:labeler:ContextMenuCopy'),'Callback',@this.CopyCallbackFcn);
                uimenu('Parent',cMenu,'Label',vision.getMessage(...
                'vision:labeler:ContextMenuCut'),'Callback',@this.CutCallbackFcn);
                uimenu('Parent',cMenu,'Label',vision.getMessage(...
                'images:imroi:deletePolyline'),'Callback',@this.DeleteCallbackFcn);
                polyline3d.UIContextMenu=cMenu;


                this.addCallbacks(polyline3d);

                this.ROI(idx)=polyline3d;
            end


            if isprop(this.ROI(1),'MarkersVisible')
                set(this.ROI,'MarkersVisible',this.MarkersVisible);
            end

        end


        function roi=createPolygon3D(this,roiName,parentName,selfUID,parentUID,color,roiVisibility)

            if isempty(selfUID)
                selfUID=vision.internal.getUniqueID();
            end

            this.NumInUse=this.NumInUse+1;
            checkIfMoreROIsRequired(this);


            idx=find(this.checkArray==0,1);
            if isempty(idx)
                idx=1;
            end


            this.ROI(idx).Parent=this.AxesHandle;
            this.ROI(idx).Label=this.getLabelName(roiName);
            this.ROI(idx).Tag=roiName;
            this.ROI(idx).Color=color;
            this.ROI(idx).UserData={'line',parentName,parentUID,selfUID};
            this.ROI(idx).Selected=0;

            try %#ok<TRYNC>
                this.ROI(idx).MarkersVisible=this.MarkersVisible;
            end

            this.ROI(idx).LabelVisible=this.LabelVisibleInternal;
            roi=this.ROI(idx);
            this.checkArray(idx)=1;
            this.ROI(idx).Visible=roiVisibility;
        end

        function checkIfMoreROIsRequired(this)
            numROIs=numel(this.ROI);
            if numROIs<this.NumInUse
                create(this,numROIs+1,this.NumInUse+49);
            end
        end




        function onButtonDown(this,varargin)
            evt=varargin{1};
            if isModeManagerActive(this)||wasClickOnAxesToolbar(this,evt)
                return;
            end

            mouseClickType=get(this.Figure,'SelectionType');

            updatePointCloudAxes(this);

            if strcmpi(mouseClickType,'alt')
                return;
            end

            selectedROI=[];
            if numel(this.CurrentROIs)
                for i=1:numel(this.CurrentROIs)
                    if this.CurrentROIs{i}.Selected
                        selectedROI=this.CurrentROIs{i};
                    end
                end
            end

            this.deselectAll();



            evtData=this.makeROIEventData(this.CurrentROIs);
            notify(this,'LabelIsSelected',evtData);

            switch mouseClickType
            case 'normal'
                if(isa(evt.HitObject,'matlab.graphics.chart.primitive.Scatter')||...
                    isa(evt.HitObject,'matlab.graphics.axis.Axes'))
                    notify(this,'DrawingStarted');
                    [roiName,parentName,roiParentUID]=getSelectedItemDefROIInstanceInfo(this);
                    selfUID='';

                    if(strcmp(this.ROIColorGroup,'By Label'))
                        color=this.SelectedLabel.Color;
                    end

                    roiVisibility=true;

                    enhancedPolylineRoi=createPolygon3D(this,roiName,parentName,selfUID,roiParentUID,color,roiVisibility);
                    enhancedPolylineRoi.Selected=true;

                    if~this.SnapToPointInternal
                        setSnapToPoints(enhancedPolylineRoi);


                        cp=getCurrentAxesPointSnappedToAngles(enhancedPolylineRoi);
                        firstPoint=[cp(1,1),cp(1,2),cp(1,3)];

                        enhancedPolylineRoi.beginDrawingFromPoint(firstPoint);
                    else
                        setSnapToPoints(enhancedPolylineRoi,this.AxesHandle.Children(end));


                        cp=getCurrentAxesPointSnappedToAngles(enhancedPolylineRoi);
                        firstPoint=[cp(1,1),cp(1,2),cp(1,3)];
                        pos=findNearestSnapPoints(enhancedPolylineRoi,firstPoint);

                        enhancedPolylineRoi.beginDrawingFromPoint(pos);
                    end

                    if~this.checkROIValidity(enhancedPolylineRoi)



                        if(isa(evt.HitObject,'matlab.graphics.chart.primitive.Scatter')||...
                            isa(evt.HitObject,'matlab.graphics.axis.Axes'))

                            this.deparent(enhancedPolylineRoi);
                        end



                        notify(this,'DrawingFinished');

                    else
                        notify(this,'DrawingFinished');
                        if this.UserIsDrawing
                            enhancedPolylineRoi.Selected=true;
                        end
                        this.CurrentROIs{end+1}=enhancedPolylineRoi;

                        actType=vision.internal.labeler.tool.actionType.Append;
                        evtData=this.makeROIEventData(this.CurrentROIs(end),actType);

                        notify(this,'LabelIsChanged',evtData);
                    end
                else
                    if~isempty(selectedROI)
                        updateSnapToPoints(this,selectedROI);
                    end
                end
            end
        end


        function addCallbacks(this,newROI)

            addCallbacks@lidar.internal.labeler.tool.ShapeLabeler(this,newROI);



            addlistener(newROI,'VertexDeleted',@(src,data)onMove(this));
            addlistener(newROI,'VertexAdded',@(src,data)onMove(this));
        end


        function TF=isModeManagerActive(this)
            hManager=uigetmodemanager(this.Figure);
            hMode=hManager.CurrentMode;
            TF=isobject(hMode)&&isvalid(hMode)&&~isempty(hMode);
        end


        function TF=wasClickOnAxesToolbar(~,evt)



            TF=~isempty(ancestor(evt.HitObject,'matlab.graphics.controls.AxesToolbar'));
        end


        function updateSnapToPoints(this,enhancedPolylineRoi)


            if this.SnapToPointInternal
                setSnapToPoints(enhancedPolylineRoi,this.AxesHandle.Children(end));
            else
                setSnapToPoints(enhancedPolylineRoi);
            end
        end

        function updatePointCloudAxes(this)


            if numel(this.CurrentROIs)&&this.SnapToPointInternal
                for i=1:numel(this.CurrentROIs)
                    enhancedPolylineRoi=this.CurrentROIs{i};
                    enhancedPolylineRoi.Parent=this.AxesHandle;
                    setSnapToPoints(enhancedPolylineRoi,this.AxesHandle.Children(end));
                end
            end
        end
    end

    methods
        function set.SnapToPoint(this,TF)
            this.SnapToPointInternal=TF;
        end

        function TF=get.SnapToPoint(this)
            TF=this.SnapToPointInternal;
        end
    end
end
