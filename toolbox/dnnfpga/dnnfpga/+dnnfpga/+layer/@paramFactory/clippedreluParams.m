function previousLayerParam=clippedreluParams(this,layer,previousLayerParam)




    if(isa(layer,'nnet.cnn.layer.ClippedReLULayer'))
        if(isfield(previousLayerParam,'reLUMode'))
            previousLayerParam.reLUMode=3;
            previousLayerParam.reLUValue=layer.Ceiling;
        end
    end

end

