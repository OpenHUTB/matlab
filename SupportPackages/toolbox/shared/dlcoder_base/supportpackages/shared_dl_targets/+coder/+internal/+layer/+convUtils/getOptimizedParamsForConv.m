function optimParamStruct = getOptimizedParamsForConv( parameterSelector, convSpecification, simdLength )
arguments
    parameterSelector
    convSpecification
    simdLength( 1, 1 )double{ mustBeInteger, mustBePositive } = 1
end

iIsIntelCPU = isa( parameterSelector, 'coder.internal.layer.parameterSelector.IntelParameterSelector' );

if ( simdLength > 1 ) && ~isempty( convSpecification )

    outputHeightSize = iGetConvOutputHeightSize( convSpecification );

    inputChannelBlockSize = iGetHeuristicBasedOptimalInputChannelBlockSize( convSpecification.Channel, simdLength );
    inputChannelMiniblockSize = iGetHeuristicBasedOptimalInputChannelMiniblockSize( convSpecification.Channel, simdLength );
    outputChannelBlockSize = iGetHeuristicBasedOptimalOutputChannelBlockSize( convSpecification.NumFilters, simdLength, iIsIntelCPU );
    outputHeightBlockSize = iGetHeuristicBasedOptimalOutputHeightBlockSize( outputChannelBlockSize, outputHeightSize, simdLength, iIsIntelCPU );

    optimParamStruct = coder.internal.layer.convUtils.CgirCpuParameters( 'SimdWidth', simdLength,  ...
        'InputChannelBlockSize', inputChannelBlockSize,  ...
        'InputChannelMiniblockSize', inputChannelMiniblockSize,  ...
        'OutputChannelBlockSize', outputChannelBlockSize,  ...
        'OutputHeightBlockSize', outputHeightBlockSize );
else
    optimParamStruct = coder.internal.layer.convUtils.CgirCpuParameters;
end

end


function inputChannelBlockSize = iGetHeuristicBasedOptimalInputChannelBlockSize( numInputChannel, simdLength )
if ( numInputChannel <= simdLength )
    inputChannelBlockSize = numInputChannel;
elseif simdLength == 16 || simdLength == 8
    inputChannelBlockSize = ceil( numInputChannel / 2 );
else
    inputChannelBlockSize = ceil( numInputChannel / 4 );
end
end


function inputChannelMiniblockSize = iGetHeuristicBasedOptimalInputChannelMiniblockSize( numInputChannel, simdLength )
inputChannelMiniblockSize = min( numInputChannel, simdLength );
end


function outputChannelBlockSize = iGetHeuristicBasedOptimalOutputChannelBlockSize( numOutputChannel, simdLength, iIsIntelCPU )
outChannelToSimdLengthRatio = ceil( numOutputChannel / simdLength );
if ( numOutputChannel < simdLength )
    outputChannelBlockSize = simdLength;
elseif ( simdLength == 16 ) && ( outChannelToSimdLengthRatio > 3 )
    outputChannelBlockSize = 48;
elseif ( simdLength == 16 ) && ( outChannelToSimdLengthRatio <= 3 )
    outputChannelBlockSize = numOutputChannel;
elseif ( simdLength == 8 ) && ( outChannelToSimdLengthRatio > 5 )
    outputChannelBlockSize = 32;
elseif ( simdLength == 8 ) && ( outChannelToSimdLengthRatio <= 5 )
    outputChannelBlockSize = numOutputChannel;
else
    assert( simdLength == 4, 'Expected SIMD Length to be 4, 8 or 16' )

    if iIsIntelCPU
        if ( outChannelToSimdLengthRatio > 4 )
            outputChannelBlockSize = 16;
        else
            outputChannelBlockSize = numOutputChannel;
        end
    else
        if ( outChannelToSimdLengthRatio > 3 )
            outputChannelBlockSize = 12;
        else
            outputChannelBlockSize = numOutputChannel;
        end
    end
end
end


function outputHeightBlockSize = iGetHeuristicBasedOptimalOutputHeightBlockSize( outputChannelBlockSize, outputHeightSize, simdLength, iIsIntelCPU )

if iIsIntelCPU
    numSimdRegisters = 32;
else

    numSimdRegisters = 16;
end

tempZ = ceil( outputChannelBlockSize / simdLength ) + 1;

outputHeightBlockSize = floor( ( numSimdRegisters - 1 ) / tempZ );

outputHeightBlockSize = min( outputHeightBlockSize, outputHeightSize );
end


function outputHeightSize = iGetConvOutputHeightSize( convSpecification )
inputSize = [ convSpecification.Height, convSpecification.Width, convSpecification.Channel ];
dummyInput = ones( inputSize );
outputHeightSize = coder.internal.layer.convUtils.computeOutputSize( dummyInput,  ...
    convSpecification.FilterSize,  ...
    convSpecification.NumFilters,  ...
    convSpecification.PaddingSize,  ...
    convSpecification.Stride,  ...
    convSpecification.Dilation );
end
