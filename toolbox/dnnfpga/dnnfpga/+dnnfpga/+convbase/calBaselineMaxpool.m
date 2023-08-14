function[out,outSize]=calBaselineMaxpool(paddedImg,inImgSize,opSize,strideSize,stridePhase,maxpoolType)




    sSize=strideSize(1:2);

    inputFeatureNum=inImgSize(1);



    resultImgSize=[inputFeatureNum;floor(((inImgSize(2:3)'-opSize(1:2)+1-stridePhase)-1)./sSize)+1];
    outSize=resultImgSize';
    if(isinteger(paddedImg))
        out=int32(zeros(outSize));
    elseif(isfi(paddedImg))
        out=zeros(outSize,'like',paddedImg);
    else
        out=zeros(outSize,class(outSize));
    end


    indices=int32(1:prod(inImgSize(2:3)));
    indices=reshape(indices,[1,inImgSize(3:-1:2)]);
    indices=permute(indices,[1,3,2]);
    if~(isinteger(paddedImg)||isfi(paddedImg))

        indices=reshape(typecast(indices(:),'single'),size(indices));
    end
    for i=1:inputFeatureNum
        for x=stridePhase(1)+1:sSize(1):inImgSize(2)-opSize(1)+1
            for y=stridePhase(2)+1:sSize(2):inImgSize(3)-opSize(2)+1
                xStart=x;
                yStart=y;
                xEnd=x+opSize(1)-1;
                yEnd=y+opSize(2)-1;


                in=paddedImg(i,xStart:xEnd,yStart:yEnd);
                if maxpoolType==0||maxpoolType==2
                    if(isfi(in))

                        out(i,(x-1)/sSize(1)+1,(y-1)/sSize(1)+1)=max(max(max(in)));
                    else
                        out(i,(x-1)/sSize(1)+1,(y-1)/sSize(1)+1)=max(in,[],'all');
                    end
                elseif maxpoolType==1
                    [~,idx]=max(in,[],'all','linear');
                    patch=indices(1,xStart:xEnd,yStart:yEnd);
                    out(i,(x-1)/sSize(1)+1,(y-1)/sSize(1)+1)=patch(idx);
                end
            end
        end
    end
end
