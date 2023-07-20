function specification=createOperationSpecification(layer,inputSize)












%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.prefer_const(inputSize);

    numFilters=coder.const(layer.NumFilters);
    filterSize=coder.const(layer.FilterSize);
    stride=coder.const(layer.Stride);
    dilation=coder.const(layer.Dilation);
    paddingSize=coder.const(layer.PaddingSize);


    if coder.const(~coder.internal.isConst([inputSize,numFilters,filterSize,...
        stride,dilation,paddingSize]))



        specification=coder.const(@feval,'coder.internal.layer.convUtils.OperationSpecification.empty');
    else
        specification=coder.const(@feval,'coder.internal.layer.convUtils.OperationSpecification',...
        "Height",inputSize(1),"Width",inputSize(2),"Channel",inputSize(3),...
        "BatchSize",inputSize(4),"NumFilters",numFilters,"FilterSize",filterSize,...
        "Stride",stride,"Dilation",dilation,"PaddingSize",paddingSize);
    end

end
