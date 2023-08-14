function outDim=dnnfpgaTblibResolveDDRDimension(DDRBitWidthLimit)
%#codegen



    coder.allowpcode('plain');

    if DDRBitWidthLimit==32
        outDim=1;
    else
        outDim=2;
    end
end

