function[inputLayers,outputLayers]=getIOLayers(dlobj)

    layers=dlobj.Layers;

    layerNameToLayerMap=containers.Map;
    for i=1:numel(layers)
        layerNameToLayerMap(layers(i).Name)=layers(i);
    end
    inputLayers=cellfun(@(layerName)layerNameToLayerMap(layerName),dlobj.InputNames,'UniformOutput',false);
    formattedNames=cell(1,numel(dlobj.OutputNames));
    for i=1:numel(dlobj.OutputNames)
        name=strsplit(dlobj.OutputNames{i},'/');
        formattedNames{i}=name{1};
    end
    formattedNames=unique(formattedNames,'stable');
    outputLayers=cellfun(@(layerName)layerNameToLayerMap(layerName),formattedNames,'UniformOutput',false);