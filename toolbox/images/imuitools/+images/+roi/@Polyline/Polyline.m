classdef(Sealed,ConstructOnLoad)Polyline<images.roi.internal.AbstractPolygon...
    &images.roi.internal.mixin.SetLabel...
    &images.roi.internal.mixin.CreateMask...
    &images.roi.internal.mixin.ReducePoints...
    &images.roi.internal.mixin.SetMarkerSize




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




        function self=Polyline(varargin)
            self@images.roi.internal.AbstractPolygon();
            parseInputs(self,varargin{:});
        end




        function BW=createMask(self,varargin)
















            [m,n,xData,yData]=validateInputs(self,varargin{:});
            BW=createOpenMask(self,m,n,xData,yData);
        end




        function reduce(self,varargin)

            reduceOpen(self,varargin{:})
        end
    end

    methods(Access=protected)


        function wireUpListeners(self,varargin)


            constrainedPos=resetConstraintsAndFigureMode(self,varargin{:});

            self.SnapToAngleInternal=false;

            self.CurrentPoint=constrainedPos;
            addVertex(self,constrainedPos(1),constrainedPos(2));


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


        function[xAlign,yAlign]=doUpdateLabelOrientation(self,us,vd,lab,xAlign,yAlign)


            [xAlign,yAlign]=findLabelOrientation(self,us,vd,lab,xAlign,yAlign);
        end


        function g=getPropertyGroups(self)
            g=matlab.mixin.util.PropertyGroup(addParentPropertyGroup(self,...
            {'Position','Label'}));
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
                end

                z=zeros(size(x));
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
                z=0;
            end

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
                x=self.PositionInternal(:,1);
                y=self.PositionInternal(:,2);
                z=zeros(size(x));
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
            {'nonempty','real','size',[NaN,2],'finite','nonsparse'},...
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