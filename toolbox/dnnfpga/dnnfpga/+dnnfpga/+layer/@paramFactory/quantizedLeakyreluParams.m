function previousLayerParam=quantizedLeakyreluParams(this,WL,previousLayerParam,layer,mapObjInputExp,mapObjOutputExp)




    if(~(WL==1)&&isa(layer,'nnet.cnn.layer.LeakyReLULayer'))
        ExpScale=strcat(layer.Name,'_Parameter');
        previousLayerParam.reLUScaleExp=mapObjInputExp(ExpScale);
        if(any(strcmpi(previousLayerParam.type,{'FPGA_FC'})))
            quantScale=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(layer.Scale,previousLayerParam.reLUScaleExp);
            previousLayerParam.reLUValue=quantScale;
            previousLayerParam.OutputExpData=mapObjOutputExp(layer.Name);
        else


            previousLayerParam.reLUValue=layer.Scale;
            previousLayerParam.OutputExpData=mapObjOutputExp(layer.Name);
        end
    end

end

