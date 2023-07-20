classdef(Sealed,ConstructOnLoad)Point3D<images.roi.internal.AbstractPoint...
    &images.roi.internal.mixin.SetLabel...
    &images.roi.internal.mixin.SetMarkerSize...
    &images.roi.internal.DrawingCanvas3D



    properties(Dependent)







Position

    end


    methods(Access={?lidar.internal.lidarViewer.measurementTool.AbstractTool,...
        ?hMockPoint3D})




        function self=Point3D(varargin)
            self@images.roi.internal.AbstractPoint();
            parseInputs(self,varargin{:});
        end
    end

    methods



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




        function setSnapToPoints(self,varargin)



            setSnapPoints(self,varargin{:});
        end
    end

    methods(Access=protected)


        function wireUpListeners(self,varargin)


            constrainedPos=resetConstraintsAndFigureMode(self,varargin{:});

            startDraw(self,constrainedPos(1),constrainedPos(2),constrainedPos(3));


            self.ButtonMotionEvt=event.listener(self.FigureHandle,...
            'WindowMouseMotion',@(~,~)drawROI(self));


            self.ButtonUpEvt=event.listener(self.FigureHandle,...
            'WindowMouseRelease',@(~,~)stopDraw(self));

        end


        function startDraw(self,x,y,z)
            self.PositionInternal=[x,y,z];
            addDragPoints(self);
        end


        function drawROI(self)
            if~isempty(self.PositionInternal)

                previousPosition=self.PositionInternal;

                pos=getConstrainedPosition(self,getCurrentAxesSnapPoint(self));
                self.PositionInternal=setROIPosition(self,pos);

                evtData=packageROIMovingEventData(self,previousPosition);

                self.MarkDirty('all');
                notify(self,'MovingROI',evtData);
            end
        end


        function reshapeROI(self,startPoint)

            pos=getConstrainedPosition(self,getCurrentAxesSnapPoint(self));

            if~isequal(pos,startPoint)
                drawROI(self);
            end

        end


        function constrainedPos=resetConstraintsAndFigureMode(self,varargin)






            delete(self.ButtonStartEvt);


            [x,y,z]=getLineData(self);
            setConstraintLimits(self,x,y,z);



            if nargin>1
                constrainedPos=varargin{1};
            else
                constrainedPos=getConstrainedPosition(self,getCurrentAxesSnapPoint(self));
            end

        end


        function pos=getCurrentAxesSnapPoint(self)

            pos=getPointsInAndOutOfAxes(self);
            pos=findNearestSnapPoint(self,pos);

        end


        function cMenu=getContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','Point3DContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:deletePoint')),...
            'Callback',@(~,~)deleteROI(self),...
            'Tag','Point3DROIContextMenuDelete');

        end

























        function addDragPoints(self)
            if isempty(self.Point)||all(~isvalid(self.Point))

                self.ROIIsUnderConstruction=true;

                clearPoints(self);
                drawDragPoints(self,'circle',1,self.LayerInternal);

                set(self.Point,'Layer','front');
                self.ROIIsUnderConstruction=false;
            end
        end


        function doUpdatePoints(self,us,P)

            [x,y,z]=getPointData(self);
            vd=images.roi.internal.transformPoints(us,x,y,z);

            for idx=1:numel(P)
                P(idx).VertexData=vd(:,idx);
            end




            if~self.UserIsDrawing&&self.ReshapableInternal&&strcmp(self.Visible,'on')
                setPrimitiveClickability(self,self.Point,'all','on');
            else
                setPrimitiveClickability(self,self.Point,'none','off');
            end


            setPointColor(self);


            setPointVisibility(self);

        end


        function setPointVisibility(self)






            if self.MarkersVisibleOnHoverInternal
                set(self.Point,'Visible',self.Visible&&self.MouseHit);
            else
                set(self.Point,'Visible',self.Visible&&self.MarkersVisibleInternal);
            end
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

    methods





        function set.Position(self,pos)

            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[1,3],'finite','nonsparse'},...
            mfilename,'Position');

            if isempty(self.PositionInternal)

                self.PositionInternal=double(pos);
                setUpROI(self);
            else
                self.PositionInternal=double(pos);
                self.MarkDirty('all');
            end

        end

        function pos=get.Position(self)
            pos=self.PositionInternal;
        end

    end
    methods(Hidden)


        function[x,y,z]=getLineData(self)
            [x,y,z]=getPointData(self);
        end


        function[x,y,z,xAlign,yAlign]=getLabelData(self)

            [x,y,z]=getPointData(self);

            xAlign='left';
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
                x=self.PositionInternal(1);
                y=self.PositionInternal(2);
                z=self.PositionInternal(3);
            end
        end
    end
end
