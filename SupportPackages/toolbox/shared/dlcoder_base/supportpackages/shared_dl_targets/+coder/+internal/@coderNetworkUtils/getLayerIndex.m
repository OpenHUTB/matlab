%#codegen









function[layerid,opPortid]=getLayerIndex(net,layerarg)




    if ischar(layerarg)

        [strs,~]=split(layerarg,'/');
        assert(iscell(strs));
        layername=strs{1};
        layerid=coder.internal.coderNetworkUtils.getLayerId(net,layername);
        layer=net.Layers(layerid);
        iValidateLayerArg(layer,strs);
        if numel(strs)==1



            opPortid=1;
        else
            portname=strs{2};



            isMaxPoolAndPortSizeOrIndices=isa(layer,'nnet.cnn.layer.MaxPooling2DLayer')&&...
            (strcmpi(portname,'size')||strcmpi(portname,'indices'));


            isSequenceFoldingAndPortMiniBatchSize=isa(layer,'nnet.cnn.layer.SequenceFoldingLayer')&&...
            strcmpi(portname,'miniBatchSize');

            if isMaxPoolAndPortSizeOrIndices||isSequenceFoldingAndPortMiniBatchSize
                error(message('dlcoder_spkg:cnncodegen:unsupported_portname',portname,layer.Name));
            end
            opPortid=coder.internal.coderNetworkUtils.getPortNum(layer,portname);
        end
    else


        assert(isnumeric(layerarg));
        layerid=layerarg;
        opPortid=1;
    end

end

function iValidateLayerArg(layer,strs)
    ilayer=nnet.cnn.layer.Layer.getInternalLayers(layer);
    ilayer=ilayer{1};
    numOutputs=numel(ilayer.OutputNames);
    if(numOutputs>1)&&(numel(strs)==1)
        if iLayerHasMultipleOutputs(layer)
            error(message('dlcoder_spkg:cnncodegen:MustSpecifyOutputForMultipleOutputLayer',layer.Name));
        end
    end
end


function tf=iLayerHasMultipleOutputs(layer)
    isCustomMimoLayer=isa(layer,'nnet.layer.Layer')&&layer.NumOutputs>1;
    isMaxPoolWithUnpooling=isa(layer,'nnet.cnn.layer.MaxPooling2DLayer')&&layer.HasUnpoolingOutputs;
    tf=isCustomMimoLayer||isMaxPoolWithUnpooling;
end
