function Z=matMulAdd(X,Y,W,activationFunction)





%#codegen

    coder.allowpcode('plain');
    coder.inline('always');





    M=coder.internal.indexInt(size(X,1));
    K=coder.internal.indexInt(size(X,2));
    N=coder.internal.indexInt(size(Y,2));


    if coder.const(nargin<4)
        activationFunction=@coder.internal.layer.utils.defaultActivation;
    end

    if coder.const(coder.internal.layer.matrixMultiplication.useBuiltIn())


        Z=coder.internal.layer.addBiasApplyActivation(X*Y,W,activationFunction);
    else
        coder.internal.assert(size(X,2)==size(Y,1),"MATLAB:innerdim");

        buildContext=eml_option('CodegenBuildContext');
        specification=coder.internal.layer.matrixMultiplication.createOperationSpecification(M,K,N);
        matrixMultiplicationParameters=coder.const(@feval,...
        'coder.internal.layer.parameterSelector.selectParameters','selectMatrixMultiplicationParameters',...
        specification,buildContext,'coder.internal.layer.matrixMultiplication.CgirBaseParameters');

        if coder.const(matrixMultiplicationParameters.UseEML)
            Z=coder.internal.layer.matrixMultiplication.callEML(X,Y,M,K,N,...
            matrixMultiplicationParameters,activationFunction,W);
        else
            Z=coder.internal.layer.matrixMultiplication.callCGIR(X,Y,M,K,N,...
            matrixMultiplicationParameters,W);

            Z=coder.internal.layer.elementwiseOperationInPlace(activationFunction,Z);
        end
    end

end
