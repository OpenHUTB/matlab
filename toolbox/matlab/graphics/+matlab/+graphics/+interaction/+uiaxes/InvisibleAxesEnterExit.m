classdef InvisibleAxesEnterExit<handle


    properties(Constant)
        AXESTEMPSTORAGE='InvisibleAxesEnterExitListener';
    end

    properties(SetAccess=private)
        Axes{mustBe_matlab_graphics_axis_AbstractAxes};
        Canvas matlab.graphics.primitive.canvas.JavaCanvas;
        MouseMotionListener;
        MouseExitedListener;
        InteractionsEnabledListener;
        Enabled=false;




        LastMousePosition=[-1,-1];
    end

    methods
        function hObj=InvisibleAxesEnterExit(ax)
            hObj.Axes=ax;
        end

        function enable(hObj)
            hObj.Canvas=ancestor(hObj.Axes,'matlab.graphics.primitive.canvas.JavaCanvas','node');
            hObj.MouseMotionListener=event.listener(ancestor(hObj.Axes,'figure'),'WindowMouseMotion',@(~,eventData)hObj.mouseMotionCallback(eventData));
            hObj.MouseExitedListener=event.listener(hObj.Canvas,'ButtonExited',@(e,d)@(~,~)hObj.canvasExited);
            hObj.InteractionsEnabledListener=event.proplistener(hObj.Axes.InteractionContainer,...
            hObj.Axes.InteractionContainer.findprop('Enabled_I'),'PreSet',@(e,d)hObj.interactionsHandler(d));

            hObj.Enabled=true;




            prop=findprop(hObj.Axes,matlab.graphics.interaction.uiaxes.InvisibleAxesEnterExit.AXESTEMPSTORAGE);
            if~isempty(prop)
                hObj.Axes.InvisibleAxesEnterExitListener=[];
                delete(prop);
            end
        end

        function hObj=disable(hObj)
            hObj.MouseMotionListener=[];
            hObj.MouseExitedListener=[];
            hObj.InteractionsEnabledListener=[];
            hObj.Enabled=false;
        end
    end

    methods(Hidden)

        function mouseMotionCallback(hObj,e)


            li=hObj.Axes.GetLayoutInformation();
            axesPosition=li.PlotBox;


            wasInside=axesPosition(1)<=hObj.LastMousePosition(1)&&axesPosition(1)+axesPosition(3)>=hObj.LastMousePosition(1)&&...
            axesPosition(2)<=hObj.LastMousePosition(2)&&axesPosition(2)+axesPosition(4)>=hObj.LastMousePosition(2);
            isInside=axesPosition(1)<=e.Point(1)&&axesPosition(1)+axesPosition(3)>=e.Point(1)&&...
            axesPosition(2)<=e.Point(2)&&axesPosition(2)+axesPosition(4)>=e.Point(2);

            hObj.LastMousePosition=e.Point;




            if~isequal(e.HitObject,ancestor(hObj.Axes,'figure'))
                anc=ancestor(e.HitObject,'matlab.graphics.primitive.canvas.JavaCanvas','node');
                if isempty(anc)||~eq(hObj.Canvas,anc)
                    hObj.LastMousePosition=[NaN,NaN];
                    isInside=false;
                end
            end




            if~isequal(wasInside,isInside)
                if wasInside
                    direction='mouseleave';
                else
                    direction='mouseenter';
                end
                eventData=matlab.graphics.controls.internal.InvisibleAxesEnterExitEventData(hObj.Axes,e.HitPrimitive,direction);
                hObj.Canvas.notify('ButtonMotion',eventData);
            end
        end

        function canvasExited(hObj)


            hObj.LastMousePosition=[NaN,NaN];
            eventData=matlab.graphics.controls.internal.InvisibleAxesEnterExitEventData(hObj.Canvas,[],'mouseleave');
            hObj.Canvas.notify('ButtonMotion',eventData);
        end

        function interactionsHandler(hObj,e)






            if strcmp(e.AffectedObject.Enabled_I,'on')
                if~isprop(hObj.Axes,matlab.graphics.interaction.uiaxes.InvisibleAxesEnterExit.AXESTEMPSTORAGE)
                    p=addprop(hObj.Axes,matlab.graphics.interaction.uiaxes.InvisibleAxesEnterExit.AXESTEMPSTORAGE);
                    p.Transient=true;
                    p.Hidden=true;
                end
                hObj.Axes.InvisibleAxesEnterExitListener=hObj;
            elseif isprop(hObj.Axes,matlab.graphics.interaction.uiaxes.InvisibleAxesEnterExit.AXESTEMPSTORAGE)&&...
                strcmp(e.AffectedObject.Enabled_I,'off')

                hObj.Axes.InvisibleAxesEnterExitListener=[];
            end
        end
    end
end



function mustBe_matlab_graphics_axis_AbstractAxes(input)
    if~isa(input,'matlab.graphics.axis.AbstractAxes')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropSetClsMismatch','%s',message('MATLAB:type:PropSetClsMismatch','matlab.graphics.axis.AbstractAxes').getString));
    end
end
