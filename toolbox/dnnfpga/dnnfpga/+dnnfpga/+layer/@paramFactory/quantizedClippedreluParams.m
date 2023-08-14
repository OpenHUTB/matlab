function previousLayerParam=quantizedClippedreluParams(this,WL,previousLayerParam,layer,mapObjOutputExp)




    if(~(WL==1)&&isa(layer,'nnet.cnn.layer.ClippedReLULayer'))
        if(any(strcmpi(previousLayerParam.type,{'FPGA_FC'})))
            reLUScaleExp=previousLayerParam.rescaleExp;
            quantScale=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(layer.Ceiling,reLUScaleExp);
            previousLayerParam.reLUValue=quantScale;
            previousLayerParam.OutputExpData=mapObjOutputExp(layer.Name);

        else
            previousLayerParam.reLUValue=layer.Ceiling;
            previousLayerParam.OutputExpData=mapObjOutputExp(layer.Name);








            previousLayerParam.reLUScaleExp=mapObjOutputExp(layer.Name);
        end
    end

end
