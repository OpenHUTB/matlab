function[dataType,status]=processorKernelType(processor)






    getBCCKernelType=processor.getBCC();

    switch(class(processor))
    case{'dnnfpga.processorbase.cnn4Processor'}
        dataType.dataTypeConv=getBCCKernelType.convp.conv.kernelDataType;
        dataType.dataTypeFC=getBCCKernelType.fcp.kernelDataType;
        dataType.dataTypeAdd='';
    case{'dnnfpga.processorbase.conv4Processor'}
        dataType.dataTypeConv=getBCCKernelType.conv.kernelDataType;
        dataType.dataTypeFC='';
        dataType.dataTypeAdd='';




    case{'dnnfpga.processorbase.cnn5Processor'}
        dataType.dataTypeConv=getBCCKernelType.convp.conv.kernelDataType;
        dataType.dataTypeFC=getBCCKernelType.fcp.kernelDataType;
        dataType.dataTypeAdd=getBCCKernelType.addp.kernelDataType;
    case{'dnnfpga.processorbase.conv5Processor'}
        dataType.dataTypeConv=getBCCKernelType.convp.conv.kernelDataType;
        dataType.dataTypeFC='';
        dataType.dataTypeAdd='';
    case{'dnnfpga.processorbase.fc5Processor'}
        dataType.dataTypeConv='';
        dataType.dataTypeFC=getBCCKernelType.fcp.kernelDataType;
        dataType.dataTypeAdd='';
    case{'dnnfpga.processorbase.adderProcessor'}
        dataType.dataTypeConv='';
        dataType.dataTypeFC='';
        dataType.dataTypeAdd=getBCCKernelType.kernelDataType;
    otherwise
        dataType.dataTypeConv='';
        dataType.dataTypeFC='';
        dataType.dataTypeAdd='';
    end

    status=(strcmpi(dataType.dataTypeConv,'int8')|strcmpi(dataType.dataTypeFC,'int8')|strcmpi(dataType.dataTypeAdd,'int8'));

end


