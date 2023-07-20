classdef ZoomInContextMenu<matlab.graphics.interaction.webmodes.contextmenus.BaseModeContextMenu




    methods
        function this=ZoomInContextMenu(this,ax,is2d)
            props_context.Parent=ancestor(ax,'figure');
            props_context.Serializable='off';
            props_context.Internal=true;
            this.contextMenu=uicontextmenu(props_context);
            m1=uimenu(this.contextMenu,'Text','Restore View','Serializable','off');
            m1.MenuSelectedFcn=@(src,evt)this.ModeResetPlotView(ax);
        end
    end
end
