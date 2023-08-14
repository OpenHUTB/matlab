function xformedNet=symmetrizeStride(net,verbose)












    networkWrapper=dltargets.internal.NetworkInfo(net,[]);







    xformedlgraph=makeStridesSymmetric(networkWrapper,verbose);


    if isa(net,'SeriesNetwork')||isa(net,'DAGNetwork')
        xformedNet=assembleNetwork(xformedlgraph);
    elseif isa(net,'dlnetwork')
        xformedNet=dlnetwork(xformedlgraph);
    end

end







function lgraph=makeStridesSymmetric(networkInfo,verbose)


    lgraph=networkInfo.SortedLayerGraph;


    layerInfoMap=networkInfo.LayerInfoMap;


    for i=1:numel(lgraph.Layers)
        layer=lgraph.Layers(i);


        isConv=false;
        isGroupedConv=false;
        isMaxPool=false;
        switch class(layer)
        case 'nnet.cnn.layer.Convolution2DLayer'
            isConv=true;
        case 'nnet.cnn.layer.GroupedConvolution2DLayer'
            isGroupedConv=true;
        case 'nnet.cnn.layer.MaxPooling2DLayer'
            isMaxPool=true;
        case 'nnet.cnn.layer.AveragePooling2DLayer'

        otherwise
            continue;
        end







        layer=nnet.internal.cnn.layer.util.ExternalInternalConverter.getInternalLayers(layer);
        layer=layer{1};


        stride=layer.Stride;


        if stride(1)==stride(2)
            continue;
        end


        layerName=layer.Name;
        padding=layer.PaddingSize;


        if isConv||isGroupedConv

            filterSize=layer.EffectiveFilterSize;
        else

            filterSize=layer.PoolSize;
        end


        layerInfo=layerInfoMap(layerName);
        inputSize=layerInfo.inputSizes{1};


        paddedImgSize=inputSize(1:2)+[padding(2)+padding(1),padding(4)+padding(3)];


        canSymm=isSymmetricEqual(paddedImgSize,filterSize,stride);


        if~any(canSymm)

            continue
        else
            if canSymm(1)
                stride(1)=stride(2);
            else
                stride(2)=stride(1);
            end


            dnnfpga.disp(message('dnnfpga:dnnfpgadisp:SymmetrizeStride',layerName),1,verbose);
        end


        layer.Stride=stride;


        if isConv
            layer=nnet.cnn.layer.Convolution2DLayer(layer);
        elseif isGroupedConv
            layer=nnet.cnn.layer.GroupedConvolution2DLayer(layer);
        elseif isMaxPool
            layer=nnet.cnn.layer.MaxPooling2DLayer(layer);
        else
            layer=nnet.cnn.layer.AveragePooling2DLayer(layer);
        end


        lgraph=replaceLayer(lgraph,layerName,layer);

    end
end




function canSymmetrize=isSymmetricEqual(imgSize,filterSize,stride)




    maxStride=imgSize-filterSize;


    strideSaturated=maxStride<stride;



    otherStrideSaturates=flip(stride)>maxStride;




    canSymmetrize=strideSaturated&otherStrideSaturates;

end
