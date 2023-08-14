
classdef RectangleLabeler<vision.internal.labeler.tool.ShapeLabeler

    properties(Access=protected)

ShapeSpec


        NumInUse=0;



ROI


ContextMenu


        checkArray=[];

    end

    methods

        function this=RectangleLabeler()
            this.ShapeSpec=labelType.Rectangle;

            createContextMenu(this);



            create(this,1,50);

        end

        function deparent(this,eroi)

            idx=find(this.ROI==eroi,1);
            this.checkArray(idx)=0;
            this.ROI(idx).Parent=gobjects(0);

            this.NumInUse=this.NumInUse-1;
        end


        function pasteSelectedROIs(this,CopiedRectROIs)

            numROIs=numel(CopiedRectROIs);
            numROIsB4Paste=numel(this.CurrentROIs);
            currentRectROIs=zeros(0,4);
            if numROIs>0
                for i=1:numROIsB4Paste
                    if this.checkROIValidity(this.CurrentROIs{i})&&size(this.CurrentROIs{i}.Position,2)==4
                        this.CurrentROIs{i}.Selected=false;
                        copiedData=this.getCopiedData(this.CurrentROIs{i});
                        currentRectROIs(end+1,:)=copiedData.Position;%#ok<AGROW>
                    end
                end

            else
                return;
            end

            imageSize=this.getImageSize();
            y_extent=imageSize(1);
            x_extent=imageSize(2);
            constraint_fcn=makeConstrainToRectFcn('imrect',...
            [0.5,x_extent+1],[0.5,y_extent+1]);


            xlim=get(this.AxesHandle,'XLim');
            displayWidth=abs(xlim(2)-xlim(1));
            ylim=get(this.AxesHandle,'YLim');
            displayHeight=abs(ylim(2)-ylim(1));
            Xoffset=round(displayWidth/100+1);
            Yoffset=round(displayHeight/100+1);
            offset(1,:)=[Xoffset,Yoffset,0,0];
            offset(2,:)=[-Xoffset,-Yoffset,0,0];
            offset(3,:)=[Xoffset,-Yoffset,0,0];
            offset(4,:)=[-Xoffset,Yoffset,0,0];
            offset(5,:)=[Xoffset,0,0,0];
            offset(6,:)=[-Xoffset,0,0,0];
            offset(7,:)=[0,Yoffset,0,0];
            offset(8,:)=[0,-Yoffset,0,0];






            currentRectROIsPosUpdated=zeros(numel(this.CurrentROIs),4);
            for in=1:length(this.CurrentROIs)
                currentRectROIsPosUpdated(in,:)=this.getCopiedData(this.CurrentROIs{in}).Position;
            end

            numPastedROIs=0;
            for i=1:numROIs
                boxPoints=CopiedRectROIs{i}.Position;




                if(boxPoints(1)>x_extent)
                    boxPoints(1)=x_extent-boxPoints(3)+1;
                end

                if(boxPoints(2)>y_extent)
                    boxPoints(2)=y_extent-boxPoints(4)+1;
                end





                boxPoints(3)=min(boxPoints(3),x_extent+1-boxPoints(1));
                boxPoints(4)=min(boxPoints(4),y_extent+1-boxPoints(2));


                offsetIndex=1;
                if~isempty(currentRectROIs)

                    if~isempty(intersect(currentRectROIs,boxPoints,'rows'))
                        lastToLastPoints=[NaN,NaN,NaN,NaN];
                        lastPoints=boxPoints;
                        try

                            findPlaceToPaste();
                        catch

                            boxPoints=constraint_fcn(boxPoints);
                        end
                    end
                end

                if~isempty(boxPoints)
                    eroi=makeEnhancedROI(this,boxPoints,CopiedRectROIs{i}.Label,...
                    CopiedRectROIs{i}.parentName,CopiedRectROIs{i}.selfUID,CopiedRectROIs{i}.parentUID,CopiedRectROIs{i}.Color,CopiedRectROIs{i}.Visible);


                    eroi.Selected=true;
                    this.CurrentROIs{end+1}=eroi;


                    currentRectROIs(end+1,:)=CopiedRectROIs{i}.Position;%#ok<AGROW>
                    numPastedROIs=numPastedROIs+1;


                    currentRectROIsPosUpdated(end+1,:)=this.getCopiedData(this.CurrentROIs{end}).Position;%#ok<AGROW>
                end
            end

            if numPastedROIs>0

                actType=vision.internal.labeler.tool.actionType.Append;
                evtData=this.makeROIEventData(this.CurrentROIs((numROIsB4Paste+1):end),actType);
                notify(this,'LabelIsChanged',evtData);
            end



            function findPlaceToPaste()


                newBoxPoints=boxPoints+offset(offsetIndex,:);
                if~isequal(constraint_fcn(newBoxPoints),newBoxPoints)



                    offsetIndex=offsetIndex+1;
                    if offsetIndex==9
                        offsetIndex=1;
                    end
                    findPlaceToPaste();
                else




                    if~isequal(lastToLastPoints,newBoxPoints)




                        if any(ismember(currentRectROIsPosUpdated,boxPoints,'rows'))



                            boxPoints=newBoxPoints;
                            lastToLastPoints=lastPoints;
                            lastPoints=boxPoints;
                            findPlaceToPaste();
                        end
                    else



                        offsetIndex=offsetIndex+1;
                        if offsetIndex==5
                            offsetIndex=1;
                        end
                        findPlaceToPaste();
                    end
                end
            end
        end


        function N=getNumSelectedROIsOfDefFamily(this,sublabelItemData)

            N=0;
            for i=1:numel(this.CurrentROIs)



                if this.CurrentROIs{i}.Selected

                    copiedData=this.getCopiedData(this.CurrentROIs{i});

                    hasMatch=(isParentROISelected(this,copiedData,sublabelItemData)||...
                    isSelfOrSiblingROISelected(this,copiedData,sublabelItemData))&&...
                    strcmpi(copiedData.UserData{1},'rect');

                    N=N+double(hasMatch);

                end
            end
        end
    end

    methods(Access=protected)






        function drawInteractiveROIs(this,roiPositions,roiNames,parentNames,selfUIDs,parentUIDs,colors,shapes,roiVisibility)


            isShapeRect=(shapes==labelType.Rectangle);
            numRects=nnz(isShapeRect);
            len=length(this.CurrentROIs);
            count=1;
            this.CurrentROIs(end+1:end+numRects)={[]};
            for n=1:numel(roiPositions)
                if isShapeRect(n)
                    roiPos=roiPositions{n};
                    if(strcmp(this.ROIColorGroup,'By Instance'))
                        currColor=this.getInstanceColorByIdx(n);
                    else
                        currColor=colors{n};
                    end
                    eroi=makeEnhancedROI(this,roiPos,roiNames{n},parentNames{n},selfUIDs{n},parentUIDs{n},currColor,roiVisibility{n});
                    this.CurrentROIs{len+count}=eroi;
                    count=count+1;
                end
            end
        end


        function eroi=makeEnhancedROI(this,rois,roiName,parentName,selfUID,parentUID,color,roiVisibility)
            eroi=createRectangle(this,roiName,parentName,selfUID,parentUID,color,roiVisibility);


            rois(1)=rois(1)-0.5;
            rois(2)=rois(2)-0.5;
            rois(3)=floor(rois(3));
            rois(4)=floor(rois(4));

            eroi.Position=rois;
        end

        function create(this,first,last)




            if isempty(this.ROI)&&first==1
                this.ROI=repmat(images.roi.Rectangle,[1,last]);
                this.checkArray=false(1,last);
            else
                this.ROI(first:last)=repmat(images.roi.Rectangle,[1,last-first+1]);
                this.checkArray(first:last)=false;
            end

            for idx=first:last

                h=images.roi.Rectangle(...
                'Label','',...
                'Tag','',...
                'SelectedColor',[1,1,0],...
                'FaceSelectable',false,...
                'FaceAlpha',0,...
                'UserData',{'rect','','',''},...
                'LabelVisible',this.LabelVisibleInternal,...
                'UIContextMenu',this.ContextMenu);


                this.addCallbacks(h);
                addlistener(h,'MovingROI',@(src,evt)onDraw(this,src,evt));

                this.ROI(idx)=h;
            end



            if isprop(this.ROI(1),'MarkersVisible')
                set(this.ROI,'MarkersVisible',this.MarkersVisible);
            end

        end


        function roi=createRectangle(this,roiName,parentName,selfUID,parentUID,color,roiVisibility)

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
            this.ROI(idx).UserData={'rect',parentName,parentUID,selfUID};
            this.ROI(idx).Selected=0;


            try %#ok<TRYNC>
                this.ROI(idx).MarkersVisible=this.MarkersVisible;
            end

            this.ROI(idx).LabelVisible=this.LabelVisibleInternal;
            roi=this.ROI(idx);
            this.checkArray(idx)=1;
            this.ROI(idx).Visible=roiVisibility;
        end

        function createContextMenu(this)


            h=images.roi.Rectangle();

            cMenu=h.UIContextMenu;


            h1=findobj(cMenu,'Tag','IPTROIContextMenuAspectRatio');
            delete(h1);
            h1=findobj(cMenu,'Tag','IPTROIContextMenuDelete');
            delete(h1);

            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCopy'),'Callback',@this.CopyCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCut'),'Callback',@this.CutCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('images:imroi:deleteRectangle'),'Callback',@this.DeleteCallbackFcn);

            this.ContextMenu=cMenu;

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
                [roiName,parentName,roi_parentUID]=getSelectedItemDefROIInstanceInfo(this);
                selfUID='';

                if(strcmp(this.ROIColorGroup,'By Label'))
                    color=this.SelectedLabel.Color;
                else
                    color=this.getNextInstanceColor();
                end

                roiVisibility=true;
                enhancedRectangleRoi=createRectangle(this,roiName,parentName,selfUID,roi_parentUID,color,roiVisibility);
                pos=this.AxesHandle.CurrentPoint(1,1:2);

                pos(1)=pos(1)-0.5;
                pos(2)=pos(2)-0.5;

                pos=round(pos);

                pos(1)=pos(1)+0.5;
                pos(2)=pos(2)+0.5;



                enhancedRectangleRoi.LabelVisible='off';
                enhancedRectangleRoi.beginDrawingFromPoint(pos);


                enhancedRectangleRoi.LabelVisible=this.LabelVisibleInternal;

                if~this.checkROIValidity(enhancedRectangleRoi)


                    this.deparent(enhancedRectangleRoi);


                    notify(this,'DrawingFinished');
                    return;
                else
                    notify(this,'DrawingFinished');
                    if this.UserIsDrawing
                        enhancedRectangleRoi.Selected=true;
                    end
                    this.CurrentROIs{end+1}=enhancedRectangleRoi;

                    actType=vision.internal.labeler.tool.actionType.Append;
                    evtData=this.makeROIEventData(this.CurrentROIs(end),actType);
                    notify(this,'LabelIsChanged',evtData);
                end

            case 'open'

                imSize=this.getImageSize();
                roiPos=[1,1,imSize(2),imSize(1)];
                [roiName,parentName,roi_parentUID]=getSelectedItemDefROIInstanceInfo(this);
                selfUID='';

                if(strcmp(this.ROIColorGroup,'By Label'))
                    color=this.SelectedLabel.Color;
                else
                    color=this.getNextInstanceColor();
                end

                roiVisibility=true;
                enhancedRectangleRoi=makeEnhancedROI(this,roiPos,roiName,parentName,selfUID,roi_parentUID,color,roiVisibility);
                this.CurrentROIs{end+1}=enhancedRectangleRoi;

                evtData=this.makeROIEventData(this.CurrentROIs);
                notify(this,'LabelIsChanged',evtData);
            end
        end


        function onDraw(~,src,~)


            pos=src.Position;

            pos(1)=pos(1)-0.5;
            pos(2)=pos(2)-0.5;

            pos=round(pos);

            pos(1)=pos(1)+0.5;
            pos(2)=pos(2)+0.5;

            src.Position=pos;

        end

    end

end
