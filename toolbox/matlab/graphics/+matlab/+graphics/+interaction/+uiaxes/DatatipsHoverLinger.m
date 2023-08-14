classdef DatatipsHoverLinger<matlab.graphics.interaction.uiaxes.DataTipsBase




    properties


        isWeb=false
    end


    methods
        function hObj=DatatipsHoverLinger(ax,objectListenerTarget,eventMoveName,...
            eventDisableName,eventEnableName,eventScrollName,hTipProvider)
            hObj=hObj@matlab.graphics.interaction.uiaxes.DataTipsBase(ax,objectListenerTarget,eventMoveName,...
            eventDisableName,eventEnableName,eventScrollName);
            hObj.DataTipProvider=hTipProvider;


        end
    end

    methods(Hidden)


        function attachListeners(hObj,~,canvas)
            hObj.attachListeners@matlab.graphics.interaction.uiaxes.DataTipsBase([],canvas);
            if~isempty(hObj.linger)
                hObj.listeners.Linger=event.listener(hObj.linger,'LingerOverObject',@(o,e)hObj.showDatatip(o,e));
            end
        end


        function showDatatip(hObj,o,e)
            if~hObj.validate(o,e)
                return;
            end
            hitObject=hObj.getHitObject(e.HitObject);
            if~isempty(hitObject)
                if isempty(hObj.DataTipProvider.get())||~isvalid(hObj.DataTipProvider.get())
                    hObj.dataTipStyle=matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerAndTip;
                    hObj.DataTipProvider.set(hObj.createDatatips(hitObject,e));
                else
                    h=hObj.DataTipProvider.get();
                    h.DataTipStyle=matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerAndTip;
                end
                hObj.buffer=15;
            end

        end

        function createOnLingerEnter(hObj,hitObject,e)

            if isa(hObj.Axes,'matlab.graphics.axis.Axes')&&hObj.isWeb&&isSnapToVertex(hObj.Axes)&&...
                (isa(hitObject,'matlab.graphics.chart.primitive.Line')||...
                isa(hitObject,'matlab.graphics.primitive.Line')||...
                isa(hitObject,'matlab.graphics.chart.primitive.Surface'))


                return
            end

            hObj.dataTipStyle=matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerOnly;
            hObj.DataTipProvider.set(hObj.createDatatips(hitObject,e));
        end


    end
end

function snap=isSnapToVertex(hObj)
    snap=matlab.graphics.interaction.getSnapToDataVertex(hObj);
    snap=strcmpi(snap,'on');
end




