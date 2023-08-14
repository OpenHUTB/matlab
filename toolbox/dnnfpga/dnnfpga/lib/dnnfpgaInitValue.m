function dataType=dnnfpgaInitValue(kernelDataType)

    if(strcmp(kernelDataType,'single'))
        dataType=-realmax('single');
    else
        dataType=intmin('int8');
    end

end