function Z=matMul(X,Y,activationFunction)




%#codegen

    coder.allowpcode('plain');
    coder.inline("always");

    if coder.const(nargin<3)
        activationFunction=@coder.internal.layer.utils.defaultActivation;
    end

    if coder.const(coder.internal.layer.matrixMultiplication.useBuiltIn())
        Z=coder.internal.layer.elementwiseOperationInPlace(activationFunction,X*Y);
    else

        coder.internal.assert(size(X,2)==size(Y,1),"MATLAB:innerdim");





        M=coder.internal.indexInt(size(X,1));
        K=coder.internal.indexInt(size(X,2));
        N=coder.internal.indexInt(size(Y,2));


        buildContext=eml_option('CodegenBuildContext');
        specification=coder.internal.layer.matrixMultiplication.createOperationSpecification(M,K,N);
        matrixMultiplicationParameters=coder.const(@feval,...
        'coder.internal.layer.parameterSelector.selectParameters','selectMatrixMultiplicationParameters',...
        specification,buildContext,'coder.internal.layer.matrixMultiplication.CgirBaseParameters');

        if coder.const(matrixMultiplicationParameters.UseEML)
            Z=coder.internal.layer.matrixMultiplication.callEML(X,Y,M,K,N,...
            matrixMultiplicationParameters,activationFunction);
        else
            Z=coder.internal.layer.matrixMultiplication.callCGIR(X,Y,M,K,N,...
            matrixMultiplicationParameters);
            Z=coder.internal.layer.elementwiseOperationInPlace(activationFunction,Z);
        end

    end
end
