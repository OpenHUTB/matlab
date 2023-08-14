classdef(Sealed,ConstructOnLoad)Circle<images.roi.internal.ROI...
    &images.roi.internal.mixin.SetLabel...
    &images.roi.internal.mixin.InsideROI...
    &images.roi.internal.mixin.CreateMask...
    &images.roi.internal.mixin.SetFill...
    &images.roi.internal.mixin.SetMarkerSize




    properties(Dependent)








Center







Radius

    end

    properties(Hidden,Dependent)

Position
    end

    properties(Dependent,GetAccess=public,SetAccess=protected)






Vertices

    end

    properties(Hidden,Access=protected)
        RadiusInternal double=[];
    end

    properties(Transient,NonCopyable=true,Hidden,Access=protected)
StartCorner
CachedRadius
    end

    methods




        function self=Circle(varargin)
            self@images.roi.internal.ROI();
            parseInputs(self,varargin{:});
        end

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
            self.RadiusInternal=0;
            self.StartCorner=[x,y];
        end


        function drawROI(self)

            if~isempty(self.PositionInternal)

                [pos,r]=defineCircle(self);


                cachedPosition=self.PositionInternal;
                cachedRadius=self.RadiusInternal;
                self.PositionInternal=pos;
                self.RadiusInternal=r;

                [candidateX,candidateY]=getLineData(self);
                if isCandidatePositionInsideConstraint(self,[candidateX,candidateY])

                    evtData=packageROIMovingEventData(self,cachedPosition,self.PositionInternal,cachedRadius,self.RadiusInternal);
                    self.MarkDirty('all');
                    notify(self,'MovingROI',evtData);

                else
                    self.PositionInternal=cachedPosition;
                    self.RadiusInternal=cachedRadius;
                end

            end

        end


        function resizeCircle(self)




            [~,r]=defineCircle(self);


            cachedRadius=self.RadiusInternal;






            self.RadiusInternal=2*r;

            [candidateX,candidateY]=getLineData(self);
            if isCandidatePositionInsideConstraint(self,[candidateX,candidateY])

                evtData=packageROIMovingEventData(self,self.PositionInternal,self.PositionInternal,cachedRadius,self.RadiusInternal);
                self.MarkDirty('all');
                notify(self,'MovingROI',evtData);

            else
                self.RadiusInternal=cachedRadius;
            end

        end


        function[pos,r]=defineCircle(self)



            pos=[self.StartCorner;getConstrainedPosition(self,getCurrentAxesPoint(self))];
            diffVec=diff(pos);



            pos=[mean(pos(:,1)),mean(pos(:,2))];


            r=hypot(diffVec(1),diffVec(2))/2;

        end


        function stopDraw(self)
            endInteractivePlacement(self);
            addDragPoints(self);
            notifyDrawCompletion(self);
        end


        function addDragPoints(self)












            if isempty(self.Point)||all(~isvalid(self.Point))

                self.ROIIsUnderConstruction=true;

                clearPoints(self);

                for idx=1:4
                    drawDragPoints(self,'circle',1,self.LayerInternal);
                end

                self.ROIIsUnderConstruction=false;

            end

        end


        function prepareToReshape(self,~)
            self.StartCorner=[self.PositionInternal(1),self.PositionInternal(2)];
        end


        function reshapeROI(self,startPoint)

            pos=getConstrainedPosition(self,getCurrentAxesPoint(self));


            if~isequal(pos,startPoint)
                resizeCircle(self);
            end

        end


        function cMenu=getContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','IPTCircleContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:deleteCircle')),...
            'Callback',@(~,~)deleteROI(self),...
            'Tag','IPTROIContextMenuDelete');

        end


        function evtData=packageROIMovingEventData(self,varargin)


            if nargin>2
                evtData=images.roi.CircleMovingEventData(varargin{1},varargin{2},...
                varargin{3},varargin{4});
            else




                evtData=images.roi.CircleMovingEventData(varargin{1},self.PositionInternal,...
                self.RadiusInternal,self.RadiusInternal);
            end
        end


        function evtData=packageROIMovedEventData(self)
            evtData=images.roi.CircleMovingEventData(self.CachedPosition,self.PositionInternal,...
            self.CachedRadius,self.RadiusInternal);
        end


        function cacheDataForROIMovedEvent(self)



            self.CachedPosition=self.PositionInternal;
            self.CachedRadius=self.RadiusInternal;
        end


        function clearPosition(self)
            self.PositionInternal=[];
            self.RadiusInternal=[];
        end


        function TF=isROIDefined(self)

            TF=~isempty(self.PositionInternal)&&~isempty(self.RadiusInternal);
        end


        function g=getPropertyGroups(self)
            g=matlab.mixin.util.PropertyGroup(addParentPropertyGroup(self,...
            {'Center','Radius','Label'}));
        end

    end

    methods(Hidden)


        function[x,y,z]=getLineData(self)

            if isempty(self.PositionInternal)||isempty(self.RadiusInternal)
                x=[];
                y=[];
                z=[];
            else

                [x,y]=images.roi.internal.ellipseToPolygon(self.RadiusInternal,self.RadiusInternal,...
                self.PositionInternal(1),self.PositionInternal(2),min(self.DataUnitsPerScreenPixel));
                x=x';
                y=y';
                z=zeros(size(x));
            end

        end


        function[x,y,z,xAlign,yAlign]=getLabelData(self)

            if isempty(self.PositionInternal)||isempty(self.RadiusInternal)
                x=[];
                y=[];
                z=[];
            else
                x=self.PositionInternal(1);
                y=self.PositionInternal(2);
                z=0;
            end

            xAlign='center';
            yAlign='middle';

        end


        function[xPos,yPos,zPos]=getPointData(self)









            if isempty(self.PositionInternal)||isempty(self.RadiusInternal)
                xPos=[];
                yPos=[];
                zPos=[];
            else


                xMinusR=self.PositionInternal(1)-0.7071*self.RadiusInternal;
                xPlusR=self.PositionInternal(1)+0.7071*self.RadiusInternal;

                yMinusR=self.PositionInternal(2)-0.7071*self.RadiusInternal;
                yPlusR=self.PositionInternal(2)+0.7071*self.RadiusInternal;

                xPos=[xMinusR,xPlusR,xPlusR,xMinusR];
                yPos=[yMinusR,yMinusR,yPlusR,yPlusR];

                zPos=zeros(size(xPos));
            end

        end


        function setPointerEnterFcn(self,src)

            idx=find(src==self.Point);

            hAx=ancestor(self,{'axes','geoaxes'});

            switch idx
            case{1,3}
                if isa(hAx,'matlab.graphics.axis.GeographicAxes')||strcmp(hAx.XDir,hAx.YDir)
                    symbol='NE';
                else
                    symbol='NW';
                end
            case{2,4}
                if isa(hAx,'matlab.graphics.axis.GeographicAxes')||strcmp(hAx.XDir,hAx.YDir)
                    symbol='NW';
                else
                    symbol='NE';
                end
            end

            dragPointerEnterFcn(self,symbol);

        end

    end

    methods





        function set.Center(self,pos)
            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[1,2],'finite','nonsparse'},...
            mfilename,'Center');

            if isempty(self.PositionInternal)

                self.PositionInternal=double(pos);
                setUpROI(self);
            else
                self.PositionInternal=double(pos);
                self.MarkDirty('all');
            end

        end

        function pos=get.Center(self)
            pos=self.PositionInternal;
        end




        function set.Radius(self,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','real','scalar','nonnegative','finite','nonsparse'},...
            mfilename,'Radius');

            if isempty(self.RadiusInternal)

                self.RadiusInternal=double(val);
                setUpROI(self);
            else
                self.RadiusInternal=double(val);
                self.MarkDirty('all');
            end

        end

        function val=get.Radius(self)
            val=self.RadiusInternal;
        end


        function set.Position(self,pos)

            self.Center=pos;
        end

        function pos=get.Position(self)
            pos=self.PositionInternal;
        end




        function pos=get.Vertices(self)
            [x,y]=getLineData(self);
            pos=[x,y];
        end

    end

end