function param=quantizedAveragepoolParams(this,WL,param,layer)




    if(~(WL==1)&&isa(layer,'nnet.cnn.layer.AveragePooling2DLayer'))
        avgMultiplier=1/(param.origOpSizeValue(1)*param.origOpSizeValue(2));
        multiplierExponentName=strcat(layer.Name,'_Parameter');
        avgmultiplierExponent=mapObjInputExp(multiplierExponentName);



        param.avgMultiplier=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(avgMultiplier,avgmultiplierExponent);



        param.rescaleExp=param.rescaleExp+avgmultiplierExponent;
    end

end

