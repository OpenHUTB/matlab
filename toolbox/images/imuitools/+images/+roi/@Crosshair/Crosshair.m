classdef(Sealed,ConstructOnLoad)Crosshair<images.roi.internal.AbstractPoint...
    &images.roi.internal.mixin.SetLabel




    properties(Dependent)








Position

    end

    properties(Transient,NonCopyable=true,Hidden,Access=protected)


        SnappedToPosition;
    end

    methods




        function self=Crosshair(varargin)
            self@images.roi.internal.AbstractPoint();
            parseInputs(self,varargin{:});
            self.addDependencyConsumed('xyzdatalimits');
        end

    end

    methods(Access=protected)


        function cMenu=getContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','IPTCrosshairContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:deleteCrosshair')),...
            'Callback',@(~,~)deleteROI(self),...
            'Tag','IPTROIContextMenuDelete');

        end


        function validateInteractionsAllowed(self,val)




            validStr=validatestring(val,{'all','none','translate'},...
            mfilename,'InteractionsAllowed');

            switch validStr
            case{'all','translate'}
                self.DraggableInternal=true;
                self.ReshapableInternal=true;
            case 'none'
                self.DraggableInternal=false;
                self.ReshapableInternal=false;
            otherwise
                assert(false,'Should not reach here');
            end

        end


        function TF=isROIConstructed(self)


            TF=~isempty(self.EdgeListener);
        end


        function addDragPoints(~)

        end


        function doUpdateLine(self,us,L,SL)

            [x,y,z]=getLineData(self);

            if~isempty(x)
                xLim=us.DataSpace.XLim;
                yLim=us.DataSpace.YLim;
                zLim=us.DataSpace.ZLim;

                x=[x;x;xLim(1);xLim(2)];
                y=[yLim(1);yLim(2);y;y];
                z=[zLim(1);zLim(1);zLim(1);zLim(1)];
            end

            [vd,~]=images.roi.internal.transformPoints(us,x,y,z);
            stripData=uint32([1,3,5]);


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

            setPrimitiveClickability(self,L,'visible','on');


            if strcmp(self.StripeColorInternal,'none')
                set(SL,'Visible','off');
            else
                set(SL,'ColorData',getStripeColor(self),...
                'LineWidth',self.LineWidthInternal,...
                'Visible',self.Visible);
            end
        end


        function[xAlign,yAlign]=doUpdateLabelOrientation(self,us,vd,lab,xAlign,yAlign)


            [xAlign,yAlign]=findLabelOrientation(self,us,vd,lab,xAlign,yAlign);
        end


        function startROIDrag(self,src)


            if isModeManagerActive(self)
                return;
            end

            click=images.roi.internal.getClickType(self.FigureHandle);
            hitObject=getHitObject(self,src);

            if strcmp(click,'left')

                [x,y,z]=getLineData(self);
                setConstraintLimits(self,x,y,z);

                cacheDataForROIMovedEvent(self);
                positionBeforeSnap=self.Position;
                self.SnappedToPosition=self.Position;


                self.FigureHandle.IPTROIPointerManager.Enabled=false;


                currentPoint=getCurrentAxesPoint(self);

                setDragBoundary(self,currentPoint,x,y,z);
                setEmptyCallbackHandle(self);



                if strcmp(hitObject,'edge')
                    newPositions=getConstrainedDragPosition(self,currentPoint);

                    self.Position=setROIPosition(self,newPositions);



                    self.SnappedToPosition=self.Position;

                    [x,y,z]=getLineData(self);
                    setDragBoundary(self,self.Position,x,y,z);
                    self.MarkDirty('all');
                end

                self.DragMotionEvt=event.listener(self.FigureHandle,...
                'WindowMouseMotion',@(~,~)dragROI(self,currentPoint));



                self.DragButtonUpEvt=event.listener(self.FigureHandle,...
                'WindowMouseRelease',@(~,~)stopDrag(self,positionBeforeSnap));

            elseif strcmp(click,'double')&&strcmp(hitObject,'edge')
                doROIDoubleClick(self);
            end

            determineSelectionStatus(self,src,click,hitObject);

        end


        function dragROI(self,startPoint)

            currentPoint=getCurrentAxesPoint(self);



            if~isequal(getConstrainedPosition(self,currentPoint),startPoint)

                previousPosition=self.PositionInternal;



                constrainedPos=getConstrainedDragPosition(self,currentPoint);
                newPositions=self.SnappedToPosition+constrainedPos-startPoint;

                pos=setROIPosition(self,newPositions);
                self.PositionInternal=pos(:,1:2);

                evtData=packageROIMovingEventData(self,previousPosition);

                self.MarkDirty('all');
                notify(self,'MovingROI',evtData);

            end

        end
    end

    methods





        function set.Position(self,pos)

            validateattributes(pos,{'numeric'},...
            {'nonempty','real','size',[1,2],'finite','nonsparse'},...
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