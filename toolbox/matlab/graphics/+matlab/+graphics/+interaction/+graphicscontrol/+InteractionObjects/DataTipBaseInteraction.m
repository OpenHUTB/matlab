classdef DataTipBaseInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase




    properties(Hidden)
Canvas
DataTipInteraction
hAxes
        hitObject=[]

    end

    methods
        function this=DataTipBaseInteraction(canvas,ax,dataTipInteraction)
            this.Type='datatip';
            this.Canvas=canvas;
            this.hAxes=ax;
            this.Object=ax;
            this.DataTipInteraction=dataTipInteraction;
            this.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.DataTip;
        end

        function response(this,eventData)



            clientX=eventData.figx;
            clientY=eventData.figy;

            hFig=ancestor(this.Canvas,'figure');



            if isempty(this.hitObject)
                for k=1:length(eventData.hitObjectIds)
                    object=this.Canvas.getHitObject(eval(sprintf('int64(%s)',eventData.hitObjectIds{k})));
                    if isa(object,'matlab.graphics.axis.AbstractAxes')
                        this.hitObject=object;
                    end
                    hit=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(object);




                    if~isempty(hit)&&~(isa(hit,'matlab.graphics.mixin.GraphicsPickable')&&hit.HitTest=="off")
                        this.hitObject=object;
                        break;
                    end
                end
            end



            datatipsEventData=matlab.graphics.interaction.graphicscontrol.InteractionObjects.DatatipsEventData...
            (this.hitObject,clientX,clientY,hFig.SelectionType);

            this.hitObject=[];
            this.handleEvent(eventData.name,datatipsEventData)
        end
    end

    methods(Abstract)
        handleEvent(hObj,eventName,eventData)%#ok<INUSD>
    end
end

