classdef GeographicAxesInteractionStrategy<matlab.graphics.interaction.uiaxes.InteractionStrategy








    methods
        function strategy=GeographicAxesInteractionStrategy()
            strategy=strategy@matlab.graphics.interaction.uiaxes.InteractionStrategy;
        end


        function tf=isValidMouseEvent(~,obj,~,evt)









            if isempty(evt.HitObject)
                tf=false;
                return
            end

            hManager=uigetmodemanager(obj.Figure);
            hMode=hManager.CurrentMode;
            modeActive=isobject(hMode)&&isvalid(hMode)&&~isempty(hMode);

            legendHit=matlab.graphics.interaction.internal.hitLegendWithDefaultButtonDownFcn(evt);

            axesToolbar=ancestor(evt.HitObject,'matlab.graphics.controls.AxesToolbar','node');
            toolbarHit=~isempty(axesToolbar);

            datatipMarkerHit=~isempty(evt.HitObject)&&isa(evt.HitObject,'matlab.graphics.shape.internal.PointTipLocator');
            datatipTextboxHit=~isempty(evt.HitObject)&&isa(evt.HitObject,'matlab.graphics.shape.internal.ScribePeer');

            if modeActive||legendHit||toolbarHit||datatipMarkerHit||datatipTextboxHit
                tf=false;
            else
                tf=true;
            end
        end


        function tf=isObjectHit(~,obj,~,evt)

            if~isempty(evt.HitObject)&&isvalid(evt.HitObject)
                hitobject=evt.HitObject;
            else
                hitobject=gobjects(0);
            end

            if~isempty(hitobject)

                h=ancestor(evt.HitObject,'geoaxes','node');
                tf=any(h==obj.Axes);


                rulerhit=~isempty(matlab.graphics.interaction.internal.hitRuler(evt));


                istxt=isa(hitobject,'matlab.graphics.primitive.Text');


                lataxis=obj.Axes.LatitudeAxis;
                if~isempty(lataxis)
                    latlabel=lataxis.Label_IS;
                else
                    latlabel=[];
                end
                lonaxis=obj.Axes.LongitudeAxis;
                if~isempty(lonaxis)
                    lonlabel=lonaxis.Label_IS;
                else
                    lonlabel=[];
                end
                titletxt=obj.Axes.Title_IS;
                decorationhit=istxt...
                &&((isscalar(latlabel)&&hitobject==latlabel)||...
                (isscalar(lonlabel)&&hitobject==lonlabel)||...
                (isscalar(titletxt)&&hitobject==titletxt));


                if rulerhit||decorationhit
                    tf=false;
                end
            else
                tf=false;
            end
        end


        function setUntransformedPanLimits(~,gx,ds,xLimitsWorld,yLimitsWorld,~)

            xCenterWorld=mean(xLimitsWorld);
            yCenterWorld=mean(yLimitsWorld);
            [xCenterProjected,yCenterProjected]=worldToProjected(ds,xCenterWorld,yCenterWorld);
            recenter(gx,xCenterProjected,yCenterProjected)
        end


        function setUntransformedZoomLimits(~,gx,ds,xLimitsWorld,yLimitsWorld,~)

            xCenterWorld=mean(xLimitsWorld);
            yCenterWorld=mean(yLimitsWorld);
            [xCenterProjected,yCenterProjected]=worldToProjected(ds,xCenterWorld,yCenterWorld);
            if diff(yLimitsWorld)>1
                zoomOut(gx,gx.StepsPerZoomLevelScrollWheel,xCenterProjected,yCenterProjected)
            else
                zoomIn(gx,gx.StepsPerZoomLevelScrollWheel,xCenterProjected,yCenterProjected)
            end
        end
    end
end
