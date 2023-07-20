function ImgOut=padImage(img,padSize,padDirect)





    imgSize=size(img);
    if(length(imgSize)<length(padSize))

        imgSize=[imgSize,ones(1,(length(padSize)-length(imgSize)))];
    elseif(length(padSize)<length(imgSize))

        padSize=[padSize,zeros(1,length(imgSize)-length(padSize))];
    end

    if(~isrow(imgSize))
        imgSize=imgSize';
    end

    if(~isrow(padSize))
        padSize=padSize';
    end

    imgOutSize=imgSize+padSize;
    if(isa((img),'int32'))
        ImgOut=int32(zeros(imgOutSize));
    elseif(isa((img),'int8'))
        ImgOut=int8(zeros(imgOutSize));
    elseif(isa((img),'half'))
        ImgOut=half(zeros(imgOutSize));
    elseif(isfi(img))
        ImgOut=zeros(imgOutSize,'like',img);
    else
        ImgOut=single(zeros(imgOutSize));
    end



    switch padDirect
    case 'post'
        if(length(imgOutSize)==2)
            ImgOut(1:imgSize(1),1:imgSize(2))=img;
        else
            ImgOut(1:imgSize(1),1:imgSize(2),1:imgSize(3))=img;
        end
    case 'pre'
        if(length(imgOutSize)==2)
            ImgOut((imgOutSize(1)-imgSize(1)+1):end,(imgOutSize(2)-imgSize(2)+1):end)=img;
        else
            ImgOut((imgOutSize(1)-imgSize(1)+1):end,(imgOutSize(2)-imgSize(2)+1):end,(imgOutSize(3)-imgSize(3)+1):end)=img;
        end
    end
end
