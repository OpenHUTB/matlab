function param=quantizedConvparams(this,WL,param,previousLayerParam,layer,mapObjInputExp,mapObjOutputExp,fiMath)




    if(isequal(class(layer),'nnet.cnn.layer.Convolution2DLayer')&&~(WL==1))
        param.WL=WL;
        layerWeightExp=strcat(layer.Name,'_Weights');
        layerBiasExp=strcat(layer.Name,'_Bias');








        param.ExpWeights=mapObjInputExp(layerWeightExp);
        param.ExpBias=mapObjInputExp(layerBiasExp);


        prevLayer=previousLayerParam.phase;
        param.ExpData=mapObjOutputExp(prevLayer);
        keyLayerName=erase(layer.Name,'_insertZeros');
        param.OutputExpData=mapObjOutputExp(keyLayerName);

        param.weights=dnnfpga.layer.scaleToQuant(param,layer.Weights,param.ExpWeights);
        param.rescaleExp=param.ExpData+param.ExpWeights;

        fiMath.SumFractionLength=-param.rescaleExp;
        param.fiMath=fiMath;
        param.WLA=fiMath.SumWordLength;

        param.bias=fi(layer.Bias,1,param.WLA,-param.rescaleExp);

    end

end

