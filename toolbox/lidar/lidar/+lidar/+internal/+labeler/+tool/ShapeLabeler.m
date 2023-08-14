


classdef ShapeLabeler<lidar.internal.labeler.tool.ROILabeler

    properties

        CurrentROIs={};
SelectedROIinfo
        LabelVisibleInternal='hover';
        ROIColorGroup='By Label';



        MarkersVisible='on';
    end

    properties(Dependent)
LabelVisible
    end

    properties(Abstract,Access=protected)

ShapeSpec
    end

    properties(Access=private)

        ROI_INSTANCE_COLOR=[0.3333,1.0000,0.6667;
        0,0,0.6667;
        0.6667,1.0000,0.3333;
        0,0.6667,1.0000;
        1.0000,0.6667,0;
        0,1.0000,1.0000;
        1.0000,1.0000,0;
        0,0.3333,1.0000;
        1.0000,0.3333,0;
        0,0,1.0000];
    end

    events

DrawingStarted


DrawingFinished


MultiROIMoving


ReshapeROI

    end

    methods(Abstract,Access=public)

        pasteSelectedROIs(this,CopiedROIs)

    end

    methods(Abstract,Access=protected)

        drawInteractiveROIs(this,roiPositions,labelNames,colors,shapes)
    end

    methods

        function drawLabels(this,data)

            drawInteractiveROIs(this,data.Positions,data.Names,data.ParentNames,data.SelfUIDs,data.ParentUIDs,data.Colors,data.Shapes,data.ROIVisibility);
        end


        function this=addCutCallback(this,cutCallback)
            this.CutCallbackFcn=cutCallback;
        end


        function this=addCopyCallback(this,copyCallback)
            this.CopyCallbackFcn=copyCallback;
        end

        function this=addDeleteCallback(this,DeleteCallback)
            this.DeleteCallbackFcn=DeleteCallback;
        end


        function deleteROIwithUID(this,uid)




            numROIs=numel(this.CurrentROIs);
            isDeleted=false(1,numROIs);



            for i=1:numROIs
                if this.checkROIValidity(this.CurrentROIs{i})
                    if strcmp(this.CurrentROIs{i}.UserData{4},uid)
                        if strcmp(this.CurrentROIs{i}.Type,'images.roi.cuboid')...
                            ||strcmp(this.CurrentROIs{i}.Type,'vision.roi.polyline3D')
                            deparent(this,this.CurrentROIs{i});
                        else
                            delete(this.CurrentROIs{i});
                        end
                        isDeleted(i)=true;

                        break;
                    end
                end
            end

            this.CurrentROIs=this.CurrentROIs(~isDeleted);
            if any(isDeleted)
                evtData=this.makeROIEventData(this.CurrentROIs);
                notify(this,'LabelIsDeleted',evtData)
            end
        end


        function N=getNumROIInstanceSelected(this)

            N=0;
            numROIs=numel(this.CurrentROIs);
            for i=1:numROIs
                N=N+this.CurrentROIs{i}.Selected;
            end
        end


        function deleteSelectedROIs(this,varargin)




            numROIs=numel(this.CurrentROIs);
            isDeleted=false(1,numROIs);
            if nargin==2



                for i=1:numROIs
                    if~(this.checkROIValidity(this.CurrentROIs{i}))
                        if~isvalid(this.CurrentROIs{i})
                            handleDeletedObj(this);
                        end
                        isDeleted(i)=true;
                    end
                end
            else

                for i=1:numROIs
                    if this.CurrentROIs{i}.Selected||~this.checkROIValidity(this.CurrentROIs{i})
                        if strcmp(this.CurrentROIs{i}.Type,'images.roi.cuboid')...
                            ||strcmp(this.CurrentROIs{i}.Type,'vision.roi.polyline3D')
                            deparent(this,this.CurrentROIs{i});
                        else
                            delete(this.CurrentROIs{i});
                        end
                        isDeleted(i)=true;
                    end
                end
            end
            this.CurrentROIs=this.CurrentROIs(~isDeleted);
            if any(isDeleted)
                evtData=this.makeROIEventData(this.CurrentROIs);
                notify(this,'LabelIsDeleted',evtData)
            end
        end


        function wipeROIs(this)

            for n=1:numel(this.CurrentROIs)
                if strcmp(this.CurrentROIs{n}.Type,'images.roi.cuboid')...
                    ||strcmp(this.CurrentROIs{n}.Type,'vision.roi.polyline3D')
                    deparent(this,this.CurrentROIs{n});
                else
                    delete(this.CurrentROIs{n});
                end
            end
            this.CurrentROIs={};
        end


        function rois=getSelectedROIsForCopy(this)

            rois={};
            for i=1:numel(this.CurrentROIs)
                if this.checkROIValidity(this.CurrentROIs{i})&&this.CurrentROIs{i}.Selected
                    thisroi=this.getCopiedData(this.CurrentROIs{i});

                    thisroi.parentName=this.CurrentROIs{i}.UserData{2};
                    thisroi.parentUID=this.CurrentROIs{i}.UserData{3};
                    thisroi.selfUID=this.CurrentROIs{i}.UserData{4};
                    rois{end+1}=thisroi;%#ok<AGROW>
                end
            end
        end







        function thisroi=copyROIByID(this,matchID)

            thisroi=[];
            for i=1:numel(this.CurrentROIs)
                if isequal(this.CurrentROIs{i}.UserData{4},matchID)
                    thisroi=this.getCopiedData(this.CurrentROIs{i});

                    thisroi.parentName=this.CurrentROIs{i}.UserData{2};
                    thisroi.parentUID=this.CurrentROIs{i}.UserData{3};
                    thisroi.selfUID=this.CurrentROIs{i}.UserData{4};
                    break
                end
            end
        end


        function selectAll(this)
            curROIs=this.CurrentROIs;
            for i=1:numel(curROIs)
                curROIs{i}.Selected=true;
            end
        end


        function selectROI(this)
            for idx=1:numel(this.CurrentROIs)
                if this.CurrentROIs{idx}.Selected
                    if idx==numel(this.CurrentROIs)||isMultipleROIselected(this)
                        activateROI(this,idx,1);
                    else
                        activateROI(this,idx,idx+1)
                        break;
                    end
                end
            end

            evtData=this.makeROIEventData(this.CurrentROIs);
            notify(this,'LabelIsChanged',evtData);
        end


        function selectROIreverse(this)
            noOfROIs=numel(this.CurrentROIs);
            if(noOfROIs>=1&&this.CurrentROIs{1}.Selected&&...
                ~isMultipleROIselected(this))
                activateROI(this,1,noOfROIs);
            else
                for idx=2:noOfROIs
                    if this.CurrentROIs{idx}.Selected
                        if~isMultipleROIselected(this)
                            activateROI(this,idx,idx-1);
                            break;
                        else
                            activateROI(this,idx,1);
                        end
                    end
                end

                evtData=this.makeROIEventData(this.CurrentROIs);
                notify(this,'LabelIsChanged',evtData);
            end
        end


        function activateROI(this,idx1,idx2)
            this.CurrentROIs{idx1}.Selected=false;
            this.CurrentROIs{idx2}.Selected=true;
        end


        function info=selectROIInfo(this)
            info=[];
            for i=1:numel(this.CurrentROIs)
                if this.CurrentROIs{i}.Selected
                    info=this.CurrentROIs{i};
                    return;
                end
            end
        end


        function moveSelectedROI(this,roiInfo,keyPressed)

            pos=roiInfo.Position;
            previousPosition=roiInfo.Position;
            if isa(roiInfo,'images.roi.Rectangle')
                switch keyPressed
                case 'uparrow'
                    pos(2)=pos(2)-1;
                    roiInfo.Position=pos;
                case 'downarrow'
                    pos(2)=pos(2)+1;
                    roiInfo.Position=pos;
                case 'rightarrow'
                    pos(1)=pos(1)+1;
                    roiInfo.Position=pos;
                case 'leftarrow'
                    pos(1)=pos(1)-1;
                    roiInfo.Position=pos;
                end
                evtData=images.roi.ROIMovingEventData(previousPosition,roiInfo.Position);
            else
                switch keyPressed
                case 'uparrow'
                    pos(:,2)=pos(:,2)-1;
                    roiInfo.Position=pos;
                case 'downarrow'
                    pos(:,2)=pos(:,2)+1;
                    roiInfo.Position=pos;
                case 'rightarrow'
                    pos(:,1)=pos(:,1)+1;
                    roiInfo.Position=pos;
                case 'leftarrow'
                    pos(:,1)=pos(:,1)-1;
                    roiInfo.Position=pos;
                end
                evtData=images.roi.ROIMovingEventData(previousPosition,roiInfo.Position);
            end
            notify(roiInfo,'MovingROI',evtData);
            onMove(this,roiInfo);
        end


        function reshapeRectROI(this,roiInfo,keyPressed)
            pos=roiInfo.Position;
            previousPosition=roiInfo.Position;
            if~isMultipleROIselected(this)
                switch keyPressed

                case{'add','equal'}
                    pos(:,1:2)=pos(:,1:2)-1.0000;
                    pos(:,3:4)=pos(:,3:4)+2.0000;
                    roiInfo.Position=pos;
                case{'subtract','hyphen'}
                    if pos(3)>3&&pos(4)>3


                        pos(:,1:2)=pos(:,1:2)+1.0000;
                        pos(:,3:4)=pos(:,3:4)-2.0000;
                        roiInfo.Position=pos;
                    else

                        return;
                    end
                end

                evtData=images.roi.ROIMovingEventData(previousPosition,roiInfo.Position);
                notify(roiInfo,'MovingROI',evtData);
                onMove(this,roiInfo);
            end
        end


        function deselectAll(this)
            curROIs=this.CurrentROIs;
            for i=1:numel(curROIs)
                if curROIs{i}.Selected
                    curROIs{i}.Selected=false;
                end
            end
        end










        function[labelName,labelInstanceUID]=getLastSelectedLabelInstanceInfo(this)
            if isempty(this.SelectedROIinfo)
                [labelName,labelInstanceUID]=deal('','');
            else
                labelName=this.SelectedROIinfo.LabelName;
                labelInstanceUID=this.SelectedROIinfo.LabelUID;
            end
        end


        function[labelName,sublabelName,selfUID,parentUID]=getLabelDefInfo(this,roi)

            data=this.getCopiedData(roi);
            ud=data.UserData;
            parentName=ud{2};

            if isempty(parentName)

                labelName=data.Tag;
                sublabelName='';
            end

            ud=roi.UserData;
            parentUID=ud{3};
            selfUID=ud{4};
        end






























        function TF=hasSelectedROI(this)
            TF=false;
            for i=1:numel(this.CurrentROIs)
                if this.CurrentROIs{i}.Selected
                    TF=true;
                    return;
                end
            end
        end


        function setSingleSelectedROIInstanceInfo(this,selected_ROIinfo)
            this.SelectedROIinfo.LabelName=selected_ROIinfo.LabelName;
            this.SelectedROIinfo.LabelUID=selected_ROIinfo.LabelUID;
            this.SelectedROIinfo.Type=selected_ROIinfo.Type;
        end


        function[labelName,sublabelName,uid,p_uid]=getSingleSelectedROIInstanceInfo(this)


            labelName='';
            sublabelName='';
            uid='';
            p_uid='';
            numSelected=0;
            for i=1:numel(this.CurrentROIs)
                if this.CurrentROIs{i}.Selected
                    [labelName,sublabelName,uid,p_uid]=getLabelDefInfo(this,this.CurrentROIs{i});
                    numSelected=numSelected+1;
                    if(numSelected>1)
                        labelName='';
                        sublabelName='';
                        uid='';
                        p_uid='';
                        return;
                    end
                end
            end
        end




        function[labelName,sublabelName,roiData]=getFirstSelectedROIInstanceInfo(this)

            labelName='';
            sublabelName='';
            roiData=[];
            for i=1:numel(this.CurrentROIs)
                if this.CurrentROIs{i}.Selected

                    [labelName,sublabelName,selfUID,parentUID]=getLabelDefInfo(this,this.CurrentROIs{i});
                    roiData.PUID=parentUID;
                    roiData.ID=selfUID;

                    copiedData=this.getCopiedData(this.CurrentROIs{i});
                    roiData.Position=copiedData.Position;
                    roiData.Color=copiedData.Color;
                    return;
                end
            end
        end


        function[labelName,roiData]=getOneSelectedROILabelInstanceInfo(this)

            labelName='';
            roiData=[];
            for i=1:numel(this.CurrentROIs)
                if this.CurrentROIs{i}.Selected

                    [labelName,sublabelName,selfUID,parentUID]=getLabelDefInfo(this,this.CurrentROIs{i});
                    if~isempty(labelName)&&isempty(sublabelName)
                        roiData.PUID=parentUID;
                        roiData.ID=selfUID;

                        copiedData=this.getCopiedData(this.CurrentROIs{i});
                        roiData.Position=copiedData.Position;
                        roiData.Color=copiedData.Color;
                        return;
                    end
                end
            end
        end


        function[roiName,parentName,parentUID]=getSelectedItemDefROIInstanceInfo(this)
            [roiName,parentName]=getSelectedItemName(this);
            if isempty(parentName)

                parentUID='';
            end
        end



        function onROISelection(this,eroi)



            curROIs=this.CurrentROIs;
            numROIs=numel(curROIs);
            for i=1:numROIs
                roi=curROIs{i};
                if((eroi~=roi)&&roi.Selected)
                    roi.Selected=false;
                end
            end
            evtData=this.makeROIEventData(curROIs);
            notify(this,'LabelIsSelected',evtData);
        end


        function onROIDeleted(this,eroi)



            isSelected=eroi.Selected;
            delete(eroi);
            if isSelected&&~(this.checkROIValidity(eroi))
                deleteSelectedROIs(this,eroi);
            else
                evtData=this.makeROIEventData(this.CurrentROIs);
                notify(this,'LabelIsChanged',evtData);
            end
        end


        function onROIClicked(this,src,evt)

            if strcmp(evt.SelectionType,'ctrl')
                if src.Selected
                    onROICtrlSelection(this,src);
                else
                    onROICtrlDeselection(this,src);
                end
            else
                onROISelectionPre(this,src,evt)
            end

        end


        function set.LabelVisible(this,val)
            val=validatestring(val,{'on','hover','off'});
            this.LabelVisibleInternal=val;
            cellfun(@(x)set(x,'LabelVisible',this.LabelVisibleInternal),this.CurrentROIs);
        end


        function val=get.LabelVisible(this)
            val=this.LabelVisibleInternal;
        end

    end


    methods(Access=protected)


        function evtData=makeROIEventData(this,data,varargin)
            rois=this.reformatCurrentROIs(data);
            evtData=vision.internal.labeler.tool.ROILabelEventData(rois,varargin{:});
        end


        function rois=reformatCurrentROIs(this,data)
            isValid=cellfun(@(r)this.checkROIValidity(r),data);

            rois=repmat(struct('ID','','ParentName','','ParentUID','','Label',[],'Position',[],'Color',[],'Shape',[],'ROIVisibility',''),...
            nnz(isValid),1);
            idx=1;
            for n=1:numel(data)
                if isValid(n)
                    data_n=data{n};
                    copiedData=this.getCopiedData(data_n);
                    ud=data_n.UserData;
                    rois(idx).ParentName=ud{2};
                    rois(idx).ParentUID=ud{3};
                    rois(idx).ID=ud{4};
                    rois(idx).Label=copiedData.Tag;
                    rois(idx).Position=copiedData.Position;
                    rois(idx).Color=copiedData.Color;
                    rois(idx).Shape=this.ShapeSpec;
                    rois(idx).ROIVisibility=copiedData.Visible;
                    idx=idx+1;
                end
            end
        end


        function addCallbacks(this,newROI)


            addlistener(newROI,'ROIClicked',@(src,evt)onROIClicked(this,src,evt));
            addlistener(newROI,'DeletingROI',@(src,~)onROIDeleted(this,src));
            addlistener(newROI,'MovingROI',@(src,evt)onMoving(this,src,evt));
            addlistener(newROI,'ROIMoved',@this.onMove);

        end


        function onMoving(this,src,evt)

            data.src=src;
            data.evt=evt;

            evtData=vision.internal.labeler.tool.ROILabelEventData(data);
            notify(this,'MultiROIMoving',evtData);

        end


        function onMove(this,varargin)





            if~this.UserIsDrawing
















                evtData=this.makeROIEventData(this.CurrentROIs);
                notify(this,'LabelIsChanged',evtData)
            end
        end


        function tf=isMultipleROIselected(this)

            tf=false;
            N=0;
            numROIs=numel(this.CurrentROIs);
            for i=1:numROIs
                roi=this.CurrentROIs{i};
                if roi.Selected
                    N=N+1;
                    if N>1
                        tf=true;
                        return;
                    end
                end
            end
        end


        function onROISelectionPre(this,src,evt)

            data.src=src;
            data.evt=evt;
            evtData=vision.internal.labeler.tool.ROILabelEventData(data);
            notify(this,'LabelIsSelectedPre',evtData);

        end


        function onROICtrlSelection(this,eroi)






            eroi.Selected=true;
            actType=vision.internal.labeler.tool.actionType.Skip;
            evtData=this.makeROIEventData(this.CurrentROIs,actType);
            notify(this,'LabelIsChanged',evtData);
        end


        function onROICtrlDeselection(this,eroi)






            eroi.Selected=false;
            actType=vision.internal.labeler.tool.actionType.Skip;
            evtData=this.makeROIEventData(this.CurrentROIs,actType);
            notify(this,'LabelIsChanged',evtData);
        end

    end
end
