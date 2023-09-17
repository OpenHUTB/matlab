function names=basemapNames
    folder=fullfile(toolboxdir('geoweb'),'geoweb','scripts','OpenLayers');
    filename=fullfile(folder,'webmap_config.xml');

    config=map.webmap.internal.readLayerConfiguration(filename);
    names=string({config.XYZLayer.LayerName})';


