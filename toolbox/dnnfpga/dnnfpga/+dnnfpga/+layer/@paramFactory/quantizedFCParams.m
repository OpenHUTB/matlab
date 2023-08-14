function param=quantizedFCParams(this,WL,param,previousLayerParam,layer,mapObjInputExp,mapObjOutputExp,fiMath)




    if(~(WL==1))
        layerWeightExp=strcat(layer.Name,'_Weights');
        layerBiasExp=strcat(layer.Name,'_Bias');

        param.ExpWeights=mapObjInputExp(layerWeightExp);
        param.ExpBias=mapObjInputExp(layerBiasExp);

        prevLayer=previousLayerParam.phase;

        param.ExpData=mapObjOutputExp(prevLayer);
        param.OutputExpData=mapObjOutputExp(layer.Name);
        param.rescaleExp=param.ExpData+param.ExpWeights;



        Weights=dnnfpga.layer.scaleToQuant(param,layer.Weights,param.ExpWeights);

        fiMath.SumFractionLength=-param.rescaleExp;
        param.fiMath=fiMath;
        param.WLA=fiMath.SumWordLength;








        Bias=fi(layer.Bias,1,param.WLA,-param.ExpWeights);

        [importedOp,importedBias]=dnnfpga.processorbase.fcProcessor.importOperator(Weights,Bias);
        param.weights=importedOp';
        param.bias=importedBias;
    end


end

