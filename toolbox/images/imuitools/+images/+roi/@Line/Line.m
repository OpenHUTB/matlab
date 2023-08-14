classdef(Sealed,ConstructOnLoad)Line<images.roi.internal.ROI...
    &images.roi.internal.mixin.SetLabel...
    &images.roi.internal.mixin.CreateMask...
    &images.roi.internal.mixin.SetMarkerSize




    properties(Dependent)








Position

    end

    properties(Transient,NonCopyable=true,Hidden,Access=protected)
        SnapToAngleInternal=false;
StartCorner
        SnapAngleIncrement=15;
    end

    methods




        function self=Line(varargin)
            self@images.roi.internal.ROI();
            parseInputs(self,varargin{:});
        end




        function BW=createMask(self,varargin)
















            [m,n,xData,yData]=validateInputs(self,varargin{:});
            BW=createOpenMask(self,m,n,xData,yData);
        end

    end

    methods(Access=protected)


        function wireUpListeners(self,varargin)


            constrainedPos=resetConstraintsAndFigureMode(self,varargin{:});

            self.SnapToAngleInternal=false;

            startDraw(self,constrainedPos(1),constrainedPos(2));


            self.KeyPressEvt=event.listener(self.FigureHandle,...
            'WindowKeyPress',@(src,evt)keyPressDuringDraw(self,evt));


            self.KeyReleaseEvt=event.listener(self.FigureHandle,...
            'WindowKeyRelease',@(src,evt)keyPressDuringDraw(self,evt));


            self.ButtonMotionEvt=event.listener(self.FigureHandle,...
            'WindowMouseMotion',@(~,~)drawROI(self));


            self.ButtonUpEvt=event.listener(self.FigureHandle,...
            'WindowMouseRelease',@(~,~)stopDraw(self));

        end


        function startDraw(self,x,y)
            self.CurrentPointIdx=2;
            self.PositionInternal=[x,y;x,y];
            self.StartCorner=[x,y];
        end


        function drawROI(self)

            if~isempty(self.PositionInternal)

                previousPosition=self.PositionInternal;

                pos=getConstrainedPosition(self,getCurrentAxesPointSnappedToAngle(self));

                newPos=self.PositionInternal;
                newPos(2,:)=pos;

                self.PositionInternal=setROIPosition(self,newPos);

                evtData=packageROIMovingEventData(self,previousPosition);

                self.MarkDirty('all');
                notify(self,'MovingROI',evtData);

            end

        end


        function resizeLine(self)

            previousPosition=self.PositionInternal;

            pos=getConstrainedPosition(self,getCurrentAxesPointSnappedToAngle(self));


            switch self.CurrentPointIdx
            case 1
                newPos=[pos;self.StartCorner];
            case 2
                newPos=[self.StartCorner;pos];
            end

            self.PositionInternal=setROIPosition(self,newPos);

            evtData=packageROIMovingEventData(self,previousPosition);

            self.MarkDirty('all');
            notify(self,'MovingROI',evtData);

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
                drawDragPoints(self,'circle',1,self.LayerInternal);
                drawDragPoints(self,'circle',1,self.LayerInternal);

                self.ROIIsUnderConstruction=false;

            end

        end


        function prepareToReshape(self,~)

            self.SnapToAngleInternal=false;
            [xPos,yPos]=getPointData(self);

            switch self.CurrentPointIdx
            case 1
                self.StartCorner=[xPos(2),yPos(2)];
            case 2
                self.StartCorner=[xPos(1),yPos(1)];
            end

        end


        function reshapeROI(self,startPoint)

            pos=getConstrainedPosition(self,getCurrentAxesPoint(self));


            if~isequal(pos,startPoint)
                resizeLine(self);
            end

        end


        function keyPressDuringInteraction(self,evt)

            switch evt.Key
            case 'shift'

                switch evt.EventName
                case 'WindowKeyPress'
                    self.SnapToAngleInternal=true;
                case 'WindowKeyRelease'
                    self.SnapToAngleInternal=false;
                end
            end

        end


        function keyPressDuringDraw(self,evt)

            if any(strcmp(evt.Key,{'shift'}))

                switch evt.EventName
                case 'WindowKeyPress'
                    self.SnapToAngleInternal=true;
                case 'WindowKeyRelease'
                    self.SnapToAngleInternal=false;
                end
            end

        end


        function pos=getCurrentAxesPointSnappedToAngle(self)

            pos=getCurrentAxesPoint(self);

            if self.SnapToAngleInternal&&~isempty(self.PositionInternal)



                if self.CurrentPointIdx==1
                    idx=2;
                else
                    idx=1;
                end
                [~,r,theta]=images.roi.internal.getAngle([self.PositionInternal(idx,:);pos]);


                mag=2*r;



                candidateTheta=self.SnapAngleIncrement*round(theta/self.SnapAngleIncrement);
                candidatePos=[mag*cosd(candidateTheta),-mag*sind(candidateTheta)]+self.StartCorner;

                if isCandidatePositionInsideConstraint(self,candidatePos)
                    pos=candidatePos;
                end

            end

        end


        function cMenu=getContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','IPTLineContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:deleteLine')),...
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
                z=zeros(size(x));
            end

        end


        function[x,y,z,xAlign,yAlign]=getLabelData(self)

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            else
                x=mean(self.PositionInternal(:,1));
                y=mean(self.PositionInternal(:,2));
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
            [x,y,z]=getLineData(self);
        end

    end

    methods





        function set.Position(self,pos)

            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[2,2],'finite','nonsparse'},...
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

end