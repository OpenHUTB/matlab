function initializeView(ax)



    for i=1:numel(ax)
        limits=getappdata(ax(i),'zoom_zoomOrigAxesLimits');
        if isempty(limits)||numel(limits)<6
            limits=matlab.graphics.interaction.internal.calculateOrigLimits(ax(i));
            matlab.graphics.interaction.internal.setOrigLimits(ax(i),limits);
        end
    end
    if isempty(resetplotview(ax,'GetStoredViewStruct'))
        matlab.graphics.interaction.internal.saveView(ax);
    end