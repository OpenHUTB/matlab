function dout=dnnfpgaPaddinglogiclibBitSlice(concat_64_bit,numOfBitsPerChannel,numofInputFeatures)
%#codegen
    coder.allowpcode('plain');
    dout=fi(zeros(numofInputFeatures,1),0,numOfBitsPerChannel,0);

    for idx=coder.unroll(1:numofInputFeatures)
        ldx=idx*numOfBitsPerChannel;
        rdx=1+(idx-1)*numOfBitsPerChannel;
        dout(idx,1)=bitsliceget(concat_64_bit,ldx,rdx);
    end
end