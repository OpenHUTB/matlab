function param=quantizedMaxpoolParams(this,WL,param,previousLayerParam,layer,mapObjOutputExp)




    if(~(WL==1)&&isa(layer,'nnet.cnn.layer.MaxPooling2DLayer'))
        prevLayer=previousLayerParam.phase;
        param.ExpData=mapObjOutputExp(prevLayer);


        param.rescaleExp=mapObjOutputExp(prevLayer);
        param.OutputExpData=mapObjOutputExp(layer.Name);
        param.avgMultiplier=1;
    end

end
