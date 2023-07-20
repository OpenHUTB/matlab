function cleanup=setupModeInteraction(ax_or_uiaxes,can,name,is2d)




    ax=findobjinternal(ax_or_uiaxes,'-isa','matlab.graphics.axis.AbstractAxes');

    interact={};

    switch name
    case 'zoom'
        zoom=matlab.graphics.interaction.graphicscontrol.InteractionObjects.ZoomInteraction(ax);
        interact{end+1}=zoom;

        stepzoom=matlab.graphics.interaction.graphicscontrol.InteractionObjects.StepZoomInteraction;
        stepzoom.Object=ax;
        interact{end+1}=stepzoom;

        pinchzoom=matlab.graphics.interaction.graphicscontrol.InteractionObjects.PinchPanZoomInteraction;
        pinchzoom.Object=ax;
        interact{end+1}=pinchzoom;

        if is2d
            regionzoom=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RegionZoomInteraction;
            regionzoom.Object=ax;
            interact{end+1}=regionzoom;

            regionzoomaffordance=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RegionZoomAffordanceInteraction;
            regionzoomaffordance.Object=ax;
            interact{end+1}=regionzoomaffordance;

            interact{end}.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Zoom;
        else
            limitzoom3d=matlab.graphics.interaction.graphicscontrol.InteractionObjects.LimitZoom3DInteraction(can,ax);
            limitzoom3d.Object=ax;
            interact{end+1}=limitzoom3d;

            interact{end}.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Zoom3d;
        end

        resetplot=matlab.graphics.interaction.graphicscontrol.InteractionObjects.ResetPlotInteraction(ax);
        interact{end+1}=resetplot;
    case 'zoomout'
        zoom=matlab.graphics.interaction.graphicscontrol.InteractionObjects.ZoomInteraction(ax);
        interact{end+1}=zoom;

        pinchzoom=matlab.graphics.interaction.graphicscontrol.InteractionObjects.PinchPanZoomInteraction;
        pinchzoom.Object=ax;
        interact{end+1}=pinchzoom;

        if~is2d
            limitzoom=matlab.graphics.interaction.graphicscontrol.InteractionObjects.LimitZoom3DInteraction(can,ax);
            limitzoom.Object=ax;
            interact{end+1}=limitzoom;
        end

        stepzoom=matlab.graphics.interaction.graphicscontrol.InteractionObjects.StepZoomInteraction;
        stepzoom.DirectionOut=true;
        stepzoom.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.ZoomOut;
        stepzoom.Object=ax;
        interact{end+1}=stepzoom;

        resetplot=matlab.graphics.interaction.graphicscontrol.InteractionObjects.ResetPlotInteraction(ax);
        interact{end+1}=resetplot;

    case 'pan'
        pan=matlab.graphics.interaction.graphicscontrol.InteractionObjects.PanInteraction(ax);
        pan.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Pan;
        interact{end+1}=pan;

        rulerpanx=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RulerPanInteraction(can,ax);
        rulerpanx.Axis='x';
        rulerpanx.Object=ax.XAxis;
        interact{end+1}=rulerpanx;

        if(isscalar(ax.YAxis))
            rulerpany=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RulerPanInteraction(can,ax);
            rulerpany.Axis='y';
            rulerpany.Object=ax.YAxis;

            interact{end+1}=rulerpany;
        else
            rulerpany1=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RulerPanInteraction(can,ax);
            rulerpany1.Axis='y';
            rulerpany1.Object=ax.YAxis(1);

            rulerpany2=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RulerPanInteraction(can,ax);
            rulerpany2.Axis='y';
            rulerpany2.Object=ax.YAxis(2);

            interact{end+1}=rulerpany1;
            interact{end+1}=rulerpany2;
        end

        rulerpanz=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RulerPanInteraction(can,ax);
        rulerpanz.Axis='z';
        rulerpanz.Object=ax.ZAxis;
        interact{end+1}=rulerpanz;

        resetplot=matlab.graphics.interaction.graphicscontrol.InteractionObjects.ResetPlotInteraction(ax);
        interact{end+1}=resetplot;

    case 'rotate'
        rotate=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RotateInteraction(can,ax);
        rotate.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Rotate;
        rotate.Object=ax;
        interact{end+1}=rotate;

        resetplot=matlab.graphics.interaction.graphicscontrol.InteractionObjects.ResetPlotInteraction(ax);
        interact{end+1}=resetplot;

    case 'brush'

        if~isdeployed

            regionbrushaffordance=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RegionZoomAffordanceInteraction;
            regionbrushaffordance.Object=ax;
            regionbrushaffordance.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Zoom;
            regionbrushaffordance.ShowConstrainedROI=false;
            interact{end+1}=regionbrushaffordance;





            brushDragEffects=matlab.graphics.interaction.graphicscontrol.InteractionObjects.BrushDragInteraction(ax);
            brushDragEffects.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Zoom;
            interact{end+1}=brushDragEffects;


            brushClickEffects=matlab.graphics.interaction.graphicscontrol.InteractionObjects.BrushClickInteraction(ax);
            interact{end+1}=brushClickEffects;
            interact{end}.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Zoom;
        end
    end

    for i=interact
        can.InteractionsManager.registerInteraction(ax,i{1});
    end

    interactionsList=matlab.graphics.interaction.internal.WebInteractionsList(can,interact);

    cleanup=onCleanup(@()interactionsList.delete());

end