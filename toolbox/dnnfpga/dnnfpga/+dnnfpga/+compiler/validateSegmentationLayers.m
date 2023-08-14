function validateSegmentationLayers(processor,net)




    layers=net.Layers;
    bcc=processor.getBCC();
    unpoolStrideLimit=bcc.convp.conv.origOpWLimit;
    convPaddingLimit=bcc.convp.conv.paddingModeWLimit;
    for i=1:numel(layers)
        if isa(layers(i),'nnet.cnn.layer.TransposedConvolution2DLayer')



            dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForFilterSize(layers(i).FilterSize,layers(i).Name,1,convPaddingLimit);

            dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSupportedStride(layers(i).Stride(1),layers(i).Name,max(unpoolStrideLimit));

            dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSymmetricStride(layers(i).Stride(1),layers(i).Stride(2),layers(i).Name);


        elseif isa(layers(i),'nnet.cnn.layer.MaxPooling2DLayer')&&layers(i).HasUnpoolingOutputs

            mLayer=layers(i);

            dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForFilterSize(mLayer.PoolSize,mLayer.Name,2,3);

            if any(mLayer.PoolSize~=mLayer.Stride)
                error(message('dnnfpga:dnnfpgacompiler:UnsupportedStrideAndFilterSize',mLayer.Name));
            end

            if any(mLayer.PaddingSize~=[0,0,0,0])
                error(message('dnnfpga:dnnfpgacompiler:PaddingUnsupported',mLayer.Name));
            end
        elseif isa(layers(i),'nnet.cnn.layer.MaxUnpooling2DLayer')
            uLayer=layers(i);

            datatype=dnnfpga.compiler.processorKernelType(processor);
            if~strcmpi(datatype.dataTypeConv,'single')
                error(message('dnnfpga:dnnfpgacompiler:UnsupportedDataTypeForLayer',uLayer.Name));
            end
        end
    end
end
