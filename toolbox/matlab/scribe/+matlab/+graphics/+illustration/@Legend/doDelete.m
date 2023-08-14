function doDelete(hObj)



    hax=hObj.Axes;

    if~isempty(hax)

        matlab.graphics.illustration.internal.updateLegendMenuToolbar([],[],hObj);








        if isprop(hax,'Legend')
            hax.setLegendExternal([]);
        end
        if isprop(hax,'CollectLegendableObjects')
            hax.CollectLegendableObjects='off';
        end
    end
