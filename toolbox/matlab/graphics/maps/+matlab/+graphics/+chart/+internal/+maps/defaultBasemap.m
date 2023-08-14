function basemap=defaultBasemap








    manager=matlab.graphics.chart.internal.maps.BaseLayerConfigurationManager.instance();
    basemap=char(manager.DefaultBasemap);
end
