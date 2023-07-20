function param=quantizedGroupconvParams(this,WL,param,layer,fiMath)




    if(isequal(class(layer),'nnet.cnn.layer.GroupedConvolution2DLayer')&&~(WL==1))



        if((layer.NumFiltersPerGroup==1)&&(layer.NumChannelsPerGroup==1))
            [param.weights,param.ExpWeights]=dnnfpga.processorbase.processorUtils.singleToInt8ConversionCW(param,layer.Weights,8);
        else
            param.weights=dnnfpga.processorbase.processorUtils.singleToInt8Conversion(param,layer.Weights,param.ExpWeights);
        end


        if((layer.NumFiltersPerGroup==1)&&(layer.NumChannelsPerGroup==1))
            [unadjustedbias,param.ExpBias]=dnnfpga.processorbase.processorUtils.singleToInt8ConversionCW(param,layer.Bias,32);

            param.bias=unadjustedbias;
            [numChannels,numGroups]=dnnfpga.processorbase.processorUtils.getNumChannels(unadjustedbias);
            for grp=0:numGroups-1
                for idx=1:numChannels
                    input=dnnfpga.processorbase.processorUtils.getInput(unadjustedbias,idx,grp);
                    output=int32(single(input)*2^single(param.ExpBias(grp*numChannels+idx)-param.rescaleExp(grp*numChannels+idx)));
                    param.bias=dnnfpga.processorbase.processorUtils.writeOutput(param.bias,idx,grp,output);
                end
            end
        else
            bfpData=dlquantization.BlockFloatingPoint((layer.Bias(:)),32);
            param.ExpBias=double(bfpData.getExponent);
            unadjustedbias=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(layer.Bias,param.ExpBias);
            param.bias=int32(single(unadjustedbias)*2^single(param.ExpBias-param.rescaleExp));
        end
        param.fiMath=fiMath;

    end

end

