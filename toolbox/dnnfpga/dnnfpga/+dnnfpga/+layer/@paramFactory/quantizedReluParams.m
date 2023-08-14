function previousLayerParam=quantizedReluParams(this,WL,previousLayerParam,layer,mapObjOutputExp)




    if(~(WL==1)&&isa(layer,'nnet.cnn.layer.ReLULayer'))
        previousLayerParam.OutputExpData=mapObjOutputExp(layer.Name);
    end

end

