function toggleAxesLayoutManager(fig,ax,tf)


    for i=1:numel(ax)
        if isa(ax(i).Parent,'matlab.graphics.layout.Layout')
            ax(i).CausesLayoutUpdate=tf;
        end
        if isprop(ax(i),'LayoutManager')
            lm=ax(i).LayoutManager;
            if~isempty(lm)&&isvalid(lm)
                lm.enableAxesDirtyListeners(tf);
            end
        end
    end


    if ishandle(fig)
        subplot_appdata=getappdata(fig,'SubplotListenersManager');
        if~isempty(subplot_appdata)
            if tf
                subplot_appdata.enable;
            else
                subplot_appdata.disable;
            end
        end
    end