function contextMenu=setupContextMenus(ax_or_uiaxes,name,is2d)




    ax=findobjinternal(ax_or_uiaxes,'-isa','matlab.graphics.axis.AbstractAxes');
    hFig=ancestor(ax_or_uiaxes,'figure');
    switch name
    case 'zoom'
        contextMenu=matlab.graphics.interaction.webmodes.contextmenus.ZoomInContextMenu(hFig,ax,is2d).contextMenu;
    case 'zoomout'
        contextMenu=matlab.graphics.interaction.webmodes.contextmenus.ZoomOutContextMenu(hFig,ax,is2d).contextMenu;
    case 'pan'
        contextMenu=matlab.graphics.interaction.webmodes.contextmenus.PanContextMenu(hFig,ax,is2d).contextMenu;
    case 'rotate'
        contextMenu=matlab.graphics.interaction.webmodes.contextmenus.RotateContextMenu(hFig,ax,is2d).contextMenu;
    case 'brush'
        contextMenu=[];
    end

end
