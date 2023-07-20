
classdef ProjCuboidLabeler<vision.internal.labeler.tool.ShapeLabeler

    properties(Access=protected)

ShapeSpec


        NumInUse=0;



ROI


ContextMenu


        checkArray=[];

    end

    methods

        function this=ProjCuboidLabeler()
            this.ShapeSpec=labelType.ProjectedCuboid;

            createContextMenu(this);



            create(this,1,50);

        end

        function deparent(this,eroi)

            idx=find(this.ROI==eroi,1);
            this.checkArray(idx)=0;
            this.ROI(idx).Parent=gobjects(0);

            this.NumInUse=this.NumInUse-1;
        end


        function pasteSelectedROIs(this,copiedProjCuboidROIs)
            numROIs=numel(copiedProjCuboidROIs);
            numROIsB4Paste=numel(this.CurrentROIs);

            currentProjCuboidROIs=zeros(0,8);
            if numROIs>0
                for i=1:numROIsB4Paste
                    if this.checkROIValidity(this.CurrentROIs{i})&&...
                        size(this.CurrentROIs{i}.Position,2)==8
                        this.CurrentROIs{i}.Selected=false;
                        copiedData=this.getCopiedData(this.CurrentROIs{i});
                        currentProjCuboidROIs(end+1,:)=copiedData.Position;%#ok<AGROW>
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
            offset(1,:)=[Xoffset,Yoffset,0,0];
            offset(2,:)=[-Xoffset,-Yoffset,0,0];
            offset(3,:)=[Xoffset,-Yoffset,0,0];
            offset(4,:)=[-Xoffset,Yoffset,0,0];
            offset(5,:)=[Xoffset,0,0,0];
            offset(6,:)=[-Xoffset,0,0,0];
            offset(7,:)=[0,Yoffset,0,0];
            offset(8,:)=[0,-Yoffset,0,0];






            currentProjCuboidROIsPosUpdated=zeros(numel(this.CurrentROIs),8);
            for in=1:length(this.CurrentROIs)
                currentProjCuboidROIsPosUpdated(in,:)=this.getCopiedData(this.CurrentROIs{in}).Position;
            end

            numPastedROIs=0;
            for i=1:numROIs
                projCuboidPos=copiedProjCuboidROIs{i}.Position;
                boxPoints=this.getBoundingBox(projCuboidPos);




                if(boxPoints(1)>x_extent)
                    boxPoints(1)=x_extent-boxPoints(3)+1;
                end

                if(boxPoints(2)>y_extent)
                    boxPoints(2)=y_extent-boxPoints(4)+1;
                end





                boxPoints(3)=min(boxPoints(3),x_extent+1-boxPoints(1));
                boxPoints(4)=min(boxPoints(4),y_extent+1-boxPoints(2));


                offsetIndex=1;

                if~isempty(currentProjCuboidROIs)

                    if doesOverlapWithExistingProjCuboidRoi(this,this.getBoundingBox(currentProjCuboidROIs),boxPoints)
                        lastToLastPoints=[NaN,NaN,NaN,NaN];
                        lastPoints=boxPoints;
                        try

                            findPlaceToPasteProjCuboid();
                        catch

                            boxPoints=[];
                        end
                    end
                end

                if~isempty(boxPoints)
                    newProjCuboidPos=bbox2ProjCuboidPos(this,boxPoints,projCuboidPos);
                    eroi=makeEnhancedROI(this,newProjCuboidPos,copiedProjCuboidROIs{i}.Label,...
                    copiedProjCuboidROIs{i}.parentName,copiedProjCuboidROIs{i}.selfUID,...
                    copiedProjCuboidROIs{i}.parentUID,copiedProjCuboidROIs{i}.Color,copiedProjCuboidROIs{i}.Visible);


                    eroi.Selected=true;
                    this.CurrentROIs{end+1}=eroi;


                    currentProjCuboidROIsPosUpdated(end+1,:)=this.getCopiedData(this.CurrentROIs{end}).Position;%#ok<AGROW>


                    currentProjCuboidROIs(end+1,:)=copiedProjCuboidROIs{i}.Position;%#ok<AGROW>
                    numPastedROIs=numPastedROIs+1;
                end
            end

            if numPastedROIs>0

                actType=vision.internal.labeler.tool.actionType.Append;
                evtData=this.makeROIEventData(this.CurrentROIs((numROIsB4Paste+1):end),actType);
                notify(this,'LabelIsChanged',evtData);
            end


            function yesNo=isBBoxOutsideImage(pos,XMin,YMin,XMax,YMax)

                Xleft=pos(:,1);
                Ytop=pos(:,2);

                Xright=pos(:,1)+pos(:,3);
                Ybottom=pos(:,2)+pos(:,4);

                yesNo=min(Xleft)<XMin||max(Xright)>XMax||...
                min(Ytop)<YMin||max(Ybottom)>YMax;
            end



            function findPlaceToPasteProjCuboid()


                newBoxPoints=boxPoints+offset(offsetIndex,:);
                if isBBoxOutsideImage(newBoxPoints,eps,eps,x_extent,y_extent)



                    offsetIndex=offsetIndex+1;
                    if offsetIndex==9
                        offsetIndex=1;
                    end
                    findPlaceToPasteProjCuboid();
                else




                    if~isequal(lastToLastPoints,newBoxPoints)




                        if doesOverlapWithExistingProjCuboidRoi(this,this.getBoundingBox(currentProjCuboidROIsPosUpdated),boxPoints)




                            boxPoints=newBoxPoints;
                            lastToLastPoints=lastPoints;
                            lastPoints=boxPoints;
                            findPlaceToPasteProjCuboid();
                        end
                    else



                        offsetIndex=offsetIndex+1;
                        if offsetIndex==9
                            offsetIndex=1;
                        end
                        findPlaceToPasteProjCuboid();
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
                    strcmpi(copiedData.UserData{1},'projCuboid');

                    N=N+double(hasMatch);

                end
            end
        end
    end

    methods(Access=protected)






        function drawInteractiveROIs(this,roiPositions,roiNames,...
            parentNames,selfUIDs,parentUIDs,colors,shapes,roiVisibility)


            for n=1:numel(roiPositions)
                if shapes(n)==labelType.ProjectedCuboid
                    roiPos=roiPositions{n};

                    if(strcmp(this.ROIColorGroup,'By Instance'))
                        currColor=this.getInstanceColorByIdx(n);
                    else
                        currColor=colors{n};
                    end

                    eroi=makeEnhancedROI(this,roiPos,roiNames{n},...
                    parentNames{n},selfUIDs{n},parentUIDs{n},currColor,roiVisibility{n});
                    this.CurrentROIs{end+1}=eroi;
                end
            end
        end


        function eroi=makeEnhancedROI(this,rois,roiName,parentName,selfUID,parentUID,color,roiVisibility)
            eroi=createProjCuboid(this,roiName,parentName,selfUID,parentUID,color,roiVisibility);


            rois(1)=rois(1)-0.5;
            rois(2)=rois(2)-0.5;
            rois(3)=floor(rois(3));
            rois(4)=floor(rois(4));

            rois(5)=rois(5)-0.5;
            rois(6)=rois(6)-0.5;
            rois(7)=floor(rois(7));
            rois(8)=floor(rois(8));

            eroi.Position=rois;
        end

        function create(this,first,last)




            for idx=first:last

                h=vision.roi.ProjectedCuboid(...
                'Label','',...
                'Tag','',...
                'SelectedColor',[1,1,0],...
                'FaceSelectable',false,...
                'FaceAlpha',0.3,...
                'UserData',{'projCuboid','','',''},...
                'LabelVisible',this.LabelVisibleInternal,...
                'UIContextMenu',this.ContextMenu);


                this.addCallbacks(h);
                addlistener(h,'MovingROI',@(src,evt)onDraw(this,src,evt));

                this.ROI=[this.ROI,h];
                this.checkArray=[this.checkArray,0];
            end

        end


        function roi=createProjCuboid(this,roiName,parentName,selfUID,parentUID,color,roiVisibility)

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
            this.ROI(idx).UserData={'projCuboid',parentName,parentUID,selfUID};
            this.ROI(idx).Selected=0;
            this.ROI(idx).LabelVisible=this.LabelVisibleInternal;
            roi=this.ROI(idx);
            this.checkArray(idx)=1;
            this.ROI(idx).Visible=roiVisibility;
        end

        function createContextMenu(this)


            h=vision.roi.ProjectedCuboid();

            cMenu=h.UIContextMenu;


            h1=findobj(cMenu,'Tag','IPTROIContextMenuAspectRatio');
            delete(h1);
            h1=findobj(cMenu,'Tag','IPTROIContextMenuDelete');
            delete(h1);

            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCopy'),'Callback',@this.CopyCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCut'),'Callback',@this.CutCallbackFcn);
            uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:deleteProjCuboid'),'Callback',@this.DeleteCallbackFcn);

            this.ContextMenu=cMenu;

        end

        function checkIfMoreROIsRequired(this)
            if numel(this.ROI)<this.NumInUse
                create(this,numel(this.ROI)+1,this.NumInUse);
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
                enhancedProjCuboidRoi=createProjCuboid(this,roiName,parentName,selfUID,roi_parentUID,color,roiVisibility);
                pos=this.AxesHandle.CurrentPoint(1,1:2);

                pos(1)=pos(1)-0.5;
                pos(2)=pos(2)-0.5;

                pos=round(pos);

                pos(1)=pos(1)+0.5;
                pos(2)=pos(2)+0.5;



                enhancedProjCuboidRoi.LabelVisible='off';
                enhancedProjCuboidRoi.beginDrawingFromPoint(pos);


                enhancedProjCuboidRoi.LabelVisible=this.LabelVisibleInternal;

                if~this.checkROIValidity(enhancedProjCuboidRoi)


                    this.deparent(enhancedProjCuboidRoi);


                    notify(this,'DrawingFinished');
                    return;
                else
                    notify(this,'DrawingFinished');
                    if this.UserIsDrawing
                        enhancedProjCuboidRoi.Selected=true;
                    end
                    this.CurrentROIs{end+1}=enhancedProjCuboidRoi;

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
                enhancedProjCuboidRoi=makeEnhancedROI(this,roiPos,roiName,parentName,selfUID,roi_parentUID,color,roiVisibility);
                this.CurrentROIs{end+1}=enhancedProjCuboidRoi;

                evtData=this.makeROIEventData(this.CurrentROIs);
                notify(this,'LabelIsChanged',evtData);
            end
        end


        function onDraw(~,src,~)


            pos=src.Position;

            pos(1)=pos(1)-0.5;
            pos(2)=pos(2)-0.5;
            pos(5)=pos(5)-0.5;
            pos(6)=pos(6)-0.5;

            pos=round(pos);

            pos(1)=pos(1)+0.5;
            pos(2)=pos(2)+0.5;
            pos(5)=pos(5)+0.5;
            pos(6)=pos(6)+0.5;

            src.Position=pos;

        end

    end

    methods(Static)

        function outBbox=getBoundingBox(pos)

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
            if iscell(pos)
                pos=pos{1};
            end
            if isvector(pos)&&size(pos,1)>1

                pos=pos';
            end

            xLeft_1stFace=pos(:,1);
            xRight_1stFace=xLeft_1stFace+pos(:,3);
            yTop_1stFace=pos(:,2);
            yBottom_1stFace=yTop_1stFace+pos(:,4);

            xLeft_2ndFace=pos(:,5);
            xRight_2ndFace=xLeft_2ndFace+pos(:,7);
            yTop_2ndFace=pos(:,6);
            yBottom_2ndFace=yTop_2ndFace+pos(:,8);

            xMin=min(xLeft_1stFace,xLeft_2ndFace);
            xMax=max(xRight_1stFace,xRight_2ndFace);

            yMin=min(yTop_1stFace,yTop_2ndFace);
            yMax=max(yBottom_1stFace,yBottom_2ndFace);

            outBbox=[xMin,yMin,xMax-xMin,yMax-yMin];

        end
    end
    methods(Access=private)

        function pos=bbox2ProjCuboidPos(~,bbox,origPos)

            xLeft_1stFace=origPos(1);
            yTop_1stFace=origPos(2);

            xLeft_2ndFace=origPos(5);
            yTop_2ndFace=origPos(6);


            xMin=bbox(1);
            yMin=bbox(2);
            xExtent=bbox(1)+bbox(3)-1;
            yExtent=bbox(2)+bbox(4)-1;

            deX_1st2nd=xLeft_2ndFace-xLeft_1stFace;
            deY_1st2nd=yTop_2ndFace-yTop_1stFace;


            if xLeft_1stFace<xLeft_2ndFace
                xLeft_1stFace=max(xMin,xLeft_1stFace);
                w_1stFace=min(origPos(3),bbox(3));


                xLeft_2ndFace=xLeft_1stFace+deX_1st2nd;
                if xLeft_2ndFace>xExtent
                    xLeft_2ndFace=xExtent-origPos(7)+1;
                    xLeft_2ndFace=max(xMin,xLeft_2ndFace);
                end
                w_2ndFace=min(origPos(7),xExtent-xLeft_2ndFace+1);
            else
                xLeft_2ndFace=max(xMin,xLeft_2ndFace);
                w_2ndFace=min(origPos(7),bbox(3));

                xLeft_1stFace=xLeft_2ndFace-deX_1st2nd;
                if xLeft_1stFace>xExtent
                    xLeft_1stFace=xExtent-origPos(3)+1;
                    xLeft_1stFace=max(xMin,xLeft_1stFace);
                end
                w_1stFace=min(origPos(3),xExtent-xLeft_1stFace+1);
            end


            if yTop_1stFace<yTop_2ndFace
                yTop_1stFace=max(yMin,yTop_1stFace);
                h_1stFace=min(origPos(4),bbox(4));


                yTop_2ndFace=yTop_1stFace+deY_1st2nd;
                if yTop_2ndFace>yExtent
                    yTop_2ndFace=yExtent-origPos(8)+1;
                    yTop_2ndFace=max(yMin,yTop_2ndFace);
                end
                h_2ndFace=min(origPos(8),yExtent-yTop_2ndFace+1);
            else
                yTop_2ndFace=max(yMin,yTop_2ndFace);
                h_2ndFace=min(origPos(8),bbox(4));

                yTop_1stFace=yTop_2ndFace-deY_1st2nd;
                if yTop_1stFace>yExtent
                    yTop_1stFace=yExtent-origPos(4)+1;
                    yTop_1stFace=max(yMin,yTop_1stFace);
                end
                h_1stFace=min(origPos(4),yExtent-yTop_1stFace+1);
            end

            pos=[xLeft_1stFace,yTop_1stFace,w_1stFace,h_1stFace...
            ,xLeft_2ndFace,yTop_2ndFace,w_2ndFace,h_2ndFace];
        end

        function tf=doesOverlapWithExistingProjCuboidRoi(~,bbox1,bbox2)
            tf=~isempty(intersect(bbox1,bbox2,'rows'));
        end
    end

end