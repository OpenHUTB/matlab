function outImg=ordfilt2GPUImpl(inpImg,order,domain,offsetsInp,padopt,isEvenForMedfilt)%#codegen



















%#ok<*EMCA>

    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');


    numNonZeros=nnz(domain);
    coder.internal.errorIf((order<1||order>numNonZeros),'images:ordfilt2:orderNotValid');


    domain=cast(domain,'like',inpImg);


    center=floor((size(domain)+1)/2);
    padSizePost=size(domain)-center;
    padSizePre=center-1;


    if numel(domain)>=225
        coder.gpu.internal.diagnostic('gpucoder:diagnostic:Ordfilt2StackLimit');
        coder.gpu.internal.diagnostic('gpucoder:diagnostic:Ordfilt2DomainSize');
    elseif numel(domain)>121
        coder.gpu.internal.diagnostic('gpucoder:diagnostic:Ordfilt2DomainSize');
    end




    if(strcmp(padopt,'zeros'))
        inpImgPadded=padarray(inpImg,padSizePre,0,'pre');
        inpImgPadded=padarray(inpImgPadded,padSizePost,0,'post');
    elseif(strcmp(padopt,'ones'))
        inpImgPadded=padarray(inpImg,padSizePre,1,'pre');
        inpImgPadded=padarray(inpImgPadded,padSizePost,1,'post');
    else
        inpImgPadded=padarray(inpImg,padSizePre,'symmetric','pre');
        inpImgPadded=padarray(inpImgPadded,padSizePost,'symmetric','post');
    end


    if isempty(offsetsInp)
        offsets=zeros(size(domain),'like',inpImg);
    else
        offsets=cast(offsetsInp,'like',inpImg);
    end


    trueOrder=order+numel(domain)-numNonZeros;


    if rem(numel(domain),2)==1&&trueOrder==ceil(numel(domain)/2)



        if isempty(offsetsInp)&&all(size(domain)>3)&&~islogical(inpImg)
            outImg=forgetfulSelect4Pixels(inpImg,inpImgPadded,size(domain),padopt);
        else

            outImg=gpucoder.stencilKernel(@ordfilt2ForgetfulSelect,inpImgPadded,size(domain),'valid',domain,order,numNonZeros,offsets);
        end

    else

        outImg=gpucoder.stencilKernel(@ordfilt2MinMax,inpImgPadded,size(domain),'valid',domain,order,numNonZeros,offsets,isEvenForMedfilt);
    end


    if isempty(offsetsInp)
        outImg=cast(outImg,'like',inpImg);
    else
        outImg=double(outImg);
    end
end


function outVal=ordfilt2MinMax(inpImg,domain,order,num_nonZeros,offsets,isEvenForMedfilt)


    if islogical(inpImg)
        inpImg=cast(inpImg.*domain,'like',inpImg);
        order=order+numel(domain)-num_nonZeros;
        sumVal=sum(inpImg(:));
        if order<=(numel(domain)-sumVal)
            outVal=cast(0,'like',inpImg);
        else
            outVal=cast(1,'like',inpImg);
        end

        if isEvenForMedfilt


            if sumVal>=numel(domain)/2
                outVal=cast(1,'like',inpImg);
            else
                outVal=cast(0,'like',inpImg);
            end
        end






    else

        isNaN_flag=false;
        for i=1:numel(domain)
            if domain(i)
                inpImg(i)=inpImg(i)+offsets(i);
                if isnan(inpImg(i))
                    isNaN_flag=true;
                end
            else
                inpImg(i)=0;
            end
        end


        if isNaN_flag
            outVal=NaN;
            return;
        end


        order=order+numel(domain)-num_nonZeros;




        if order>ceil(numel(domain)/2)
            numIters=numel(domain)-order+1;
        else
            numIters=order;
        end

        startIdx=1;
        endIdx=numel(domain);
        for iter=1:numIters
            minIdx=findMinIdx(inpImg,startIdx,endIdx);
            inpImg=swapEle(inpImg,minIdx,iter);

            maxIdx=findMaxIdx(inpImg,startIdx,endIdx);
            inpImg=swapEle(inpImg,maxIdx,numel(domain)-iter+1);

            startIdx=startIdx+1;
            endIdx=endIdx-1;
        end

        if isEvenForMedfilt


            outVal=double(imlincomb(0.5,inpImg(order),0.5,inpImg(order+1)));
        else
            outVal=double(inpImg(order));
        end

    end

end


function outVal=ordfilt2ForgetfulSelect(inpImg,domain,order,num_nonZeros,offsets)


    if islogical(inpImg)
        inpImg=cast(inpImg.*domain,'like',inpImg);
        order=order+numel(domain)-num_nonZeros;
        sumVal=sum(inpImg(:));
        if order<=(numel(domain)-sumVal)
            outVal=cast(0,'like',inpImg);
        else
            outVal=cast(1,'like',inpImg);
        end







    else

        isNaN_flag=false;
        for i=1:numel(domain)
            if domain(i)
                inpImg(i)=inpImg(i)+offsets(i);
                if isnan(inpImg(i))
                    isNaN_flag=true;
                end
            else
                inpImg(i)=0;
            end
        end


        if isNaN_flag
            outVal=NaN;
            return;
        end

        num=numel(domain);
        endIdx=ceil(num/2)+1;
        iter=num-endIdx+1;
        outVal=performForgetfulSelection(inpImg,iter);
    end
end

function[finalOutimg]=forgetfulSelect4Pixels(img,nimg,sz,padopt)


    [rows,cols]=size(img);



    rowEven=mod(rows,2)==0;
    colEven=mod(cols,2)==0;


    if~rowEven&&~colEven
        if(strcmp(padopt,'zeros'))
            nimgPad=padarray(nimg,[1,1],0,'post');
        elseif(strcmp(padopt,'ones'))
            nimgPad=padarray(nimg,[1,1],1,'post');
        else
            nimgPad=padarray(nimg,[1,1],'symmetric','post');
        end
        outimg=coder.nullcopy(zeros(rows+1,cols+1));

    elseif~rowEven&&colEven
        if(strcmp(padopt,'zeros'))
            nimgPad=padarray(nimg,[1,0],0,'post');
        elseif(strcmp(padopt,'ones'))
            nimgPad=padarray(nimg,[1,0],1,'post');
        else
            nimgPad=padarray(nimg,[1,0],'symmetric','post');
        end
        outimg=coder.nullcopy(zeros(rows+1,cols));

    elseif~colEven&&rowEven
        if(strcmp(padopt,'zeros'))
            nimgPad=padarray(nimg,[0,1],0,'post');
        elseif(strcmp(padopt,'ones'))
            nimgPad=padarray(nimg,[0,1],1,'post');
        else
            nimgPad=padarray(nimg,[0,1],'symmetric','post');
        end
        outimg=coder.nullcopy(zeros(rows,cols+1));

    else
        nimgPad=nimg;
        outimg=coder.nullcopy(zeros(rows,cols));
    end


    win=coder.nullcopy(zeros(sz(1)+1,sz(2)+1,'like',img));


    rowIdx=sz(1)-1;
    colIdx=sz(2)-1;




    for y=colIdx/2+1:2:cols+colIdx/2

        for x=rowIdx/2+1:2:rows+rowIdx/2

            for j=y-colIdx/2:y+colIdx/2+1
                for i=x-rowIdx/2:x+rowIdx/2+1
                    win(i+(rowIdx/2)-x+1,j+(colIdx/2)-y+1)=nimgPad(i,j);
                end
            end

            [outimg(x-rowIdx/2,y-colIdx/2),outimg(x-rowIdx/2,(y-colIdx/2)+1),...
            outimg((x-rowIdx/2)+1,y-colIdx/2),...
            outimg((x-rowIdx/2)+1,(y-colIdx/2)+1)]=medianOperation(win,sz(1),sz(2));
        end
    end

    if~rowEven||~colEven
        finalOutimg=outimg(1:rows,1:cols);
    else
        finalOutimg=outimg;
    end
end



function[pixel1,pixel2,pixel3,pixel4]=medianOperation(window,filterRow,filterCol)



    isNaNFlag=false;
    for i=2:filterRow-1
        for j=2:filterCol-1
            if isnan(window(i,j))
                isNaNFlag=true;
            end
        end
    end

    if isNaNFlag
        pixel1=NaN;
        pixel2=NaN;
        pixel3=NaN;
        pixel4=NaN;
        return;
    end

    isNaNFlagPixel1=false;
    isNaNFlagPixel2=false;
    isNaNFlagPixel3=false;
    isNaNFlagPixel4=false;
    pixel1CornerValues=[window(1,2:end-1),window(1:end-1,1)'];
    pixel2CornerValues=[window(1,2:end-1),window(1:end-1,end)'];
    pixel3CornerValues=[window(end,2:end-1),window(2:end,1)'];
    pixel4CornerValues=[window(end,2:end-1),window(2:end,end)'];
    for i=1:numel(pixel1CornerValues)
        if isnan(pixel1CornerValues(i))
            isNaNFlagPixel1=true;
        end
        if isnan(pixel2CornerValues(i))
            isNaNFlagPixel2=true;
        end
        if isnan(pixel3CornerValues(i))
            isNaNFlagPixel3=true;
        end
        if isnan(pixel4CornerValues(i))
            isNaNFlagPixel4=true;
        end
    end



    firstEnd=((filterRow*filterCol)+3)/2;

    totalElementsNhood=numel(window(2:end-1,2:end-1));

    iter=totalElementsNhood-firstEnd+1;

    outValNhood=performForgetfulSelection(window(2:end-1,2:end-1),iter);



    pixel12CornerValues=[outValNhood,window(1,2:end-1)];


    pixel34CornerValues=[outValNhood,window(end,2:end-1)];


    outValpixel12=performForgetfulSelection(pixel12CornerValues(:),(filterCol-1));

    outValpixel34=performForgetfulSelection(pixel34CornerValues(:),(filterCol-1));




    pixel1EdgeValues=[outValpixel12',window(1:end-1,1)'];
    pixel2EdgeValues=[outValpixel12',window(1:end-1,end)'];
    pixel3EdgeValues=[outValpixel34',window(2:end,1)'];
    pixel4EdgeValues=[outValpixel34',window(2:end,end)'];



    if isNaNFlagPixel1
        pixel1=NaN;
    else
        pixel1=performForgetfulSelection(pixel1EdgeValues(:),filterRow);
    end


    if isNaNFlagPixel2
        pixel2=NaN;
    else
        pixel2=performForgetfulSelection(pixel2EdgeValues(:),filterRow);
    end


    if isNaNFlagPixel3
        pixel3=NaN;
    else
        pixel3=performForgetfulSelection(pixel3EdgeValues(:),filterRow);
    end


    if isNaNFlagPixel4
        pixel4=NaN;
    else
        pixel4=performForgetfulSelection(pixel4EdgeValues(:),filterRow);
    end

end
function outVal=performForgetfulSelection(inpImg,numIterations)
    startIdx=1;
    endIdx=numel(inpImg)-numIterations+1;

    for i=1:numIterations

        minIdx=findMinIdx(inpImg,startIdx,endIdx);
        inpImg=swapEle(inpImg,minIdx,startIdx);


        maxIdx=findMaxIdx(inpImg,startIdx+1,endIdx);
        inpImg=swapEle(inpImg,maxIdx,endIdx);

        startIdx=startIdx+1;
        if i~=numIterations
            inpImg=swapEle(inpImg,endIdx,endIdx+i);
        end
    end
    outVal=double(inpImg(numIterations+1:end-numIterations));
end



function minIdx=findMinIdx(inpImg,startIdx,endIdx)
    minIdx=startIdx;
    minVal=inpImg(startIdx);
    for iter=startIdx+1:endIdx
        if inpImg(iter)<minVal
            minVal=inpImg(iter);
            minIdx=iter;
        end
    end
end


function maxIdx=findMaxIdx(inpImg,startIdx,endIdx)
    maxIdx=startIdx;
    maxVal=inpImg(startIdx);
    for iter=startIdx+1:endIdx
        if inpImg(iter)>maxVal
            maxVal=inpImg(iter);
            maxIdx=iter;
        end
    end
end


function arr=swapEle(arr,a,b)
    t=arr(a);
    arr(a)=arr(b);
    arr(b)=t;
end
