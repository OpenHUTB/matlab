function param=groupconvParams(this,layer,param,processor)




    if(isequal(class(layer),'nnet.cnn.layer.GroupedConvolution2DLayer'))
        if((layer.NumFiltersPerGroup==1)&&(layer.NumChannelsPerGroup==1))
            param.type='FPGA_ConvND';

            filterSizeLimit=dnnfpga.compiler.processorPoolSizeLimit(processor);


            if((layer.FilterSize<=2)|(layer.FilterSize>filterSizeLimit))
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedFilterSize',param.phase,3,filterSizeLimit);
                error(msg);
            end
        end
        [h,w,c,f,g]=size(layer.Weights);
        param.weights=reshape(layer.Weights,[h,w,c,f*g]);
        [h,w,c,g]=size(layer.Bias);
        param.bias=reshape(layer.Bias,[h,w,c*g]);

        param.convSplitMode=layer.NumGroups;

    end
end

