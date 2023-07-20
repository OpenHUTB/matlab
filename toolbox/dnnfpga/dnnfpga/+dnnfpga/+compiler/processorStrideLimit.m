function[poolSizeLimit]=processorStrideLimit(processor)





    getBCC=processor.getBCC();

    switch(class(processor))
    case{'dnnfpga.processorbase.conv2Processor'}
        poolSizeLimit=getBCC.strideModeWLimit;
    case{'dnnfpga.processorbase.cnn2Processor'}
        poolSizeLimit=getBCC.conv.strideModeWLimit;
    case{'dnnfpga.processorbase.cnn4Processor','dnnfpga.processorbase.cnn5Processor'}
        poolSizeLimit=getBCC.convp.conv.strideModeWLimit;
    case{'dnnfpga.processorbase.conv4Processor','dnnfpga.processorbase.conv5Processor'}
        poolSizeLimit=getBCC.conv.strideModeWLimit;
    otherwise
        poolSizeLimit=12;
    end
end