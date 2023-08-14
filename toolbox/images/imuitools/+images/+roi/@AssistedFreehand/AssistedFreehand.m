classdef(Sealed,ConstructOnLoad)AssistedFreehand<images.roi.internal.AbstractFreehand...
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

    properties(Transient)





Image
    end

    properties(Dependent)







Position














Waypoints

    end

    properties(Transient,NonCopyable=true,Access=protected,Hidden)
        LastClickPoint=[];
        FreeSegment=[];
        ClickedOnStartPointToClose=false;
    end

    methods




        function self=AssistedFreehand(varargin)
            self@images.roi.internal.AbstractFreehand();

            if nargin~=0
                if isa(varargin{1},'matlab.graphics.primitive.Image')
                    self.Image=varargin{1};

                    varargin{1}=varargin{1}.Parent;
                    parseInputs(self,varargin{2:end});
                end
                parseInputs(self,varargin{:});
            end
        end




        function BW=createMask(self,varargin)
















            if nargin==1
                [m,n,xData,yData]=validateInputs(self,self.Image);
            else
                [m,n,xData,yData]=validateInputs(self,varargin{:});
            end

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




        function set.Image(self,hImage)
            validateattributes(hImage,...
            {'matlab.graphics.primitive.Image'},...
            {'scalar'});
            self.Image=hImage;
            images.roi.AssistedFreehand.prepareForAssistedFreehand(hImage);
        end
    end

    methods(Hidden,Access=protected)
        function setDrawingCanvas(varargin)
            error(message('images:imroi:drawingCanvasIsReadOnly'));
        end
    end

    methods(Access=protected)

        function validateParentBeforeDrawing(self)
            self.setAndCheckImage();
        end

        function prepareROISpecificDrawingSetup(self)
            prepareStartPoint(self);

            self.Image.AssistedFreehandExecutor.startNewROI();



            self.SkipFaceRendering=true;
        end


        function startDraggingToAddPoints(self)


            self.DragMotionEvt=event.listener(self.FigureHandle,...
            'WindowMouseMotion',@(src,evt)dragToAddPoints(self,evt));

            if~self.UserIsDragging





                self.LastClickPoint=getCurrentAxesPoint(self);
            end

            self.UserIsDragging=true;
        end


        function stopDraggingToAddPoints(self,~)
            delete(self.ButtonUpEvt);
            delete(self.DragMotionEvt);

            self.UserIsDragging=false;

            mouseUpPoint=getCurrentAxesPoint(self);
            if self.LastClickPoint~=mouseUpPoint


                constrainedPos=getConstrainedPosition(self,mouseUpPoint);
                closePreviousSegment=false;
                addVertex(self,constrainedPos(1),constrainedPos(2),closePreviousSegment);
            end
        end


        function stopDraw(self)
            endInteractivePlacement(self);


            self.FreeSegment=[];

            addWayPointToLastClickPoint=~self.ClickedOnStartPointToClose;


            self.WaypointsInternal(size(self.PositionInternal,1),1)...
            =addWayPointToLastClickPoint;


            self.SkipFaceRendering=false;
            addDragPoints(self);
            notifyDrawCompletion(self);
        end


        function clickedOnStartPoint(self)

            pos=[self.PositionInternal;self.FreeSegment];
            self.PositionInternal=setROIPosition(self,pos);
            self.ClickedOnStartPointToClose=true;
        end


        function addVertex(self,x,y,acceptPreviousFreeSegment)
            if nargin<4
                acceptPreviousFreeSegment=true;
            end

            newPos=[x,y];
            if isempty(self.PositionInternal)

                pos=newPos;
            elseif~self.UserIsDragging&&acceptPreviousFreeSegment

                acceptedSegment=self.FreeSegment;
                if isempty(acceptedSegment)


                    acceptedSegment=newPos;
                end
                pos=[self.PositionInternal;acceptedSegment];
            else

                pos=[self.PositionInternal;newPos];
            end


            self.PositionInternal=setROIPosition(self,pos);

            if~self.UserIsDragging


                seedPoint=self.PositionInternal(end,:);
                constrainedPos=getConstrainedPosition(self,seedPoint);
                constrainedPos=self.axes2image(constrainedPos);
                self.Image.AssistedFreehandExecutor.setSeedPointAtXY(constrainedPos);

                self.addWaypoint(size(self.PositionInternal,1));
            end
        end


        function undo(self)

            if nnz(self.WaypointsInternal)<2

                return;
            end


            delete(self.Point(end));
            self.Point(end)=[];

            delete(self.PointListener(end));
            self.PointListener(end)=[];



            lastTwoWayPoints=find(self.WaypointsInternal,2,'last');


            self.PositionInternal=self.PositionInternal(1:lastTwoWayPoints(1),:);
            self.WaypointsInternal=self.WaypointsInternal(1:lastTwoWayPoints(1),:);


            seedPoint=self.PositionInternal(end,:);
            seedPoint=self.axes2image(seedPoint);
            self.Image.AssistedFreehandExecutor.setSeedPointAtXY(seedPoint);

            animateConnectionLine(self);

        end


        function[xAlign,yAlign]=doUpdateLabelOrientation(self,us,vd,lab,xAlign,yAlign)


            [xAlign,yAlign]=findLabelOrientation(self,us,vd,lab,xAlign,yAlign);
        end


        function animateConnectionLine(self)
            pos=getCurrentAxesPoint(self);
            if self.UserIsDragging
                self.FreeSegment=pos;
            else

                freePoint=self.axes2image(pos);
                self.FreeSegment=self.Image.AssistedFreehandExecutor.getSegmentToXY(freePoint);
                self.FreeSegment=self.image2axes(self.FreeSegment);
                filterSize=2*ceil(2*self.SigmaInternal)+1;
                self.FreeSegment=images.roi.internal.filterPositionData(self.FreeSegment,self.SigmaInternal,filterSize);

                if isempty(self.FreeSegment)


                    self.FreeSegment=pos;
                end
            end

            self.MarkDirty('all');
        end


        function g=getPropertyGroups(self)
            g=matlab.mixin.util.PropertyGroup(addParentPropertyGroup(self,...
            {'Position','Closed','Label'}));
        end

    end

    methods(Hidden)

        function[scale,imageOrigin]=getTransformationData(self)
            imageOrigin=[self.Image.XData(1),self.Image.YData(1)];
            imageCorner=[self.Image.XData(2),self.Image.YData(2)];
            imageSize=[size(self.Image.CData,2),size(self.Image.CData,1)];

            imageDelta=imageCorner-imageOrigin;
            if imageDelta==0
                imageDelta=1;
            end

            scale=(imageSize-1)./imageDelta;
        end

        function pos=axes2image(self,pos)
            [scale,imageOrigin]=self.getTransformationData();
            pos=scale.*(pos-imageOrigin)+1;
            pos=round(pos);

        end

        function pos=image2axes(self,pos)
            [scale,imageOrigin]=self.getTransformationData();
            pos=(pos-1)./scale+imageOrigin;
        end

        function setAndCheckImage(self)
            if isempty(self.Image)

                hImages=[];
                hFigure=get(0,'CurrentFigure');
                if~isempty(hFigure)&&isvalid(hFigure)
                    hAxes=hFigure.CurrentAxes;
                    if~isempty(hAxes)&&isvalid(hAxes)
                        hImages=findobj(hAxes,'Type','image');
                    end
                end
                if isempty(hImages)
                    error(message('images:imroi:noimages'));
                else

                    self.Image=hImages(1);
                    self.Parent=ancestor(self.Image,'axes');
                end
            end

            if~isvalid(self.Image)
                error(message('images:imroi:invalidImage'));
            end

            if isempty(self.Parent)
                self.Parent=ancestor(self.Image,'axes');
            end



            if isempty(self.Image.Parent)||self.Parent~=self.Image.Parent
                error(message('images:imroi:parentMismatch'));
            end

        end


        function[x,y,z]=getLineData(self)
            if isempty(self.PositionInternal)
                x=[];
                y=[];
                z=[];
            else
                x=self.PositionInternal(:,1);
                y=self.PositionInternal(:,2);

                if self.UserIsDrawing&&~isempty(self.FreeSegment)

                    x=[x;self.FreeSegment(:,1)];
                    y=[y;self.FreeSegment(:,2)];
                elseif self.ClosedInternal
                    x(end+1)=x(1);
                    y(end+1)=y(1);
                end

                z=zeros(size(x));
            end

        end
    end

    methods





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

    methods(Static,Hidden)

        function prepareForAssistedFreehand(imageHandle,varargin)



            validateattributes(imageHandle,{'matlab.graphics.primitive.Image'},...
            {'scalar'},'nonempty');

            if isprop(imageHandle,'AssistedFreehandExecutor')...
                &&isvalid(imageHandle.AssistedFreehandExecutor)

                return
            end




            if~isprop(imageHandle,'AssistedFreehandExecutor')
                assistedFreehandExecutor=imageHandle.addprop('AssistedFreehandExecutor');
                assistedFreehandExecutor.Hidden=true;
                assistedFreehandExecutor.Transient=true;
            end

            images.roi.AssistedFreehand.recomputeAssistance(imageHandle,varargin{:});

            if nargin==1


                addlistener(imageHandle,'CData','PostSet',...
                @(varargin)images.roi.AssistedFreehand.recomputeAssistance(varargin{2}.AffectedObject));
            end
        end

        function recomputeAssistance(imageHandle,imageData)

            validateattributes(imageHandle.CData,{'numeric','logical'},{'nonempty'},...
            mfilename,'Image.CData');

            if nargin==2

                im=imageData;
                validateattributes(im,{'numeric'},...
                {'ndims',2});
            else

                if size(imageHandle.CData,3)==3
                    im=rgb2gray(imageHandle.CData);
                else
                    im=imageHandle.CData(:,:,1);
                end
            end


            im=single(im);
            im=rescale(im);


            imageHandle.AssistedFreehandExecutor=images.internal.IntelligentScissors(im);
        end

    end

end
