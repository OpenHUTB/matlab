




function outImg=bwlookupGPUImpl(inpImg,lut)%#codegen


    coder.allowpcode('plain');
    coder.inline('always');
    coder.gpu.kernelfun;


    numLUTElements=numel(lut);

    if numLUTElements==16
        nhoodSize=[2,2];
    else
        nhoodSize=[3,3];
    end


    bin2decLUT=gpucoder.transpose(2.^(0:prod(nhoodSize)-1));



    coder.gpu.constantMemory(bin2decLUT);
    coder.gpu.constantMemory(lut);


    outImg=gpucoder.stencilKernel(@applyLUTForInputPatch,inpImg,nhoodSize,'same',bin2decLUT,lut);
end

function outVal=applyLUTForInputPatch(inpImgPatch,bin2decLUT,lut)


    inpImgPatch_bin=inpImgPatch~=0;



    val=sum(inpImgPatch_bin(:).*bin2decLUT);


    outVal=lut(val+1);

end