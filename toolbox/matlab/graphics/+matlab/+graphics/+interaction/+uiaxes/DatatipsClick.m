classdef DatatipsClick<matlab.graphics.interaction.uiaxes.DataTipsBase



    properties
eventClickName
pinnedTip
    end
    properties(Constant)

        BUFFER_TO_PIN=8;
    end

    methods
        function hObj=DatatipsClick(ax,objectListenerTarget,eventClickName,hTipProvider)
            hObj=hObj@matlab.graphics.interaction.uiaxes.DataTipsBase(ax,objectListenerTarget,'',...
            '','','');

            hObj.dataTipStyle=matlab.graphics.shape.internal.util.PointDataTipStyle.MarkerAndTip;
            hObj.eventClickName=eventClickName;
            hObj.DataTipProvider=hTipProvider;


        end

        function attachListeners(hObj,~,canvas)
            hObj.attachListeners@matlab.graphics.interaction.uiaxes.DataTipsBase([],canvas);
            hObj.clickEvent(hObj.objectListenerTarget);
        end



        function clickEvent(hObj,objectListenerTarget)
            fig=ancestor(hObj.Axes,'figure');
            if isempty(fig)
                return;
            end

            if matlab.uitools.internal.uimode.isLiveEditorFigure(fig)


                return
            end


            if isequal(objectListenerTarget,fig)




                objectListenerTarget=matlab.graphics.interaction.uiaxes.ClickEvent...
                (fig,'WindowMousePress','WindowMouseRelease');
                objectListenerTarget.enable();
            end
            hObj.listeners.Click=event.listener(objectListenerTarget,hObj.eventClickName,@(o,e)hObj.ClickToShowDatatip(o,e));
        end

        function ClickToShowDatatip(hObj,o,e)



            if~strcmp(e.SelectionType,'normal')||~hObj.validate(o,e)



                return;
            end

            fig=ancestor(hObj.Axes,'figure');

            hit=hObj.getHitObject(e.HitObject);
            if isempty(hit)
                return;
            end

            hObj.DataTipProvider.set(hObj.createDatatips(hit,e));
            hObj.showDatatip(o,e);



            if~isempty(hObj.DataTipProvider.get())&&isvalid(hObj.DataTipProvider.get())
                dist=0;
                if~isempty(hObj.pixelPointEnter)
                    dist=hObj.getDistance(e);
                end
                if hObj.isTipInteractionEnabled(hObj.DataTipProvider.get())&&dist<matlab.graphics.interaction.uiaxes.DatatipsClick.BUFFER_TO_PIN
                    hObj.DataTipProvider.get().PinnedView='on';
                    if matlab.ui.internal.isUIFigure(fig)
                        hObj.pinnedTip=hObj.DataTipProvider.get();
                    end
                end
            end



            if~isempty(hObj.pinnedTip)&&isvalid(hObj.pinnedTip)
                hObj.pinnedTip.setParentToMiddleLayer(fig);
            end

            if matlab.ui.internal.isUIFigure(fig)
                hObj.DataTipProvider.set([]);
            end


            matlab.graphics.datatip.internal.generateDataTipLiveCode(hObj.pinnedTip,...
            matlab.internal.editor.figure.ActionID.DATATIP_ADDED);
        end



        function showDatatip(hObj,o,e)
            if~hObj.validate(o,e)
                return;
            end



            if~isempty(hObj.DataTipProvider.get())&&isvalid(hObj.DataTipProvider.get())


                if hObj.isTipInteractionEnabled(hObj.DataTipProvider.get())&&isprop(hObj,'eventClickName')&&strcmpi(e.EventName,hObj.eventClickName)
                    hObj.DataTipProvider.get().PinnedView='on';
                    fig=ancestor(hObj.Axes,'figure');
                    if matlab.ui.internal.isUIFigure(fig)
                        hObj.pinnedTip=hObj.DataTipProvider.get();
                    end
                end
            end
        end
    end
end
