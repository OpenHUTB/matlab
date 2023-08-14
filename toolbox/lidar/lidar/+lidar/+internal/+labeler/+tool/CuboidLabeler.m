classdef CuboidLabeler<lidar.internal.labeler.tool.ShapeLabeler




    properties(Access=protected)

ShapeSpec

        PreviewCuboid=[];
        PreviewCuboidLocation=[0,0,0];
        PreviewCuboidDimensions=[6,5,4];
        DefaultCuboidDimensions=[6,5,4];
        PreviewCuboidVisible='off';
PreviewScatter

KeyPressListener
KeyReleaseListener
MouseMotionListener
MouseButtonDownListener
MouseButtonUpListener
MouseScrollWheelListener

        XPressedFlag=false;
        YPressedFlag=false;
        ZPressedFlag=false;

        SnapToFitInternal(1,1)logical=true;
        ClusterDataInternal(1,1)logical=false;

        UserIsRotating=false;


        NumInUse=0;



ROI


        checkArray=[];

    end

    properties(Access=public)
        UsePCFit=false;
    end

    properties(Dependent)
ClusterData
SnapToFit
    end

    methods

        function this=CuboidLabeler()
            this.ShapeSpec=labelType.Cuboid;



            create(this,1,50);
        end


        function deparent(this,eroi)


            idx=find(this.ROI==eroi,1);
            this.checkArray(idx)=0;
            this.ROI(idx).Parent=gobjects(0);

            this.NumInUse=this.NumInUse-1;
        end


        function pasteSelectedROIs(this,CopiedCuboidROIs)

            numROIs=numel(CopiedCuboidROIs);

            if numROIs>0
                for i=1:numel(this.CurrentROIs)
                    if this.checkROIValidity(this.CurrentROIs{i})&&size(this.CurrentROIs{i}.Position,2)==6
                        this.CurrentROIs{i}.Selected=false;
                    end
                end
            else
                return;
            end

            numPastedROIs=0;
            for i=1:numROIs
                pos=CopiedCuboidROIs{i}.Position;

                if~isempty(pos)
                    eroi=makeEnhancedROI(this,pos,CopiedCuboidROIs{i}.Label,...
                    CopiedCuboidROIs{i}.parentName,CopiedCuboidROIs{i}.selfUID,CopiedCuboidROIs{i}.parentUID,CopiedCuboidROIs{i}.Color,CopiedCuboidROIs{i}.Visible);


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

                    hasMatch=(isParentROISelected(this,copiedData,sublabelItemData)||...
                    isthisOrSiblingROISelected(this,copiedData,sublabelItemData))&&...
                    strcmpi(copiedData.UserData{1},'cuboid');

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






        function drawInteractiveROIs(this,roiPositions,roiNames,parentNames,selfUIDs,parentUIDs,colors,shapes,roiVisibility)


            for n=1:numel(roiPositions)
                if shapes(n)==labelType.Cuboid
                    roiPos=roiPositions{n};
                    eroi=makeEnhancedROI(this,roiPos,roiNames{n},parentNames{n},selfUIDs{n},parentUIDs{n},colors{n},roiVisibility{n});
                    this.CurrentROIs{end+1}=eroi;
                end
            end
        end


        function eroi=makeEnhancedROI(this,rois,roiName,parentName,selfUID,parentUID,color,roiVisibility)




            eroi=createCuboid(this,roiName,parentName,selfUID,parentUID,color,roiVisibility);
            set(eroi,'CenteredPosition',rois(1:6),'RotationAngle',rois(7:9));
        end


        function create(this,first,last)




            for idx=first:last

                h=images.roi.Cuboid(...
                'Label','',...
                'Tag','',...
                'SelectedColor',[1,1,0],...
                'Rotatable','z',...
                'LabelVisible',this.LabelVisibleInternal,...
                'UserData',{'cuboid','','',''});

                cMenu=h.UIContextMenu;
                h1=findobj(cMenu,'Tag','IPTROIContextMenuDelete');
                delete(h1);
                uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCopy'),'Callback',@this.CopyCallbackFcn);
                uimenu('Parent',cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCut'),'Callback',@this.CutCallbackFcn);
                uimenu('Parent',cMenu,'Label',vision.getMessage('images:imroi:deleteCuboid'),'Callback',@this.DeleteCallbackFcn);
                h.UIContextMenu=cMenu;


                this.addCallbacks(h);

                this.ROI=[this.ROI,h];
                this.checkArray=[this.checkArray,0];
            end

        end


        function roi=createCuboid(this,roiName,parentName,selfUID,parentUID,color,roiVisibility)

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
            this.ROI(idx).UserData={'cuboid',parentName,parentUID,selfUID};
            this.ROI(idx).LabelVisible=this.LabelVisibleInternal;
            this.ROI(idx).Selected=0;
            this.ROI(idx).RotationAngle=[0,0,0];
            this.ROI(idx).InteractionsAllowed='all';
            roi=this.ROI(idx);
            this.checkArray(idx)=1;
            this.ROI(idx).Visible=roiVisibility;

        end


        function addCallbacks(this,newROI)


            addlistener(newROI,'ROIClicked',@(src,evt)onROIClicked(this,src,evt));
            addlistener(newROI,'DeletingROI',@(src,~)onROIDeleted(this,src));
            addlistener(newROI,'MovingROI',@(src,evt)MovingROICallback(this,src,evt));
            addlistener(newROI,'ROIMoved',@this.ROIMovedCallback);

        end


        function checkIfMoreROIsRequired(this)
            if numel(this.ROI)<this.NumInUse
                create(this,numel(this.ROI)+1,this.NumInUse);
            end
        end




        function onButtonDown(~,varargin)

        end

        function hidePreviewCuboid(this)
            this.PreviewCuboidVisible='off';
            updatePreviewCuboid(this);
        end

    end

    methods(Access=protected)

        function updatePreviewCuboid(this)

            set(this.PreviewCuboid,'Position',[this.PreviewCuboidLocation,this.PreviewCuboidDimensions],...
            'Visible',this.PreviewCuboidVisible);

            if strcmp(this.PreviewCuboidVisible,'on')

                x=this.ImageHandle.XData(isfinite(this.ImageHandle.XData));
                y=this.ImageHandle.YData(isfinite(this.ImageHandle.YData));
                z=this.ImageHandle.ZData(isfinite(this.ImageHandle.ZData));


                if(~isempty(x)&&~isempty(y)&&~isempty(z)&&~isempty(this.PreviewCuboid))
                    TF=inROI(this.PreviewCuboid,x,y,z);
                    set(this.PreviewScatter,'XData',x(TF),'YData',y(TF),'ZData',z(TF),'Visible','on')
                else
                    set(this.PreviewScatter,'Visible','off')
                end
            else
                set(this.PreviewScatter,'Visible','off')
            end

        end

        function mouseMotionCallback(this,evt)

            if isModeManagerActive(this)
                hidePreviewCuboid(this);
                return;
            end

            if this.UserIsDrawing
                return;
            end

            if isa(evt.HitObject,'matlab.graphics.chart.primitive.Scatter')

                if this.ClusterDataInternal

                    points=sum(([this.ImageHandle.XData',this.ImageHandle.YData',this.ImageHandle.ZData']-evt.IntersectionPoint).^2,2);
                    [~,idx]=min(points);
                    label=this.ImageHandle.ClusterData==this.ImageHandle.ClusterData(idx);

                    this.PreviewCuboidLocation=[min(this.ImageHandle.XData(label)),min(this.ImageHandle.YData(label)),min(this.ImageHandle.ZData(label))];
                    this.PreviewCuboidDimensions=[max(this.ImageHandle.XData(label)),max(this.ImageHandle.YData(label)),max(this.ImageHandle.ZData(label))]-this.PreviewCuboidLocation;

                else
                    this.PreviewCuboidLocation=evt.IntersectionPoint-(0.5*this.PreviewCuboidDimensions);
                end
                this.PreviewCuboidVisible='on';

            elseif isa(evt.HitObject,'matlab.graphics.axis.Axes')
                this.PreviewCuboidVisible='on';
            else
                this.PreviewCuboidVisible='off';
            end

            updatePreviewCuboid(this);

        end

        function mousePressCallback(this,evt)

            if isModeManagerActive(this)||wasClickOnAxesToolbar(this,evt)
                return;
            end

            mouseClickType=images.roi.internal.getClickType(this.Figure);

            if strcmpi(mouseClickType,'ctrl')||...
                strcmpi(mouseClickType,'shift')
                return;
            elseif strcmpi(mouseClickType,'middle')
                this.UserIsRotating=true;
                rotate3d(this.AxesHandle,'on','-orbit');
            end

            this.deselectAll();



            evtData=this.makeROIEventData(this.CurrentROIs);
            notify(this,'LabelIsSelected',evtData);

            if strcmpi(mouseClickType,'left')

                if(isa(evt.HitObject,'matlab.graphics.chart.primitive.Scatter')||isa(evt.HitObject,'matlab.graphics.axis.Axes'))...
                    &&strcmp(this.PreviewCuboid.Visible,'on')
                    [roiName,parentName,roi_parentUID]=getSelectedItemDefROIInstanceInfo(this);
                    selfUID='';
                    roiVisibility=true;
                    enhancedCuboidRoi=createCuboid(this,roiName,parentName,selfUID,roi_parentUID,this.SelectedLabel.Color,roiVisibility);
                    enhancedCuboidRoi.Selected=true;

                    set(enhancedCuboidRoi,'Position',[this.PreviewCuboidLocation,this.PreviewCuboidDimensions]);

                    x=this.ImageHandle.XData(isfinite(this.ImageHandle.XData));
                    y=this.ImageHandle.YData(isfinite(this.ImageHandle.YData));
                    z=this.ImageHandle.ZData(isfinite(this.ImageHandle.ZData));
                    if this.SnapToFitInternal

                        if~isempty(x)

                            TF=inROI(enhancedCuboidRoi,x,y,z);

                            if sum(TF)>1

                                xLim=[min(x(TF)),max(x(TF))];
                                yLim=[min(y(TF)),max(y(TF))];
                                zLim=[min(z(TF)),max(z(TF))];

                                set(enhancedCuboidRoi,'Position',[xLim(1),yLim(1),zLim(1),xLim(2)-xLim(1),yLim(2)-yLim(1),zLim(2)-zLim(1)]);

                            end
                        end
                    end



                    this.autoAlign(enhancedCuboidRoi,x,y,z);

                    this.CurrentROIs{end+1}=enhancedCuboidRoi;

                    evtData=this.makeROIEventData(this.CurrentROIs);
                    notify(this,'LabelIsChanged',evtData);

                end

            end

            hidePreviewCuboid(this);

        end

        function autoAlign(~,~,~,~,~)

        end

        function mouseReleaseCallback(this,~)

            if this.UserIsRotating
                this.UserIsRotating=false;
                rotate3d(this.AxesHandle,'off');
            end

        end

        function mouseScrollCallback(this,evt)

            if isModeManagerActive(this)
                return;
            end

            isIncreaseSize=evt.VerticalScrollCount>0;
            scaleFactor=1.1;

            keyPressedFlags=[false,false,false];

            if this.XPressedFlag
                keyPressedFlags(1)=true;
            end

            if this.YPressedFlag
                keyPressedFlags(2)=true;
            end

            if this.ZPressedFlag
                keyPressedFlags(3)=true;
            end

            if isIncreaseSize
                candidateSize=this.PreviewCuboidDimensions.*scaleFactor;
            else
                candidateSize=this.PreviewCuboidDimensions./scaleFactor;
            end

            if candidateSize>0
                oldLocation=this.PreviewCuboidLocation;
                oldCenter=oldLocation+(0.5*this.PreviewCuboidDimensions);
                this.PreviewCuboidDimensions(keyPressedFlags)=candidateSize(keyPressedFlags);
                this.PreviewCuboidLocation(keyPressedFlags)=oldCenter(keyPressedFlags)-(0.5*candidateSize(keyPressedFlags));
            end

            updatePreviewCuboid(this);

        end

        function TF=isModeManagerActive(this)
            hManager=uigetmodemanager(this.Figure);
            hMode=hManager.CurrentMode;
            TF=isobject(hMode)&&isvalid(hMode)&&~isempty(hMode);
        end

        function TF=wasClickOnAxesToolbar(~,evt)



            TF=~isempty(ancestor(evt.HitObject,'matlab.graphics.controls.AxesToolbar'));
        end

        function MovingROICallback(this,src,evt)
            this.UserIsDrawing=true;
            x=this.ImageHandle.XData(isfinite(this.ImageHandle.XData));
            y=this.ImageHandle.YData(isfinite(this.ImageHandle.YData));
            z=this.ImageHandle.ZData(isfinite(this.ImageHandle.ZData));
            if~(isempty(x)&&isempty(y)&&isempty(z))
                TF=inROI(src,x,y,z);
                set(this.PreviewScatter,'XData',x(TF),'YData',y(TF),'ZData',z(TF),'Visible','on')
            else
                set(this.PreviewScatter,'Visible','off')
            end
            data.src=src;
            data.evt=evt;

            evtData=vision.internal.labeler.tool.ROILabelEventData(data);
            notify(this,'MultiROIMoving',evtData);
        end

        function ROIMovedCallback(this,varargin)
            this.UserIsDrawing=false;
            set(this.PreviewScatter,'Visible','off')

            evtData=this.makeROIEventData(this.CurrentROIs);
            notify(this,'LabelIsChanged',evtData)
        end

    end

    methods

        function keyPressCallback(this,evt)

            keyPressed=evt.Key;
            modPressed=evt.Modifier;

            if strcmp(evt.EventName,'WindowKeyPress')&&isempty(modPressed)
                panStepProperties=[0.001,0.1,2];
                HorizontalRotate=true;
                RotateDirection=1;
                if isequal(keyPressed,'a')&&strcmp(this.PreviewCuboidVisible,'off')
                    this.lookAround(panStepProperties,HorizontalRotate,RotateDirection,this.AxesHandle);
                elseif isequal(keyPressed,'d')
                    this.lookAround(panStepProperties,HorizontalRotate,-RotateDirection,this.AxesHandle);
                elseif isequal(keyPressed,'w')
                    this.lookAround(panStepProperties,~HorizontalRotate,-RotateDirection,this.AxesHandle);
                elseif isequal(keyPressed,'s')
                    this.lookAround(panStepProperties,~HorizontalRotate,RotateDirection,this.AxesHandle);
                end
            end

            if any(strcmp(evt.Key,{'r'}))
                import matlab.graphics.interaction.internal.setPointer
                switch evt.EventName
                case 'WindowKeyPress'
                    if~isModeManagerActive(this)
                        this.PreviewCuboidVisible='off';
                        updatePreviewCuboid(this);
                        hFigure=evt.Source;
                        newCursor='rotate';
                        setPointer(hFigure,newCursor);
                        rotate3d(this.AxesHandle,'on','-orbit');
                    end
                case 'WindowKeyRelease'
                    rotate3d(this.AxesHandle,'off');
                    hFigure=evt.Source;
                    newCursor='arrow';
                    setPointer(hFigure,newCursor);
                end
                return;
            end

            if isModeManagerActive(this)
                return;
            end

            isXPressed=any(strcmp(evt.Key,{'x','a'}));
            isYPressed=any(strcmp(evt.Key,{'y','a'}));
            isZPressed=any(strcmp(evt.Key,{'z','a'}));

            if isXPressed
                switch evt.EventName
                case 'WindowKeyPress'
                    this.XPressedFlag=true;
                case 'WindowKeyRelease'
                    this.XPressedFlag=false;
                end
            end

            if isYPressed
                switch evt.EventName
                case 'WindowKeyPress'
                    this.YPressedFlag=true;
                case 'WindowKeyRelease'
                    this.YPressedFlag=false;
                end
            end

            if isZPressed
                switch evt.EventName
                case 'WindowKeyPress'
                    this.ZPressedFlag=true;
                case 'WindowKeyRelease'
                    this.ZPressedFlag=false;
                end
            end

        end


        function activate(this,fig,ax,imageHandle)

            this.attachToImage(fig,ax,imageHandle);

            if~isempty(this.MouseButtonDownListener)&&isvalid(this.MouseButtonDownListener)&&fig==this.MouseButtonDownListener.Source{:}
                this.KeyPressListener.Enabled=true;
                this.KeyReleaseListener.Enabled=true;
                this.MouseMotionListener.Enabled=true;
                this.MouseButtonDownListener.Enabled=true;
                this.MouseButtonUpListener.Enabled=true;
                this.MouseScrollWheelListener.Enabled=true;
            else
                this.KeyPressListener=event.listener(fig,'WindowKeyPress',@(src,evt)keyPressCallback(this,evt));
                this.KeyReleaseListener=event.listener(fig,'WindowKeyRelease',@(src,evt)keyPressCallback(this,evt));
                this.MouseMotionListener=event.listener(fig,'WindowMouseMotion',@(src,evt)mouseMotionCallback(this,evt));
                this.MouseButtonDownListener=event.listener(fig,'WindowMousePress',@(src,evt)mousePressCallback(this,evt));
                this.MouseButtonUpListener=event.listener(fig,'WindowMouseRelease',@(src,evt)mouseReleaseCallback(this,evt));
                this.MouseScrollWheelListener=event.listener(fig,'WindowScrollWheel',@(src,evt)mouseScrollCallback(this,evt));
            end

            if isempty(this.PreviewScatter)

                hold(ax,'on');

                this.PreviewScatter=scatter3(NaN,NaN,NaN,10,[1,1,0],'.',...
                'HitTest','off',...
                'PickableParts','none',...
                'Parent',ax,...
                'HandleVisibility','off');

                hold(ax,'off');

            end

            if isempty(this.PreviewCuboid)

                this.PreviewCuboid=images.roi.Cuboid('Color',[0,1,1],...
                'InteractionsAllowed','none',...
                'Parent',ax,...
                'FaceAlpha',0,...
                'EdgeAlpha',0.5);

            end


            set(this.ImageHandle,'ButtonDownFcn',@this.onButtonDownWrapper);
        end


        function deactivate(this)

            delete(this.PreviewCuboid);
            this.PreviewCuboid=[];
            delete(this.PreviewScatter);
            this.PreviewScatter=[];

            if~isempty(this.MouseButtonDownListener)&&isvalid(this.MouseButtonDownListener)
                this.KeyPressListener.Enabled=false;
                this.KeyReleaseListener.Enabled=false;
                this.MouseMotionListener.Enabled=false;
                this.MouseButtonDownListener.Enabled=false;
                this.MouseButtonUpListener.Enabled=false;
                this.MouseScrollWheelListener.Enabled=false;
            else
                delete(this.KeyPressListener);
                delete(this.KeyReleaseListener);
                delete(this.MouseMotionListener);
                delete(this.MouseButtonDownListener);
                delete(this.MouseButtonUpListener);
                delete(this.MouseScrollWheelListener);
            end
        end

    end
    methods

        function[cuboid,cm]=getOrientedBox(this,~,TF,x,y,z)

            inx=x(TF);
            iny=y(TF);
            inz=z(TF);
            xyzPoints=[inx',iny',inz'];
            ptc=pointCloud(xyzPoints);
            [cuboid,cm]=this.pcCrop(ptc);

        end

        function[cuboid,model]=pcCrop(~,ptC)
            minZ=ptC.ZLimits(1);
            maxZ=ptC.ZLimits(2);
            area=[];
            H=(maxZ-minZ);
            limitZ=minZ;
            prevArea=-1;
            maxGrad=0;

            for i=minZ-0.01:H/20:maxZ-H/2+0.01
                in=ptC.findPointsInROI([ptC.XLimits+[-0.1,0.1],ptC.YLimits+[-0.1,0.1],i-H/40,i+H/40]);
                if(numel(in)>4)
                    area=abs((max(ptC.Location(in,1))-min(ptC.Location(in,1)))*(max(ptC.Location(in,2))-min(ptC.Location(in,2))));
                    gradArea=prevArea-area;
                    if(maxGrad<gradArea&&prevArea~=0)
                        limitZ=i-H/40;
                        maxGrad=gradArea;
                        prevArea=area;
                    end
                    if(prevArea<0)
                        prevArea=area;
                    end
                end
            end
            in=ptC.findPointsInROI([ptC.XLimits,ptC.YLimits,limitZ,ptC.ZLimits(2)]);

            ptC=select(ptC,in);
            model=pcfitcuboid(ptC);
            cuboid=[model.Center-model.Dimensions/2+[0,0,ptC.ZLimits(1)-limitZ],model.Dimensions+abs([0,0,ptC.ZLimits(1)-limitZ]),model.Orientation(3)];
        end
    end


    methods

        function set.ClusterData(this,TF)
            this.ClusterDataInternal=TF;

            if~TF
                this.PreviewCuboidDimensions=this.DefaultCuboidDimensions;
                updatePreviewCuboid(this);
            end

        end

        function TF=get.ClusterData(this)
            TF=this.ClusterDataInternal;
        end


        function set.SnapToFit(this,TF)
            this.SnapToFitInternal=TF;
        end

        function TF=get.SnapToFit(this)
            TF=this.SnapToFitInternal;
        end

        function TF=isCuboidResizeButtonPressed(this)
            TF=this.XPressedFlag||this.YPressedFlag||this.ZPressedFlag;
        end

    end

    methods(Access=private,Static)


        function lookAround(panStepProperties,horizontalPan,panDirection,currentAxes)
            udata=pointclouds.internal.pcui.utils.getAppData(currentAxes,'PCUserData');

            minLimit=min(udata.dataLimits);
            maxLimit=max(udata.dataLimits);
            viewAngle=currentAxes.CameraViewAngle;

            panStepSize=panStepProperties(1);
            panAngleMin=panStepProperties(2);
            panAngleMax=panStepProperties(3);

            theta=panDirection*(max(min(panStepSize*(maxLimit-minLimit),panAngleMax),panAngleMin));

            if horizontalPan
                campan(currentAxes,theta,0);
            else
                campan(currentAxes,0,theta);
            end

            currentAxes.CameraViewAngle=viewAngle;
        end
    end

end
