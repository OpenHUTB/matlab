function obj=initializeLayers(obj)





%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    numLayers=coder.const(@feval,'getNumLayers',obj.DLCustomCoderNetwork);
    numTunableLayers=coder.const(@feval,'getNumTunableLayers',obj.DLCustomCoderNetwork);

    tunableLayers=cell(1,numTunableLayers);

    tunableLayerCount=0;

    tunableLayerIndices=zeros(1,numTunableLayers);
    isLayerTunable=false(1,numLayers);

    for iLayer=coder.unroll(1:numLayers)
        layer=coder.const(@feval,'getLayer',obj.DLCustomCoderNetwork,iLayer);


        propertiesAndFiles=coder.const(@feval,'getLayerToPropertyFiles',...
        obj.DLCustomCoderNetwork,layer.Name);




        numProperties=size(propertiesAndFiles,2);



        if numProperties>0
            tunableLayerCount=tunableLayerCount+1;
            for iProp=coder.unroll(1:numProperties)
                layer.(propertiesAndFiles{1,iProp})=coder.internal.read(propertiesAndFiles{2,iProp});
            end
            tunableLayers{tunableLayerCount}=layer;
            tunableLayerIndices(tunableLayerCount)=iLayer;
            isLayerTunable(iLayer)=true;
        end
    end

    obj.TunableLayers=tunableLayers;
    obj.TunableLayerIndices=tunableLayerIndices;
    obj.IsLayerTunable=isLayerTunable;

end
