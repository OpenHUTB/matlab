classdef(Sealed,ConstructOnLoad)ProjectedCuboid<vision.roi.internal.ROI...
    &images.roi.internal.mixin.SetLabel...
    &images.roi.internal.mixin.SetAspectRatio...
    &images.roi.internal.mixin.InsideROI...
    &images.roi.internal.mixin.CreateMask...
    &vision.roi.internal.mixin.SetFill...
    &images.roi.internal.mixin.SetRotation...
    &images.roi.internal.mixin.SetMarkerSize



...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...




    properties(Dependent)







Position


    end


    properties(Dependent,GetAccess=public,SetAccess=protected)





Vertices

    end

    properties(Dependent,Hidden)







CenteredPosition

    end

    properties(Hidden,Access=protected)


        PositionInternal2=[0,0];
        WidthInternal2=0;
        HeightInternal2=0;
        IsSecondFaceGrowing=false;
        IsSecondFaceFromLeft=true;


        StartCorner2=[0,0];
        CachedPosition2=[0,0];
        CachedHeight2=0;
        CachedWidth2=0;

        PrevDragPosXY=[0,0];
        DragStarted=false;
        DragEnded=false;


        IsAxisAligned=1
        EightVertices;

    end

    properties(Transient,NonCopyable=true,Hidden,Access=protected)
        RestrictPosition=[NaN,NaN];
    end

    methods




        function self=ProjectedCuboid(varargin)
            self@vision.roi.internal.ROI();
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
            self.StartCorner=[x,y];
            self.RestrictPosition=[NaN,NaN];

            self.PositionInternal2=[x,y];
            self.HeightInternal2=0;
            self.WidthInternal2=0;
            self.StartCorner2=[x,y];
        end


        function drawROI(self)

            if~isempty(self.PositionInternal)


                constrainedPos=getConstrainedPosition(self,getCurrentAxesPoint(self));

                if isempty(self.CurrentPointIdx)


                    newPos(1,:)=self.StartCorner;
                    [newPos(2,1),newPos(2,2)]=setRectangleRestriction(self,constrainedPos(1),constrainedPos(2));
                    pos=[min(newPos(:,1)),min(newPos(:,2)),max(newPos(:,1))-min(newPos(:,1)),max(newPos(:,2))-min(newPos(:,2))];

                    pos=setROIPosition(self,pos);



                    cachedPosition=self.PositionInternal;
                    cachedWidth=self.WidthInternal;
                    cachedHeight=self.HeightInternal;

                    self.PositionInternal=pos(1:2);
                    self.WidthInternal=pos(3);
                    self.HeightInternal=pos(4);

                    self.PositionInternal2=self.PositionInternal;
                    self.WidthInternal2=self.WidthInternal;
                    self.HeightInternal2=self.HeightInternal;

                    cachedPosition2=self.PositionInternal2;
                    cachedWidth2=self.WidthInternal2;
                    cachedHeight2=self.HeightInternal2;
                else

                    [face1Pos,face2Pos]=getFacePositions(self,constrainedPos);

                    [face1Pos(1),face1Pos(2)]=setRectangleRestriction(self,face1Pos(1),face1Pos(2));
                    [face2Pos(1),face2Pos(2)]=setRectangleRestriction(self,face2Pos(1),face2Pos(2));


                    self.PositionInternal=face1Pos(1:2);
                    self.WidthInternal=face1Pos(3);
                    self.HeightInternal=face1Pos(4);

                    self.PositionInternal2=face2Pos(1:2);
                    self.WidthInternal2=face2Pos(3);
                    self.HeightInternal2=face2Pos(4);

                    cachedPosition=self.PositionInternal;
                    cachedWidth=self.WidthInternal;
                    cachedHeight=self.HeightInternal;

                    cachedPosition2=self.PositionInternal2;
                    cachedWidth2=self.WidthInternal2;
                    cachedHeight2=self.HeightInternal2;
                end

                previousPosition=[cachedPosition,cachedWidth,cachedHeight];
                previousPosition2=[cachedPosition2,cachedWidth2,cachedHeight2];

                currentPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal];
                currentPosition2=[self.PositionInternal2,self.WidthInternal2,self.HeightInternal2];

                previousPos=[previousPosition,previousPosition2];
                currentPos=[currentPosition,currentPosition2];

                evtData=packageROIMovingEventData(self,previousPos,currentPos,0,0);
                notify(self,'MovingROI',evtData);
                self.MarkDirty('all');

            end


        end


        function stopDraw(self)
            endInteractivePlacement(self);
            addDragPoints(self);
            notifyDrawCompletion(self);
        end


        function pos=setROIPosition(self,pos)




            if numel(pos)==2
                pos=[pos,self.WidthInternal,self.HeightInternal...
                ,pos,self.WidthInternal2,self.HeightInternal2];
            end
        end


        function addDragPoints(self)














            if isempty(self.Point)||all(~isvalid(self.Point))

                self.ROIIsUnderConstruction=true;

                clearPoints(self);

                for idx=1:12

                    drawDragPoints(self,'square',1,'front');
                end

                for idx=13:14
                    drawDragPoints(self,'diamond',1.2,'front');
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



            [xPos,yPos]=getUnrotatedPointData(self);

            self.ShiftKeyPressed=false;
            self.IsSecondFaceGrowing=false;

            switch self.CurrentPointIdx
            case{7,3,4}
                self.StartCorner=[xPos(5),yPos(5)];
            case 6
                self.StartCorner=[xPos(8),yPos(8)];
            case{2,5,1}
                self.StartCorner=[xPos(7),yPos(7)];
            case 8
                self.StartCorner=[xPos(6),yPos(6)];
            case 9
                self.StartCorner=[xPos(11),yPos(11)];
            case 10
                self.StartCorner=[xPos(12),yPos(12)];
            case 11
                self.StartCorner=[xPos(9),yPos(9)];
            case 12
                self.StartCorner=[xPos(10),yPos(10)];
            case 13
                self.StartCorner=[xPos(8),yPos(8)];
                self.IsSecondFaceFromLeft=true;
                self.IsSecondFaceGrowing=true;
            case 14
                self.StartCorner=[xPos(5),yPos(5)];
                self.IsSecondFaceFromLeft=false;
                self.IsSecondFaceGrowing=true;
            end

            if(0)
                switch self.CurrentPointIdx


                case 1
                    self.RestrictPosition=[xPos(8),NaN];
                case 2
                    self.RestrictPosition=[NaN,yPos(5)];
                case 3
                    self.RestrictPosition=[xPos(7),NaN];
                case 4
                    self.RestrictPosition=[NaN,yPos(8)];
                case{5,6,7,8,13,14}
                    self.RestrictPosition=[NaN,NaN];
                case{9,11}
                    self.RestrictPosition=[xPos(13),NaN];
                case 10
                    self.RestrictPosition=[NaN,yPos(14)];
                case 12
                    self.RestrictPosition=[NaN,yPos(13)];
                end
            else
                self.RestrictPosition=[NaN,NaN];
            end

        end


        function reshapeROI(self,startPoint)

            pos=getConstrainedPosition(self,getCurrentAxesPoint(self));


            if~isequal(pos,startPoint)
                self.FaceAlpha=0.3;
                drawROI(self);

            end

        end


        function updateROISpecificProperties(self)





            if~self.FixedAspectRatioInternal||...
                (self.HeightInternal~=0&&self.WidthInternal~=0)
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

            x=zeros(14,1);
            y=zeros(14,1);


            x(8)=self.PositionInternal(1);
            x(1)=x(8)+(0.5*self.WidthInternal);
            x(5)=x(8)+self.WidthInternal;

            y(8)=self.PositionInternal(2);
            y(7)=y(8)+self.HeightInternal;
            y(4)=y(8)+(0.5*self.HeightInternal);

            x(13)=self.PositionInternal2(1);
            x(9)=x(13)+(0.5*self.WidthInternal2);
            x(14)=x(13)+self.WidthInternal2;

            y(13)=self.PositionInternal2(2);
            y(11)=y(13)+self.HeightInternal2;
            y(12)=y(13)+(0.5*self.HeightInternal2);

            x(1)=x(1);y(1)=y(8);
            x(2)=x(5);y(2)=y(4);
            x(3)=x(1);y(3)=y(7);
            x(4)=x(8);y(4)=y(4);
            x(5)=x(5);y(5)=y(8);
            x(6)=x(5);y(6)=y(7);
            x(7)=x(8);y(7)=y(7);
            x(8)=x(8);y(8)=y(8);

            x(9)=x(9);y(9)=y(13);
            x(10)=x(14);y(10)=y(12);
            x(11)=x(9);y(11)=y(11);
            x(12)=x(13);y(12)=y(12);
            x(13)=x(13);y(13)=y(13);
            x(14)=x(14);y(14)=y(13);

            xPos=x;
            yPos=y;

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


        function setPointVisibility(self)

            if~isempty(self.Point)
                if(~self.ReshapableInternal&&~self.DraggableInternal)||self.UserIsDragging
                    set(self.Point,'Visible','off');
                else
                    if self.FixedAspectRatioInternal
                        set(self.Point([5,7,9,11]),'Visible',self.Visible);
                        setPrimitiveClickability(self,self.Point([5,7,9,11]),'visible','on');
                        set(self.Point([6,8,10,12]),'Visible','off');
                        setPrimitiveClickability(self,self.Point([6,8,10,12]),'none','off');
                    else
                        set(self.Point,'Visible',self.Visible);
                    end
                end
            end
        end


        function setPointSize(self)

            if isROIConstructed(self)

                set(self.Point(1:14),'Size',self.MarkerSizeInternal);
            end
        end


        function validateInteractionsAllowed(self,val)



            validStr=validatestring(val,{'all','none','reshape','translate'});

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
                error(message('vision:labeler:invalidProjCubeInteractionInput',val));
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




                pos=varargin{1};
                previousPosition=[pos(1:2),self.WidthInternal,self.HeightInternal...
                ,pos(5:6),self.WidthInternal2,self.HeightInternal2];
                currentPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal...
                ,self.PositionInternal2,self.WidthInternal2,self.HeightInternal2];
                evtData=images.roi.RectangleMovingEventData(previousPosition,currentPosition,...
                0,0);
            end
        end


        function evtData=packageROIMovedEventData(self)
            prevPos=[self.CachedPosition,self.CachedWidth,self.CachedHeight...
            ,self.CachedPosition2,self.CachedWidth2,self.CachedHeight2];
            curPos=[self.PositionInternal,self.WidthInternal,self.HeightInternal...
            ,self.PositionInternal,self.WidthInternal,self.HeightInternal];
            evtData=images.roi.RectangleMovingEventData(prevPos,...
            curPos,...
            0,0);
        end


        function cacheDataForROIMovedEvent(self)



            self.CachedPosition=self.PositionInternal;
            self.CachedHeight=self.HeightInternal;
            self.CachedWidth=self.WidthInternal;

            self.CachedPosition2=self.PositionInternal2;
            self.CachedHeight2=self.HeightInternal2;
            self.CachedWidth2=self.WidthInternal2;
        end


        function clearPosition(self)
            self.PositionInternal=[];
            self.HeightInternal=[];
            self.WidthInternal=[];

            self.PositionInternal2=[];
            self.HeightInternal2=[];
            self.WidthInternal2=[];
        end


        function g=getPropertyGroups(self)
            g=matlab.mixin.util.PropertyGroup(addParentPropertyGroup(self,...
            {'Position','RotationAngle','AspectRatio','Label'}));
        end

        function doUpdateMarkerLayer(self)

            P=self.Point;
            if isempty(P)
                return;
            end

            if isCuboidDepthZero(self)
                layer='back';
            else
                layer='front';
            end

            P(5).Layer=layer;
            P(8).Layer=layer;
            P(9).Layer=layer;
            P(10).Layer=layer;
            P(11).Layer=layer;
            P(12).Layer=layer;
        end

        function doUpdatePoints(self,us,P)
            doUpdateMarkerLayer(self);
            doUpdatePoints@images.roi.internal.ROI(self,us,P);
        end


        function doUpdateFill(self,us,fill,color,~,~)

            [x,y]=getShadedFaceXY(self);
            if isempty(x)
                return;
            end
            doUpdateFill@vision.roi.internal.mixin.SetFill(self,us,fill,color,x,y);
        end

    end

    methods(Hidden)

        function tf=isCuboidDepthZero(self)
            tf=true;
            [a,b,c,d,e,f,g,h]=get8Points(self);
            if~isempty(a)
                tf=(a(1)==e(1)&&a(2)==e(2))&&...
                (b(1)==f(1)&&b(2)==f(2))&&...
                (c(1)==g(1)&&c(2)==g(2))&&...
                (d(1)==h(1)&&d(2)==h(2));
            end

        end

        function[a,b,c,d,e,f,g,h]=get8Points(self)

            if isempty(self)||isempty(self.PositionInternal)
                a=[];
                b=[];
                c=[];
                d=[];
                e=[];
                f=[];
                g=[];
                h=[];
                return;
            end

            if(self.PositionInternal(1)==self.PositionInternal2(1))&&...
                (self.PositionInternal(2)==self.PositionInternal2(2))


                self.WidthInternal2=self.WidthInternal;
                self.HeightInternal2=self.HeightInternal;
            end


            x8=self.PositionInternal(1);
            x7=x8;
            x6=x8+self.WidthInternal;
            x5=x6;

            y8=self.PositionInternal(2);
            y7=y8+self.HeightInternal;
            y6=y7;
            y5=y8;

            a=[x8,y8];
            b=[x7,y7];
            c=[x6,y6];
            d=[x5,y5];


            x13=self.PositionInternal2(1);
            x14=x13+self.WidthInternal2;
            x15=x14;
            x16=x13;

            y13=self.PositionInternal2(2);
            y14=y13;
            y15=y14+self.HeightInternal2;
            y16=y15;

            e=[x13,y13];
            f=[x16,y16];
            g=[x15,y15];
            h=[x14,y14];
        end


        function[x,y,z,varargout]=getLineData(self)

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
                varargout{1}=0;
            elseif(self.IsAxisAligned==0)

                a=self.EightVertices(1,:);
                b=self.EightVertices(2,:);
                c=self.EightVertices(3,:);
                d=self.EightVertices(4,:);
                e=self.EightVertices(5,:);
                f=self.EightVertices(6,:);
                g=self.EightVertices(7,:);
                h=self.EightVertices(8,:);
                linePtsSolid=[a;b;c;d;a;e;f;g;h;e;f;b;c;g;h;d];
                x=linePtsSolid(:,1);
                y=linePtsSolid(:,2);
                z=zeros(size(x));
                varargout{1}=length(x);

            else

                [a,b,c,d,e,f,g,h]=get8Points(self);
                [linePtsSolid,linePtsDotted]=getLinePointsSolidDotted(a,b,c,d,e,f,g,h);



                xSolid=linePtsSolid(:,1);
                ySolid=linePtsSolid(:,2);
                zSolid=zeros(size(xSolid));

                xDotted=linePtsDotted(:,1);
                yDotted=linePtsDotted(:,2);
                zDotted=zeros(size(xDotted));

                x=[xSolid;xDotted];
                y=[ySolid;yDotted];
                z=[zSolid;zDotted];

                varargout{1}=length(xSolid);
            end
        end


        function[x,y,z,xAlign,yAlign]=getLabelData(self)


            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            else
                x=self.PositionInternal(1);

                hAx=ancestor(self,'axes');
                if isempty(hAx)||strcmp(hAx.YDir,'normal')
                    y=self.PositionInternal(2);
                else
                    y=self.PositionInternal(2)+self.HeightInternal;
                end

                z=0;
            end

            xAlign='left';
            yAlign='bottom';

        end


        function[xPos,yPos,zPos]=getPointData(self)





            if isempty(self.PositionInternal)
                xPos=[];
                yPos=[];
                zPos=[];
            else

                [xPos,yPos]=getUnrotatedPointData(self);

                zPos=zeros(size(xPos));
            end

        end


        function setPointerEnterFcn(self,src)








            idx=find(src==self.Point);

            switch idx
            case{1,3}
                symbol='north2';
            case{2,4}
                symbol='east2';
            case{5,7}
                symbol='NE';
            case{6,8}
                symbol='NW';
            case{9,11}
                symbol='north';
            case{10,12}
                symbol='east';
            case{13,14}
                symbol='arrowhead';
            end

            dragPointerEnterFcn(self,symbol);

        end


        function evtData=packageReshapeROIEventData(self,varargin)




            previousPos=[varargin{1}];
            currentPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal];
            currentPosition2=[self.PositionInternal2,self.WidthInternal2,self.HeightInternal2];
            currentPos=[currentPosition,currentPosition2];
            evtData=vision.roi.ProjectedCuboidMovingEventData(previousPos,currentPos,...
            self.ThetaInternal,self.ThetaInternal);
        end

    end

    methods





        function set.Position(self,pos)

            if all(size(pos,[1,2])==[8,2])

                validateattributes(pos,{'numeric'},...
                {'nonempty','real','size',[8,2,NaN],'finite','nonsparse'},...
                mfilename,'Position');

                self.EightVertices=pos;


                [~,minVertex]=min(pos(:,1));
                self.PositionInternal=pos(minVertex,:);
                self.WidthInternal=0;
                self.HeightInternal=0;
                self.IsAxisAligned=0;
                resetRect=isempty(self.PositionInternal);
            else
                validateattributes(pos,{'numeric'},...
                {'nonempty','real','size',[1,8],'finite','nonsparse'},...
                mfilename,'Position');








                self.IsAxisAligned=1;
                if self.FixedAspectRatioInternal&&all(pos(3:4)==0)&&all(pos(7:8)==0)
                    error(message('images:imroi:fixedNaNAspectRatio'));
                end

                pos=double(pos);

                resetRect=isempty(self.PositionInternal);

                self.PositionInternal=pos(1:2);
                self.WidthInternal=pos(3);
                self.HeightInternal=pos(4);

                self.PositionInternal2=pos(5:6);
                self.WidthInternal2=pos(7);
                self.HeightInternal2=pos(8);

            end

            if resetRect

                setUpROI(self);
            else
                updateAspectRatio(self);
                self.MarkDirty('all');
            end

        end

        function pos=get.Position(self)
            if~self.IsAxisAligned
                pos=self.EightVertices;
            else

                if isempty(self.PositionInternal)||isempty(self.WidthInternal)||isempty(self.HeightInternal)||...
                    isempty(self.PositionInternal2)||isempty(self.WidthInternal2)||isempty(self.HeightInternal2)
                    pos=[];
                else
                    pos=[self.PositionInternal,self.WidthInternal,self.HeightInternal...
                    ,self.PositionInternal2,self.WidthInternal2,self.HeightInternal2];
                end
            end
        end




        function pos=get.Vertices(self)
            if~self.IsAxisAligned
                pos=self.EightVertices;
            else

                projectedCuboidPosition=self.Position;
                vertices=zeros(8,2);
                vertices(1,:)=projectedCuboidPosition(1:2);
                vertices(2,:)=vertices(1,:)+[projectedCuboidPosition(3),0];
                vertices(3,:)=vertices(1,:)+[projectedCuboidPosition(3),projectedCuboidPosition(4)];
                vertices(4,:)=vertices(1,:)+[0,projectedCuboidPosition(4)];
                vertices(5,:)=projectedCuboidPosition(5:6);
                vertices(6,:)=vertices(5,:)+[projectedCuboidPosition(7),0];
                vertices(7,:)=vertices(5,:)+[projectedCuboidPosition(7),projectedCuboidPosition(8)];
                vertices(8,:)=vertices(5,:)+[0,projectedCuboidPosition(8)];

                pos=vertices;
            end
        end




        function set.CenteredPosition(self,pos)
            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[2,4],'finite','nonsparse'},...
            mfilename,'CenteredPosition');

            if pos(3)<0||pos(4)<0||pos(7)<0||pos(8)<0
                error(message('vision:labeler:invalidProjectedCuboid'));
            end

            if self.FixedAspectRatioInternal&&all(pos(3:4)==0)&&all(pos(7:8)==0)
                error(message('images:imroi:fixedNaNAspectRatio'));
            end

            pos=double(pos);

            resetRect=isempty(self.PositionInternal);

            self.PositionInternal=pos(1:2)-(0.5*pos(3:4));
            self.WidthInternal=pos(3);
            self.HeightInternal=pos(4);

            self.PositionInternal2=pos(5:6)-(0.5*pos(7:8));
            self.WidthInternal2=pos(7);
            self.HeightInternal2=pos(8);

            if resetRect

                setUpROI(self);
            else
                updateAspectRatio(self);
                self.MarkDirty('all');
            end

        end

        function pos=get.CenteredPosition(self)
            if isempty(self.PositionInternal)||isempty(self.WidthInternal)||isempty(self.HeightInternal)||...
                isempty(self.PositionInternal2)||isempty(self.WidthInternal2)||isempty(self.HeightInternal2)
                pos=[];
            else
                pos=[self.PositionInternal+(0.5*[self.WidthInternal,self.HeightInternal]),self.WidthInternal,self.HeightInternal...
                ,self.PositionInternal2+(0.5*[self.WidthInternal2,self.HeightInternal2]),self.WidthInternal2,self.HeightInternal2];
            end
        end

    end

    methods
        function[face1Pos,face2Pos]=getFacePositions(self,mouseXY)


            xyFace1TopLeft=self.PositionInternal;
            xyFace2TopLeft=self.PositionInternal2;
            xFace1Right=xyFace1TopLeft(1)+self.WidthInternal;
            yFace1Bottom=xyFace1TopLeft(2)+self.HeightInternal;
            xFace2Right=xyFace2TopLeft(1)+self.WidthInternal2;
            yFace2Bottom=xyFace2TopLeft(2)+self.HeightInternal2;

            xOffsetFace1=0;
            yOffsetFace1=0;

            hOffsetFace1=0;
            wOffsetFace1=0;

            xOffsetFace2=0;
            yOffsetFace2=0;

            hOffsetFace2=0;
            wOffsetFace2=0;

            switch self.CurrentPointIdx
            case 1
                [yOffsetFace1,yOffsetFace2,hOffsetFace1,hOffsetFace2]=...
                firstFaceTop(self,mouseXY,xyFace1TopLeft,xyFace2TopLeft);

            case 2
                [wOffsetFace1,wOffsetFace2]=...
                firstFaceRight(self,mouseXY,xyFace2TopLeft,xFace1Right);

            case 3
                [hOffsetFace1,hOffsetFace2]=...
                firstFaceBottom(self,mouseXY,xyFace2TopLeft,yFace1Bottom);

            case 4
                [xOffsetFace1,xOffsetFace2,wOffsetFace1,wOffsetFace2]=...
                firstFaceLeft(self,mouseXY,xyFace1TopLeft,xyFace2TopLeft);

            case 5
                [yOffsetFace1,yOffsetFace2,hOffsetFace1,hOffsetFace2]=...
                firstFaceTop(self,mouseXY,xyFace1TopLeft,xyFace2TopLeft);
                [wOffsetFace1,wOffsetFace2]=...
                firstFaceRight(self,mouseXY,xyFace2TopLeft,xFace1Right);
            case 6
                [wOffsetFace1,wOffsetFace2]=...
                firstFaceRight(self,mouseXY,xyFace2TopLeft,xFace1Right);
                [hOffsetFace1,hOffsetFace2]=...
                firstFaceBottom(self,mouseXY,xyFace2TopLeft,yFace1Bottom);
            case 7
                [hOffsetFace1,hOffsetFace2]=...
                firstFaceBottom(self,mouseXY,xyFace2TopLeft,yFace1Bottom);
                [xOffsetFace1,xOffsetFace2,wOffsetFace1,wOffsetFace2]=...
                firstFaceLeft(self,mouseXY,xyFace1TopLeft,xyFace2TopLeft);
            case 8
                [yOffsetFace1,yOffsetFace2,hOffsetFace1,hOffsetFace2]=...
                firstFaceTop(self,mouseXY,xyFace1TopLeft,xyFace2TopLeft);
                [xOffsetFace1,xOffsetFace2,wOffsetFace1,wOffsetFace2]=...
                firstFaceLeft(self,mouseXY,xyFace1TopLeft,xyFace2TopLeft);
            case 9

                yOffsetFace2=mouseXY(2)-xyFace2TopLeft(2);
                hOffsetFace2=-yOffsetFace2;

            case 10

                wOffsetFace2=mouseXY(1)-xFace2Right;

            case 11

                hOffsetFace2=mouseXY(2)-yFace2Bottom;

            case 12

                xOffsetFace2=mouseXY(1)-xyFace2TopLeft(1);
                wOffsetFace2=-xOffsetFace2;

            case 13


                xFace2LeftMouse=mouseXY(1);
                yFace2TopMouse=mouseXY(2);
                yOffsetFace2=secondFaceBottom(self,yFace2TopMouse,xyFace2TopLeft);



                xFace2Right=xFace2LeftMouse+self.WidthInternal2;
                xyFace2RightNew=getConstrainedPosition(self,[xFace2Right,nan]);
                xFace2RightNew=xyFace2RightNew(1);
                if xFace2RightNew~=xFace2Right
                    xFace2LeftMouse=xFace2RightNew-self.WidthInternal2;
                end
                xOffsetFace2=xFace2LeftMouse-xyFace2TopLeft(1);


            case 14
                xFace2RightMouse=mouseXY(1);
                yFace2TopMouse=mouseXY(2);


                yOffsetFace2=secondFaceBottom(self,yFace2TopMouse,xyFace2TopLeft);


                xFace2Left=xFace2RightMouse-self.WidthInternal2;
                xyFace2LeftNew=getConstrainedPosition(self,[xFace2Left,nan]);
                xFace2LeftNew=xyFace2LeftNew(1);
                if xFace2LeftNew~=xFace2Left
                    xFace2RightMouse=xFace2LeftNew+self.WidthInternal2;

                end
                xOffsetFace2=xFace2RightMouse-self.WidthInternal2-xyFace2TopLeft(1);

            end

            face1Pos=[xyFace1TopLeft(1)+xOffsetFace1...
            ,xyFace1TopLeft(2)+yOffsetFace1...
            ,self.WidthInternal+wOffsetFace1...
            ,self.HeightInternal+hOffsetFace1];

            face2Pos=[xyFace2TopLeft(1)+xOffsetFace2...
            ,xyFace2TopLeft(2)+yOffsetFace2...
            ,self.WidthInternal2+wOffsetFace2...
            ,self.HeightInternal2+hOffsetFace2];
        end

    end

    methods(Hidden,Access=protected)

        function setFillListenerState(self,fillListener)
            setFillListenerState@vision.roi.internal.mixin.SetFill(self,fillListener);
        end


        function dragROI(self,startPoint)

            currentPoint=getCurrentAxesPoint(self);



            if~isequal(getConstrainedPosition(self,currentPoint),startPoint)

                if~self.DragStarted
                    self.PrevDragPosXY=getConstrainedDragPosition(self,currentPoint);
                    self.DragStarted=true;
                    self.DragEnded=false;
                    return;
                end

                constrainedPos=getConstrainedDragPosition(self,currentPoint);


                dragOffset=[constrainedPos-self.PrevDragPosXY];
                dragOffset=computeAllowableDragOffset(self,dragOffset);

                previousPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal];
                previousPosition2=[self.PositionInternal2,self.WidthInternal2,self.HeightInternal2];
                previousPos=[previousPosition,previousPosition2];

                self.PositionInternal=self.PositionInternal+dragOffset;
                self.PositionInternal2=self.PositionInternal2+dragOffset;

                evtData=packageROIMovingEventData(self,previousPos);

                notify(self,'MovingROI',evtData);
                self.MarkDirty('all');

                self.PrevDragPosXY=constrainedPos;
            end

        end


        function stopDrag(self,startPoint)


            updateROISpecificProperties(self);

            self.UserIsDragging=false;
            deleteInternalEvents(self);


            self.FigureHandle.IPTROIPointerManager.Enabled=true;

            self.DragStarted=false;
            self.DragEnded=true;

            if~isequal(getCurrentAxesPoint(self),startPoint)
                evtData=packageROIMovedEventData(self);
                notify(self,'ROIMoved',evtData);
                self.MarkDirty('all');
            end

        end
    end

    methods(Access=protected)

        function[yOffsetFace1,yOffsetFace2,hOffsetFace1,hOffsetFace2]=...
            firstFaceTop(self,mouseXY,xyFace1TopLeft,xyFace2TopLeft)



            yOffsetFace1=mouseXY(2)-xyFace1TopLeft(2);


            yOffsetFace2=yOffsetFace1;
            yFace2Top=xyFace2TopLeft(2)+yOffsetFace2;

            xyFace2TopNew=getConstrainedPosition(self,[nan,yFace2Top]);
            yFace2TopNew=xyFace2TopNew(2);
            if yFace2TopNew~=yFace2Top
                yOffsetFace2=yFace2TopNew-xyFace2TopLeft(2);
                yOffsetFace1=yOffsetFace2;
            end


            hOffsetFace1=-yOffsetFace1;


            hOffsetFace2=hOffsetFace1;
        end

        function[wOffsetFace1,wOffsetFace2]=...
            firstFaceRight(self,mouseXY,xyFace2TopLeft,xFace1Right)

            wOffsetFace1=mouseXY(1)-xFace1Right;


            wOffsetFace2=wOffsetFace1;
            xFace2Right=xyFace2TopLeft(1)+self.WidthInternal2+wOffsetFace2;

            xyFace2RightNew=getConstrainedPosition(self,[xFace2Right,nan]);
            xFace2RightNew=xyFace2RightNew(1);
            if xFace2RightNew~=xFace2Right
                wOffsetFace2=xFace2RightNew-xyFace2TopLeft(1)-self.WidthInternal2;
                wOffsetFace1=wOffsetFace2;
            end
        end

        function[hOffsetFace1,hOffsetFace2]=firstFaceBottom(self,...
            mouseXY,xyFace2TopLeft,yFace1Bottom)

            hOffsetFace1=mouseXY(2)-yFace1Bottom;


            hOffsetFace2=hOffsetFace1;

            yFace2Bottom=xyFace2TopLeft(2)+self.HeightInternal2+hOffsetFace2;

            xyFace2BottomNew=getConstrainedPosition(self,[nan,yFace2Bottom]);
            yFace2BottomNew=xyFace2BottomNew(2);
            if yFace2BottomNew~=yFace2Bottom
                hOffsetFace2=yFace2BottomNew-xyFace2TopLeft(2)-self.HeightInternal2;
                hOffsetFace1=hOffsetFace2;
            end
        end

        function[xOffsetFace1,xOffsetFace2,wOffsetFace1,wOffsetFace2]=...
            firstFaceLeft(self,mouseXY,xyFace1TopLeft,xyFace2TopLeft)

            xOffsetFace1=mouseXY(1)-xyFace1TopLeft(1);


            xOffsetFace2=xOffsetFace1;

            xFace2Left=xyFace2TopLeft(1)+xOffsetFace2;
            xyFace2LeftNew=getConstrainedPosition(self,[xFace2Left,nan]);
            xFace2LeftNew=xyFace2LeftNew(1);
            if xFace2LeftNew~=xFace2Left
                xOffsetFace2=xFace2LeftNew-xyFace2TopLeft(1);
                xOffsetFace1=xOffsetFace2;
            end
            wOffsetFace1=-xOffsetFace1;
            wOffsetFace2=wOffsetFace1;
        end

        function yOffsetFace2=secondFaceBottom(self,yFace2TopMouse,xyFace2TopLeft)

            yFace2Bottom=yFace2TopMouse+self.HeightInternal2;
            xyFace2BottomNew=getConstrainedPosition(self,[nan,yFace2Bottom]);
            yFace2BottomNew=xyFace2BottomNew(2);
            if yFace2BottomNew~=yFace2Bottom
                yFace2TopMouse=yFace2BottomNew-self.HeightInternal2;
            end
            yOffsetFace2=yFace2TopMouse-xyFace2TopLeft(2);
        end

        function dragOffsetNew=computeAllowableDragOffset(self,dragOffset)
            [a,b,c,d,e,f,g,h]=get8Points(self);
            x=[a(1),b(1),c(1),d(1),e(1),f(1),g(1),h(1)];
            y=[a(2),b(2),c(2),d(2),e(2),f(2),g(2),h(2)];

            dX=dragOffset(1);
            dY=dragOffset(2);

            xNew=x+dX;
            yNew=y+dY;

            minXnew=min(xNew);
            maxXnew=max(xNew);

            minYnew=min(yNew);
            maxYnew=max(yNew);

            minXY=getConstrainedPosition(self,[minXnew,minYnew]);
            maxXY=getConstrainedPosition(self,[maxXnew,maxYnew]);


            dXnew=dX;
            if minXY(1)~=minXnew
                dXnew=minXY(1)-minXnew;
            elseif maxXY(1)~=maxXnew
                dXnew=maxXY(1)-maxXnew;
            end


            dYnew=dY;
            if minXY(2)~=minYnew
                dYnew=minXY(2)-minYnew;
            elseif maxXY(2)~=maxYnew
                dYnew=maxXY(2)-maxYnew;
            end

            dragOffsetNew=[dXnew,dYnew];
        end
    end

    methods
        function[x,y]=getShadedFaceXY(self)

            [a,b,c,d,e,f,g,h]=get8Points(self);

            if isempty(a)
                x=[];
                y=[];
                return;
            end
            x=[a(1);b(1);c(1);d(1);e(1);f(1);g(1);h(1)];
            y=[a(2);b(2);c(2);d(2);e(2);f(2);g(2);h(2)];






            a=[x(1),y(1)];
            b=[x(2),y(2)];
            c=[x(3),y(3)];
            d=[x(4),y(4)];
            e=[x(5),y(5)];
            f=[x(6),y(6)];
            g=[x(7),y(7)];
            h=[x(8),y(8)];

            len=24;
            x=nan(len,1);
            y=nan(len,1);


            i=0;
            x((i+1):(i+5))=[a(1);b(1);c(1);d(1);a(1)];
            y((i+1):(i+5))=[a(2);b(2);c(2);d(2);a(2)];
            len=5;
            if(h(1)>d(1))

                i=i+6;
                x((i+1):(i+5))=[d(1);h(1);g(1);c(1);d(1)];
                y((i+1):(i+5))=[d(2);h(2);g(2);c(2);d(2)];
                len=len+6;
            end

            if(e(1)<a(1))

                i=i+6;
                x((i+1):(i+5))=[a(1);b(1);f(1);e(1);a(1)];
                y((i+1):(i+5))=[a(2);b(2);f(2);e(2);a(2)];
                len=len+6;
            end


            i=i+6;
            x((i+1):(i+5))=[a(1);d(1);h(1);e(1);a(1)];
            y((i+1):(i+5))=[a(2);d(2);h(2);e(2);a(2)];
            len=len+6;

            x((len+1):end)=[];
            y((len+1):end)=[];
        end
    end


end

function[linePtsSolid,linePtsDotted]=getLinePointsSolidDotted(a,b,c,d,e,f,g,h)











    linePtsSolid=[a;b;c;d;a];




    linePtsDotted=[a;e;f;b;a;e;h;g;f;e;h;d;c;g;h];
    isRightSolid=(h(1)>d(1));
    isLeftSolid=(e(1)<a(1));





    if isRightSolid

        if g(2)>c(2)

            linePtsSolid=[linePtsSolid;d;h;g;f;g;c;d;a];
        else
            linePtsSolid=[linePtsSolid;d;h;g;c;d;a];
        end

        if h(2)<d(2)
            linePtsSolid=[linePtsSolid;d;h;e;h;d;a];
        end
    else


        if h(2)<d(2)

            linePtsSolid=[linePtsSolid;a;d;h;e;h;d;a];

        end


        if g(2)>c(2)

            linePtsSolid=[linePtsSolid;a;d;c;g;f;g;c;d;a];
        end
    end





    if isLeftSolid

        linePtsSolid=[linePtsSolid;e;f;b;a];


        if e(2)<a(2)
            linePtsSolid=[linePtsSolid;e;h;e;a];
        end
    else



        if e(2)<a(2)

            linePtsSolid=[linePtsSolid;a;e;h;e;a];

        end



        if f(2)>b(2)

            linePtsSolid=[linePtsSolid;a;b;f;b;a];
        end
    end

end
