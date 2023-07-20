function updatePeersAndMarkAllSeriesDirty(hObj,obj,evd)




    matlab.graphics.chart.primitive.bar.internal.updatePeers(obj,evd);

    markAllSeriesDirty(hObj);