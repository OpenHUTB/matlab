classdef DataTipControl<matlab.graphics.interaction.graphicscontrol.GenericControl



    properties
Obj
    end

    methods
        function this=DataTipControl(obj)
            this=this@matlab.graphics.interaction.graphicscontrol.GenericControl();
            this.Type='DataTipHoverMarker';
            this.Obj=obj;
        end

        function response=process(this,message)
            response=struct;
            if isfield(message,'name')&&ischar(message.name)
                switch message.name
                case 'renderDataTip'
                    response=this.renderDataTip(message.X,message.Y,message.limits);
                case 'hideDataTip'
                    this.hideDataTip();
                otherwise

                    response=process@matlab.graphics.interaction.graphicscontrol.GenericControl(this,message);
                end
            end
        end
    end

    methods

        function hideDataTip(this)
            this.setVisibility(false);
        end

        function response=renderDataTip(this,X,Y,limits)
            hit=this.getHitInfo(X,Y);
            pixelPoint=hit.pixelPoint;
            response.isLocationUpdated=false;

            if this.isObjectDataAnnotatable(hit.object)
                obj=hit.object;


                index=obj.getNearestPoint(pixelPoint);


                pos=obj.getReportedPosition(index);
                pt=pos.getLocation(obj);



                if numel(pt)==2
                    pt(3)=0;
                end

                pt=pt';


                [hCamera,aboveMatrix,hDataSpace,belowMatrix]=matlab.graphics.internal.getSpatialTransforms(obj);
                nearestDSPoint=belowMatrix*[pt;1];

                if nearestDSPoint(1)>=limits(1)&&nearestDSPoint(1)<=limits(2)&&...
                    nearestDSPoint(2)>=limits(3)&&nearestDSPoint(2)<=limits(4)&&...
                    nearestDSPoint(3)>=limits(5)&&nearestDSPoint(3)<=limits(6)

                    screenPt=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(obj,pt);



                    this.Obj.Parent.PixelPosition=[screenPt(1),screenPt(2)];
                    response.isLocationUpdated=true;
                end
            end

            if response.isLocationUpdated
                this.setVisibility(true);
            else
                this.setVisibility(false);
            end
        end
    end

    methods(Access=private)
        function c=getCanvas(~,obj)
            c=ancestor(obj,'matlab.graphics.primitive.canvas.Canvas','node');
        end

        function val=isObjectDataAnnotatable(~,obj)
            val=false;
            dataAnnotatableObj=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(obj);

            if~isempty(dataAnnotatableObj)&&...
                (isa(dataAnnotatableObj,'matlab.graphics.chart.primitive.Line')||...
                isa(dataAnnotatableObj,'matlab.graphics.chart.primitive.Surface'))
                val=true;
            end
        end

        function setVisibility(this,val)
            switch val
            case{'on',true}
                alpha=255;
            case{'off',false}
                alpha=0;
            otherwise
                return
            end

            if~isempty(this.Obj.NodeChildren(1).EdgeColorData)
                this.Obj.NodeChildren(1).EdgeColorData(4)=uint8(alpha);
            end

            if~isempty(this.Obj.NodeChildren(2).FaceColorData)
                this.Obj.NodeChildren(2).FaceColorData(4)=uint8(alpha);
            end
        end

        function hit=getHitInfo(this,X,Y)
            c=this.getCanvas(this.Obj);
            hit.object=c.hittest(X,Y);
            hFig=ancestor(this.Obj,'figure');
            hit.pixelPoint=[X+1,hFig.Position(4)-Y];
        end
    end


end
