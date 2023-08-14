function sanityChecks(net,cnnp,exponentsData)





    if~isa(cnnp,'dnnfpga.processorbase.cnn5Processor')

        if(~dnnfpga.compiler.canCompileNet(net))
            msg=message('dnnfpga:simulation:InvalidNetwork');
            error(msg);
        end
    end
    validKernelDataTypes={'single','int8','int4'};
    validQuantDataTypes={'int4','int8'};



    dataType=dnnfpga.compiler.processorKernelType(cnnp);
    if(isa(cnnp,'dnnfpga.processorbase.cnn4Processor')||isa(cnnp,'dnnfpga.processorbase.cnn2Processor')...
        ||isa(cnnp,'dnnfpga.processorbase.cnn5Processor'))

        if(~any(strcmpi(dataType.dataTypeConv,validKernelDataTypes)))
            msg=message('dnnfpga:simulation:InvalidDataTypeForConvLayer');
            error(msg);
        end

        if(~any(strcmpi(dataType.dataTypeFC,validKernelDataTypes)))
            msg=message('dnnfpga:simulation:InvalidDataTypeForFCLayer');
            error(msg);
        end


        if(strcmpi(dataType.dataTypeConv,'single')&&any(strcmpi(dataType.dataTypeFC,validQuantDataTypes)))
            msg=message('dnnfpga:quantization:UnsupportedDataTypeCombination');
            error(msg);
        end
    end


    if(any(strcmpi(dataType.dataTypeConv,validQuantDataTypes))||any(strcmpi(dataType.dataTypeFC,validQuantDataTypes)))

        if(isempty(exponentsData))
            msg=message('dnnfpga:quantization:NoExponentData');
            error(msg);
        end

        if(~isempty(exponentsData))
            if(~isfield(exponentsData,'Name')||~isfield(exponentsData,'Exponent'))
                msg=message('dnnfpga:quantization:InvalidExponentData');
                error(msg);
            end
        end
    end

    if(isa(cnnp,'dnnfpga.processorbase.cnn5Processor'))

        valid=false;
        for i=1:numel(validKernelDataTypes)
            if(all(strcmpi(validKernelDataTypes{i},{dataType.dataTypeConv,dataType.dataTypeFC,dataType.dataTypeAdd})))
                valid=true;
                break;
            end
        end
        if(~valid)
            msg=message('dnnfpga:quantization:UnsupportedDataTypeCombinationDAGNet');
            error(msg);
        end


        if(~any(strcmpi(dataType.dataTypeAdd,validKernelDataTypes)))
            msg=message('dnnfpga:simulation:InvalidDataTypeForAddLayer');
            error(msg);
        end

    end

    if(numel(net.InputNames)>1)
        error(message('dnnfpga:simulation:MultipleInputNetworksNotSupported'));
    end

