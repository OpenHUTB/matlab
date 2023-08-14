classdef(Sealed,ConstructOnLoad)Ellipse<images.roi.internal.ROI...
    &images.roi.internal.mixin.SetLabel...
    &images.roi.internal.mixin.SetAspectRatio...
    &images.roi.internal.mixin.InsideROI...
    &images.roi.internal.mixin.CreateMask...
    &images.roi.internal.mixin.SetFill...
    &images.roi.internal.mixin.SetRotation...
    &images.roi.internal.mixin.SetMarkerSize




    properties(Dependent)








Center












SemiAxes

    end

    properties(Hidden,Dependent)

Position
    end

    properties(Dependent,GetAccess=public,SetAccess=protected)






Vertices

    end

    properties(Transient,NonCopyable=true,Hidden,Access=protected)
        RestrictPosition=[NaN,NaN];
    end

    methods




        function self=Ellipse(varargin)
            self@images.roi.internal.ROI();

            self.AspectRatioInternal=(1+sqrt(5))/2;
            parseInputs(self,varargin{:});
        end

    end

    methods(Access=protected)


        function wireUpListeners(self,varargin)


            constrainedPos=resetConstraintsAndFigureMode(self,varargin{:});

            self.ShiftKeyPressed=false;


            if~self.FixedAspectRatioInternal
                self.AspectRatioInternal=(1+sqrt(5))/2;
            end

            startDraw(self,constrainedPos(1),constrainedPos(2));


            self.KeyPressEvt=event.listener(self.FigureHandle,...
            'WindowKeyPress',@(src,evt)keyPressDuringDraw(self,evt));


            self.KeyReleaseEvt=event.listener(self.FigureHandle,...
            'WindowKeyRelease',@(src,evt)keyPressDuringDraw(self,evt));


            self.ButtonMotionEvt=event.listener(self.FigureHandle,...
            'WindowMouseMotion',@(~,~)drawROI(self));


            self.ButtonUpEvt=event.listener(self.FigureHandle,...
            'WindowMouseRelease',@(~,~)stopDraw(self));

            self.ScrollWheelEvt=event.listener(self.FigureHandle,...
            'WindowScrollWheel',@(src,evt)scrollWheelDuringPlacement(self,evt));

        end


        function startDraw(self,x,y)
            self.PositionInternal=[x,y];
            self.HeightInternal=0;
            self.WidthInternal=0;
            self.StartCorner=[x,y];
            self.RestrictPosition=[NaN,NaN];
        end


        function drawROI(self)

            if~isempty(self.PositionInternal)

                [pos,a,theta]=images.roi.internal.getAngle([self.StartCorner;...
                getConstrainedPosition(self,getCurrentAxesPoint(self))]);

                if self.UserIsDrawing
                    b=getFixedWidth(self,a);

                    if self.FixedAspectRatioInternal
                        if isnan(self.AspectRatioInternal)

                            a=0;
                            b=0;
                        elseif self.AspectRatioInternal==0



                            b=a/((1+sqrt(5))/2);
                            a=0;
                        end
                    end

                end

                cachedPosition=self.PositionInternal;
                cachedA=self.HeightInternal;
                cachedB=self.WidthInternal;
                cachedTheta=self.ThetaInternal;

                self.PositionInternal=pos;
                self.HeightInternal=a;
                self.WidthInternal=b;
                self.ThetaInternal=theta;

                [candidateX,candidateY]=getLineData(self);
                if isCandidatePositionInsideConstraint(self,[candidateX,candidateY])

                    evtData=packageROIMovingEventData(self,cachedPosition,self.PositionInternal,...
                    [cachedA,cachedB],[self.HeightInternal,self.WidthInternal],...
                    cachedTheta,self.ThetaInternal);

                    self.MarkDirty('all');
                    notify(self,'MovingROI',evtData);

                else
                    self.PositionInternal=cachedPosition;
                    self.ThetaInternal=cachedTheta;
                    self.HeightInternal=cachedA;
                    self.WidthInternal=cachedB;
                end

            end

        end


        function resizeEllipse(self)


            if self.FixedAspectRatioInternal&&isnan(self.AspectRatioInternal)
                return;
            end

            pos=[self.StartCorner;getConstrainedPosition(self,getCurrentAxesPoint(self))];

            diffVec=diff(pos);
            diffMag=hypot(diffVec(1),diffVec(2));

            if~isnan(self.RestrictPosition(1))
                b=diffMag;
                a=getHeight(self,b);

                if self.FixedAspectRatioInternal&&isinf(self.AspectRatioInternal)
                    return;
                end
            end

            if~isnan(self.RestrictPosition(2))
                a=diffMag;
                b=getWidth(self,a);

                if self.FixedAspectRatioInternal&&self.AspectRatioInternal==0
                    return;
                end
            end

            cachedA=self.HeightInternal;
            cachedB=self.WidthInternal;

            self.HeightInternal=a;
            self.WidthInternal=b;

            [candidateX,candidateY]=getLineData(self);
            if isCandidatePositionInsideConstraint(self,[candidateX,candidateY])

                evtData=packageROIMovingEventData(self,self.PositionInternal,self.PositionInternal,...
                [cachedA,cachedB],[self.HeightInternal,self.WidthInternal],...
                self.ThetaInternal,self.ThetaInternal);

                self.MarkDirty('all');
                notify(self,'MovingROI',evtData);

            else
                self.HeightInternal=cachedA;
                self.WidthInternal=cachedB;
            end

        end


        function rotateEllipse(self)

            cachedTheta=self.ThetaInternal;

            self.ThetaInternal=findAngle(self,[self.StartCorner;getConstrainedPosition(self,getCurrentAxesPoint(self))]);

            [candidateX,candidateY]=getLineData(self);
            if isCandidatePositionInsideConstraint(self,[candidateX,candidateY])

                evtData=packageROIMovingEventData(self,self.PositionInternal,self.PositionInternal,...
                [self.HeightInternal,self.WidthInternal],[self.HeightInternal,self.WidthInternal],...
                cachedTheta,self.ThetaInternal);

                self.MarkDirty('all');
                notify(self,'MovingROI',evtData);

            else
                self.ThetaInternal=cachedTheta;
            end

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

                for idx=1:2:8


                    drawDragPoints(self,'circle',3,self.LayerInternal);
                    drawDragPoints(self,'circle',1,self.LayerInternal);
                end

                self.ROIIsUnderConstruction=false;

            end

        end


        function prepareToReshape(self,~)













            self.StartCorner=[self.PositionInternal(1),self.PositionInternal(2)];
            self.SnapToAngleInternal=false;
            self.ShiftKeyPressed=false;

            switch self.CurrentPointIdx

            case{1,3,5,7}
                self.RestrictPosition=[NaN,NaN];
                self.StartAngle=[];

            case{2,6}
                self.RestrictPosition=[self.HeightInternal,NaN];

            case{4,8}
                self.RestrictPosition=[NaN,self.WidthInternal];
            end

        end


        function reshapeROI(self,startPoint)

            pos=getConstrainedPosition(self,getCurrentAxesPoint(self));


            if~isequal(pos,startPoint)
                switch self.CurrentPointIdx
                case{1,3,5,7}
                    rotateEllipse(self);
                otherwise
                    resizeEllipse(self);
                end

            end
        end


        function keyPressDuringInteraction(self,evt)


            toggleAspectRatio=any(strcmp(evt.Key,{'shift'}));

            if toggleAspectRatio
                switch evt.EventName
                case 'WindowKeyPress'
                    if any(eq(self.CurrentPointIdx,[1,3,5,7]))
                        self.SnapToAngleInternal=true;
                        rotateEllipse(self);
                    else
                        if~self.ShiftKeyPressed
                            updateAspectRatio(self);
                            self.ShiftKeyPressed=true;
                            resizeEllipse(self);
                        end
                    end
                case 'WindowKeyRelease'
                    if any(eq(self.CurrentPointIdx,[1,3,5,7]))
                        self.SnapToAngleInternal=false;
                        rotateEllipse(self);
                    else
                        self.ShiftKeyPressed=false;
                        resizeEllipse(self);
                    end
                end

            end

        end


        function keyPressDuringDraw(self,evt)


            toggleAspectRatio=any(strcmp(evt.Key,{'shift'}));

            if toggleAspectRatio
                switch evt.EventName
                case 'WindowKeyPress'
                    self.ShiftKeyPressed=true;
                case 'WindowKeyRelease'
                    self.ShiftKeyPressed=false;
                end
                drawROI(self);
            end

        end


        function cMenu=getContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','IPTEllipseContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:fixAspectRatio')),...
            'Callback',@(~,~)toggleFixAspectRatio(self),...
            'Tag','IPTROIContextMenuAspectRatio');
            uimenu(cMenu,'Label',getString(message('images:imroi:deleteEllipse')),...
            'Callback',@(~,~)deleteROI(self),...
            'Tag','IPTROIContextMenuDelete');

        end


        function prepareROISpecificContextMenu(self,cMenu)


            setAspectRatioContextMenuCheck(self,cMenu);


            enableContextMenuDelete(self,cMenu);

        end


        function setPointColor(self)

            if~isempty(self.Point)
                if self.MouseHit
                    set(self.Point([2,4,6,8]),'EdgeColorData',getColor(self),...
                    'FaceColorData',getFaceColor(self));
                else
                    set(self.Point([2,4,6,8]),'EdgeColorData',getEdgeColor(self),...
                    'FaceColorData',getColor(self));
                end
            end
        end


        function setPointSize(self)

            if isROIConstructed(self)
                set(self.Point([1,3,5,7]),'Size',2*self.MarkerSizeInternal);
                set(self.Point([2,4,6,8]),'Size',self.MarkerSizeInternal);
            end
        end


        function updateROISpecificProperties(self)





            if isempty(self.HeightInternal)||isempty(self.WidthInternal)
                return;
            end

            if~self.FixedAspectRatioInternal&&...
                self.HeightInternal~=0&&self.WidthInternal~=0
                updateAspectRatio(self);
            end
        end


        function scrollWheelDuringPlacement(self,evt)
            scrollToAdjustAspectRatio(self,evt);
            drawROI(self);
        end


        function evtData=packageROIMovingEventData(self,varargin)



            if nargin>2
                evtData=images.roi.EllipseMovingEventData(varargin{1},varargin{2},...
                varargin{3},varargin{4},...
                varargin{5},varargin{6});
            else




                currentSemiAxes=[self.HeightInternal,self.WidthInternal];
                evtData=images.roi.EllipseMovingEventData(varargin{1},self.PositionInternal,...
                currentSemiAxes,currentSemiAxes,...
                self.ThetaInternal,self.ThetaInternal);

            end
        end


        function evtData=packageROIMovedEventData(self)
            evtData=images.roi.EllipseMovingEventData(self.CachedPosition,self.PositionInternal,...
            [self.CachedHeight,self.CachedWidth],[self.HeightInternal,self.WidthInternal],...
            self.CachedTheta,self.ThetaInternal);
        end


        function cacheDataForROIMovedEvent(self)



            self.CachedPosition=self.PositionInternal;
            self.CachedTheta=self.ThetaInternal;
            self.CachedHeight=self.HeightInternal;
            self.CachedWidth=self.WidthInternal;
        end


        function clearPosition(self)
            self.PositionInternal=[];
            self.HeightInternal=[];
            self.WidthInternal=[];
            self.ThetaInternal=0;
        end


        function TF=isROIDefined(self)

            TF=~isempty(self.PositionInternal)&&~isempty(self.HeightInternal)&&...
            ~isempty(self.WidthInternal);
        end


        function g=getPropertyGroups(self)
            g=matlab.mixin.util.PropertyGroup(addParentPropertyGroup(self,...
            {'Center','SemiAxes','RotationAngle','AspectRatio','Label'}));
        end

    end

    methods(Hidden)


        function[x,y,z]=getLineData(self)

            if isempty(self.PositionInternal)||isempty(self.HeightInternal)||isempty(self.WidthInternal)
                x=[];
                y=[];
                z=[];
            else
                [x,y]=images.roi.internal.ellipseToPolygon(self.HeightInternal,self.WidthInternal,...
                self.PositionInternal(1),self.PositionInternal(2),min(self.DataUnitsPerScreenPixel));
                [x,y]=rotateLineData(self,x,y,self.PositionInternal(1),self.PositionInternal(2),true);
                z=zeros(size(x));
            end

        end


        function[x,y,z,xAlign,yAlign]=getLabelData(self)

            if isempty(self.PositionInternal)||isempty(self.HeightInternal)||isempty(self.WidthInternal)
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













            if isempty(self.PositionInternal)||isempty(self.HeightInternal)||isempty(self.WidthInternal)
                xPos=[];
                yPos=[];
                zPos=[];
            else


                x=self.PositionInternal(1);
                xMinusA=self.PositionInternal(1)-self.HeightInternal;
                xPlusA=self.PositionInternal(1)+self.HeightInternal;

                y=self.PositionInternal(2);
                yMinusA=self.PositionInternal(2)-self.WidthInternal;
                yPlusA=self.PositionInternal(2)+self.WidthInternal;

                xPos=[x,x,xPlusA,xPlusA,x,x,xMinusA,xMinusA];
                yPos=[yMinusA,yMinusA,y,y,yPlusA,yPlusA,y,y];

                [xPos,yPos]=rotateLineData(self,xPos,yPos,x,y,true);
                zPos=zeros(size(xPos));
            end

        end


        function setPointerEnterFcn(self,src)

            idx=find(src==self.Point);

            switch idx
            case{1,3,5,7}
                symbol='rotate';
            case 2
                symbol=getRotatedSymbol(self,270);
            case 4
                symbol=getRotatedSymbol(self,0);
            case 6
                symbol=getRotatedSymbol(self,90);
            case 8
                symbol=getRotatedSymbol(self,180);

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


        function set.Position(self,pos)

            self.Center=pos;
        end

        function pos=get.Position(self)
            pos=self.PositionInternal;
        end




        function set.SemiAxes(self,val)


            matlab.images.internal.errorIfgpuArray(val);

            validateattributes(val,{'numeric'},...
            {'nonempty','real','size',[1,2],'nonnegative','finite','nonsparse'},...
            mfilename,'SemiAxes');

            val=double(val);

            if self.FixedAspectRatioInternal&&all(val==0)
                error(message('images:imroi:fixedNaNAspectRatio'));
            end

            if isempty(self.HeightInternal)&&isempty(self.WidthInternal)

                self.HeightInternal=val(1);
                self.WidthInternal=val(2);
                setUpROI(self);
            else
                self.HeightInternal=val(1);
                self.WidthInternal=val(2);
                updateAspectRatio(self);
                self.MarkDirty('all');
            end

        end

        function val=get.SemiAxes(self)
            val=[self.HeightInternal,self.WidthInternal];
        end




        function pos=get.Vertices(self)
            [x,y]=getLineData(self);
            pos=[x,y];
        end

    end

end