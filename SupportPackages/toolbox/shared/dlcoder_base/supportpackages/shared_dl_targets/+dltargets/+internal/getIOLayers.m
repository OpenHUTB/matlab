function [ inputLayers, outputLayers ] = getIOLayers( dlobj )
arguments
    dlobj( 1, 1 ){ mustBeA( dlobj, [ "dlnetwork", "SeriesNetwork", "DAGNetwork" ] ) }
end

layers = dlobj.Layers;

layerNameToLayerMap = containers.Map;
for i = 1:numel( layers )
    layerNameToLayerMap( layers( i ).Name ) = layers( i );
end

inputLayerNames = iStripPortNames( dlobj.InputNames );
outputLayerNames = iStripPortNames( dlobj.OutputNames );

inputLayerNames = unique( inputLayerNames, 'stable' );
inputLayers = cellfun( @( layerName )layerNameToLayerMap( layerName ), inputLayerNames, 'UniformOutput', false );

outputLayerNames = unique( outputLayerNames, 'stable' );
outputLayers = cellfun( @( layerName )layerNameToLayerMap( layerName ), outputLayerNames, 'UniformOutput', false );
end

function layerNames = iStripPortNames( layerNameAndPortNames )
layerNames = cell( 1, numel( layerNameAndPortNames ) );
for i = 1:numel( layerNameAndPortNames )
    name = strsplit( layerNameAndPortNames{ i }, '/' );
    layerNames{ i } = name{ 1 };
end
end


