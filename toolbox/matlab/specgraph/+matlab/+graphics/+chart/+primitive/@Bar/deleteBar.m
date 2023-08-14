function deleteBar(hBar,~,~)


    parent=hBar.Parent;
    if~isscalar(parent)||(isprop(parent,'BeingDeleted')&&parent.BeingDeleted=="on")
        return
    end

    hPeers=matlab.graphics.chart.primitive.bar.internal.getBarPeers(hBar);


    if isempty(hPeers)
        return;
    end

    markAllSeriesDirty(hBar);


    set(hPeers,'NumPeers',numel(hPeers));
