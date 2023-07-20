function[out,outSize]=calBaselineAveragepool(paddedImg,inImgSize,opSize,strideSize,stridePhase,avgMultiplier)



    sSize=strideSize(1:2);
    inputFeatureNum=inImgSize(1);

    if(numel(inImgSize)==2)
        inImgSize=[inImgSize,1];
    end

    resultImgSize=[inputFeatureNum;floor(((inImgSize(2:3)'-opSize(1:2)+1-stridePhase)-1)./sSize)+1];
    outSize=resultImgSize';
    if(isinteger(paddedImg))
        out=int32(zeros(outSize));
    else
        out=zeros(outSize,class(outSize));
    end

    for i=1:inputFeatureNum
        for x=stridePhase(1)+1:sSize(1):inImgSize(2)-opSize(1)+1
            for y=stridePhase(2)+1:sSize(2):inImgSize(3)-opSize(2)+1
                xStart=x;
                yStart=y;
                xEnd=x+opSize(1)-1;
                yEnd=y+opSize(2)-1;

                out(i,(x-1)/sSize(1)+1,(y-1)/sSize(1)+1)=sum(sum(paddedImg(i,xStart:xEnd,yStart:yEnd)));
            end
        end
    end

    out=out*avgMultiplier;
end