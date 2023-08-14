function toggleMode(obj,name,val)


    can=ancestor(obj,'matlab.graphics.primitive.canvas.Canvas','node');

    switch lower(val)
    case 'on'
        enablemode(obj,can,name);
    case 'off'
        disablemode(obj,can,name);
    case 'toggle'
        togglemode(obj,can,name);
    case 'noaction'
    end

end

function enablemode(obj,can,name)
    is2dim=is2D(obj);
    obj.InteractionContainer.clearList;
    fig=localGetFigure(obj);



    import matlab.internal.editor.figure.*;
    if~(FigureUtils.isEditorEmbeddedFigure(fig)||...
        FigureUtils.isEditorSnapshotFigure(fig))
        setModeContextMenu(obj,matlab.graphics.interaction.webmodes.contextmenus.setupContextMenus(obj,name,is2dim));
    end

    obj.InteractionContainer.CurrentMode=name;
    obj.InteractionContainer.List=matlab.graphics.interaction.webmodes.setupModeInteraction(obj,can,name,is2dim);
    matlab.graphics.interaction.keyboardinteraction.addKeyListeners(fig);
end

function disablemode(obj,can,name)

    if strcmp(obj.InteractionContainer.CurrentMode,name)
        obj.InteractionContainer.clearList;
        obj.InteractionContainer.CurrentMode='none';
        obj.InteractionContainer.Canvas=can;
        obj.InteractionContainer.updateInteractions();
        fig=localGetFigure(obj);
        matlab.graphics.interaction.keyboardinteraction.removeKeyListeners(fig);
        if isprop(obj,'ModeContextMenu')
            if(~isequal(obj.ModeContextMenu,''))
                delete(obj.ModeContextMenu);
            end
            obj.ModeContextMenu=[];
        end
    end

end
function togglemode(obj,can,name)

    if strcmp(obj.InteractionContainer.CurrentMode,name)
        disablemode(obj,can,name);
    else
        enablemode(obj,can,name);
    end
end

function fig=localGetFigure(ax)
    fig=ancestor(ax,'figure');
end

function setModeContextMenu(ax,contextMenu)
    if~isprop(ax,'ModeContextMenu')
        modeMenuProp=addprop(ax,'ModeContextMenu');
        modeMenuProp.Hidden=true;
        modeMenuProp.Transient=true;
    end
    ax.ModeContextMenu=contextMenu;
end
