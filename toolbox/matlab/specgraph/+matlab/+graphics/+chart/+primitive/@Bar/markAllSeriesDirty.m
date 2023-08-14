function markAllSeriesDirty(hObj)








    p=matlab.graphics.chart.primitive.bar.internal.getBarPeers(hObj);

    for ix=1:numel(p)



        p(ix).MarkDirty('limits');
    end