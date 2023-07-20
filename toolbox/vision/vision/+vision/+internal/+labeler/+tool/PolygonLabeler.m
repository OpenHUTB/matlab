
classdef PolygonLabeler<vision.internal.labeler.tool.ShapeLabeler

    properties(Access=protected)

ShapeSpec


        NumInUse=0;



ROI


        checkArray=[];


        Alpha=0;


        BlockedAutomationModeFlag=false;
    end

    properties(Access=private)
SendToBackCallbackFcn
BringToFrontCallbackFcn
    end

    methods

        function this=PolygonLabeler(varargin)
            this.ShapeSpec=labelType.Polygon;

            if nargin>0
                this.BlockedAutomationModeFlag=varargin{1};
            end



            create(this,1,50);
        end

        function deparent(this,eroi)


            idx=find(this.ROI==eroi,1);
            this.checkArray(idx)=0;
            this.ROI(idx).Parent=gobjects(0);

            this.NumInUse=this.NumInUse-1;
        end

        function handleDeletedObj(this)


            idx=find(~isvalid(this.ROI),1);
            h=images.roi.Polygon(...
            'Label','',...
            'Tag','',...
            'SelectedColor',[1,1,0],...
            'FaceAlpha',this.Alpha,...
            'FaceSelectable',false,...
            'UserData',{'polygon','','',''});

            cMenu=h.UIContextMenu;
            h1=findobj(cMenu,'Tag','IPTROIContextMenuDelete');
            delete(h1);
            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCopy'),'Callback',@this.CopyCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCut'),'Callback',@this.CutCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('images:imroi:deletePolygon'),'Callback',@this.DeleteCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuSendToBack'),'Callback',@this.SendToBackCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuBringToFront'),'Callback',@this.BringToFrontCallbackFcn);
            h.UIContextMenu=cMenu;


            this.addCallbacks(h);
            this.ROI(idx)=h;
        end


        function pasteSelectedROIs(this,CopiedPolygonROIs)

            numROIs=numel(CopiedPolygonROIs);
            numROIsB4Paste=numel(this.CurrentROIs);

            currentPolygonROIs={};
            if numROIs>0
                for i=1:numROIsB4Paste
                    if this.checkROIValidity(this.CurrentROIs{i})&&size(this.CurrentROIs{i}.Position,2)==2
                        this.CurrentROIs{i}.Selected=false;
                        currentPolygonROIs{end+1}=this.CurrentROIs{i}.Position;%#ok<AGROW>
                    end
                end

            else
                return;
            end


            imageSize=this.getImageSize();
            y_extent=imageSize(1);
            x_extent=imageSize(2);
            xlim=get(this.AxesHandle,'XLim');
            displayWidth=abs(xlim(2)-xlim(1));
            ylim=get(this.AxesHandle,'YLim');
            displayHeight=abs(ylim(2)-ylim(1));
            Xoffset=round(displayWidth/100+1);
            Yoffset=round(displayHeight/100+1);
            offset(1,:)=[Xoffset,Yoffset];
            offset(2,:)=[-Xoffset,-Yoffset];
            offset(3,:)=[Xoffset,-Yoffset];
            offset(4,:)=[-Xoffset,Yoffset];
            offset(5,:)=[Xoffset,0];
            offset(6,:)=[-Xoffset,0];
            offset(7,:)=[0,Yoffset];
            offset(8,:)=[0,-Yoffset];






            [~,~,dim3]=size(currentPolygonROIs);

            currentPolygonROIsPosUpdated=cell(length(this.CurrentROIs),dim3);
            for in=1:length(this.CurrentROIs)
                currentPolygonROIsPosUpdated{in}=this.CurrentROIs{in}.Position;
            end

            numPastedROIs=0;
            for i=1:numROIs
                polyPts=CopiedPolygonROIs{i}.Position;


                if(max(polyPts(1,:))>x_extent+1)||(max(polyPts(:,2))>y_extent+1)
                    continue;
                end


                offsetIndex=1;

                if~isempty(this.CurrentROIs)

                    if isOverlapWithExistingPolyRoi(polyPts)
                        lastToLastPoints=[];
                        lastPoints=polyPts;
                        try

                            findPlaceToPastePolygon();
                        catch

                            polyPts=[];
                        end
                    end
                end

                if~isempty(polyPts)
                    copiedData=CopiedPolygonROIs{i};
                    eRoi=makeEnhancedROI(this,polyPts,copiedData.Label,...
                    copiedData.parentName,copiedData.selfUID,copiedData.parentUID,copiedData.Color,copiedData.Visible);

                    eRoi.Selected=true;
                    this.CurrentROIs{end+1}=eRoi;
                    numPastedROIs=numPastedROIs+1;


                    currentPolygonROIsPosUpdated{end+1,:}=this.getCopiedData(this.CurrentROIs{end}).Position;%#ok<AGROW>
                end
            end

            if numPastedROIs>0

                actType=vision.internal.labeler.tool.actionType.Append;
                evtData=this.makeROIEventData(this.CurrentROIs((numROIsB4Paste+1):end),actType);
                notify(this,'LabelIsChanged',evtData);
            end


            function isOverlapDetected=isOverlapWithExistingPolyRoi(inPos)
                isOverlapDetected=false;

                for roiInx=1:numel(currentPolygonROIsPosUpdated)

                    if isequal(currentPolygonROIsPosUpdated{roiInx},inPos)
                        isOverlapDetected=true;
                        break;
                    end
                end
            end


            function yesNo=isPositionOutsideImage(pos,XMin,YMin,XMax,YMax)
                X=pos(:,1);
                Y=pos(:,2);
                yesNo=min(X)<XMin||max(X)>XMax||min(Y)<YMin||max(Y)>YMax;
            end



            function findPlaceToPastePolygon()


                newLinePoints=polyPts+offset(offsetIndex,:);
                if isPositionOutsideImage(newLinePoints,eps,eps,x_extent,y_extent)



                    offsetIndex=offsetIndex+1;
                    if offsetIndex==9
                        offsetIndex=1;
                    end
                    findPlaceToPastePolygon();
                else




                    if~isequal(lastToLastPoints,newLinePoints)




                        if isOverlapWithExistingPolyRoi(polyPts)



                            polyPts=newLinePoints;
                            lastToLastPoints=lastPoints;
                            lastPoints=polyPts;
                            findPlaceToPastePolygon();
                        end
                    else



                        offsetIndex=offsetIndex+1;
                        if offsetIndex==9
                            offsetIndex=1;
                        end
                        findPlaceToPastePolygon();
                    end
                end
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
                    strcmpi(copiedData.UserData{1},'polygon');

                    N=N+double(hasMatch);

                end
            end
        end
    end

    methods
        function this=setAlpha(this,alpha)


            for i=1:numel(this.CurrentROIs)
                this.CurrentROIs{i}.FaceAlpha=alpha;
            end
            this.Alpha=alpha;
        end

        function this=setFaceSelectable(this,flag)


            for i=1:numel(this.CurrentROIs)
                this.CurrentROIs{i}.FaceSelectable=flag;
            end
        end

        function addSendToBackCallback(this,sendToBackCallback)
            this.SendToBackCallbackFcn=sendToBackCallback;
        end
        function addBringToFrontCallback(this,bringToFrontCallback)
            this.BringToFrontCallbackFcn=bringToFrontCallback;
        end


        function sendToBack(this)

            selectedROIUIDs=[];
            currentROIUIDs=[];


            for j=1:numel(this.CurrentROIs)
                currentROIUIDs{j}=this.CurrentROIs{j}.UserData{4};%#ok<AGROW>
                currentROIParentUIDs{j}=this.CurrentROIs{j}.UserData{3};%#ok<AGROW>
            end


            for i=1:numel(this.SelectedROIinfo)
                [~,sublabelName,selfUID,parentUID]=getLabelDefInfoFromUID(this,this.SelectedROIinfo(i).LabelUID);


                childrenROIIdx=find(...
                cellfun(@(id)isequal(id,selfUID),...
                currentROIParentUIDs));

                if(isempty(sublabelName))


                    selectedROIUIDs{end+1}=selfUID;%#ok<AGROW>
                    if(~isempty(childrenROIIdx))
                        selectedROIUIDs=horzcat(selectedROIUIDs,currentROIUIDs(childrenROIIdx));%#ok<AGROW>
                    end
                else
                    selectedROIUIDs{end+1}=parentUID;%#ok<AGROW>
                    selectedROIUIDs{end+1}=selfUID;%#ok<AGROW>
                end
            end

            selectedROIIdx=find(...
            cellfun(@(id)any(strcmp(id,selectedROIUIDs)),...
            currentROIUIDs));



            selectedROI=this.CurrentROIs(selectedROIIdx);
            this.CurrentROIs(selectedROIIdx)=[];

            this.CurrentROIs=[selectedROI,this.CurrentROIs];

            evtData=this.makeROIEventData(this.CurrentROIs);
            notify(this,'LabelIsChanged',evtData);


            rois=this.reformatCurrentROIs(this.CurrentROIs);
            this.wipeROIs();
            for idx=1:size(rois,1)
                eroi=makeEnhancedROI(this,rois(idx).Position,...
                rois(idx).Label,rois(idx).ParentName,rois(idx).ID,...
                rois(idx).ParentUID,rois(idx).Color,rois(idx).ROIVisibility);
                this.CurrentROIs{end+1}=eroi;
            end

        end


        function bringToFront(this)

            selectedROIUIDs=[];
            currentROIUIDs=[];

            for j=1:numel(this.CurrentROIs)
                currentROIUIDs{j}=this.CurrentROIs{j}.UserData{4};%#ok<AGROW>
                currentROIParentUIDs{j}=this.CurrentROIs{j}.UserData{3};%#ok<AGROW>
            end


            for i=1:numel(this.SelectedROIinfo)

                [~,sublabelName,selfUID,parentUID]=getLabelDefInfoFromUID(this,this.SelectedROIinfo(i).LabelUID);


                childrenROIIdx=find(...
                cellfun(@(id)isequal(id,selfUID),...
                currentROIParentUIDs));

                if(isempty(sublabelName))


                    selectedROIUIDs{end+1}=selfUID;%#ok<AGROW>
                    if(~isempty(childrenROIIdx))
                        selectedROIUIDs=horzcat(selectedROIUIDs,currentROIUIDs(childrenROIIdx));%#ok<AGROW>
                    end
                else
                    selectedROIUIDs{end+1}=parentUID;%#ok<AGROW>
                    selectedROIUIDs{end+1}=selfUID;%#ok<AGROW>
                end
            end

            selectedROIIdx=find(...
            cellfun(@(id)any(strcmp(id,selectedROIUIDs)),...
            currentROIUIDs));


            selectedROI=this.CurrentROIs(selectedROIIdx);
            this.CurrentROIs(selectedROIIdx)=[];

            this.CurrentROIs=horzcat(this.CurrentROIs,selectedROI);

            evtData=this.makeROIEventData(this.CurrentROIs);
            notify(this,'LabelIsChanged',evtData);


            rois=this.reformatCurrentROIs(this.CurrentROIs);
            this.wipeROIs();
            for idx=1:size(rois,1)
                eroi=makeEnhancedROI(this,rois(idx).Position,rois(idx).Label,...
                rois(idx).ParentName,rois(idx).ID,rois(idx).ParentUID,rois(idx).Color,rois(idx).ROIVisibility);
                this.CurrentROIs{end+1}=eroi;
            end

        end
    end

    methods(Access=protected)





        function drawInteractiveROIs(this,roiPositions,labelNames,parentNames,selfUIDs,parentUIDs,colors,shapes,roiVisibility)

            isShapePolygon=(shapes==labelType.Polygon);
            numPolygons=nnz(isShapePolygon);
            len=length(this.CurrentROIs);
            count=1;
            this.CurrentROIs(end+1:end+numPolygons)={[]};
            for n=1:numel(roiPositions)
                roiPos=roiPositions{n};
                if isShapePolygon(n)
                    if~iscell(roiPos)
                        roiPos={roiPos};
                    end
                    for lineRoiInx=1:size(roiPos,1)

                        if(strcmp(this.ROIColorGroup,'By Instance'))
                            currColor=this.getInstanceColorByIdx(n);
                        else
                            currColor=colors{n};
                        end

                        eroi=makeEnhancedROI(this,roiPos{lineRoiInx},labelNames{n},parentNames{n},selfUIDs{n},parentUIDs{n},currColor,roiVisibility{n});
                        this.CurrentROIs{len+count}=eroi;
                        count=count+1;
                    end
                end
            end

        end


        function eroi=makeEnhancedROI(this,rois,roiName,parentName,selfUID,parentUID,color,roiVisibility)
            eroi=createPolygon(this,roiName,parentName,selfUID,parentUID,color,roiVisibility);
            eroi.Position=rois;


        end

        function create(this,first,last)




            if isempty(this.ROI)&&first==1
                this.ROI=repmat(images.roi.Polygon,[1,last]);
                this.checkArray=false(1,last);
            else
                this.ROI(first:last)=repmat(images.roi.Polygon,[1,last-first+1]);
                this.checkArray(first:last)=false;
            end


            faceSelectable=true;
            if(this.Alpha==0)
                faceSelectable=false;
            end

            for idx=first:last

                h=images.roi.Polygon(...
                'Label','',...
                'Tag','',...
                'SelectedColor',[1,1,0],...
                'FaceAlpha',this.Alpha,...
                'FaceSelectable',faceSelectable,...
                'LabelVisible',this.LabelVisibleInternal,...
                'UserData',{'polygon','','',''});

                cMenu=h.UIContextMenu;
                h1=findobj(cMenu,'Tag','IPTROIContextMenuDelete');
                delete(h1);
                if~this.BlockedAutomationModeFlag
                    uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCopy'),'Callback',@this.CopyCallbackFcn);
                    uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCut'),'Callback',@this.CutCallbackFcn);
                end
                uimenu('Parent',cMenu,'Label',vision.getMessage('images:imroi:deletePolygon'),'Callback',@this.DeleteCallbackFcn);
                if~this.BlockedAutomationModeFlag
                    uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuSendToBack'),'Callback',@this.SendToBackCallbackFcn);
                    uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuBringToFront'),'Callback',@this.BringToFrontCallbackFcn);
                end
                h.UIContextMenu=cMenu;


                this.addCallbacks(h);

                this.ROI(idx)=h;
            end



            if isprop(this.ROI(1),'MarkersVisible')
                set(this.ROI,'MarkersVisible',this.MarkersVisible);
            end

        end


        function roi=createPolygon(this,roiName,parentName,selfUID,parentUID,color,roiVisibility)

            if isempty(selfUID)
                selfUID=vision.internal.getUniqueID();
            end

            this.NumInUse=this.NumInUse+1;
            checkIfMoreROIsRequired(this);


            idx=find(this.checkArray==0,1);
            if isempty(idx)
                idx=1;
            end


            faceSelectable=true;
            if(this.Alpha==0)
                faceSelectable=false;
            end


            imageSize=this.getImageSize();
            this.ROI(idx).Parent=this.AxesHandle;
            this.ROI(idx).Label=this.getLabelName(roiName);
            this.ROI(idx).Tag=roiName;
            this.ROI(idx).Color=color;
            this.ROI(idx).DrawingArea=[0.5,0.5,imageSize(2),imageSize(1)];
            this.ROI(idx).UserData={'polygon',parentName,parentUID,selfUID};
            this.ROI(idx).Selected=0;
            this.ROI(idx).FaceAlpha=this.Alpha;
            this.ROI(idx).FaceSelectable=faceSelectable;


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

            mouseClickType=get(this.Figure,'SelectionType');

            if strcmpi(mouseClickType,'alt')
                return;
            end

            this.deselectAll();



            evtData=this.makeROIEventData(this.CurrentROIs);
            notify(this,'LabelIsSelected',evtData);

            switch mouseClickType
            case 'normal'
                notify(this,'DrawingStarted');
                [roiName,parentName,roiParentUID]=getSelectedItemDefROIInstanceInfo(this);
                selfUID='';

                if(strcmp(this.ROIColorGroup,'By Label'))
                    color=this.SelectedLabel.Color;
                else
                    color=this.getNextInstanceColor();
                end
                roiVisibility=true;
                enhancedPolygonRoi=createPolygon(this,roiName,parentName,selfUID,roiParentUID,color,roiVisibility);

                cp=this.AxesHandle.CurrentPoint;

                enhancedPolygonRoi.beginDrawingFromPoint([cp(1,1),cp(1,2)]);

                if~this.checkROIValidity(enhancedPolygonRoi)

                    this.deparent(enhancedPolygonRoi);


                    notify(this,'DrawingFinished');
                    return;
                else
                    notify(this,'DrawingFinished');
                    if this.UserIsDrawing
                        enhancedPolygonRoi.Selected=true;
                    end
                    this.CurrentROIs{end+1}=enhancedPolygonRoi;

                    actType=vision.internal.labeler.tool.actionType.Append;
                    evtData=this.makeROIEventData(this.CurrentROIs(end),actType);
                    notify(this,'LabelIsChanged',evtData);
                end
            end
        end


        function addCallbacks(this,newROI)

            addCallbacks@vision.internal.labeler.tool.ShapeLabeler(this,newROI);


            addlistener(newROI,'VertexDeleted',@(src,data)onMove(this));
            addlistener(newROI,'VertexAdded',@(src,data)onMove(this));
        end

    end

end
