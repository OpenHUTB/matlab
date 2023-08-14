classdef(Sealed,ConstructOnLoad)Rectangle<images.roi.internal.ROI...
    &images.roi.internal.mixin.SetLabel...
    &images.roi.internal.mixin.SetAspectRatio...
    &images.roi.internal.mixin.InsideROI...
    &images.roi.internal.mixin.CreateMask...
    &images.roi.internal.mixin.SetFill...
    &images.roi.internal.mixin.SetRotation...
    &images.roi.internal.mixin.SetMarkerSize




    properties(Dependent)







Position








Rotatable

    end

    properties(Dependent,GetAccess=public,SetAccess=protected)






Vertices

    end

    properties(Dependent,Hidden)







CenteredPosition

WaitWhileDrawing

    end

    properties(Hidden,Access=protected)
        RotatableInternal=false;
    end

    properties(Transient,NonCopyable=true,Hidden,Access=protected)
        RestrictPosition=[NaN,NaN];
    end

    methods




        function self=Rectangle(varargin)
            self@images.roi.internal.ROI();
            parseInputs(self,varargin{:});
            self.addDependencyConsumed('xyzdatalimits');
        end

    end

    methods(Access=protected)


        function wireUpListeners(self,varargin)


            constrainedPos=resetConstraintsAndFigureMode(self,varargin{:});

            self.ShiftKeyPressed=false;

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
            self.PositionInternal=[x,y];
            self.HeightInternal=0;
            self.WidthInternal=0;
            self.ThetaInternal=0;
            self.StartCorner=[x,y];
            self.RestrictPosition=[NaN,NaN];
        end


        function drawROI(self)

            if~isempty(self.PositionInternal)

                isRectangleRotated=self.ThetaInternal~=0;

                if isRectangleRotated
                    pos=getConstrainedPosition(self,getCurrentAxesPoint(self));
                    [constrainedPos(1),constrainedPos(2)]=rotateLineData(self,pos(1),pos(2),...
                    (self.PositionInternal(1)+0.5*self.WidthInternal),...
                    (self.PositionInternal(2)+0.5*self.HeightInternal),false);
                else
                    constrainedPos=getConstrainedPosition(self,getCurrentAxesPoint(self));
                end

                newPos(1,:)=self.StartCorner;
                [newPos(2,1),newPos(2,2)]=setRectangleRestriction(self,constrainedPos(1),constrainedPos(2));
                pos=[min(newPos(:,1)),min(newPos(:,2)),max(newPos(:,1))-min(newPos(:,1)),max(newPos(:,2))-min(newPos(:,2))];

                if isRectangleRotated
                    [pos,shiftRequired]=shiftCenterOfRotation(self,pos);
                end

                pos=setROIPosition(self,pos);

                cachedPosition=self.PositionInternal;
                cachedWidth=self.WidthInternal;
                cachedHeight=self.HeightInternal;

                self.PositionInternal=pos(1:2);
                self.WidthInternal=pos(3);
                self.HeightInternal=pos(4);

                previousPosition=[cachedPosition,cachedWidth,cachedHeight];
                currentPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal];

                if isRectangleRotated
                    [candidateX,candidateY]=getLineData(self);
                    if isCandidatePositionInsideConstraint(self,[candidateX,candidateY])


                        self.StartCorner=self.StartCorner+shiftRequired;
                        self.RestrictPosition=self.RestrictPosition+shiftRequired;

                        evtData=packageROIMovingEventData(self,previousPosition,currentPosition,self.ThetaInternal,self.ThetaInternal);
                        self.MarkDirty('all');
                        notify(self,'MovingROI',evtData);

                    else
                        self.PositionInternal=cachedPosition;
                        self.WidthInternal=cachedWidth;
                        self.HeightInternal=cachedHeight;
                    end

                else
                    evtData=packageROIMovingEventData(self,previousPosition,currentPosition,self.ThetaInternal,self.ThetaInternal);
                    self.MarkDirty('all');
                    notify(self,'MovingROI',evtData);
                end

            end

        end


        function[pos,shiftRequired]=shiftCenterOfRotation(self,pos)










            newCenterX=pos(1)+0.5*pos(3);
            newCenterY=pos(2)+0.5*pos(4);


            [rotatedCenterX,rotatedCenterY]=rotateLineData(self,newCenterX,newCenterY,...
            (self.PositionInternal(1)+0.5*self.WidthInternal),...
            (self.PositionInternal(2)+0.5*self.HeightInternal),true);



            shiftRequired=[(rotatedCenterX-newCenterX),(rotatedCenterY-newCenterY)];
            pos(1)=pos(1)+shiftRequired(1);
            pos(2)=pos(2)+shiftRequired(2);

        end


        function stopDraw(self)
            endInteractivePlacement(self);
            addDragPoints(self);
            notifyDrawCompletion(self);
        end


        function pos=setROIPosition(self,pos)

            if numel(pos)==2
                pos=[pos,self.WidthInternal,self.HeightInternal];
            end
        end


        function addDragPoints(self)












            if isempty(self.Point)||all(~isvalid(self.Point))

                self.ROIIsUnderConstruction=true;

                clearPoints(self);

                for idx=1:4
                    drawDragPoints(self,'circle',3,self.LayerInternal);
                end

                for idx=1:8
                    drawDragPoints(self,'square',1,self.LayerInternal);
                end

                self.ROIIsUnderConstruction=false;

            end
        end


        function[x,y]=setRectangleRestriction(self,x,y)

            if self.ShiftKeyPressed||self.FixedAspectRatioInternal

                oldH=y-self.StartCorner(2);
                oldW=x-self.StartCorner(1);
                newAR=abs(oldH)/abs(oldW);



                if isnan(self.AspectRatioInternal)
                    x=self.StartCorner(1);
                    y=self.StartCorner(2);
                elseif newAR>self.AspectRatioInternal
                    newH=abs(oldW.*self.AspectRatioInternal);
                    y=(oldH.*(newH./abs(oldH)))+self.StartCorner(2);
                else
                    newW=abs(oldH./self.AspectRatioInternal);
                    x=(oldW.*(newW./abs(oldW)))+self.StartCorner(1);
                end

            else


                if~isnan(self.RestrictPosition(1))
                    x=self.RestrictPosition(1);
                end

                if~isnan(self.RestrictPosition(2))
                    y=self.RestrictPosition(2);
                end

            end

        end


        function prepareToReshape(self,~)











            self.StartAngle=[];

            [xPos,yPos]=getUnrotatedPointData(self);

            self.SnapToAngleInternal=false;
            self.ShiftKeyPressed=false;

            switch self.CurrentPointIdx
            case{1,2,3,4}
                self.StartCorner=[xPos(6),yPos(8)];
            case{5,6,12}
                self.StartCorner=[xPos(9),yPos(9)];
            case 7
                self.StartCorner=[xPos(11),yPos(11)];
            case{8,9,10}
                self.StartCorner=[xPos(5),yPos(5)];
            case 11
                self.StartCorner=[xPos(7),yPos(7)];
            end

            switch self.CurrentPointIdx

            case{1,2,3,4,5,7,9,11}
                self.RestrictPosition=[NaN,NaN];


            case 6
                self.RestrictPosition=[xPos(5),NaN];
            case 10
                self.RestrictPosition=[xPos(9),NaN];


            case 8
                self.RestrictPosition=[NaN,yPos(9)];
            case 12
                self.RestrictPosition=[NaN,yPos(5)];
            end

        end


        function reshapeROI(self,startPoint)

            pos=getConstrainedPosition(self,getCurrentAxesPoint(self));


            if~isequal(pos,startPoint)
                switch self.CurrentPointIdx
                case{1,2,3,4}
                    rotateROI(self);
                otherwise
                    drawROI(self);
                end

            end

        end


        function rotateROI(self)

            cachedTheta=self.ThetaInternal;

            self.ThetaInternal=findAngle(self,[self.StartCorner;getConstrainedPosition(self,getCurrentAxesPoint(self))]);

            [candidateX,candidateY]=getLineData(self);
            if~isCandidatePositionInsideConstraint(self,[candidateX,candidateY])
                self.ThetaInternal=cachedTheta;
            end

            currentPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal];

            evtData=packageROIMovingEventData(self,currentPosition,currentPosition,cachedTheta,self.ThetaInternal);
            self.MarkDirty('all');
            notify(self,'MovingROI',evtData);
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


        function keyPressDuringInteraction(self,evt)

            toggleAspectRatio=any(strcmp(evt.Key,{'shift'}));

            if toggleAspectRatio
                switch evt.EventName
                case 'WindowKeyPress'

                    switch self.CurrentPointIdx

                    case{1,2,3,4}
                        self.SnapToAngleInternal=true;
                        rotateROI(self);
                    case{6,8,10,12}


                        return;
                    otherwise
                        if~self.ShiftKeyPressed
                            updateAspectRatio(self);
                        end
                        self.ShiftKeyPressed=true;
                        drawROI(self);
                    end

                case 'WindowKeyRelease'

                    switch self.CurrentPointIdx

                    case{1,2,3,4}
                        self.SnapToAngleInternal=false;
                        rotateROI(self);
                    case{6,8,10,12}


                        return;
                    otherwise
                        self.ShiftKeyPressed=false;
                        drawROI(self);
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

        function[xPos,yPos]=getUnrotatedPointData(self)

            x=self.PositionInternal(1);
            xPlusW=self.PositionInternal(1)+self.WidthInternal;
            xPlusHalfW=self.PositionInternal(1)+(0.5*self.WidthInternal);

            y=self.PositionInternal(2);
            yPlusH=self.PositionInternal(2)+self.HeightInternal;
            yPlusHalfH=self.PositionInternal(2)+(0.5*self.HeightInternal);

            xPos=[x;xPlusW;xPlusW;x;x;xPlusHalfW;xPlusW;xPlusW;xPlusW;xPlusHalfW;x;x];
            yPos=[y;y;yPlusH;yPlusH;y;y;y;yPlusHalfH;yPlusH;yPlusH;yPlusH;yPlusHalfH];

        end


        function cMenu=getContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','IPTRectangleContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:fixAspectRatio')),...
            'Callback',@(~,~)toggleFixAspectRatio(self),...
            'Tag','IPTROIContextMenuAspectRatio');
            uimenu(cMenu,'Label',getString(message('images:imroi:deleteRectangle')),...
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
                    set(self.Point(5:12),'EdgeColorData',getColor(self),...
                    'FaceColorData',getFaceColor(self));
                else
                    set(self.Point(5:12),'EdgeColorData',getEdgeColor(self),...
                    'FaceColorData',getColor(self));
                end
            end
        end


        function setPointVisibility(self)

            if~isempty(self.Point)
                if(~self.ReshapableInternal&&~self.DraggableInternal)||self.UserIsDragging
                    set(self.Point,'Visible','off');
                    setPrimitiveClickability(self,self.Point(1:4),'none','off');
                else
                    if self.FixedAspectRatioInternal
                        if self.MarkersVisibleOnHoverInternal
                            set(self.Point([5,7,9,11]),'Visible',self.Visible&&self.MouseHit);
                        else
                            set(self.Point([5,7,9,11]),'Visible',self.Visible&&self.MarkersVisibleInternal);
                        end
                        setPrimitiveClickability(self,self.Point([5,7,9,11]),'visible','on');
                        set(self.Point([6,8,10,12]),'Visible','off');
                        setPrimitiveClickability(self,self.Point([6,8,10,12]),'none','off');
                    else
                        if self.MarkersVisibleOnHoverInternal
                            set(self.Point,'Visible',self.Visible&&self.MouseHit);
                        else
                            set(self.Point,'Visible',self.Visible&&self.MarkersVisibleInternal);
                        end
                    end
                    if self.RotatableInternal
                        setPrimitiveClickability(self,self.Point(1:4),'all','on');
                    else
                        setPrimitiveClickability(self,self.Point(1:4),'none','off');
                    end
                end
            end
        end


        function setPointSize(self)

            if isROIConstructed(self)
                set(self.Point(1:4),'Size',2*self.MarkerSizeInternal);
                set(self.Point(5:12),'Size',self.MarkerSizeInternal);
            end
        end


        function validateInteractionsAllowed(self,val)



            validStr=validatestring(val,{'all','none','translate'});

            switch validStr
            case 'all'
                self.DraggableInternal=true;
                self.ReshapableInternal=true;
            case 'none'
                self.DraggableInternal=false;
                self.ReshapableInternal=false;
            case 'translate'
                self.DraggableInternal=true;
                self.ReshapableInternal=false;
            otherwise
                error(message('images:imroi:invalidRectangleInteractionInput',val));
            end

        end


        function validateLabelVisible(self,val)




            validStr=validatestring(val,{'on','off','hover','inside'});

            switch validStr
            case 'on'
                self.LabelVisibleInternal=true;
                self.LabelVisibleOnHoverInternal=false;
                self.LabelVisibleInsideInternal=false;
            case 'off'
                self.LabelVisibleInternal=false;
                self.LabelVisibleOnHoverInternal=false;
                self.LabelVisibleInsideInternal=false;
            case 'hover'
                self.LabelVisibleInternal=false;
                self.LabelVisibleOnHoverInternal=true;
                self.LabelVisibleInsideInternal=false;
            case 'inside'
                self.LabelVisibleInternal=true;
                self.LabelVisibleOnHoverInternal=false;
                self.LabelVisibleInsideInternal=true;
            end

        end


        function evtData=packageROIMovingEventData(self,varargin)


            if nargin>2
                evtData=images.roi.RectangleMovingEventData(varargin{1},varargin{2},...
                varargin{3},varargin{4});
            else




                previousPosition=[varargin{1},self.WidthInternal,self.HeightInternal];
                currentPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal];
                evtData=images.roi.RectangleMovingEventData(previousPosition,currentPosition,...
                self.ThetaInternal,self.ThetaInternal);
            end
        end


        function evtData=packageROIMovedEventData(self)
            evtData=images.roi.RectangleMovingEventData([self.CachedPosition,self.CachedWidth,self.CachedHeight],...
            [self.PositionInternal,self.WidthInternal,self.HeightInternal],...
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

        function[xAlign,yAlign]=doUpdateLabelOrientation(self,us,~,lab,xAlign,yAlign)

            if~willLabelFitInsideROI(self,us,lab)


                if strcmp(yAlign,'bottom')
                    yAlign='top';
                else
                    yAlign='bottom';
                end
            end

        end


        function g=getPropertyGroups(self)
            g=matlab.mixin.util.PropertyGroup(addParentPropertyGroup(self,...
            {'Position','RotationAngle','AspectRatio','Label'}));
        end

    end

    methods(Hidden)


        function[x,y,z]=getLineData(self)

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            else
                x=[self.PositionInternal(1);self.PositionInternal(1);...
                self.PositionInternal(1)+self.WidthInternal;...
                self.PositionInternal(1)+self.WidthInternal;...
                self.PositionInternal(1)];
                y=[self.PositionInternal(2);...
                self.PositionInternal(2)+self.HeightInternal;...
                self.PositionInternal(2)+self.HeightInternal;...
                self.PositionInternal(2);self.PositionInternal(2)];
                if self.ThetaInternal~=0
                    if~isempty(ancestor(self,'geoaxes'))
                        x=[linspace(x(1),x(2),50)';linspace(x(2),x(3),50)';...
                        linspace(x(3),x(4),50)';linspace(x(4),x(5),50)'];
                        y=[linspace(y(1),y(2),50)';linspace(y(2),y(3),50)';...
                        linspace(y(3),y(4),50)';linspace(y(4),y(5),50)'];
                        x([51,101,151])=[];
                        y([51,101,151])=[];
                    end
                    [x,y]=rotateLineData(self,x',y',...
                    (self.PositionInternal(1)+0.5*self.WidthInternal),...
                    (self.PositionInternal(2)+0.5*self.HeightInternal),true);
                end
                z=zeros(size(x));
            end
        end


        function[x,y,z,xAlign,yAlign]=getLabelData(self)

            isRectangleRotatable=self.ThetaInternal~=0||self.RotatableInternal;

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            elseif isRectangleRotatable
                x=self.PositionInternal(1)+0.5*self.WidthInternal;
                y=self.PositionInternal(2)+0.5*self.HeightInternal;
                z=0;
            else
                x=self.PositionInternal(1);

                hAx=ancestor(self,'axes');
                if isempty(hAx)||strcmp(hAx.YDir,'normal')
                    y=self.PositionInternal(2)+self.HeightInternal;
                else
                    y=self.PositionInternal(2);
                end

                z=0;
            end

            if isRectangleRotatable
                xAlign='center';
                yAlign='middle';
            else
                xAlign='left';
                yAlign='top';
            end

        end


        function[xPos,yPos,zPos]=getPointData(self)









            if isempty(self.PositionInternal)
                xPos=[];
                yPos=[];
                zPos=[];
            else

                [xPos,yPos]=getUnrotatedPointData(self);

                if self.ThetaInternal~=0
                    [xPos,yPos]=rotateLineData(self,xPos',yPos',...
                    (self.PositionInternal(1)+0.5*self.WidthInternal),...
                    (self.PositionInternal(2)+0.5*self.HeightInternal),true);
                end
                zPos=zeros(size(xPos));

            end

        end


        function setPointerEnterFcn(self,src)












            idx=find(src==self.Point);

            switch idx
            case{1,2,3,4}
                symbol='rotate';
            case{6,10}
                symbol=getRotatedSymbol(self,90);
            case{8,12}
                symbol=getRotatedSymbol(self,0);
            case{5,9}
                symbol=getRotatedSymbol(self,135);
            case{7,11}
                symbol=getRotatedSymbol(self,45);
            end

            dragPointerEnterFcn(self,symbol);

        end

    end

    methods





        function set.Position(self,pos)
            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[1,4],'finite','nonsparse'},...
            mfilename,'Position');

            if pos(3)<0||pos(4)<0
                error(message('images:imroi:invalidRectangle'));
            end

            if self.FixedAspectRatioInternal&&all(pos(3:4)==0)
                error(message('images:imroi:fixedNaNAspectRatio'));
            end

            pos=double(pos);

            if isempty(self.PositionInternal)

                self.PositionInternal=pos(1:2);
                self.WidthInternal=pos(3);
                self.HeightInternal=pos(4);
                setUpROI(self);
            else
                self.PositionInternal=pos(1:2);
                self.WidthInternal=pos(3);
                self.HeightInternal=pos(4);
                updateAspectRatio(self);
                self.MarkDirty('all');
            end

        end

        function pos=get.Position(self)
            if isempty(self.PositionInternal)||isempty(self.WidthInternal)||isempty(self.HeightInternal)
                pos=[];
            else
                pos=[self.PositionInternal,self.WidthInternal,self.HeightInternal];
            end
        end



        function set.Rotatable(self,TF)
            validateattributes(TF,{'logical','numeric'},...
            {'nonempty','real','scalar','finite','nonsparse'},...
            mfilename,'Rotatable');

            self.RotatableInternal=logical(TF);

            self.MarkDirty('all');
        end

        function TF=get.Rotatable(self)
            TF=self.RotatableInternal;
        end




        function pos=get.Vertices(self)

            [x,y]=getPointData(self);
            if~isempty(x)
                pos=[x(1),y(1);x(4),y(4);x(3),y(3);x(2),y(2)];
            else
                pos=[];
            end
        end




        function set.CenteredPosition(self,pos)
            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[1,4],'finite','nonsparse'},...
            mfilename,'CenteredPosition');

            if pos(3)<0||pos(4)<0
                error(message('images:imroi:invalidRectangle'));
            end

            if self.FixedAspectRatioInternal&&all(pos(3:4)==0)
                error(message('images:imroi:fixedNaNAspectRatio'));
            end

            pos=double(pos);

            if isempty(self.PositionInternal)

                self.PositionInternal=pos(1:2)-(0.5*pos(3:4));
                self.WidthInternal=pos(3);
                self.HeightInternal=pos(4);
                setUpROI(self);
            else
                self.PositionInternal=pos(1:2)-(0.5*pos(3:4));
                self.WidthInternal=pos(3);
                self.HeightInternal=pos(4);
                updateAspectRatio(self);
                self.MarkDirty('all');
            end

        end

        function pos=get.CenteredPosition(self)
            if isempty(self.PositionInternal)||isempty(self.WidthInternal)||isempty(self.HeightInternal)
                pos=[];
            else
                pos=[self.PositionInternal+(0.5*[self.WidthInternal,self.HeightInternal]),self.WidthInternal,self.HeightInternal];
            end
        end

        function set.WaitWhileDrawing(self,TF)
            self.BlockWhileDrawing=TF;
        end

        function TF=get.WaitWhileDrawing(self)
            TF=self.BlockWhileDrawing;
        end

    end

end
