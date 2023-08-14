classdef(Abstract,AllowedSubclasses={?images.roi.Point,...
    ?lidar.roi.Point3D,...
    ?images.roi.Crosshair})...
    AbstractPoint<images.roi.internal.ROI






    methods


        function self=AbstractPoint()
            self@images.roi.internal.ROI();
        end

    end

    methods(Abstract,Access=protected)
        addDragPoints(self)
    end

    methods(Access=protected)


        function wireUpListeners(self,varargin)


            constrainedPos=resetConstraintsAndFigureMode(self,varargin{:});

            startDraw(self,constrainedPos(1),constrainedPos(2));


            self.ButtonMotionEvt=event.listener(self.FigureHandle,...
            'WindowMouseMotion',@(~,~)drawROI(self));


            self.ButtonUpEvt=event.listener(self.FigureHandle,...
            'WindowMouseRelease',@(~,~)stopDraw(self));

        end


        function startDraw(self,x,y)
            self.PositionInternal=[x,y];
            addDragPoints(self);
        end


        function drawROI(self)
            if~isempty(self.PositionInternal)

                previousPosition=self.PositionInternal;

                pos=getConstrainedPosition(self,getCurrentAxesPoint(self));
                self.PositionInternal=setROIPosition(self,pos);

                evtData=packageROIMovingEventData(self,previousPosition);

                self.MarkDirty('all');
                notify(self,'MovingROI',evtData);
            end
        end


        function reshapeROI(self,startPoint)

            pos=getConstrainedPosition(self,getCurrentAxesPoint(self));


            if~isequal(pos,startPoint)
                drawROI(self);
            end

        end


        function g=getPropertyGroups(self)
            g=matlab.mixin.util.PropertyGroup(addParentPropertyGroup(self,...
            {'Position','Label'}));
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
                z=0;
            end

        end
    end
end