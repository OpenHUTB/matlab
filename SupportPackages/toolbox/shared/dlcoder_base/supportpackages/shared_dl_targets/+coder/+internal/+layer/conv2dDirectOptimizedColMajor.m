function Z=conv2dDirectOptimizedColMajor(layer,X,varargin)

























%#codegen

    coder.inline("never");
    coder.allowpcode('plain');

    narginchk(2,8);

    args=coder.internal.layer.utils.parseInferenceInputs(varargin{:},X);
    activationFunction=args.ActivationFunction;
    activationFunctionType=coder.const(args.ActivationFunctionType);
    activationParams=coder.const(args.ActivationParams);


    buildContext=eml_option('CodegenBuildContext');
    specification=coder.internal.layer.convUtils.createOperationSpecification(layer,size(X,1:4));
    convolutionParameters=coder.const(@feval,...
    'coder.internal.layer.parameterSelector.selectParameters','selectConvolutionParameters',...
    specification,buildContext,'coder.internal.layer.convUtils.CgirBaseParameters');

    Z=coder.internal.layer.optimized.conv(X,...
    Weights=layer.Weights,...
    Bias=layer.Bias,...
    Stride=layer.Stride,...
    Padding=layer.PaddingSize,...
    Dilation=layer.Dilation,...
    FilterSize=layer.FilterSize,...
    NumFilters=layer.NumFilters,...
    ConvolutionParameters=convolutionParameters,...
    AreLearnablesReformatted=true,...
    ActivationParams=activationParams,...
    ActivationFunctionType=activationFunctionType...
    );



    coder.extrinsic('coder.internal.layer.utils.isActivationSupportedForCgirFusion');
    if~coder.const(coder.internal.layer.utils.isActivationSupportedForCgirFusion(activationFunctionType))
        Z=coder.internal.layer.elementwiseOperationInPlace(activationFunction,Z);
    end

end
