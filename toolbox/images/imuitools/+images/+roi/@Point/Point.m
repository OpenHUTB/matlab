classdef(Sealed,ConstructOnLoad)Point<images.roi.internal.AbstractPoint...
    &images.roi.internal.mixin.SetLabel...
    &images.roi.internal.mixin.SetMarkerSize




    properties(Dependent)







Position

    end

    methods




        function self=Point(varargin)
            self@images.roi.internal.AbstractPoint();
            parseInputs(self,varargin{:});
        end

    end

    methods(Access=protected)


        function cMenu=getContextMenu(self)

            cMenu=uicontextmenu('Parent',gobjects(0),...
            'Tag','IPTPointContextMenu',...
            'Visible','off');
            uimenu(cMenu,'Label',getString(message('images:imroi:deletePoint')),...
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


        function addDragPoints(self)
            if isempty(self.Point)||all(~isvalid(self.Point))

                self.ROIIsUnderConstruction=true;

                clearPoints(self);
                drawDragPoints(self,'circle',1,self.LayerInternal);

                self.ROIIsUnderConstruction=false;
            end
        end


        function[xAlign,yAlign]=doUpdateLabelOrientation(self,us,vd,lab,xAlign,yAlign)


            [xAlign,yAlign]=findLabelOrientation(self,us,vd,lab,xAlign,yAlign);
        end


        function doUpdatePoints(self,us,P)

            [x,y,z]=getPointData(self);
            vd=images.roi.internal.transformPoints(us,x,y,z);

            for idx=1:numel(P)
                P(idx).VertexData=vd(:,idx);
            end




            if~self.UserIsDrawing&&self.ReshapableInternal&&strcmp(self.Visible,'on')
                setPrimitiveClickability(self,self.Point,'all','on');
            else
                setPrimitiveClickability(self,self.Point,'none','off');
            end


            setPointColor(self);


            setPointVisibility(self);

        end


        function setPointVisibility(self)






            if self.MarkersVisibleOnHoverInternal
                set(self.Point,'Visible',self.Visible&&self.MouseHit);
            else
                set(self.Point,'Visible',self.Visible&&self.MarkersVisibleInternal);
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