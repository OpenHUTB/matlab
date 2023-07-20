classdef(Sealed,ConstructOnLoad)Polyline3D<images.roi.internal.AbstractPolygon...
    &images.roi.internal.mixin.SetLabel...
    &images.roi.internal.mixin.SetMarkerSize...
    &images.roi.internal.DrawingCanvas3D






    events





AddingVertex





VertexAdded





DeletingVertex





VertexDeleted

    end

    properties(Dependent)







Position

    end

    properties(Dependent,Hidden)








MinimumNumberOfPoints

    end

    properties(Hidden,Access=protected)
        MinimumNumberOfPointsInternal=2;
    end

    methods




        function self=Polyline3D(varargin)
            self@images.roi.internal.AbstractPolygon();
            parseInputs(self,varargin{:});
        end




        function draw(self,varargin)


















            setSnapPoints(self,varargin{:});


            prepareToDraw(self);
            setEmptyCallbackHandle(self);

            self.ButtonStartEvt=event.listener(self.FigureHandle,...
            'WindowMousePress',@(src,evt)waitForButtonPressToBegin(self,evt));


            notify(self,'DrawingStarted');
            wireUpEscapeKeyListener(self);
            cleanupObject=onCleanup(@()self.cleanUpForCtrlC());
            uiwait(self.FigureHandle);
        end




        function beginDrawingFromPoint(self,pos)






            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[1,3],'finite','nonsparse'},...
            mfilename,'Location');

            prepareToDraw(self);
            setEmptyCallbackHandle(self);
            wireUpListeners(self,pos);
            notify(self,'DrawingStarted');
            wireUpEscapeKeyListener(self);
            cleanupObject=onCleanup(@()self.cleanUpForCtrlC());
            uiwait(self.FigureHandle);
        end




        function stopDrawing(self)


            stopDraw(self);
        end




        function setSnapToPoints(self,varargin)



            setSnapPoints(self,varargin{:});
        end




        function correctedPosition=findNearestSnapPoints(self,position)
            correctedPosition=findNearestSnapPoint(self,position);
        end




        function pos=getCurrentAxesPointSnappedToAngles(self)
            pos=getCurrentAxesPointSnappedToAngle(self);
        end
    end

    methods(Static,Hidden)



        function[Pos,insertPos,minimumDistance]=...
            calculatePointsAndNormalDistance(candidatePos,viewPos)


            point1=candidatePos;
            vector1=diff(candidatePos);


            point2=viewPos(1,:);
            vector2=diff(viewPos);
            vector2=repmat(vector2,size(vector1,1),1);


            normal=cross(vector1,vector2,2);

            P1P2=point2-point1;
            P2P1=point1-point2;

            minimumDistance=abs(dot(P1P2(1:end-1,:),normal,2)./vecnorm(normal,2,2));


            t1=(dot(P1P2(1:end-1,:),cross(vector2,normal,2),2)...
            ./dot(vector1,cross(vector2,normal,2),2));
            insertPos=point1(1:end-1,:)+t1.*vector1;


            t2=(dot(P2P1(1:end-1,:),cross(vector1,normal,2),2)...
            ./dot(vector2,cross(vector1,normal,2),2));
            Pos=point2+t2.*vector2;
        end

    end


    methods(Access=protected)


        function wireUpListeners(self,varargin)


            constrainedPos=resetConstraintsAndFigureMode(self,varargin{:});

            self.SnapToAngleInternal=false;

            self.CurrentPoint=constrainedPos;
            addVertex(self,constrainedPos(1),constrainedPos(2),constrainedPos(3));


            self.ButtonDownEvt=event.listener(self.FigureHandle,...
            'WindowMousePress',@(src,evt)onAxesClick(self,evt));


            self.ButtonMotionEvt=event.listener(self.FigureHandle,...
            'WindowMouseMotion',@(~,~)animateConnectionLine(self));


            self.KeyPressEvt=event.listener(self.FigureHandle,...
            'WindowKeyPress',@(src,evt)keyPressDuringDraw(self,evt));

            self.KeyReleaseEvt=event.listener(self.FigureHandle,...
            'WindowKeyRelease',@(src,evt)keyPressDuringDraw(self,evt));

        end


        function cMenu=getContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','IPTPolylineContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:addVertex')),...
            'Callback',@(~,~)onLineClickAddVertex(self),...
            'Tag','IPTROIContextMenuAddPoint');
            uimenu(cMenu,'Label',getString(message('images:imroi:deletePolyline')),...
            'Callback',@(~,~)deleteROI(self),...
            'Tag','IPTROIContextMenuDelete');

        end


        function g=getPropertyGroups(self)
            g=matlab.mixin.util.PropertyGroup(addParentPropertyGroup(self,...
            {'Position','Label'}));
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

            for i=1:numel(self.Point)
                set(self.Point(i),'Layer','front');
            end

        end


        function reshapeROI(self,startPoint)

            pos=getConstrainedPosition(self,getCurrentAxesPointSnappedToAngle(self));


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


        function constrainedPos=resetConstraintsAndFigureMode(self,varargin)






            delete(self.ButtonStartEvt);


            [x,y,z]=getLineData(self);
            setConstraintLimits(self,x,y,z);



            if nargin>1
                constrainedPos=varargin{1};
            else
                constrainedPos=getConstrainedPosition(self,getCurrentAxesPointSnappedToAngle(self));
            end

        end


        function pos=getCurrentAxesPointSnappedToAngle(self)

            pos=getPointsInAndOutOfAxes(self);
            pos=findNearestSnapPoint(self,pos);

            if self.SnapToAngleInternal&&isROIDefined(self)



                [~,r,theta]=vision.roi.internal.getAngle3D([self.PositionInternal(end,:);pos]);



                mag=2*r;






                candidateAlpha=self.SnapAngleIncrement*round(theta(1)/self.SnapAngleIncrement);
                candidateBeta=self.SnapAngleIncrement*round(theta(2)/self.SnapAngleIncrement);
                candidateGamma=self.SnapAngleIncrement*round(theta(3)/self.SnapAngleIncrement);

                candidatePos=[mag*cosd(candidateAlpha),mag*cosd(candidateBeta),...
                mag*cosd(candidateGamma)]+self.PositionInternal(end,:);





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


        function[insertPos,newIdx]=insertVertex3D(self)




            viewPos=getPointsInAndOutOfAxes(self);


            candidateLine=diff(self.Position);


            normalDistance=zeros(size(candidateLine,1),1);
            mousePos=zeros(size(candidateLine));
            candidatePos=zeros(size(candidateLine));



            [mousePos(1:end,:),candidatePos(1:end,:),normalDistance(1:end)]...
            =self.calculatePointsAndNormalDistance(self.Position,viewPos);

            idx=(1:size(self.Position,1)-1)';

            deltaMousePos=mousePos-self.Position(1:end-1,:);
            mouseMag=sqrt(sum(deltaMousePos.^2,2));

            deltaLinePos=diff(self.Position,1,1);
            lineMag=sqrt(sum(deltaLinePos.^2,2));




            idx(mouseMag(1:end)>lineMag(1:end)|dot(deltaMousePos,deltaLinePos,2)<0)=[];


            if isempty(idx)
                idx=1;
            end



            distanceToNearestLine=normalDistance(idx);


            [~,newIdx]=min(distanceToNearestLine);
            insertPos=candidatePos(idx(newIdx),:);
            newIdx=idx(newIdx)+1;

        end


        function onLineClickAddVertex(self)

            [insertPos,newIdx]=insertVertex3D(self);


            if(isempty(insertPos)||isempty(newIdx))
                return;
            end

            notify(self,'AddingVertex');

            addVertex(self,insertPos(1),insertPos(2),insertPos(3),newIdx);

            self.MarkDirty('all');
            notify(self,'VertexAdded');

        end


        function addVertex(self,x,y,z,vertexNum)


            pos=self.PositionInternal;
            newPos=[x,y,z];

            if nargin<5

                vertexNum=self.NumPoints+1;
                pos(vertexNum,:)=newPos;
            else

                pos=[pos(1:vertexNum-1,:);newPos;pos(vertexNum:end,:)];
            end


            self.PositionInternal=setROIPosition(self,pos);

            self.NumPoints=self.NumPoints+1;
            drawPoint(self,vertexNum);
            notify(self,'VertexAdded');
        end


        function continueDraw(self)

            setConstraintLimits(self,[],[],[]);
            constrainedPos=getConstrainedPosition(self,getCurrentAxesPointSnappedToAngle(self));
            addVertex(self,constrainedPos(1),constrainedPos(2),constrainedPos(3));

        end


        function dragROI(self,startPoint)

            currentPoint=getCurrentAxesPoint(self);



            if~isequal(getConstrainedPosition(self,currentPoint),startPoint)

                previousPosition=self.PositionInternal;

                constrainedPos=getConstrainedDragPosition(self,currentPoint);
                newPositions=self.CachedPosition+constrainedPos-startPoint;

                pos=setROIPosition(self,newPositions);
                self.PositionInternal=pos(:,1:3);

                evtData=packageROIMovingEventData(self,previousPosition);

                self.MarkDirty('all');
                notify(self,'MovingROI',evtData);

            end
        end

    end

    methods(Hidden)


        function[x,y,z]=getLineData(self)

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            else
                x=self.PositionInternal(:,1);
                y=self.PositionInternal(:,2);
                z=self.PositionInternal(:,3);

                if self.UserIsDrawing
                    x(end+1)=self.CurrentPoint(1);
                    y(end+1)=self.CurrentPoint(2);
                    z(end+1)=self.CurrentPoint(3);
                end
            end

        end


        function[x,y,z,xAlign,yAlign]=getLabelData(self)

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            else
                x=self.PositionInternal(1,1);
                y=self.PositionInternal(1,2);
                z=self.PositionInternal(1,3);
            end

            xAlign='right';
            hAx=ancestor(self,'axes');
            if isempty(hAx)||strcmp(hAx.YDir,'normal')
                yAlign='top';
            else
                yAlign='bottom';
            end

        end


        function[x,y,z]=getPointData(self)

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            else
                x=self.PositionInternal(:,1);
                y=self.PositionInternal(:,2);
                z=self.PositionInternal(:,3);
            end

        end

    end

    methods



        function set.MinimumNumberOfPoints(self,val)

            validateattributes(val,{'numeric'},...
            {'nonempty','real','scalar','nonnegative','integer','finite','nonsparse'},...
            mfilename,'MinimumNumberOfPoints');

            self.MinimumNumberOfPointsInternal=double(val);

        end

        function val=get.MinimumNumberOfPoints(self)
            val=self.MinimumNumberOfPointsInternal;
        end




        function set.Position(self,pos)

            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[NaN,3],'finite','nonsparse'},...
            mfilename,'Position');

            pos=double(pos);

            if numel(self.PositionInternal)~=numel(pos)

                self.ROIIsUnderConstruction=true;

                clearPosition(self);
                clearPoints(self);

                self.PositionInternal=pos;
                self.NumPoints=size(pos,1);

                setUpROI(self);

                self.ROIIsUnderConstruction=false;

            else
                self.PositionInternal=pos;

            end

            self.MarkDirty('all');

        end

        function pos=get.Position(self)
            pos=self.PositionInternal;
        end

    end

end