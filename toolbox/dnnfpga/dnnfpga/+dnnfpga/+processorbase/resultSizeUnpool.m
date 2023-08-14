function sz=resultSizeUnpool(padding,stride,stridePhase,dilation,imgSize,origOpSizeValue,origImgSize,unpoolRemainder)
    if(all(size(dilation)==1))

        dilation=[dilation;dilation];
    elseif(size(dilation,1)==1)
        dilation=dilation';
    end

    stride=[stride;stride];
    if(numel(padding)==1)
        padding=ones(1,4)*padding;
    end


    if any(origImgSize>imgSize)
        unpoolRemainder=zeros(size(unpoolRemainder));
        padding=zeros(size(padding));
    end









    origOpSizeValue=origOpSizeValue(1:2);

    dilatedOpSize=(origOpSizeValue-1).*dilation+[1;1];
    paddedImgSize=imgSize+[padding(2)+padding(1);padding(4)+padding(3)];


    assert(all(stridePhase==0));
    assert(all(dilation==1));
    assert(all(padding==0));
    assert(all(stride==1));






    sz=paddedImgSize.*dilatedOpSize+unpoolRemainder;
end

