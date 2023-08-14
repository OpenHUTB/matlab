
classdef LineLabeler<vision.internal.labeler.tool.ShapeLabeler

    properties(Access=protected)

ShapeSpec


        NumInUse=0;



ROI


        checkArray=[];

    end

    methods

        function this=LineLabeler()
            this.ShapeSpec=labelType.Line;



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
            h=images.roi.Polyline(...
            'Label','',...
            'Tag','',...
            'SelectedColor',[1,1,0],...
            'UserData',{'line','','',''});

            cMenu=h.UIContextMenu;
            h1=findobj(cMenu,'Tag','IPTROIContextMenuDelete');
            delete(h1);
            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCopy'),'Callback',@this.CopyCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCut'),'Callback',@this.CutCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('images:imroi:deletePolyline'),'Callback',@this.DeleteCallbackFcn);
            h.UIContextMenu=cMenu;


            this.addCallbacks(h);
            this.ROI(idx)=h;
        end


        function pasteSelectedROIs(this,CopiedLineROIs)
            numROIs=numel(CopiedLineROIs);
            numROIsB4Paste=numel(this.CurrentROIs);

            currentLineROIs={};
            if numROIs>0
                for i=1:numROIsB4Paste
                    if this.checkROIValidity(this.CurrentROIs{i})&&size(this.CurrentROIs{i}.Position,2)==2
                        this.CurrentROIs{i}.Selected=false;
                        currentLineROIs{end+1}=this.CurrentROIs{i}.Position;%#ok<AGROW>
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






            [~,~,dim3]=size(currentLineROIs);

            currentLineROIsPosUpdated=cell(numel(this.CurrentROIs),dim3);
            for in=1:length(this.CurrentROIs)
                currentLineROIsPosUpdated{in}=this.CurrentROIs{in}.Position;
            end

            numPastedROIs=0;
            for i=1:numROIs
                linePts=CopiedLineROIs{i}.Position;


                if(max(linePts(:,1))>x_extent+1)||(max(linePts(:,2))>y_extent+1)
                    continue;
                end


                offsetIndex=1;

                if~isempty(this.CurrentROIs)

                    if isOverlapWithExistingLineRoi(linePts)
                        lastToLastPoints=[];
                        lastPoints=linePts;
                        try

                            findPlaceToPasteLine();
                        catch

                            linePts=[];
                        end
                    end
                end

                if~isempty(linePts)
                    copiedData=CopiedLineROIs{i};
                    eRoi=makeEnhancedROI(this,linePts,copiedData.Label,...
                    copiedData.parentName,copiedData.selfUID,copiedData.parentUID,copiedData.Color,copiedData.Visible);

                    eRoi.Selected=true;
                    this.CurrentROIs{end+1}=eRoi;
                    numPastedROIs=numPastedROIs+1;


                    currentLineROIsPosUpdated{end+1,:}=this.getCopiedData(this.CurrentROIs{end}).Position;%#ok<AGROW>
                end
            end

            if numPastedROIs>0

                actType=vision.internal.labeler.tool.actionType.Append;
                evtData=this.makeROIEventData(this.CurrentROIs((numROIsB4Paste+1):end),actType);
                notify(this,'LabelIsChanged',evtData);
            end


            function isOverlapDetected=isOverlapWithExistingLineRoi(inPos)
                isOverlapDetected=false;

                for roiInx=1:numel(currentLineROIsPosUpdated)

                    if isequal(currentLineROIsPosUpdated{roiInx},inPos)
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



            function findPlaceToPasteLine()


                newLinePoints=linePts+offset(offsetIndex,:);
                if isPositionOutsideImage(newLinePoints,eps,eps,x_extent,y_extent)



                    offsetIndex=offsetIndex+1;
                    if offsetIndex==9
                        offsetIndex=1;
                    end
                    findPlaceToPasteLine();
                else




                    if~isequal(lastToLastPoints,newLinePoints)




                        if isOverlapWithExistingLineRoi(linePts)



                            linePts=newLinePoints;
                            lastToLastPoints=lastPoints;
                            lastPoints=linePts;
                            findPlaceToPasteLine();
                        end
                    else



                        offsetIndex=offsetIndex+1;
                        if offsetIndex==9
                            offsetIndex=1;
                        end
                        findPlaceToPasteLine();
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
                    strcmpi(copiedData.UserData{1},'line');

                    N=N+double(hasMatch);

                end
            end
        end
    end

    methods(Access=protected)





        function drawInteractiveROIs(this,roiPositions,labelNames,parentNames,selfUIDs,parentUIDs,colors,shapes,roiVisibility)

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
                this.ROI=repmat(images.roi.Polyline,[1,last]);
                this.checkArray=false(1,last);
            else
                this.ROI(first:last)=repmat(images.roi.Polyline,[1,last-first+1]);
                this.checkArray(first:last)=false;
            end

            for idx=first:last

                h=images.roi.Polyline(...
                'Label','',...
                'Tag','',...
                'SelectedColor',[1,1,0],...
                'LabelVisible',this.LabelVisibleInternal,...
                'UserData',{'line','','',''});

                cMenu=h.UIContextMenu;
                h1=findobj(cMenu,'Tag','IPTROIContextMenuDelete');
                delete(h1);
                uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCopy'),'Callback',@this.CopyCallbackFcn);
                uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCut'),'Callback',@this.CutCallbackFcn);
                uimenu('Parent',cMenu,'Label',vision.getMessage('images:imroi:deletePolyline'),'Callback',@this.DeleteCallbackFcn);
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


            imageSize=this.getImageSize();
            this.ROI(idx).Parent=this.AxesHandle;
            this.ROI(idx).Label=this.getLabelName(roiName);
            this.ROI(idx).Tag=roiName;
            this.ROI(idx).Color=color;
            this.ROI(idx).DrawingArea=[0.5,0.5,imageSize(2),imageSize(1)];
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
                enhancedPolylineRoi=createPolygon(this,roiName,parentName,selfUID,roiParentUID,color,roiVisibility);

                cp=this.AxesHandle.CurrentPoint;

                enhancedPolylineRoi.beginDrawingFromPoint([cp(1,1),cp(1,2)]);

                if~this.checkROIValidity(enhancedPolylineRoi)

                    this.deparent(enhancedPolylineRoi);


                    notify(this,'DrawingFinished');
                    return;
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
            end
        end


        function addCallbacks(this,newROI)

            addCallbacks@vision.internal.labeler.tool.ShapeLabeler(this,newROI);


            addlistener(newROI,'VertexDeleted',@(src,data)onMove(this));
            addlistener(newROI,'VertexAdded',@(src,data)onMove(this));
        end

    end

end
