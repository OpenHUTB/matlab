function doDelete(hObj)



    hax=hObj.Axes;

    if~isempty(hax)

        matlab.graphics.illustration.internal.updateLegendMenuToolbar([],[],hObj);








        if isprop(hax,'Colorbar')
            hax.setColorbarExternal([]);
        end
    end