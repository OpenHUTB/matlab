function iconFilenames=basemapIcons









    selector=matlab.graphics.chart.internal.maps.BaseLayerSelector;
    basemapNames=selector.BaseLayers;
    basemapFilenames=basemapNames+".png";

    folder=fullfile(toolboxdir('shared'),'basemaps','resources','icons');
    iconFilenames=fullfile(folder,basemapFilenames);

    customBasemapNames=selector.CustomBaseLayers;
    customIconFilenames=arrayfun(@map.internal.basemaps.addCustomBasemapIcon,...
    customBasemapNames);

    iconFilenames=[iconFilenames;customIconFilenames];
end

