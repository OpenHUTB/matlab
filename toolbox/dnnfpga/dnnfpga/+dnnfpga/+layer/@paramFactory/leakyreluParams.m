function previousLayerParam=leakyreluParams(this,layer,previousLayerParam)




    if(isa(layer,'nnet.cnn.layer.LeakyReLULayer'))
        if(isfield(previousLayerParam,'reLUMode'))
            previousLayerParam.reLUMode=2;
            previousLayerParam.reLUValue=layer.Scale;
        end
    end

end
