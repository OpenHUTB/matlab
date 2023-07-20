function postMessage()



    color=getappdata(0,'CONNECTOR2_FIGURE_COLOR');
    if~isempty(color)
        set(0,'DefaultFigureColor',color);
    end
