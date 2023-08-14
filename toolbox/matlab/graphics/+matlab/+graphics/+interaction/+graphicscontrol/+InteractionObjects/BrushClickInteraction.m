classdef BrushClickInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase



    properties
Axes
    end

    methods
        function this=BrushClickInteraction(ax)
            this.Type='brushclick';
            this.ID=uint64(0);
            this.ObjectPeerID=uint64(0);
            this.Axes=ax;
            this.Object=ax;
            this.Actions=matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.Click;
        end

        function response(this,eventdata)



            if strcmp(eventdata.name,'click')

                canvasContainer=ancestor(this.Axes,'matlab.ui.container.Container');
                if isprop(eventdata,'hitObjectIds')

                    if numel(eventdata.hitObjectIds)>=1
                        hitobj=canvasContainer.getCanvas.getHitObject(eval(sprintf('int64(%s)',eventdata.hitObjectIds{1})));
                    else
                        return
                    end
                else
                    hitobj=eventdata.HitObject;
                end



                hitobj=ancestor(hitobj,'matlab.graphics.mixin.Selectable');
                hitobj=matlab.graphics.chart.internal.ChartHelpers.getPickableAncestor(hitobj);
                if isempty(hitobj)
                    return
                end

                if isplotchild(hitobj)
                    datamanager.brushRectangle(this.Axes,hitobj,...
                    [],[eventdata.figx,eventdata.figy],[],1,[1,0,0],'','');
                elseif ishghandle(hitobj,'axes')
                    brushObjects=datamanager.getBrushableObjs(this.Axes);
                    datamanager.brushRectangle(this.Axes,brushObjects,...
                    [],[],[],1,[1,0,0],'','');
                end
            end
        end
    end

end
