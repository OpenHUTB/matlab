
function createOverflowButton(obj)
    if isempty(obj.OverflowButton)

        obj.OverflowButton=matlab.ui.controls.ToolbarPushButton('Parent',obj);
        obj.OverflowButton.Visible_I='off';
        obj.OverflowButton.ButtonPushedFcn=@(e,d)overflowCallback(e,d);
        obj.OverflowButton.Tooltip=matlab.internal.Catalog('MATLAB:uistring:figuretoolbar')...
        .getString('TooltipString_Toolbar_ShowMore');
        obj.OverflowButton.Tag='overflow';
        obj.OverflowButton.Serializable='off';
        obj.OverflowButton.HandleVisibility='off';
        obj.OverflowButton.Internal=true;

        obj.OverflowButton.setOverflowIcon('collapsed');
    end
end


function overflowCallback(source,~)



    obj=source.Parent;

    obj.IsOpen=~obj.IsOpen;

    icon='expanded';
    tooltip='TooltipString_Toolbar_ShowLess';
    vis='on';

    if~obj.IsOpen
        icon='collapsed';
        tooltip='TooltipString_Toolbar_ShowMore';
        vis='off';
    end

    source.setOverflowIcon(icon);
    source.Tooltip=matlab.internal.Catalog('MATLAB:uistring:figuretoolbar')...
    .getString(tooltip);

    obj.OverflowBackground.Visible=vis;

    source.Visible=vis;



    obj.Opacity=obj.Opacity;


    obj.redrawToolbar();
end