classdef(Sealed,ConstructOnLoad)Freehand<images.roi.internal.AbstractFreehand...
    &images.roi.internal.mixin.SetLabel...
    &images.roi.internal.mixin.SetClosed...
    &images.roi.internal.mixin.InsideROI...
    &images.roi.internal.mixin.CreateMask...
    &images.roi.internal.mixin.SetFill...
    &images.roi.internal.mixin.SetSmoothing...
    &images.roi.internal.mixin.ReducePoints...
    &images.roi.internal.mixin.SetMarkerSize




    events





AddingWaypoint





WaypointAdded





RemovingWaypoint





WaypointRemoved

    end

    properties(Dependent)









Multiclick







Position














Waypoints

    end

    properties(Access=protected)
        MulticlickInternal(1,1)logical=false;
    end

    properties(Transient,NonCopyable=true,Access=protected)
BackPoint
FilterStartIndex
    end

    methods




        function self=Freehand(varargin)
            self@images.roi.internal.AbstractFreehand();
            parseInputs(self,varargin{:});
        end




        function BW=createMask(self,varargin)


















            [m,n,xData,yData]=validateInputs(self,varargin{:});

            if self.ClosedInternal
                BW=createClosedMask(self,m,n,xData,yData);
            else
                BW=createOpenMask(self,m,n,xData,yData);
            end
        end




        function reduce(self,varargin)
            if self.ClosedInternal
                reduceClosed(self,varargin{:})
            else
                reduceOpen(self,varargin{:});
            end
        end
    end

    methods(Access=protected)


        function wireUpListeners(self,varargin)
            self.BackPoint=[];
            wireUpListeners@images.roi.internal.AbstractFreehand(self,varargin{:})
        end


        function startDraggingToAddPoints(self)


            addBackPoint(self);
            self.FilterStartIndex=size(self.PositionInternal,1);
            self.DragMotionEvt=event.listener(self.FigureHandle,...
            'WindowMouseMotion',@(src,evt)dragToAddPoints(self,evt));

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



            self.WaypointsInternal=logical.empty;
            endInteractivePlacement(self);
            addDragPoints(self);
            notifyDrawCompletion(self);
        end


        function addVertex(self,x,y)



            newPos=[x,y];

            if isempty(self.PositionInternal)
                pos=newPos;
                if self.MulticlickInternal



                    self.WaypointsInternal=true;
                end
            else
                pos=self.PositionInternal;
                pos=[pos;newPos];
            end


            self.PositionInternal=setROIPosition(self,pos);

        end


        function undo(self)

            if numel(self.BackPoint)<2
                return;
            end


            self.PositionInternal(self.BackPoint(end-1)+1:end,:)=[];
            self.BackPoint(end)=[];

            animateConnectionLine(self);

        end


        function smoothPosition(self)

            if isempty(self.FilterStartIndex)||self.SigmaInternal==0
                self.FilterStartIndex=[];
                return;
            end
            startIdx=self.FilterStartIndex;
            endIdx=size(self.PositionInternal,1);
            filterSize=2*ceil(2*self.SigmaInternal)+1;
            pos=images.roi.internal.filterPositionData(self.PositionInternal(startIdx:endIdx,:),self.SigmaInternal,filterSize);
            self.PositionInternal(startIdx:endIdx,:)=pos;

            self.MarkDirty('all');
        end


        function[xAlign,yAlign]=doUpdateLabelOrientation(self,us,vd,lab,xAlign,yAlign)


            [xAlign,yAlign]=findLabelOrientation(self,us,vd,lab,xAlign,yAlign);
        end


        function g=getPropertyGroups(self)

            props={'Position','Closed','Label'};

            if~isempty(self.Parent)

                props=[props,'Multiclick'];
            end

            g=matlab.mixin.util.PropertyGroup(addParentPropertyGroup(self,...
            props));

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

                if self.UserIsDrawing
                    x(end+1)=self.CurrentPoint(1);
                    y(end+1)=self.CurrentPoint(2);
                elseif self.ClosedInternal
                    x(end+1)=x(1);
                    y(end+1)=y(1);
                end

                z=zeros(size(x));
            end

        end

    end

    methods





        function set.Multiclick(self,TF)

            validateattributes(TF,{'logical','numeric'},...
            {'nonempty','real','scalar','finite','nonsparse'},...
            mfilename,'Multiclick');

            self.MulticlickInternal=logical(TF);

        end

        function TF=get.Multiclick(self)
            TF=self.MulticlickInternal;
        end




        function set.Position(self,pos)
            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[NaN,2],'finite','nonsparse'},...
            mfilename,'Position');

            if isempty(self.PositionInternal)
                self.PositionInternal=double(pos);
                setUpROI(self);
            elseif numel(self.WaypointsInternal)~=size(pos,1)

                self.PositionInternal=double(pos);
                self.WaypointsInternal=[];
                clearPoints(self);
                setUpROI(self);
            else
                self.PositionInternal=double(pos);
            end

            self.MarkDirty('all');

        end

        function pos=get.Position(self)
            pos=self.PositionInternal;
        end




        function set.Waypoints(self,TF)

            validateattributes(TF,{'logical'},...
            {'nonempty','real','size',[NaN,1],'finite','nonsparse'},...
            mfilename,'Waypoints');

            if~isempty(self.PositionInternal)&&numel(TF)~=size(self.PositionInternal,1)
                error(message('images:imroi:invalidWaypoints'));
            end

            self.WaypointsInternal=TF;

            if~isempty(self.PositionInternal)
                clearPoints(self);
                setUpROI(self);
            end

        end

        function TF=get.Waypoints(self)
            TF=self.WaypointsInternal;
        end

    end

end
