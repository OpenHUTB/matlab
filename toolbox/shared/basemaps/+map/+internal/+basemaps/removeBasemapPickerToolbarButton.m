function removeBasemapPickerToolbarButton(tb)









    try
        children=[tb.Children];
        index=arrayfun(@(c)isappdata(c,"mapbutton_basemap"),children);
        delete(children(index))
    catch e
        throwAsCaller(e)
    end
end


