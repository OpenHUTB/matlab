classdef(Abstract,AllowedSubclasses={?images.roi.AssistedFreehand,...
    ?images.roi.Freehand})...
    AbstractFreehand<images.roi.internal.AbstractPolygon





    properties(Access=protected)
        WaypointsInternal=[];
    end

    properties(Hidden,Access=protected)
        LabelLocationInternal char='firstvertex';
    end

    properties(Transient,NonCopyable=true,Access=protected)
        UserLeftStartPoint=false;
    end

    properties(Dependent,Hidden)








LabelLocation

    end

    methods

        function self=AbstractFreehand()
            self@images.roi.internal.AbstractPolygon();
        end

    end

    methods(Hidden)


        function onLineClickAddWaypoint(self)

            if isempty(self.WaypointsInternal)
                return;
            end



            clickPos=getCurrentAxesPoint(self);



            [insertIdx,xLine,yLine]=insertVertex(self,clickPos);
            insertPos=images.roi.internal.getPositionOnLine(xLine,yLine,clickPos);


            diffVec=hypot(self.PositionInternal(:,1)-clickPos(1),self.PositionInternal(:,2)-clickPos(2));
            [~,addIdx]=min(diffVec);



            distanceToInsertPos=sqrt(sum((insertPos-clickPos).^2));
            distanceToNearestPos=sqrt(sum((self.PositionInternal(addIdx,:)-clickPos).^2));

            if distanceToInsertPos<distanceToNearestPos




                notify(self,'AddingWaypoint');

                pos=self.PositionInternal;
                pos=[pos(1:insertIdx-1,:);insertPos;pos(insertIdx:end,:)];


                self.PositionInternal=setROIPosition(self,pos);


                TF=self.WaypointsInternal;
                TF=[TF(1:insertIdx-1,:);true;TF(insertIdx:end,:)];
                self.WaypointsInternal=TF;

                waypointIdx=sum(self.WaypointsInternal(1:insertIdx));
                drawPoint(self,waypointIdx);

            else



                if self.WaypointsInternal(addIdx)


                    return;
                else
                    notify(self,'AddingWaypoint');
                    addWaypoint(self,addIdx);
                end

            end

            self.MarkDirty('all');
            notify(self,'WaypointAdded');

        end

    end

    methods(Access=protected)


        function wireUpListeners(self,varargin)


            constrainedPos=resetConstraintsAndFigureMode(self,varargin{:});

            self.SnapToAngleInternal=false;

            self.WaypointsInternal=logical([]);
            self.UserLeftStartPoint=false;


            self.CurrentPoint=constrainedPos;
            addVertex(self,constrainedPos(1),constrainedPos(2));

            self.ButtonUpEvt=event.listener(self.FigureHandle,...
            'WindowMouseRelease',@(src,evt)stopDraggingToAddPoints(self,evt));

            startDraggingToAddPoints(self);


            self.ButtonDownEvt=event.listener(self.FigureHandle,...
            'WindowMousePress',@(src,evt)onAxesClick(self,evt));


            self.ButtonMotionEvt=event.listener(self.FigureHandle,...
            'WindowMouseMotion',@(~,~)animateConnectionLine(self));


            self.KeyPressEvt=event.listener(self.FigureHandle,...
            'WindowKeyPress',@(src,evt)keyPressDuringDraw(self,evt));


            self.KeyReleaseEvt=event.listener(self.FigureHandle,...
            'WindowKeyRelease',@(src,evt)keyPressDuringDraw(self,evt));

        end


        function startDraggingToAddPoints(~)

        end


        function cMenu=getVertexContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','IPTFreehandWaypointContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:deleteWaypoint')),...
            'Callback',@(~,~)removeWaypoint(self),...
            'Tag','IPTFreehandWaypointContextMenuRemove');

        end


        function cMenu=getContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','IPTFreehandContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:addWaypoint')),...
            'Callback',@(~,~)onLineClickAddWaypoint(self),...
            'Tag','IPTROIContextMenuAddPoint');
            uimenu(cMenu,'Label',getString(message('images:imroi:deleteFreehand')),...
            'Callback',@(~,~)deleteROI(self),...
            'Tag','IPTROIContextMenuDelete');

        end


        function continueDraw(self)


            self.ButtonUpEvt=event.listener(self.FigureHandle,...
            'WindowMouseRelease',@(src,evt)stopDraggingToAddPoints(self,evt));
            setConstraintLimits(self,[],[],[]);
            constrainedPos=getConstrainedPosition(self,getCurrentAxesPointSnappedToAngle(self));
            addVertex(self,constrainedPos(1),constrainedPos(2));
            startDraggingToAddPoints(self);

        end


        function dragToAddPoints(self,evt)

            if~self.UserLeftStartPoint&&~self.isUserOnStartPoint(evt)
                self.UserLeftStartPoint=true;
            end
            constrainedPos=getConstrainedPosition(self,getCurrentAxesPoint(self));
            addVertex(self,constrainedPos(1),constrainedPos(2));

        end


        function addBackPoint(self)


            if isempty(self.BackPoint)||self.BackPoint(end)~=size(self.PositionInternal,1)
                self.BackPoint(end+1)=size(self.PositionInternal,1);
            end
        end


        function stopDraggingToAddPoints(self,evt)

            delete(self.ButtonUpEvt);
            delete(self.DragMotionEvt);
            smoothPosition(self);

            if~self.MulticlickInternal||(self.UserLeftStartPoint&&self.isUserOnStartPoint(evt))
                stopDraw(self);
            else
                addBackPoint(self);
            end

        end


        function stopDraw(self)
            endInteractivePlacement(self);
            addDragPoints(self);
            notifyDrawCompletion(self);
        end


        function addDragPoints(self)

            if isempty(self.PositionInternal)
                return;
            end

            self.ROIIsUnderConstruction=true;

            clearPoints(self);

            if isempty(self.WaypointsInternal)
                self.WaypointsInternal=images.roi.internal.getAutoWaypoints(self.PositionInternal,isFreehandClosed(self));
            end

            if any(self.WaypointsInternal)
                for idx=1:numel(self.WaypointsInternal(self.WaypointsInternal))
                    drawPoint(self,idx);
                end
            end

            self.ROIIsUnderConstruction=false;

        end


        function TF=isFreehandClosed(~)



            TF=true;
        end


        function addVertex(self,x,y)



            newPos=[x,y];

            if isempty(self.PositionInternal)
                pos=newPos;
            else

                pos=self.PositionInternal;
                pos=[pos;newPos];
            end


            self.PositionInternal=setROIPosition(self,pos);

        end


        function addWaypoint(self,vertexNum)


            self.WaypointsInternal(vertexNum,:)=true;
            newIdx=sum(self.WaypointsInternal(1:vertexNum));

            drawPoint(self,newIdx);

        end


        function removeWaypoint(self)


            notify(self,'RemovingWaypoint');

            hPoint=self.Point(self.CurrentPointIdx);
            hPointListener=self.PointListener(self.CurrentPointIdx);


            self.Point(self.CurrentPointIdx)=[];
            delete(hPoint);


            self.PointListener(self.CurrentPointIdx)=[];
            delete(hPointListener);

            [idx]=find(self.WaypointsInternal,self.CurrentPointIdx);
            self.WaypointsInternal(idx(end))=false;

            self.MarkDirty('all');
            notify(self,'WaypointRemoved');

        end


        function doROIDoubleClick(self)
            onLineClickAddWaypoint(self);
        end



        function reshapeROI(self,startPoint)

            pos=getConstrainedPosition(self,getCurrentAxesPoint(self));


            if~isequal(pos,startPoint)

                idx=find(self.WaypointsInternal);
                waypoint=idx(self.CurrentPointIdx);
                adjustVal=zeros([size(self.PositionInternal,1),1]);
                numPoints=numel(adjustVal);

                if self.CurrentPointIdx==1

                    if numPoints>1
                        if nnz(self.WaypointsInternal)>1||~isFreehandClosed(self)

                            if isFreehandClosed(self)

                                waypointNeighbor1=idx(end);
                                waypointNeighbor2=idx(self.CurrentPointIdx+1);



                                tempAdjustVal=self.fitWaypointAdjustmentToCurve(numPoints-waypointNeighbor1+1+waypoint,false);
                                adjustVal(waypointNeighbor1:end)=tempAdjustVal(1:numPoints-waypointNeighbor1+1);
                                adjustVal(1:waypoint)=tempAdjustVal(numPoints-waypointNeighbor1+2:end);
                            else

                                waypointNeighbor1=1;
                                if nnz(self.WaypointsInternal)>1
                                    waypointNeighbor2=idx(self.CurrentPointIdx+1);
                                else
                                    waypointNeighbor2=numPoints;
                                end

                                adjustVal(waypointNeighbor1:waypoint)=self.fitWaypointAdjustmentToCurve(waypoint-waypointNeighbor1+1,false);
                            end

                            adjustVal(waypoint:waypointNeighbor2)=self.fitWaypointAdjustmentToCurve(waypointNeighbor2-waypoint+1,true);

                        else




                            adjustVal=adjustVal+1;
                        end
                    else


                        adjustVal=1;
                    end

                elseif self.CurrentPointIdx==nnz(self.WaypointsInternal)




                    if isFreehandClosed(self)

                        waypointNeighbor2=idx(1);



                        tempAdjustVal=self.fitWaypointAdjustmentToCurve(numPoints-waypoint+1+waypointNeighbor2,true);
                        adjustVal(waypoint:end)=tempAdjustVal(1:numPoints-waypoint+1);
                        adjustVal(1:waypointNeighbor2)=tempAdjustVal(numPoints-waypoint+2:end);
                    else

                        waypointNeighbor2=numPoints;
                        adjustVal(waypoint:waypointNeighbor2)=self.fitWaypointAdjustmentToCurve(waypointNeighbor2-waypoint+1,true);
                    end

                    waypointNeighbor1=idx(self.CurrentPointIdx-1);
                    adjustVal(waypointNeighbor1:waypoint)=self.fitWaypointAdjustmentToCurve(waypoint-waypointNeighbor1+1,false);

                else

                    waypointNeighbor1=idx(self.CurrentPointIdx-1);
                    waypointNeighbor2=idx(self.CurrentPointIdx+1);

                    adjustVal(waypoint:waypointNeighbor2)=self.fitWaypointAdjustmentToCurve(waypointNeighbor2-waypoint+1,true);
                    adjustVal(waypointNeighbor1:waypoint)=self.fitWaypointAdjustmentToCurve(waypoint-waypointNeighbor1+1,false);
                end



                adjustedBoolean=adjustVal>0;

                adjustVal=adjustVal.*(pos-self.PositionInternal(waypoint,:));

                cachedPos=self.PositionInternal;
                self.PositionInternal=setROIPosition(self,self.PositionInternal+adjustVal);

                [candidateX,candidateY]=getLineData(self);
                if isCandidatePositionInsideConstraint(self,[candidateX(adjustedBoolean),candidateY(adjustedBoolean)])

                    evtData=packageROIMovingEventData(self,cachedPos);
                    self.MarkDirty('all');
                    notify(self,'MovingROI',evtData);

                else
                    self.PositionInternal=cachedPos;
                end

            end

        end

    end

    methods(Hidden)


        function[x,y,z]=getPointData(self)

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            else
                x=self.PositionInternal(self.WaypointsInternal,1);
                y=self.PositionInternal(self.WaypointsInternal,2);
                z=zeros(size(x));
            end

        end


        function[x,y,z,xAlign,yAlign]=getLabelData(self)

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            elseif strcmp(self.LabelLocationInternal,'firstvertex')
                x=self.PositionInternal(1,1);
                y=self.PositionInternal(1,2);
                z=0;
            else
                x=mean([max(self.PositionInternal(:,1)),min(self.PositionInternal(:,1))]);
                y=mean([max(self.PositionInternal(:,2)),min(self.PositionInternal(:,2))]);
                z=0;
            end

            if strcmp(self.LabelLocationInternal,'firstvertex')
                xAlign='left';
                hAx=ancestor(self,'axes');
                if isempty(hAx)||strcmp(hAx.YDir,'normal')
                    yAlign='top';
                else
                    yAlign='bottom';
                end
            else
                xAlign='center';
                yAlign='middle';
            end

        end

    end

    methods(Sealed,Hidden,Access=protected)


        function updateROIWhenClosedSet(self)



            if isempty(self.WaypointsInternal)
                return;
            end

            TF=self.WaypointsInternal;

            if isFreehandClosed(self)
                pos=self.PositionInternal;
                pos=diff([pos;pos(1,:)]);
                posLength=hypot(pos(:,1),pos(:,2));
                cumLength=cumsum(posLength);




                TF(end)=posLength(end)>=0.05*cumLength(end);

            else


                TF(end)=true;
            end


            self.Waypoints=TF;

        end

    end

    methods(Static,Hidden,Access=protected)


        function y=fitWaypointAdjustmentToCurve(n,TF)


            x=linspace(0,1,n)';
            y1=sin((pi/2)*x);
            y2=exp(-5*(x.^2));
            if TF
                y1=flipud(y1);
            else
                y2=flipud(y2);
            end

            y=(y1+y2)/2;

        end

    end

    methods




        function set.LabelLocation(self,val)

            self.LabelLocationInternal=validatestring(val,{'firstvertex','center'});

            self.MarkDirty('all');

        end

        function val=get.LabelLocation(self)
            val=self.LabelLocationInternal;
        end

    end

end