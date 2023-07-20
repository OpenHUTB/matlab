classdef ROI<images.roi.internal.ROI





    properties(Transient,Hidden,NonCopyable=true,Access=protected)

StripeEdgeListener
    end


    methods(Abstract,Hidden)

        [x,y,z,varargout]=getLineData(self)
    end


    methods(Hidden,Access=protected)




        function wireUpLineListeners(self)
            wireUpLineListeners@images.roi.internal.ROI(self);
            self.StripeEdgeListener=event.listener(self.StripeEdge,'Hit',@(src,evt)startROIDrag(self,src));

            if~self.DraggableInternal
                self.StripeEdgeListener.Enabled=false;
            end

        end

    end

    methods(Hidden,Access=protected)



        function color=getStripeColor(self)
            if~strcmp(self.SelectedColorInternal,'none')
                color=uint8(([self.StripeColorInternal,self.AlphaInternal]*255).');
            else
                color=getColorInternal(self);
            end
        end



        function setPointColor(self)
            if~isempty(self.Point)

                if self.MouseHit
                    rectMarkerEdgeColor=getColor(self);
                    rectMarkerFaceColor=getFaceColor(self);

                    diamondMarkerEdgeColor=getColor(self);
                    diamondMarkerFaceColor=getFaceColor(self);
                else
                    rectMarkerEdgeColor=uint8(([0,0,0,self.AlphaInternal]*255).');
                    rectMarkerFaceColor=getColor(self);

                    diamondMarkerEdgeColor=invert(rectMarkerEdgeColor);
                    diamondMarkerFaceColor=getColor(self);
                end
                set(self.Point(1:12),'EdgeColorData',rectMarkerEdgeColor,...
                'FaceColorData',rectMarkerFaceColor);
                set(self.Point(13:14),'EdgeColorData',diamondMarkerEdgeColor,...
                'FaceColorData',diamondMarkerFaceColor);
            end
        end

    end

    methods(Hidden,Access=protected)



        function doUpdateLine(self,us,L,SL)

            [x,y,z,numSolidPts]=getLineData(self);

            xSolid=x(1:numSolidPts);
            ySolid=y(1:numSolidPts);
            zSolid=z(1:numSolidPts);

            xDotted=x((numSolidPts+1):end);
            yDotted=y((numSolidPts+1):end);
            zDotted=z((numSolidPts+1):end);


            if numel(xSolid)==1
                xSolid=[xSolid;xSolid];
                ySolid=[ySolid;ySolid];
                zSolid=[zSolid;zSolid];
            end

            if numel(xDotted)==1
                xDotted=[xDotted;xDotted];
                yDotted=[yDotted;yDotted];
                zDotted=[zDotted;zDotted];
            end

            [vdSolid,stripDataSolid]=images.roi.internal.transformPoints(us,xSolid,ySolid,zSolid);
            [vdStrip,stripDataStrip]=images.roi.internal.transformPoints(us,xDotted,yDotted,zDotted);


            L.VertexData=vdSolid;
            L.StripData=stripDataSolid;

            SL.VertexData=vdStrip;
            SL.StripData=stripDataStrip;

            if strcmp(self.EdgeColorInternal,'none')
                color=getColor(self);
            else
                color=uint8(([self.EdgeColorInternal,self.AlphaInternal]*255).');
            end

            set(L,'ColorData',color,...
            'LineWidth',self.LineWidthInternal,...
            'Visible',self.Visible);

...
...
...
...
...
...
...

            dottedLineColor=getColor(self);

            set(SL,'ColorData',dottedLineColor,...
            'LineWidth',1,...
            'Visible',self.Visible);

            setPrimitiveClickability(self,L,'visible','on');
            setPrimitiveClickability(self,SL,'visible','on');
        end

    end

end

function clr=invert(color)

    clr=color;
    clr(1:3)=uint8(255)-color(1:3);
end
