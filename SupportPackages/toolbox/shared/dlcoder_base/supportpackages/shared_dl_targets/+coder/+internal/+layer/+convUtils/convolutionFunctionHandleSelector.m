function convolutionFunctionHandle=convolutionFunctionHandleSelector(algorithm)











%#codegen


    coder.allowpcode('plain')











    switch algorithm
    case 'GemmColMajor'
        convolutionFunctionHandle=@coder.internal.layer.conv2dGemmColMajor;

    case 'GemmRowMajor'
        convolutionFunctionHandle=@coder.internal.layer.conv2dGemmRowMajor;

    case 'WinogradColMajor'
        convolutionFunctionHandle=@coder.internal.layer.conv2dWinogradColMajor;

    case 'WinogradRowMajor'
        convolutionFunctionHandle=@coder.internal.layer.conv2dWinogradRowMajor;

    case 'DirectColMajor'
        convolutionFunctionHandle=@coder.internal.layer.conv2dDirectColMajor;

    case 'DirectRowMajor'
        convolutionFunctionHandle=@coder.internal.layer.conv2dDirectRowMajor;

    case 'Optimized'
        convolutionFunctionHandle=@coder.internal.layer.conv2dDirectOptimizedColMajor;

    case 'OneByOneConvAsOptimizedMatMul'
        convolutionFunctionHandle=@coder.internal.layer.oneByoneConv2dAsMatrixMultiplication;
    end

end
