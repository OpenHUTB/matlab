function B=algimbilateralfilterGPUImpl(A,spatialWeights,padSize,NeighborhoodSize,rangeSigmaTerm)%#codegen

























    coder.allowpcode('plain');

    coder.gpu.internal.kernelfunImpl(false);


    B=gpucoder.stencilKernel(@applyKernel,A,size(spatialWeights),'valid',...
    spatialWeights,padSize,NeighborhoodSize,rangeSigmaTerm);
end


function outVal=applyKernel(ALocalNeighbor,spatialWeights,...
    padSize,NeighborhoodSize,rangeSigmaTerm)
    coder.inline('always');
    sum_weights=zeros(1,'like',ALocalNeighbor);
    sum_weightedPixels=zeros(1,'like',ALocalNeighbor);
    coder.gpu.internal.constantMemoryImpl(spatialWeights,false);

    arow=1+padSize(1);
    acol=1+padSize(2);
    ACenterPixel=ALocalNeighbor(arow,acol);
    for iy=1:NeighborhoodSize(1)
        for ix=1:NeighborhoodSize(2)
            intensityDiff=ALocalNeighbor(iy,ix)-ACenterPixel(1,1);
            intensityWeights=exp(-(intensityDiff.*intensityDiff)/rangeSigmaTerm);
            weights=spatialWeights(iy,ix).*intensityWeights;
            sum_weights=sum_weights+weights;
            sum_weightedPixels=sum_weightedPixels+weights.*ALocalNeighbor(iy,ix,1);
        end
    end
    outVal=sum_weightedPixels./(sum_weights+eps);
end