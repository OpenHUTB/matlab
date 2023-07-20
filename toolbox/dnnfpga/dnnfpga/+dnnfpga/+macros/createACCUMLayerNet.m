function net=createACCUMLayerNet(layer,~)

    function prefixed=addPrefix(name)
        prefixed=[layer.Name,'.',name];
    end

    sz=layer.InputSize;

    sz=[1,1,sz];


    inLayer=imageInputLayer(sz,'Name',addPrefix('in'),'Normalization','none');
    stateReadLayer=imageInputLayer(sz,'Name',addPrefix('state__Read'),'Normalization','none');
    addLayer=additionLayer(2,'Name',addPrefix('add'));
    stateWriteLayer=regressionLayer('Name',addPrefix('state__Write'));
    fcLayer=fullyConnectedLayer(6,'Name',addPrefix('fc'));
    outLayer=regressionLayer('Name',addPrefix('out'));


    lgraph=layerGraph([inLayer,addLayer,outLayer]);
    lgraph=addLayers(lgraph,stateReadLayer);
    lgraph=addLayers(lgraph,stateWriteLayer);
    lgraph=connectLayers(lgraph,addPrefix('state__Read'),addPrefix('add/in2'));
    lgraph=connectLayers(lgraph,addPrefix('add'),addPrefix('state__Write'));

    net=assembleNetwork(lgraph);
end
