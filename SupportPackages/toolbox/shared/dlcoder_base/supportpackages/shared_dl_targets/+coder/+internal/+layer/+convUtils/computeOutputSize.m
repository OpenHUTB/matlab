function[hOut,wOut,cOut,bOut,paddedInputHW,effectiveFilterSize]=computeOutputSize(X,filterSize,numFilters,...
    paddingSize,stride,dilation)









%#codegen

    coder.allowpcode('plain')
    coder.inline('always')


    filterSize=double(filterSize);
    numFilters=double(numFilters);
    paddingSize=double(paddingSize);
    stride=double(stride);
    dilation=double(dilation);

    coder.internal.prefer_const(filterSize,numFilters,paddingSize,stride,dilation)


    [H,W,~,bOut]=size(X,1:4);

    cOut=coder.const(numFilters);

    [hOut,wOut,paddedInputHW,effectiveFilterSize]=iComputeAdditionalOutputSizes(H,W,filterSize,paddingSize,stride,dilation);

    hOut=coder.const(hOut);
    wOut=coder.const(wOut);

end

function[hOut,wOut,paddedInputHW,effectiveFilterSize]=...
    iComputeAdditionalOutputSizes(H,W,filterSize,paddingSize,stride,dilation)

    coder.allowpcode('plain')
    coder.inline('always')

    inputSizeHW=[H,W];
    effectiveFilterSize=dilation.*(filterSize-1)+1;
    top=1;bottom=2;left=3;right=4;
    paddingHW=[paddingSize(top)+paddingSize(bottom),paddingSize(left)+paddingSize(right)];
    paddedInputHW=inputSizeHW+paddingHW;
    outputHW=floor((paddedInputHW-effectiveFilterSize)./stride)+1;


    hOut=outputHW(1);
    wOut=outputHW(2);
end
