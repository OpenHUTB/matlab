classdef(Sealed,ConstructOnLoad)Cuboid<images.roi.internal.ROI...
    &images.roi.internal.DrawingCanvas3D...
    &images.roi.internal.mixin.SetLabel




    properties(Dependent)







FaceAlpha










FaceAlphaOnHover











FaceColorOnHover













Position











Rotatable










RotationAngle











ScrollWheelDuringDraw

    end

    properties(Dependent,Hidden)















CenteredPosition






MarkerSize

    end

    properties(Dependent,GetAccess=public,SetAccess=protected)






Vertices

    end

    properties(Hidden,Access=protected)


        HeightInternal double=[];
        WidthInternal double=[];
        DepthInternal double=[];
        ThetaInternal double=[0,0,0];
        RotatableInternal logical=[false,false,false];
        ScrollWheelInternal logical=[true,true,true];
        FaceColorOnHoverInternal matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='none';
        FaceAlphaOnHoverInternal=0.4;
        FaceAlphaInternal(1,1)double{mustBeReal}=0.2;

    end

    properties(Transient,NonCopyable=true,Hidden,Access=protected)


        Face matlab.graphics.primitive.world.TriangleStrip
FaceListener


CachedHeight
CachedWidth
CachedDepth
CachedTheta



        CurrentFaceIdx=0;



        LockDimensions=false;


        ShiftKeyPressed=false;





        ShiftKeyFlag=false;



        IsFaceInverted=false;


        TranslationAdjustment=0;
        DragPlanePoint=[0,0,0];
        DragPlaneNormal=[0,0,0];
        StartCorner=[];


        SnapAngleIncrement=15;

    end

    methods




        function self=Cuboid(varargin)

            self@images.roi.internal.ROI();


            self.LayerInternal='front';


            createFaces(self);




            delete(self.Edge);
            self.Edge=matlab.graphics.primitive.world.LineStrip(...
            'HitTest','off','ColorType','truecoloralpha',...
            'ColorBinding','object','Layer',self.LayerInternal,'HandleVisibility','off',...
            'PickableParts','none','Internal',true);
            self.addNode(self.Edge);

            delete(self.StripeEdge);
            self.StripeEdge=matlab.graphics.primitive.world.LineStrip(...
            'HitTest','off','PickableParts','none',...
            'ColorType','truecoloralpha','ColorBinding','object',...
            'Layer',self.LayerInternal,'LineStyle','dashed','HandleVisibility','off',...
            'Internal',true);
            self.addNode(self.StripeEdge);

            delete(self.LabelHandle);
            self.LabelHandle=matlab.graphics.primitive.world.Text(...
            'Layer',self.LayerInternal,'HitTest','off','HandleVisibility','off',...
            'Margin',1,'LineStyle','none','PickableParts','none',...
            'Font',matlab.graphics.general.Font('Name','Helvetica'),...
            'Internal',true);
            self.addNode(self.LabelHandle);

            self.Type=class(self);


            self.LineWidthInternal=1;

            parseInputs(self,varargin{:});

        end




        function in=inROI(self,x,y,z)




            supportedClasses={'single','double'};
            supportedAttributes={'real','finite','nonempty','nonsparse'};

            validateattributes(x,supportedClasses,supportedAttributes,mfilename,'x');
            validateattributes(y,supportedClasses,supportedAttributes,mfilename,'y');
            validateattributes(z,supportedClasses,supportedAttributes,mfilename,'z');

            if~isvector(x)
                error(message('images:validate:requireVectorInput'));
            end

            if~isequal(size(x),size(y))
                error(message('images:validate:unequalSizeMatrices','x','y'));
            end

            if~isequal(size(x),size(z))
                error(message('images:validate:unequalSizeMatrices','x','z'));
            end

            points=[x(:),y(:),z(:)];
            n=numel(x);

            [xROI,yROI,zROI]=getPointData(self);



            u=[xROI(2)-xROI(1),yROI(2)-yROI(1),zROI(2)-zROI(1)];
            v=[xROI(5)-xROI(1),yROI(5)-yROI(1),zROI(5)-zROI(1)];
            w=[xROI(4)-xROI(1),yROI(4)-yROI(1),zROI(4)-zROI(1)];


            unitU=u/norm(u);
            unitV=v/norm(v);
            unitW=w/norm(w);



            uDotPoints=dot(points-[xROI(1),yROI(1),zROI(1)],repmat(unitU,[n,1]),2);
            vDotPoints=dot(points-[xROI(1),yROI(1),zROI(1)],repmat(unitV,[n,1]),2);
            wDotPoints=dot(points-[xROI(1),yROI(1),zROI(1)],repmat(unitW,[n,1]),2);











            in=uDotPoints>=0...
            &uDotPoints<=dot(u,unitU,2)...
            &vDotPoints>=0...
            &vDotPoints<=dot(v,unitV,2)...
            &wDotPoints>=0...
            &wDotPoints<=dot(w,unitW,2);

        end




        function draw(self,varargin)


















            setSnapPoints(self,varargin{:});


            prepareToDraw(self);
            setEmptyCallbackHandle(self);


            wireUpListeners(self);


            notify(self,'DrawingStarted');
            wireUpEscapeKeyListener(self);
            cleanupObject=onCleanup(@()self.cleanUpForCtrlC());
            uiwait(self.FigureHandle);
        end




        function beginDrawingFromPoint(self,pos,varargin)



















            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[1,3],'finite','nonsparse'},...
            mfilename,'Location');




            setSnapPoints(self,varargin{:});


            prepareToDraw(self);
            setEmptyCallbackHandle(self);


            wireUpListeners(self,pos);


            notify(self,'DrawingStarted');
            wireUpEscapeKeyListener(self);
            cleanupObject=onCleanup(@()self.cleanUpForCtrlC());
            uiwait(self.FigureHandle);
        end

    end

    methods(Access=protected)


        function wireUpListeners(self,varargin)


            resetConstraintsAndFigureMode(self,varargin{:});

            self.ShiftKeyPressed=false;

            startDraw(self,varargin{:});


            self.ButtonMotionEvt=event.listener(self.FigureHandle,...
            'WindowMouseMotion',@(src,evt)drawROI(self,evt));


            self.ButtonUpEvt=event.listener(self.FigureHandle,...
            'WindowMouseRelease',@(~,evt)stopDraw(self,evt));


            self.ScrollWheelEvt=event.listener(self.FigureHandle,...
            'WindowScrollWheel',@(~,evt)scrollWheelDuringDraw(self,evt));

        end


        function startDraw(self,varargin)

            if nargin>1




                pos=findNearestSnapPoint(self,varargin{1});

                if isfinite(self.PositionConstraint)

                    newDimensions=[(self.PositionConstraint(2)-self.PositionConstraint(1))/3,(self.PositionConstraint(4)-self.PositionConstraint(3))/3,(self.PositionConstraint(6)-self.PositionConstraint(5))/3];
                else


                    hAx=ancestor(self,'axes');
                    newDimensions=[(hAx.XLim(2)-hAx.XLim(1))/3,(hAx.YLim(2)-hAx.XLim(1))/3,(hAx.ZLim(2)-hAx.XLim(1))/3];
                end

                maxPos=getConstrainedPosition(self,pos+0.5*newDimensions);
                minPos=getConstrainedPosition(self,pos-0.5*newDimensions);

                self.PositionInternal=minPos;
                self.WidthInternal=maxPos(1)-minPos(1);
                self.HeightInternal=maxPos(2)-minPos(2);
                self.DepthInternal=maxPos(3)-minPos(3);

            else



                if isfinite(self.PositionConstraint)

                    self.WidthInternal=(self.PositionConstraint(2)-self.PositionConstraint(1))/3;
                    self.HeightInternal=(self.PositionConstraint(4)-self.PositionConstraint(3))/3;
                    self.DepthInternal=(self.PositionConstraint(6)-self.PositionConstraint(5))/3;

                    self.PositionInternal=[self.PositionConstraint(1)+self.WidthInternal,self.PositionConstraint(3)+self.HeightInternal,self.PositionConstraint(5)+self.DepthInternal];

                else


                    hAx=ancestor(self,'axes');

                    self.WidthInternal=(hAx.XLim(2)-hAx.XLim(1))/3;
                    self.HeightInternal=(hAx.YLim(2)-hAx.XLim(1))/3;
                    self.DepthInternal=(hAx.ZLim(2)-hAx.XLim(1))/3;
                    self.PositionInternal=[hAx.XLim(1)+self.WidthInternal,hAx.YLim(1)+self.HeightInternal,hAx.ZLim(1)+self.DepthInternal];
                end

            end

            self.ThetaInternal=[0,0,0];
            self.StartCorner=[0,0,0];

        end


        function extrudeROI(self)

            if~isempty(self.PositionInternal)



                cachedPosition=self.PositionInternal;
                cachedWidth=self.WidthInternal;
                cachedHeight=self.HeightInternal;
                cachedDepth=self.DepthInternal;

                candidatePosition=cachedPosition;
                candidateDimensions=[cachedWidth,cachedHeight,cachedDepth];



                isRectangleRotated=any(self.ThetaInternal~=0);



                pos=getPointsInAndOutOfAxes(self);



                u=diff(pos);
                v=pos(1,:)-self.DragPlanePoint;
                d=dot(self.DragPlaneNormal,u);
                n=-dot(self.DragPlaneNormal,v);

                if abs(d)<10^-5

                    return;
                end


                intersectPoint=pos(1,:)+((n/d).*u);

                if isRectangleRotated
                    [x,y,z]=rotateLineData(self,intersectPoint(1),intersectPoint(2),intersectPoint(3),...
                    (cachedPosition(1)+0.5*cachedWidth),...
                    (cachedPosition(2)+0.5*cachedHeight),...
                    (cachedPosition(3)+0.5*cachedDepth),false);
                    intersectPoint=[x,y,z];
                else
                    intersectPoint=getConstrainedPosition(self,intersectPoint);
                end

                switch self.CurrentFaceIdx
                case{1,2}
                    idx=1;
                case{3,4}
                    idx=2;
                case{5,6}
                    idx=3;
                otherwise


                    return;
                end

                if self.ShiftKeyPressed||self.LockDimensions

                    if self.ShiftKeyFlag




                        self.ShiftKeyFlag=false;
                        if intersectPoint(idx)<self.StartCorner(idx)
                            self.IsFaceInverted=false;
                            self.TranslationAdjustment=0;
                        else
                            self.IsFaceInverted=true;
                            self.TranslationAdjustment=candidateDimensions(idx);
                        end
                    end
                    candidatePosition(idx)=intersectPoint(idx)-self.TranslationAdjustment;
                else

                    if intersectPoint(idx)<self.StartCorner(idx)
                        candidateDimensions(idx)=abs(intersectPoint(idx)-(candidatePosition(idx)+candidateDimensions(idx)));
                        candidatePosition(idx)=intersectPoint(idx);
                    else
                        candidateDimensions(idx)=abs(intersectPoint(idx)-candidatePosition(idx));
                    end
                end








                pos=[candidatePosition,candidateDimensions];
                if isRectangleRotated
                    [pos,shiftRequired]=shiftCenterOfRotation(self,pos);
                end

                pos=setROIPosition(self,pos);


                self.PositionInternal=pos(1:3);
                self.WidthInternal=pos(4);
                self.HeightInternal=pos(5);
                self.DepthInternal=pos(6);


                [candidateX,candidateY,candidateZ]=getPointData(self);
                if isCandidatePositionInsideConstraint(self,[candidateX,candidateY,candidateZ])

                    if isRectangleRotated

                        self.StartCorner=self.StartCorner+shiftRequired;
                    end



                    previousPosition=[cachedPosition,cachedWidth,cachedHeight,cachedDepth];
                    currentPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal,self.DepthInternal];


                    evtData=packageROIMovingEventData(self,previousPosition,currentPosition,self.ThetaInternal,self.ThetaInternal);
                    self.MarkDirty('all');
                    notify(self,'MovingROI',evtData);

                else


                    self.PositionInternal=cachedPosition;
                    self.WidthInternal=cachedWidth;
                    self.HeightInternal=cachedHeight;
                    self.DepthInternal=cachedDepth;
                end

            end

        end

        function drawROI(self,~)

            if isModeManagerActive(self)
                return;
            end

            if~isempty(self.PositionInternal)



                cachedPosition=self.PositionInternal;
                cachedWidth=self.WidthInternal;
                cachedHeight=self.HeightInternal;
                cachedDepth=self.DepthInternal;


                candidatePosition=findNearestSnapPoint(self,getPointsInAndOutOfAxes(self))-(0.5*[cachedWidth,cachedHeight,cachedDepth]);

                pos=[candidatePosition,cachedWidth,cachedHeight,cachedDepth];
                pos=setROIPosition(self,pos);


                self.PositionInternal=pos(1:3);
                self.WidthInternal=pos(4);
                self.HeightInternal=pos(5);
                self.DepthInternal=pos(6);


                [candidateX,candidateY,candidateZ]=getPointData(self);
                if isCandidatePositionInsideConstraint(self,[candidateX,candidateY,candidateZ])



                    previousPosition=[cachedPosition,cachedWidth,cachedHeight,cachedDepth];
                    currentPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal,self.DepthInternal];
                    evtData=packageROIMovingEventData(self,previousPosition,currentPosition,self.ThetaInternal,self.ThetaInternal);
                    self.MarkDirty('all');
                    notify(self,'MovingROI',evtData);

                else


                    self.PositionInternal=cachedPosition;
                    self.WidthInternal=cachedWidth;
                    self.HeightInternal=cachedHeight;
                    self.DepthInternal=cachedDepth;
                end

            end

        end


        function[pos,shiftRequired]=shiftCenterOfRotation(self,pos)










            newCenterX=pos(1)+0.5*pos(4);
            newCenterY=pos(2)+0.5*pos(5);
            newCenterZ=pos(3)+0.5*pos(6);


            [rotatedCenterX,rotatedCenterY,rotatedCenterZ]=rotateLineData(self,newCenterX,newCenterY,newCenterZ,...
            (self.PositionInternal(1)+0.5*self.WidthInternal),...
            (self.PositionInternal(2)+0.5*self.HeightInternal),...
            (self.PositionInternal(3)+0.5*self.DepthInternal),true);



            shiftRequired=[(rotatedCenterX-newCenterX),(rotatedCenterY-newCenterY),(rotatedCenterZ-newCenterZ)];
            pos(1)=pos(1)+shiftRequired(1);
            pos(2)=pos(2)+shiftRequired(2);
            pos(3)=pos(3)+shiftRequired(3);

        end


        function stopDraw(self,evt)

            if isModeManagerActive(self)||wasClickOnAxesToolbar(self,evt)
                return;
            end


            endInteractivePlacement(self);
            self.SnapPoints=[];
            setUpROI(self);
            notifyDrawCompletion(self);

        end


        function doCustomUpdate(self,us)


































            if~isempty(self.PositionInternal)

                [x,y,z]=getPointData(self);
                vd=images.roi.internal.transformPoints(us,x,y,z);

                set(self.Face(1),'VertexData',vd(:,[2,3,7,6]));
                set(self.Face(2),'VertexData',vd(:,[1,5,8,4]));
                set(self.Face(3),'VertexData',vd(:,[5,6,7,8]));
                set(self.Face(4),'VertexData',vd(:,[1,4,3,2]));
                set(self.Face(5),'VertexData',vd(:,[4,8,7,3]));
                set(self.Face(6),'VertexData',vd(:,[1,2,6,5]));

                set(self.Face,'VertexIndices',uint32([2,4,1,2,3,4]));


                color=getColor(self);
                color(4)=uint8(self.FaceAlphaInternal*255);

                set(self.Face,'ColorData',color,'ColorBinding','object',...
                'ColorType','truecoloralpha','Visible',self.Visible);

                if~self.UserIsDrawing&&(self.ReshapableInternal||self.DraggableInternal)&&strcmp(self.Visible,'on')

                    identifySelectedFace(self,[us.Camera.Target;us.Camera.Position]);
                else



                    setPrimitiveClickability(self,self.Face,'none','off');
                end

                if self.CurrentFaceIdx>0&&self.MouseHit&&self.DraggableInternal&&~self.UserIsDragging

                    if strcmp(self.FaceColorOnHoverInternal,'none')
                        color=getColor(self);
                        color(4)=uint8(self.FaceAlphaInternal*255);
                    else
                        color=uint8(([self.FaceColorOnHoverInternal,self.FaceAlphaInternal]*255).');
                    end

                    if~strcmp(self.FaceAlphaOnHoverInternal,'none')
                        color(4)=uint8(self.FaceAlphaOnHoverInternal*255);
                    end

                    set(self.Face(self.CurrentFaceIdx),'ColorData',color);

                end

            else
                set(self.Face,'VertexData',[]);
                set(self.Face,'VertexIndices',[]);
            end


        end

        function doUpdateLine(self,us,L,SL)

            [x,y,z]=getLineData(self);

            [vd,~]=images.roi.internal.transformPoints(us,x,y,z);
            stripData=uint32(1:2:25);


            L.VertexData=vd;
            L.StripData=stripData;

            SL.VertexData=vd;
            SL.StripData=stripData;

            if strcmp(self.EdgeColorInternal,'none')
                color=getColor(self);
            else
                color=uint8(([self.EdgeColorInternal,self.AlphaInternal]*255).');
            end

            set(L,'ColorData',color,...
            'LineWidth',self.LineWidthInternal,...
            'Visible',self.Visible);


            if strcmp(self.StripeColorInternal,'none')
                set(SL,'Visible','off');
            else
                set(SL,'ColorData',getStripeColor(self),...
                'LineWidth',self.LineWidthInternal,...
                'Visible',self.Visible);
            end

        end


        function[pickableparts,hittest]=getLabelClickability(~)


            pickableparts='none';
            hittest='off';
        end


        function createFaces(self)

            for idx=1:6

                hFace=matlab.graphics.primitive.world.TriangleStrip(...
                'HitTest','on','Layer',self.LayerInternal,'HandleVisibility','off',...
                'Visible','off','PickableParts','visible',...
                'BackFaceCulling','back','Internal',true);
                self.addNode(hFace);

                self.addNode(hFace);
                hFaceListener=event.listener(hFace,'Hit',@(src,evt)startROIReshape(self,src,evt));

                self.Face=[self.Face,hFace];
                self.FaceListener=[self.FaceListener,hFaceListener];

            end

        end


        function hitObject=getHitObject(self,src)

            if self.Edge==src
                hitObject='edge';
            elseif self.LabelHandle==src
                hitObject='label';
            else
                hitObject='face';
            end

        end


        function prepareToReshape(self,evt)

            self.ShiftKeyPressed=false;

            if self.LockDimensions
                self.ShiftKeyFlag=true;
            end

            self.UserIsDragging=true;

            if~isempty(self.CurrentPointIdx)






                self.StartCorner=getCurrentAxesPoint(self)-(self.PositionInternal+[self.WidthInternal,self.HeightInternal,self.DepthInternal]);



                return;
            end





            switch self.CurrentFaceIdx
            case 1
                [xNorm,yNorm,zNorm]=rotateLineData(self,0,1,0,0,0,0,true);
                self.StartCorner=self.PositionInternal;
            case 2
                [xNorm,yNorm,zNorm]=rotateLineData(self,0,-1,0,0,0,0,true);
                self.StartCorner=self.PositionInternal+[self.WidthInternal,self.HeightInternal,self.DepthInternal];
            case 3
                [xNorm,yNorm,zNorm]=rotateLineData(self,0,0,1,0,0,0,true);
                self.StartCorner=self.PositionInternal;
            case 4
                [xNorm,yNorm,zNorm]=rotateLineData(self,0,0,-1,0,0,0,true);
                self.StartCorner=self.PositionInternal+[self.WidthInternal,self.HeightInternal,self.DepthInternal];
            case 5
                [xNorm,yNorm,zNorm]=rotateLineData(self,0,1,0,0,0,0,true);
                self.StartCorner=self.PositionInternal;
            case 6
                [xNorm,yNorm,zNorm]=rotateLineData(self,0,-1,0,0,0,0,true);
                self.StartCorner=self.PositionInternal+[self.WidthInternal,self.HeightInternal,self.DepthInternal];
            otherwise
                return;
            end

            self.DragPlanePoint=evt.IntersectionPoint;
            self.DragPlaneNormal=[xNorm,yNorm,zNorm];

        end


        function setPointColor(~)


        end


        function setPointSize(self)

            if isROIConstructed(self)
                set(self.Point,'Size',self.MarkerSizeInternal);
            end
        end


        function setLayer(self)

            set(self.Edge,'Layer',self.LayerInternal);
            set(self.StripeEdge,'Layer',self.LayerInternal);
            set(self.LabelHandle,'Layer',self.LayerInternal);
            set(self.Fill,'Layer',self.LayerInternal);
            set(self.Face,'Layer',self.LayerInternal);

            if~isempty(self.Point)
                set(self.Point,'Layer',self.LayerInternal);
            end

        end


        function identifySelectedFace(self,points)


































            normalVectors=[1,0,0;
            -1,0,0;
            0,1,0;
            0,-1,0;
            0,0,1;
            0,0,-1];

            [x,y,z]=rotateLineData(self,normalVectors(:,1)',normalVectors(:,2)',normalVectors(:,3)',0,0,0,true);

            normalVectors=[x,y,z];


            u=diff(points);
            u=u/norm(u);

            if any(isnan(u))



                self.CurrentFaceIdx=0;
                return;
            end


            v=dot(normalVectors,repmat(u,[6,1]),2);






            setPrimitiveClickability(self,self.Face(v<=0),'none','off');
            setPrimitiveClickability(self,self.Face(v>0),'all','on');




            if self.CurrentFaceIdx>0&&v(self.CurrentFaceIdx)<=0
                self.CurrentFaceIdx=0;
            end

            if~any(self.RotatableInternal)


                setPrimitiveClickability(self,self.Point,'none','off');
            else




                idx=find(v>0);
                if~isempty(idx)


                    visiblePoints=identifyVisiblePoints(self,idx);

                    setPrimitiveClickability(self,self.Point(~visiblePoints),'none','off');
                    setPrimitiveClickability(self,self.Point(visiblePoints),'all','on');

                end
            end

        end

        function visiblePoints=identifyVisiblePoints(~,idx)



            visiblePoints=false([8,1]);

            if any(idx==1)
                visiblePoints([2,3,6,7])=true;
            end

            if any(idx==2)
                visiblePoints([1,4,5,8])=true;
            end

            if any(idx==3)
                visiblePoints([5,6,7,8])=true;
            end

            if any(idx==4)
                visiblePoints([1,2,3,4])=true;
            end

            if any(idx==5)
                visiblePoints([3,4,7,8])=true;
            end

            if any(idx==6)
                visiblePoints([1,2,5,6])=true;
            end

        end


        function reshapeROI(self,startPoint)

            pos=getConstrainedPosition(self,getCurrentAxesPoint(self));


            if~isequal(pos,startPoint)



                if~isempty(self.CurrentPointIdx)
                    rotateROI(self);
                else
                    extrudeROI(self);
                end

            end

        end


        function rotateROI(self)

            cachedTheta=self.ThetaInternal;

            pos=getCurrentAxesPoint(self);






            startVector=self.StartCorner;
            currentVector=pos-(self.PositionInternal+[self.WidthInternal,self.HeightInternal,self.DepthInternal]);


            axis=cross(startVector/norm(startVector),currentVector/norm(currentVector));
            l=norm(axis);


            ang=5*asin(l);



            if any(isnan(axis))||ang==0
                return;
            end



            t=makehgtform('axisrotate',axis,ang);


            sy=sqrt(t(1,1).*t(1,1)+t(2,1).*t(2,1));
            singular=sy<10*eps(class(t));



            eul=[atan2(t(3,2),t(3,3)),atan2(-t(3,1),sy),atan2(t(2,1),t(1,1))];


            if singular
                eul=[atan2(-t(2,3),t(2,2)),...
                atan2(-t(3,1),sy),zeros(1,1,'like',t)];
            end


            candidateTheta=cachedTheta+(eul*180/pi);


            candidateTheta(candidateTheta<0)=360+candidateTheta(candidateTheta<0);
            candidateTheta(candidateTheta>360)=candidateTheta(candidateTheta>360)-360;



            if self.ShiftKeyPressed
                candidateTheta=self.SnapAngleIncrement*round(candidateTheta/self.SnapAngleIncrement);
            end



            if~isequal(candidateTheta(self.RotatableInternal),self.ThetaInternal(self.RotatableInternal))



                self.ThetaInternal(self.RotatableInternal)=candidateTheta(self.RotatableInternal);



                [candidateX,candidateY,candidateZ]=getPointData(self);
                if~isCandidatePositionInsideConstraint(self,[candidateX,candidateY,candidateZ])


                    self.ThetaInternal=cachedTheta;
                else

                    self.StartCorner=currentVector;




                    currentPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal,self.DepthInternal];



                    evtData=packageROIMovingEventData(self,currentPosition,currentPosition,cachedTheta,self.ThetaInternal);

                    self.MarkDirty('all');
                    notify(self,'MovingROI',evtData);

                end

            end

        end


        function keyPressDuringInteraction(self,evt)

            shiftPressed=any(strcmp(evt.Key,{'shift'}));

            if shiftPressed
                switch evt.EventName
                case 'WindowKeyPress'
                    pressShiftKey(self);
                case 'WindowKeyRelease'
                    releaseShiftKey(self);
                end

            end

        end


        function scrollWheelDuringDraw(self,evt)

            if isModeManagerActive(self)
                return;
            end

            scaleFactor=1.1;

            if evt.VerticalScrollCount<0
                scaleFactor=1/scaleFactor;
            end

            keyPressedFlags=[1,1,1];



            keyPressedFlags(self.ScrollWheelInternal)=scaleFactor;

            if~isempty(self.PositionInternal)


                cachedPosition=self.PositionInternal;
                cachedWidth=self.WidthInternal;
                cachedHeight=self.HeightInternal;
                cachedDepth=self.DepthInternal;

                candidateSize=keyPressedFlags.*([cachedWidth,cachedHeight,cachedDepth]);


                candidateSize(candidateSize<=0)=eps;





                oldCenter=cachedPosition+(0.5*[cachedWidth,cachedHeight,cachedDepth]);
                candidatePosition=oldCenter-(0.5*candidateSize);

                pos=[candidatePosition,candidateSize];
                pos=setROIPosition(self,pos);

                self.PositionInternal=pos(1:3);
                self.WidthInternal=pos(4);
                self.HeightInternal=pos(5);
                self.DepthInternal=pos(6);


                [candidateX,candidateY,candidateZ]=getPointData(self);
                if isCandidatePositionInsideConstraint(self,[candidateX,candidateY,candidateZ])


                    previousPosition=[cachedPosition,cachedWidth,cachedHeight,cachedDepth];
                    currentPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal,self.DepthInternal];

                    evtData=packageROIMovingEventData(self,previousPosition,currentPosition,self.ThetaInternal,self.ThetaInternal);
                    self.MarkDirty('all');
                    notify(self,'MovingROI',evtData);

                else



                    self.PositionInternal=cachedPosition;
                    self.WidthInternal=cachedWidth;
                    self.HeightInternal=cachedHeight;
                    self.DepthInternal=cachedDepth;
                end

            end

        end


        function pressShiftKey(self)





            if~self.ShiftKeyPressed
                self.ShiftKeyFlag=true;
            end

            self.ShiftKeyPressed=true;

            if~isempty(self.CurrentPointIdx)
                rotateROI(self);
            else
                extrudeROI(self);
            end

        end


        function releaseShiftKey(self)

            self.ShiftKeyFlag=false;
            self.ShiftKeyPressed=false;

            if~isempty(self.CurrentPointIdx)
                rotateROI(self);
            else


                switch self.CurrentFaceIdx
                case{1,2}
                    if self.IsFaceInverted
                        self.StartCorner(1)=self.PositionInternal(1);
                    else
                        self.StartCorner(1)=self.PositionInternal(1)+self.WidthInternal;
                    end
                case{3,4}
                    if self.IsFaceInverted
                        self.StartCorner(2)=self.PositionInternal(2);
                    else
                        self.StartCorner(2)=self.PositionInternal(2)+self.HeightInternal;
                    end
                case{5,6}
                    if self.IsFaceInverted
                        self.StartCorner(3)=self.PositionInternal(3);
                    else
                        self.StartCorner(3)=self.PositionInternal(3)+self.DepthInternal;
                    end
                end

                extrudeROI(self);
            end

        end


        function updateROISpecificProperties(self)
            self.UserIsDragging=false;
        end


        function doROIShiftClick(self,evt)

            wireUpReshapeListeners(self,evt);
            pressShiftKey(self);
        end


        function wireUpLineListeners(~)

        end


        function addDragPoints(self)

            if isempty(self.Point)||all(~isvalid(self.Point))

                self.ROIIsUnderConstruction=true;

                clearPoints(self);

                for idx=1:8
                    drawDragPoints(self,'circle',0.5,self.LayerInternal);
                end

                self.ROIIsUnderConstruction=false;

            end
        end


        function cMenu=getContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','IPTRectangleContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:deleteCuboid')),...
            'Callback',@(~,~)deleteROI(self),...
            'Tag','IPTROIContextMenuDelete');
            uimenu(cMenu,'Label',getString(message('images:imroi:lockDimensions')),...
            'Callback',@(src,~)lockCuboidDimensions(self,src),...
            'Tag','IPTROIContextMenuLock');

        end


        function prepareROISpecificContextMenu(self,cMenu)


            setLockContextMenuCheck(self,cMenu);


            enableContextMenuDelete(self,cMenu);

        end


        function setLockContextMenuCheck(self,cMenu)
            hobj=findall(cMenu,'Type','uimenu','Tag','IPTROIContextMenuLock');
            if~isempty(hobj)
                if self.DraggableInternal
                    if self.ReshapableInternal
                        hobj.Enable='on';
                    else
                        hobj.Enable='off';
                    end
                else
                    hobj.Enable='off';
                end

                if self.LockDimensions
                    hobj.Checked='on';
                else
                    hobj.Checked='off';
                end
            end
        end

        function lockCuboidDimensions(self,hobj)
            self.LockDimensions=~self.LockDimensions;
            if self.LockDimensions
                self.ShiftKeyFlag=true;
            end
            if self.LockDimensions
                hobj.Checked='on';
            else
                hobj.Checked='off';
            end
        end


        function validateInteractionsAllowed(self,val)



            validStr=validatestring(val,{'all','none','translate'});

            switch validStr
            case 'all'
                self.DraggableInternal=true;
                self.ReshapableInternal=true;
                self.LockDimensions=false;
                TF=true;
            case 'none'
                self.DraggableInternal=false;
                self.ReshapableInternal=false;
                TF=false;
            case 'translate'
                self.DraggableInternal=true;
                self.ReshapableInternal=false;
                self.LockDimensions=true;
                TF=true;
            otherwise
                error(message('images:imroi:invalidCuboidInteractionInput',val));
            end

            self.FaceListener(1).Enabled=TF;
            self.FaceListener(2).Enabled=TF;
            self.FaceListener(3).Enabled=TF;
            self.FaceListener(4).Enabled=TF;
            self.FaceListener(5).Enabled=TF;
            self.FaceListener(6).Enabled=TF;

        end


        function evtData=packageROIMovingEventData(self,varargin)


            if nargin>2
                evtData=images.roi.CuboidMovingEventData(varargin{1},varargin{2},...
                varargin{3},varargin{4});
            else




                previousPosition=[varargin{1},self.WidthInternal,self.HeightInternal,self.DepthInternal];
                currentPosition=[self.PositionInternal,self.WidthInternal,self.HeightInternal,self.DepthInternal];
                evtData=images.roi.CuboidMovingEventData(previousPosition,currentPosition,...
                self.ThetaInternal,self.ThetaInternal);
            end
        end


        function evtData=packageROIMovedEventData(self)
            evtData=images.roi.CuboidMovingEventData([self.CachedPosition,self.CachedWidth,self.CachedHeight,self.CachedDepth],...
            [self.PositionInternal,self.WidthInternal,self.HeightInternal,self.DepthInternal],...
            self.CachedTheta,self.ThetaInternal);
        end


        function cacheDataForROIMovedEvent(self)



            self.CachedPosition=self.PositionInternal;
            self.CachedTheta=self.ThetaInternal;
            self.CachedHeight=self.HeightInternal;
            self.CachedWidth=self.WidthInternal;
            self.CachedDepth=self.DepthInternal;
        end



        function[x,y,z]=rotateLineData(self,x,y,z,centerX,centerY,centerZ,positiveFlag)






            c=cosd(self.ThetaInternal);
            s=sind(self.ThetaInternal);

            Rx=[1,0,0;...
            0,c(1),-s(1);...
            0,s(1),c(1)];

            Ry=[c(2),0,s(2);...
            0,1,0;...
            -s(2),0,c(2)];

            Rz=[c(3),-s(3),0;...
            s(3),c(3),0;...
            0,0,1];


            rotationMatrix=Rz*Ry*Rx;

            if positiveFlag
                pos=rotationMatrix*[(x-centerX);(y-centerY);(z-centerZ)];
            else
                pos=rotationMatrix\[(x-centerX);(y-centerY);(z-centerZ)];
            end

            x=(pos(1,:)+centerX)';
            y=(pos(2,:)+centerY)';
            z=(pos(3,:)+centerZ)';

        end


        function clearPosition(self)
            self.PositionInternal=[];
            self.HeightInternal=[];
            self.WidthInternal=[];
            self.DepthInternal=[];
            self.ThetaInternal=[0,0,0];
        end


        function g=getPropertyGroups(self)
            g=matlab.mixin.util.PropertyGroup(addParentPropertyGroup(self,...
            {'Position','RotationAngle','Label'}));
        end

    end

    methods(Hidden)


        function setPointerEnterFcn(self,~)
            dragPointerEnterFcn(self,'rotate');
        end


        function setFaceEnterFcn(self,hObject)
            self.CurrentFaceIdx=find(self.Face==hObject);



            try
                self.MouseHit=true;
                if self.DraggableInternal
                    images.roi.internal.setROIPointer(self.FigureHandle,'hand');
                end
            catch

            end
            self.MarkDirty('all');
        end


        function[x,y,z]=getLineData(self)

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            else

                x=ones([24,1])*self.PositionInternal(1);
                x([2:5,10:13,19:22])=x([2:5,10:13,19:22])+self.WidthInternal;

                y=ones([24,1])*self.PositionInternal(2);
                y([4:7,12:15,21:24])=y([4:7,12:15,21:24])+self.HeightInternal;

                z=ones([24,1])*self.PositionInternal(3);
                z([9:16,18,20,22,24])=z([9:16,18,20,22,24])+self.DepthInternal;

                if any(self.ThetaInternal~=0)
                    [x,y,z]=rotateLineData(self,x',y',z',...
                    (self.PositionInternal(1)+0.5*self.WidthInternal),...
                    (self.PositionInternal(2)+0.5*self.HeightInternal),...
                    (self.PositionInternal(3)+0.5*self.DepthInternal),true);
                end

            end
        end


        function[x,y,z,xAlign,yAlign]=getLabelData(self)

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            else
                x=self.PositionInternal(1)+0.5*self.WidthInternal;
                y=self.PositionInternal(2)+0.5*self.HeightInternal;
                z=self.PositionInternal(3)+0.5*self.DepthInternal;
            end

            xAlign='center';
            yAlign='middle';

        end


        function[x,y,z]=getPointData(self)

            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            else

                x=ones([8,1])*self.PositionInternal(1);
                x([2,3,6,7])=x([2,3,6,7])+self.WidthInternal;

                y=ones([8,1])*self.PositionInternal(2);
                y(5:8)=y(5:8)+self.HeightInternal;

                z=ones([8,1])*self.PositionInternal(3);
                z([3,4,7,8])=z([3,4,7,8])+self.DepthInternal;

                if any(self.ThetaInternal~=0)
                    [x,y,z]=rotateLineData(self,x',y',z',...
                    (self.PositionInternal(1)+0.5*self.WidthInternal),...
                    (self.PositionInternal(2)+0.5*self.HeightInternal),...
                    (self.PositionInternal(3)+0.5*self.DepthInternal),true);
                end

            end

        end

    end

    methods





        function set.FaceAlpha(self,val)

            validateattributes(val,{'numeric'},...
            {'nonempty','real','scalar','nonsparse','>=',0,'<=',1},...
            mfilename,'FaceAlpha');

            self.FaceAlphaInternal=double(val);


            self.MarkDirty('all');

        end

        function val=get.FaceAlpha(self)
            val=self.FaceAlphaInternal;
        end




        function set.FaceAlphaOnHover(self,val)


            matlab.images.internal.errorIfgpuArray(val);

            if(ischar(val)||isstring(val))&&strcmp(val,'none')
                self.FaceAlphaOnHoverInternal='none';
            else

                validateattributes(val,{'numeric'},...
                {'nonempty','real','scalar','nonsparse','>=',0,'<=',1},...
                mfilename,'FaceAlphaOnHover');

                self.FaceAlphaOnHoverInternal=double(val);

            end


            self.MarkDirty('all');

        end

        function val=get.FaceAlphaOnHover(self)
            val=self.FaceAlphaOnHoverInternal;
        end




        function set.FaceColorOnHover(self,color)

            if(ischar(color)||isstring(color))&&strcmp(color,'none')
                self.FaceColorOnHoverInternal='none';
            else
                self.FaceColorOnHoverInternal=convertColorSpec(images.internal.ColorSpecToRGBConverter,color);
            end

            self.MarkDirty('all');

        end

        function val=get.FaceColorOnHover(self)
            val=self.FaceColorOnHoverInternal;
        end




        function set.Position(self,pos)
            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[1,6],'finite','nonsparse'},...
            mfilename,'Position');

            if pos(4)<0||pos(5)<0||pos(6)<0
                error(message('images:imroi:invalidCuboid'));
            end

            pos=double(pos);

            if isempty(self.PositionInternal)

                self.PositionInternal=pos(1:3);
                self.WidthInternal=pos(4);
                self.HeightInternal=pos(5);
                self.DepthInternal=pos(6);
                setUpROI(self);
            else
                self.PositionInternal=pos(1:3);
                self.WidthInternal=pos(4);
                self.HeightInternal=pos(5);
                self.DepthInternal=pos(6);
                self.MarkDirty('all');
            end

        end

        function pos=get.Position(self)
            if isempty(self.PositionInternal)||isempty(self.WidthInternal)||isempty(self.HeightInternal)||isempty(self.DepthInternal)
                pos=[];
            else
                pos=[self.PositionInternal,self.WidthInternal,self.HeightInternal,self.DepthInternal];
            end
        end




        function set.CenteredPosition(self,pos)
            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[1,6],'finite','nonsparse'},...
            mfilename,'CenteredPosition');

            if pos(4)<0||pos(5)<0||pos(6)<0
                error(message('images:imroi:invalidCuboid'));
            end

            pos=double(pos);

            if isempty(self.PositionInternal)

                self.PositionInternal=pos(1:3)-(0.5*pos(4:6));
                self.WidthInternal=pos(4);
                self.HeightInternal=pos(5);
                self.DepthInternal=pos(6);
                setUpROI(self);
            else
                self.PositionInternal=pos(1:3)-(0.5*pos(4:6));
                self.WidthInternal=pos(4);
                self.HeightInternal=pos(5);
                self.DepthInternal=pos(6);
                self.MarkDirty('all');
            end

        end

        function pos=get.CenteredPosition(self)
            if isempty(self.PositionInternal)||isempty(self.WidthInternal)||isempty(self.HeightInternal)||isempty(self.DepthInternal)
                pos=[];
            else
                pos=[self.PositionInternal+(0.5*[self.WidthInternal,self.HeightInternal,self.DepthInternal]),self.WidthInternal,self.HeightInternal,self.DepthInternal];
            end
        end




        function set.MarkerSize(self,val)


            setMarkerSize(self,val);

        end

        function val=get.MarkerSize(self)
            val=getMarkerSize(self);
        end




        function set.Rotatable(self,val)
            validateattributes(val,{'char','string'},{'scalartext'},...
            mfilename,'Rotatable');

            validStr=validatestring(val,{'all','none','x','y','z'});

            switch validStr

            case 'none'
                self.RotatableInternal=[false,false,false];
            case 'all'
                self.RotatableInternal=[true,true,true];
            case 'z'
                self.RotatableInternal=[false,false,true];
            case 'y'
                self.RotatableInternal=[false,true,false];
            case 'x'
                self.RotatableInternal=[true,false,false];
            end

        end

        function val=get.Rotatable(self)

            if all(self.RotatableInternal)
                val='all';
            elseif any(self.RotatableInternal)
                if self.RotatableInternal(1)
                    val='z';
                elseif self.RotatableInternal(2)
                    val='y';
                else
                    val='x';
                end
            else
                val='none';
            end

        end




        function set.RotationAngle(self,val)
            validateattributes(val,{'numeric'},...
            {'nonempty','real','size',[1,3],'finite','nonsparse'},...
            mfilename,'RotationAngle');



            val=mod(double(val),360);

            self.ThetaInternal=val;


            self.MarkDirty('all');
        end

        function val=get.RotationAngle(self)
            val=self.ThetaInternal;
        end




        function set.ScrollWheelDuringDraw(self,val)
            validateattributes(val,{'char','string'},{'scalartext'},...
            mfilename,'ScrollWheelDuringDraw');

            validStr=validatestring(val,{'allresize','none','xresize','yresize','zresize'});

            switch validStr

            case 'none'
                self.ScrollWheelInternal=[false,false,false];
            case 'allresize'
                self.ScrollWheelInternal=[true,true,true];
            case 'xresize'
                self.ScrollWheelInternal=[true,false,false];
            case 'yresize'
                self.ScrollWheelInternal=[false,true,false];
            case 'zresize'
                self.ScrollWheelInternal=[false,false,true];
            end

        end

        function val=get.ScrollWheelDuringDraw(self)

            if all(self.ScrollWheelInternal)
                val='all';
            elseif any(self.ScrollWheelInternal)
                if self.ScrollWheelInternal(1)
                    val='x';
                elseif self.ScrollWheelInternal(2)
                    val='y';
                else
                    val='z';
                end
            else
                val='none';
            end

        end




        function pos=get.Vertices(self)

            if isempty(self.PositionInternal)||isempty(self.WidthInternal)||isempty(self.HeightInternal)||isempty(self.DepthInternal)
                pos=[];
            else
                [x,y,z]=getPointData(self);
                pos=[x,y,z];
            end

        end

    end

end
