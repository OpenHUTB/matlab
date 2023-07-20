classdef(Abstract,AllowedSubclasses={?images.roi.internal.AbstractFreehand,...
    ?images.roi.Polygon,...
    ?images.roi.Polyline,...
    ?vision.roi.Polyline3D})...
    AbstractPolygon<images.roi.internal.ROI





    properties(Transient,NonCopyable=true,Hidden,Access=protected)
        SnapToAngleInternal=false;
        SnapAngleIncrement=15;
    end

    methods


        function self=AbstractPolygon()
            self@images.roi.internal.ROI();
        end

    end

    methods(Access=protected)


        function completed=onAxesClick(self,evt)

            if isModeManagerActive(self)||wasClickOnAxesToolbar(self,evt)
                return;
            end

            click=images.roi.internal.getClickType(self.FigureHandle);

            if~strcmp(click,'left')&&isempty(self.PositionInternal)
                completed=false;
                return
            end

            completed=any(strcmp(click,{'right','double'}));

            if self.isUserOnStartPoint(evt)
                completed=true;
                clickedOnStartPoint(self);
            end



            if completed
                stopDraw(self);
            else
                continueDraw(self);
            end

        end


        function clickedOnStartPoint(~)

        end


        function drawPoint(self,vertexNum)

            [hPoint,hPointListener]=createPoint(self,'circle',1,self.LayerInternal);

            pointListenerHandles=self.PointListener;
            self.PointListener=[pointListenerHandles(1:vertexNum-1),hPointListener,pointListenerHandles(vertexNum:end)];

            pointHandles=self.Point;
            self.Point=[pointHandles(1:vertexNum-1),hPoint,pointHandles(vertexNum:end)];

            if(length(self.Point)==1)&&self.UserIsDrawing
                set(self.StartPoint,'Layer','front');
            end

        end


        function reshapeROI(self,startPoint)

            pos=getConstrainedPosition(self,getCurrentAxesPoint(self));


            if~isequal(pos,startPoint)

                previousPosition=self.PositionInternal;

                newPos=self.PositionInternal;
                newPos(self.CurrentPointIdx,:)=pos;


                self.PositionInternal=setROIPosition(self,newPos);

                evtData=packageROIMovingEventData(self,previousPosition);

                self.MarkDirty('all');
                notify(self,'MovingROI',evtData);
            end

        end


        function doROIDoubleClick(self)
            onLineClickAddVertex(self);
        end


        function prepareROISpecificDrawingSetup(self)


            prepareStartPoint(self);
        end


        function prepareStartPoint(self)
            if isempty(self.StartPoint)
                self.StartPoint=matlab.graphics.primitive.world.Marker(...
                'Layer','front','Size',self.MarkerSizeInternal,...
                'HitTest','on','Style','circle','HandleVisibility','off',...
                'FaceColorType','truecoloralpha',...
                'Visible','off','Internal',true);
                self.addNode(self.StartPoint);
            else
                set(self.StartPoint,'Layer','front','HitTest','on','Size',self.MarkerSizeInternal);
            end
        end


        function setStartPointVisibility(self)

            if self.UserIsDrawing
                set(self.StartPoint,'Visible',self.Visible);
            else
                set(self.StartPoint,'Visible','off');
            end
        end


        function TF=isUserOnStartPoint(self,evt)
            TF=~isempty(evt.HitPrimitive)&&evt.HitPrimitive==self.StartPoint;
        end


        function[newIndex,xLine,yLine]=insertVertex(self,mousePos)


















            [x,y]=getLineData(self);
            pos=[x,y];



            idx=(1:numel(x)-1)';
            candidatePos=pos(1:end-1,:);

            deltaMousePos=mousePos-candidatePos;
            mouseMag=sqrt(sum(deltaMousePos.^2,2));

            deltaLinePos=diff(pos,1,1);
            lineMag=sqrt(sum(deltaLinePos.^2,2));




            idx(mouseMag>lineMag|dot(deltaMousePos,deltaLinePos,2)<0)=[];


            if isempty(idx)
                idx=1;
            end




            insertPos=(dot(deltaLinePos,deltaMousePos,2)./dot(deltaLinePos,deltaLinePos,2)).*deltaLinePos+candidatePos;



            distanceToNearestLine=sqrt(sum((mousePos-insertPos).^2,2));
            distanceToNearestLine=distanceToNearestLine(idx);

            [~,newIndex]=min(distanceToNearestLine);
            newIndex=idx(newIndex)+1;

            xLine=pos(newIndex-1:newIndex,1);
            yLine=pos(newIndex-1:newIndex,2);

        end


        function showContextMenu(self,src)

            delete(self.ContextMenuListener);
            self.ContextMenuListener=[];

            if self.Edge==src||self.LabelHandle==src||self.Fill==src

                if isempty(self.UIContextMenuInternal)
                    self.UIContextMenuInternal=getContextMenu(self);
                end
                cMenu=self.UIContextMenuInternal;
                cMenu.Parent=self.FigureHandle;
                enableContextMenuDelete(self,cMenu);
                enableContextMenuAddPoint(self,cMenu,src);
            elseif any(self.Point==src)

                if isempty(self.UIPointContextMenuInternal)
                    self.UIPointContextMenuInternal=getVertexContextMenu(self);
                    self.UIPointContextMenuInternal.Parent=self.FigureHandle;
                end
                cMenu=self.UIPointContextMenuInternal;
            end


            drawnow;

            displayContextMenuInFigure(self,cMenu);

        end


        function enableContextMenuAddPoint(self,cMenu,src)


            hobj=findall(cMenu,'Type','uimenu','Tag','IPTROIContextMenuAddPoint');
            if~isempty(hobj)
                if self.LabelHandle==src||self.Fill==src
                    hobj.Enable='off';
                else
                    hobj.Enable='on';
                end
            end
        end


        function pos=getCurrentAxesPointSnappedToAngle(self)

            pos=getCurrentAxesPoint(self);

            if self.SnapToAngleInternal&&isROIDefined(self)



                [~,r,theta]=images.roi.internal.getAngle([self.PositionInternal(end,:);pos]);


                mag=2*r;



                candidateTheta=self.SnapAngleIncrement*round(theta/self.SnapAngleIncrement);
                candidatePos=[mag*cosd(candidateTheta),-mag*sind(candidateTheta)]+self.PositionInternal(end,:);




                if isCandidatePositionInsideConstraint(self,candidatePos)
                    pos=candidatePos;
                end

            end

        end


        function animateConnectionLine(self)


            if isROIDefined(self)







                setEmptyCallbackHandle(self);

                self.CurrentPoint=getCurrentAxesPointSnappedToAngle(self);
                self.MarkDirty('all');

            end

        end


        function keyPressDuringDraw(self,evt)

            switch evt.Key
            case 'shift'

                switch evt.EventName
                case 'WindowKeyPress'
                    self.SnapToAngleInternal=true;
                case 'WindowKeyRelease'
                    self.SnapToAngleInternal=false;
                end
            case 'return'

                if strcmp(evt.EventName,'WindowKeyRelease')
                    stopDraw(self);
                end
            case 'backspace'

                if strcmp(evt.EventName,'WindowKeyRelease')
                    undo(self);
                end
            end

        end


        function addDragPoints(self)
            for idx=1:size(self.PositionInternal,1)
                drawPoint(self,idx);
            end
        end


        function cMenu=getVertexContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','IPTPolygonVertexContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:deleteVertex')),...
            'Callback',@(~,~)deleteVertex(self),...
            'Tag','IPTPolygonVertexContextMenuDelete');

        end


        function deleteVertex(self)

            if~self.DeletableInternal
                return;
            end




            if(self.NumPoints-1)<self.MinimumNumberOfPoints
                deleteROI(self);
                return;
            end


            notify(self,'DeletingVertex');

            hPoint=self.Point(self.CurrentPointIdx);
            hPointListener=self.PointListener(self.CurrentPointIdx);


            self.PositionInternal(self.CurrentPointIdx,:)=[];


            self.Point(self.CurrentPointIdx)=[];
            delete(hPoint);


            self.PointListener(self.CurrentPointIdx)=[];
            delete(hPointListener);

            self.NumPoints=self.NumPoints-1;

            self.MarkDirty('all');
            notify(self,'VertexDeleted');

        end


        function onLineClickAddVertex(self)

            notify(self,'AddingVertex');

            clickPos=getCurrentAxesPoint(self);

            [newIdx,xLine,yLine]=insertVertex(self,clickPos);
            insertPos=images.roi.internal.getPositionOnLine(xLine,yLine,clickPos);
            addVertex(self,insertPos(1),insertPos(2),newIdx);

            self.MarkDirty('all');
            notify(self,'VertexAdded');

        end


        function addVertex(self,x,y,vertexNum)


            pos=self.PositionInternal;
            newPos=[x,y];

            if nargin<4

                vertexNum=self.NumPoints+1;
                pos(vertexNum,:)=newPos;
            else

                pos=[pos(1:vertexNum-1,:);newPos;pos(vertexNum:end,:)];
            end


            self.PositionInternal=setROIPosition(self,pos);

            self.NumPoints=self.NumPoints+1;
            drawPoint(self,vertexNum);

        end


        function continueDraw(self)

            setConstraintLimits(self,[],[],[]);
            constrainedPos=getConstrainedPosition(self,getCurrentAxesPointSnappedToAngle(self));
            addVertex(self,constrainedPos(1),constrainedPos(2));

        end


        function undo(self)

            if(self.NumPoints)<=1
                return;
            end


            self.PositionInternal(end,:)=[];
            hPoint=self.Point(end);
            delete(hPoint);
            self.Point(end)=[];
            self.NumPoints=self.NumPoints-1;

            animateConnectionLine(self);

        end

    end

    methods(Hidden)


        function setPointerEnterFcn(self,src)
            if src==self.StartPoint
                images.roi.internal.setROIPointer(self.FigureHandle,'circle');
            else
                dragPointerEnterFcn(self,'circle');
            end
        end

    end

end