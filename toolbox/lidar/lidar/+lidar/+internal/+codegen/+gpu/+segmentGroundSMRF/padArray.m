function paddedImg=padArray(inpImg,padSize,padVal)




















%#codegen

    coder.allowpcode('plain');


    totImgSize=[size(inpImg,1),size(inpImg,2)]+2*padSize;
    paddedImg=padVal*ones(totImgSize);


    coder.gpu.kernel;
    for cIter=padSize(2)+1:size(inpImg,2)+padSize(2)
        coder.gpu.kernel;
        for rIter=padSize(1)+1:size(inpImg,1)+padSize(1)
            paddedImg(rIter,cIter)=inpImg(rIter-padSize(1),cIter-padSize(2));
        end
    end
end
