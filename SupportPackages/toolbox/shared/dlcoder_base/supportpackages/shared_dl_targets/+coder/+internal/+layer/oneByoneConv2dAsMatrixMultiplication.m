function Z=oneByoneConv2dAsMatrixMultiplication(layer,X,varargin)



























%#codegen

    coder.inline("never");
    coder.allowpcode('plain');

    narginchk(2,8);


    args=coder.internal.layer.utils.parseInferenceInputs(varargin{:},X);
    activationFunction=args.ActivationFunction;


    [outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize]=coder.internal.layer.convUtils.computeOutputSize(X,...
    layer.FilterSize,...
    layer.NumFilters,...
    layer.PaddingSize,...
    layer.Stride,...
    layer.Dilation);


































    reshapedX=reshape(permute(X,[1,2,4,3]),size(X,1)*size(X,2)*size(X,4),size(X,3));

    M=coder.internal.indexInt(size(reshapedX,1));
    Y=layer.Weights;
    W=layer.Bias;

    K=coder.internal.indexInt(size(reshapedX,2));
    N=coder.internal.indexInt(size(Y,2));

    buildContext=eml_option('CodegenBuildContext');


    specification=coder.internal.layer.matrixMultiplication.createOperationSpecification(M,K,N);
    matrixMultiplicationParameters=coder.const(@feval,...
    'coder.internal.layer.parameterSelector.selectParameters','selectMatrixMultiplicationParameters',...
    specification,buildContext,'coder.internal.layer.matrixMultiplication.CgirBaseParameters');






    Z=coder.internal.layer.matrixMultiplication.callCGIR(...
    reshapedX,Y,M,K,N,matrixMultiplicationParameters,W);

    Z=coder.internal.layer.elementwiseOperationInPlace(activationFunction,Z);



































    Z=permute(reshape(Z,outputHeightSize,outputWidthSize,outputBatchSize,outputChannelSize),[1,2,4,3]);

end
